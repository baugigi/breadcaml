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

(** The Snake game *)

open IOtools

(** Game parameters *)
type game_params = {
  snake_len     : int; (** Initial snake length *)
  delay_max     : int; (** Max no. of idle cycles to slow the snake *)
  delay_step    : int; (** No. of cycles to reduce for each point gained *)
  food_at_wall  : int; (** Score beyond which food can be next to a wall *)
  bricks_score  : int; (** Score beyond which bricks can appear *)
  bricks_period : int; (** Points ( > 0 ) between two brick apparitions *) 
  }

let params = {
  snake_len     =  10;
  delay_max     = 250;
  delay_step    =   5;
  food_at_wall  =  30;
  bricks_score  =  10;
  bricks_period =   3;
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
    in the direction [dir] *)
let next_to x y = function
  | Up    -> (x, succ y)
  | Down  -> (x, pred y)
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
let action_of_key = function
  | '\145' -> Move Up
  | '\017' -> Move Down
  | '\157' -> Move Left
  | '\029' -> Move Right
  | 'p'    -> Pause
  | 'y'    -> Answer_yes
  | 'n'    -> Answer_no
  | '\000' -> No_action
  | _      -> Unknown

(*****)

(** type: drawable cells *)
type cell =
  | Space
  | Wall
  | Food
  | Snake_head
  | Snake_tail of direction * direction

(** [get_cell x y] returns the kind of the cell at position ([x],[y]) *) 
let get_cell x y = match get_char x y with
  | 0x20 -> Space
  | 0x5a -> Food
  | 0x51 -> Snake_head
  | 0x42 -> Snake_tail(Up, Down)
  | 0x4b -> Snake_tail(Up, Left)
  | 0x4a -> Snake_tail(Up, Right)
  | 0x49 -> Snake_tail(Down, Left)
  | 0x55 -> Snake_tail(Down, Right)
  | 0x43 -> Snake_tail(Left, Right)
  | _ -> Wall

(** [near_wall x y] is [true] if the cell at ([x],[y]) shares a border or a
    corner with a wall *)
let near_wall x y =
  let px = pred x and sx = succ x and py = pred y and sy = succ y in
  let rec f_aux = function
    | (x',y') :: cells -> get_cell x' y' = Wall || f_aux cells
    | [] -> false in
  f_aux [(px, sy);   (x, sy);   (sx, sy);
         (px,  y);              (sx,  y);
         (px, py);   (x, py);   (sx, py);]

(** [rnd min max] returns a random integer from [min] to [max] (0 <= [min] <=
    [max], not checked) *)
let rnd min max = min + Random.int (succ max - min)

(** [put_cell x y kind] set the [kind] of the cell at position ([x],[y]) *)
let put_cell x y kind =
  let k = match kind with
    | Space      -> 0x20
    | Wall       -> 0x66
    | Food       -> 0x5a
    | Snake_head -> 0x51
    | Snake_tail(Up, Down)    | Snake_tail(Down, Up)    -> 0x42
    | Snake_tail(Up, Left)    | Snake_tail(Left, Up)    -> 0x4b
    | Snake_tail(Up, Right)   | Snake_tail(Right, Up)   -> 0x4a
    | Snake_tail(Down, Left)  | Snake_tail(Left, Down)  -> 0x49
    | Snake_tail(Down, Right) | Snake_tail(Right, Down) -> 0x55 
    | Snake_tail(Left, Right) | Snake_tail(Right, Left) -> 0x43
    | _ -> failwith "put_cell" in
  put_char x y k

(** [delay n] does an idle loop [n] times to slow down the snake's run *)
let rec delay n = if n > 0 then delay (pred n)

(** [print_score st] gets the player's score from [st] and print it *)
let print_score st =
  let score = string_of_int st.score in
  let score = String.(sub score 1 (pred (length score))) in
  print_at 2 24 ("score:" ^ score)

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
  match get_cell x y with
  | Space when ok_walls || not (near_wall x y) -> put_cell x y Food
  | _ -> feed_snake st

(** [put_brick st] chooses a random place and puts a wall brick in it when
    [st.score] is greater than [params.bricks_score] and a multiple of
    [params.bricks_period]; the brick is not put if there are other ones in
    the neighbourhood or the place is too near the snake's head *)
let put_brick =
  let cnt = ref params.bricks_period in fun st ->
    if st.score > params.bricks_score then
      if !cnt > 0 then decr cnt
      else (let x = rnd 2 37 and y = rnd 2 22 in
            if get_cell x y = Space
               && dist x y st.head.x st.head.y > 5
               && not (near_wall x y) then
              (put_cell x y Wall;
               cnt := params.bricks_period))
           
(** [get_new_dir current_dir] returns the new snake direction entered by the
    player, if any, or [current_dir]; if the player requests a [Pause], it waits
    for a new player action *)
let rec get_new_dir ?(pause=false) cur_dir = match action_of_key(get_key()) with
  | Move new_dir when new_dir <> opposite_dir cur_dir -> new_dir
  | Pause when not pause -> get_new_dir ~pause:true cur_dir
  | No_action when pause -> get_new_dir ~pause cur_dir
  | _ -> cur_dir

(*****)

(** [init ()] performs the game initialization and returns the first game
    status *)
let init () =
  let x = (40 - params.snake_len) / 2 and y = 12 in
  let st = {
      head = { x; y; dir = Left };
      tail = { x = x + params.snake_len; y; dir = Right };
      score = 0
    } in
  print_string "{CLR}{UCASE}{SWOFF}";
  for x = 0 to 39 do
    let y = 24 * x / 39 in
    put_cell x 0 Wall;         (* top wall *)
    put_cell (39 - x) 24 Wall; (* bottom wall *)
    put_cell 0 y Wall;         (* left wall *)
    put_cell 39 (24 - y) Wall  (* right wall *)
  done;
  print_score st;
  put_cell x y Snake_head;
  for i = 1 to params.snake_len do
    put_cell (x + i) y (Snake_tail (Left, Right))
  done;
  Random.self_init ();
  feed_snake st;
  st

(** [game_loop st] performs the game loop, starting from [st] status *)
let rec game_loop st =
  delay (params.delay_max - st.score * params.delay_step);
  let dir = get_new_dir st.head.dir in
  let (x, y) = next_to st.head.x st.head.y dir in
  match get_cell x y with
  | Space -> game_loop { st with head = move_head dir st; tail = move_tail st }
  | Food ->
    let st = { st with head = move_head dir st; score = succ st.score } in
    print_score st;
    put_brick st;
    feed_snake st;
    game_loop st
  | _ ->
    let rec get_answer () = match action_of_key (get_key ()) with
      | Answer_yes -> true
      | Answer_no -> false
      | _ -> get_answer () in
    print_center 12 " *** you lost! *** ";
    print_center 11 " play again (y/n)? ";
    if get_answer () then game_loop (init ()) else st.score

;;

let score = game_loop (init ()) in
    print_string "{CLR}{LCASE}{SWON}Your score:";
    print_int score
