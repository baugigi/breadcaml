(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
   2, come specificato nel file  LICENZA-it nella cartella principale del
   progetto.
   —————————————————————————————————————————————————————————————————————— *)

(** The Snake game, written with the C64 library (link with [c64lib.cma]).

    Controls: cursor keys or joystick in port 2 to steer, [p] to pause (any
    key resumes), [y]/[n] or the fire button to answer at the end of a game.
    The snake's speed is measured in video frames (see {!C64.Sound.wait_frame}).
    Coordinates are screen ones: [x] is the column (0..39), [y] the row
    (0..24, from the top). *)

open C64

(** Game parameters *)
type game_params = {
  snake_len     : int; (** Initial snake length *)
  delay_max     : int; (** No. of video frames between two steps at start *)
  delay_min     : int; (** Min no. of video frames between two steps *)
  speedup_score : int; (** Points needed to gain one frame of speed *)
  food_at_wall  : int; (** Score beyond which food can be next to a wall *)
  bricks_score  : int; (** Score beyond which bricks can appear *)
  bricks_period : int; (** Points ( > 0 ) between two brick apparitions *)
  }

let params = {
  snake_len     = 10;
  delay_max     = 12;
  delay_min     =  2;
  speedup_score =  3;
  food_at_wall  = 30;
  bricks_score  = 10;
  bricks_period =  3;
  }

(** Game status *)
type status = {
  head : snake_end; (** Snake's head data *)
  tail : snake_end; (** Snake's tail data *)
  score : int;      (** Gamer's current score *)
  }

(** Snake's extremities *)
and snake_end = {
  x : int;         (** x position *)
  y : int;         (** y position *)
  dir : direction; (** Direction the end is facing *)
  }

(** Directions *)
and direction = Up | Down | Left | Right

(** [opposite_dir dir] returns the opposite direction of [dir] *)
let opposite_dir = function
  | Up    -> Down
  | Down  -> Up
  | Left  -> Right
  | Right -> Left

(** [dist x y x' y'] returns the "Manhattan distance" between two cells *)
let dist x y x' y' = abs (x - x') + abs (y - y')

(** [next_to x y dir] returns the coordinates of the location next to ([x],[y])
    in the direction [dir] ([y] grows downwards) *)
let next_to x y = function
  | Up    -> (x, pred y)
  | Down  -> (x, succ y)
  | Left  -> (pred x, y)
  | Right -> (succ x, y)

(*****)

(** type: player actions *)
type player_action =
  | No_action
  | Move of direction
  | Pause
  | Answer_yes
  | Answer_no
  | Unknown

(** [action_of_key keypress] returns the action corresponding to a [keypress] *)
let action_of_key k =
  if      k = Char.Control.up  then Move Up
  else if k = Char.Control.dn  then Move Down
  else if k = Char.Control.lf  then Move Left
  else if k = Char.Control.rt  then Move Right
  else if k = 'p'              then Pause
  else if k = 'y'              then Answer_yes
  else if k = 'n'              then Answer_no
  else if k = Char.Control.nul then No_action
  else Unknown

(** [action_of_joy ()] returns the action requested with the joystick in
    port 2 (the fire button is [Answer_yes]) *)
let action_of_joy () =
  let j = Key.joy 2 in
  if      j land Key.joy_up    <> 0 then Move Up
  else if j land Key.joy_down  <> 0 then Move Down
  else if j land Key.joy_left  <> 0 then Move Left
  else if j land Key.joy_right <> 0 then Move Right
  else if j land Key.joy_fire  <> 0 then Answer_yes
  else No_action

(** [get_action ()] returns the pending action from the keyboard or, if there
    is none, from the joystick *)
let get_action () = match action_of_key (Key.get ()) with
  | No_action -> action_of_joy ()
  | action -> action

(*****)

(** Screen codes of the cells (see the character set ROM) *)
module Code = struct
  let space      = 0x20
  let wall       = 0x66
  let food       = 0x5a
  let head       = 0x51
  let vertical   = 0x42 (** body going up-down *)
  let horizontal = 0x43 (** body going left-right *)
  let up_left    = 0x4b
  let up_right   = 0x4a
  let down_left  = 0x49
  let down_right = 0x55
end

(** type: drawable cells *)
type cell =
  | Space
  | Wall
  | Food
  | Snake_head
  | Snake_tail of direction * direction

(** [get_cell x y] returns the kind of the cell at position ([x],[y]) *)
let get_cell x y =
  let c = Screen.get x y in
  if      c = Code.space      then Space
  else if c = Code.food       then Food
  else if c = Code.head       then Snake_head
  else if c = Code.vertical   then Snake_tail (Up, Down)
  else if c = Code.up_left    then Snake_tail (Up, Left)
  else if c = Code.up_right   then Snake_tail (Up, Right)
  else if c = Code.down_left  then Snake_tail (Down, Left)
  else if c = Code.down_right then Snake_tail (Down, Right)
  else if c = Code.horizontal then Snake_tail (Left, Right)
  else Wall

let is_space x y = match get_cell x y with Space -> true | _ -> false
let is_wall  x y = match get_cell x y with Wall  -> true | _ -> false

(** [near_wall x y] is [true] if the cell at ([x],[y]) shares a border or a
    corner with a wall *)
let near_wall x y =
  let px = pred x and sx = succ x and py = pred y and sy = succ y in
  let rec f_aux = function
    | (x',y') :: cells -> is_wall x' y' || f_aux cells
    | [] -> false in
  f_aux [(px, sy);   (x, sy);   (sx, sy);
         (px,  y);              (sx,  y);
         (px, py);   (x, py);   (sx, py);]

(** [rnd min max] returns a random integer from [min] to [max] (0 <= [min] <=
    [max], not checked) *)
let rnd min max = min + Random.int (succ max - min)

(** Colors (color RAM) of the cells *)
let color_of = function
  | Space        -> 0
  | Wall         -> 11 (* dark grey *)
  | Food         -> 2  (* red *)
  | Snake_head   -> 7  (* yellow *)
  | Snake_tail _ -> 5  (* green *)

(** [put_cell x y kind] set the [kind] of the cell at position ([x],[y]) *)
let put_cell x y kind =
  let k = match kind with
    | Space      -> Code.space
    | Wall       -> Code.wall
    | Food       -> Code.food
    | Snake_head -> Code.head
    | Snake_tail(Up, Down)    | Snake_tail(Down, Up)    -> Code.vertical
    | Snake_tail(Up, Left)    | Snake_tail(Left, Up)    -> Code.up_left
    | Snake_tail(Up, Right)   | Snake_tail(Right, Up)   -> Code.up_right
    | Snake_tail(Down, Left)  | Snake_tail(Left, Down)  -> Code.down_left
    | Snake_tail(Down, Right) | Snake_tail(Right, Down) -> Code.down_right
    | Snake_tail(Left, Right) | Snake_tail(Right, Left) -> Code.horizontal
    | _ -> failwith "put_cell" in
  Screen.put x y k;
  Screen.put_color x y (color_of kind)

(** [print_center y str] prints [str] (white) in the middle of the row [y] *)
let print_center y str =
  Screen.print_at ~color:1 ((Screen.cols - String.length str) / 2) y str

(** [print_score st] gets the player's score from [st] and print it in the
    top wall; [string_of_int] puts a space before positive numbers: drop it *)
let print_score st =
  let score = string_of_int st.score in
  let score =
    if String.length score > 0 && score.[0] = ' '
    then String.sub score 1 (pred (String.length score)) else score in
  Screen.print_at ~color:1 2 0 ("score:" ^ score)

(*****)

(** Sound effects: voice 1 (pulse) for the food, voice 2 (noise) for the
    crash. The gates are released at every step, see [game_loop]. *)
let init_sound () =
  Sound.init ~detect_clock:false ();
  Sound.waveform 1 Sound.pulse;
  Sound.pulse_width 1 2048;
  Sound.adsr 1 ~a:0 ~d:6 ~s:0 ~r:6;
  Sound.waveform 2 Sound.noise;
  Sound.adsr 2 ~a:0 ~d:9 ~s:0 ~r:9

let beep () = Sound.play 1 69   (* A5 *)
let thud () = Sound.play 2 24
let release_sound () = Sound.stop 1; Sound.stop 2

(*****)

(** [move_head new_dir st] moves the snake's head one step in the [new_dir]
    direction, adds a piece of body next to the head and returns the new values
    for [st.head] *)
let move_head new_dir st =
  let x = st.head.x and y = st.head.y in
  put_cell x y (Snake_tail(new_dir, opposite_dir st.head.dir));
  let (x, y) = next_to x y new_dir in
  put_cell x y Snake_head;
  { x; y; dir = new_dir }

(** [move_tail st] deletes the snake's tail end and returns the new value for
    the [st.tail] field *)
let move_tail st =
  let x = st.tail.x and y = st.tail.y in
  match get_cell x y with
  | Snake_tail(a, b) ->
    let towards_body = if st.tail.dir = a then b else a in
    put_cell x y Space;
    let (x, y) = next_to x y towards_body in
    { x; y; dir = opposite_dir towards_body }
  | _ -> failwith "move_tail"

(** [feed_snake st] put a piece of food in a random empty place; if
    [st.score] is greater than [params.food_at_wall], the food may be placed
    next to a wall. Teorically this function may not terminate; practically,
    you should have filled all the available holes with your long snake ;) *)
let rec feed_snake st =
  let ok_walls = st.score > params.food_at_wall in
  let x = if ok_walls then rnd 1 38 else rnd 2 37
  and y = if ok_walls then rnd 1 23 else rnd 2 22 in
  if is_space x y && (ok_walls || not (near_wall x y))
  then put_cell x y Food
  else feed_snake st

(** [put_brick st] chooses a random place and puts a wall brick in it when
    [st.score] is greater than [params.bricks_score] and a multiple of
    [params.bricks_period]; the brick is not put if there are other ones in
    the neighbourhood or the place is too near the snake's head *)
let put_brick =
  let cnt = ref params.bricks_period in fun st ->
    if st.score > params.bricks_score then
      if !cnt > 0 then decr cnt
      else (let x = rnd 2 37 and y = rnd 2 22 in
            if is_space x y
               && dist x y st.head.x st.head.y > 5
               && not (near_wall x y) then
              (put_cell x y Wall;
               cnt := params.bricks_period))

(** [pause ()] freezes the game (the border turns red) until the player does
    something *)
let pause () =
  Screen.border 2;
  let rec wait () =
    Sound.wait_frame ();
    match get_action () with
    | No_action -> wait ()
    | _ -> () in
  wait ();
  Screen.border 0

(** [get_new_dir cur_dir frames] waits [frames] video frames, polling the
    keyboard and the joystick at each frame, and returns the last direction
    requested in the meantime (a U-turn is not accepted: it would be
    suicide) or [cur_dir] *)
let get_new_dir cur_dir frames =
  let dir = ref cur_dir in
  for _i = 1 to frames do
    Sound.wait_frame ();
    match get_action () with
    | Move d when d <> opposite_dir cur_dir -> dir := d
    | Pause -> pause ()
    | _ -> ()
  done;
  !dir

(** [frames st] is the number of video frames between two steps *)
let frames st =
  Int.max params.delay_min (params.delay_max - st.score / params.speedup_score)

(*****)

(** [init ()] performs the game initialization and returns the first game
    status *)
let init () =
  let x = (Screen.cols - params.snake_len) / 2 and y = Screen.rows / 2 in
  let st = {
      head = { x; y; dir = Left };
      tail = { x = x + params.snake_len; y; dir = Right };
      score = 0
    } in
  Screen.border 0;
  Screen.background 0;
  Screen.lower_case false;              (* upper case/graphics set *)
  print_char Char.Control.swoff;        (* no SHIFT+C= charset switching *)
  Screen.clear ();
  let w = Screen.cols - 1 and h = Screen.rows - 1 in
  for x = 0 to w do
    let y = h * x / w in
    put_cell x 0 Wall;         (* top wall *)
    put_cell (w - x) h Wall;   (* bottom wall *)
    put_cell 0 y Wall;         (* left wall *)
    put_cell w (h - y) Wall    (* right wall *)
  done;
  print_score st;
  put_cell x y Snake_head;
  for i = 1 to params.snake_len do
    put_cell (x + i) y (Snake_tail (Left, Right))
  done;
  feed_snake st;
  st

(** [get_answer ()] waits for the player's answer to the "play again" question
    ([y] or fire = true, [n] = false) *)
let get_answer () =
  while Key.get () <> Char.Control.nul do () done;   (* flush the keyboard *)
  let rec wait () =
    Sound.wait_frame ();
    match get_action () with
    | Answer_yes -> true
    | Answer_no -> false
    | _ -> wait () in
  wait ()

(** [game_loop st] performs the game loop, starting from [st] status *)
let rec game_loop st =
  let dir = get_new_dir st.head.dir (frames st) in
  release_sound ();
  let (x, y) = next_to st.head.x st.head.y dir in
  match get_cell x y with
  | Space -> game_loop { st with head = move_head dir st; tail = move_tail st }
  | Food ->
    beep ();
    let st = { st with head = move_head dir st; score = succ st.score } in
    print_score st;
    put_brick st;
    feed_snake st;
    game_loop st
  | _ ->
    thud ();
    print_center 12 " *** you lost! *** ";
    print_center 13 " play again (y/n)? ";
    if get_answer () then (release_sound (); game_loop (init ())) else st.score

let () =
  Random.self_init ();
  init_sound ();
  let score = game_loop (init ()) in
  Sound.silence ();
  Screen.lower_case true;
  print_char Char.Control.swon;
  Screen.clear ();
  print_string "Your score:";
  print_int score;
  print_newline ()
