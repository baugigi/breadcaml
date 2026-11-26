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
module Hw = struct
  module Mem = struct
    external peek_view : int -> int = "caml_nonstd_hw_peek"
    external peek_ram : int -> int = "caml_nonstd_hw_peek_ram"
    external peek_at_view : int -> int -> int = "caml_nonstd_hw_peek_at"
    external peek_at_ram : int -> int -> int = "caml_nonstd_hw_peek_at_ram"
    external poke : int -> int -> unit = "caml_nonstd_hw_poke"
    external unsafe_poke : int -> int -> unit = "caml_nonstd_hw_unsafe_poke"
    external poke_at : int -> int -> int -> unit = "caml_nonstd_hw_poke_at"
    external unsafe_poke_at : int -> int -> int -> unit
      = "caml_nonstd_hw_unsafe_poke_at"

    external fill_at : int -> int -> int -> int -> unit
      = "caml_nonstd_hw_fill_at"
    external unsafe_fill_at : int -> int -> int -> int -> unit
      = "caml_nonstd_hw_unsafe_fill_at"
    external blit_at : int -> int -> int -> int -> int -> unit
      = "caml_nonstd_hw_blit_at"
    external unsafe_blit_at : int -> int -> int -> int -> int -> unit
      = "caml_nonstd_hw_unsafe_blit_at"

    let fill a len v = fill_at ((a asr 8) land 255) (a land 255) len v
    let unsafe_fill a len v =
      unsafe_fill_at ((a asr 8) land 255) (a land 255) len v
    let blit src dst len =
      blit_at ((src asr 8) land 255) (src land 255)
              ((dst asr 8) land 255) (dst land 255) len
    let unsafe_blit src dst len =
      unsafe_blit_at ((src asr 8) land 255) (src land 255)
                     ((dst asr 8) land 255) (dst land 255) len

    let peek ?(ram = false) a = if ram then peek_ram a else peek_view a
    let peek_at ?(ram = false) p o =
      if ram then peek_at_ram p o else peek_at_view p o
  end

  module Nmi = struct
    external block : unit -> unit = "caml_nonstd_hw_nmi_block"
    external unblock : unit -> unit = "caml_nonstd_hw_nmi_unblock"
  end

  module Vic = struct
    external peek : int -> int = "caml_nonstd_hw_vic_peek"
    external poke : int -> int -> unit = "caml_nonstd_hw_vic_poke"
    let mx8 = 0x10 and cr1 = 0x11 and raster = 0x12 and lpx = 0x13
    and lpy = 0x14 and me = 0x15 and cr2 = 0x16 and mye = 0x17
    and vmcb = 0x18 and irqst = 0x19 and irqen = 0x1A and mdp = 0x1B
    and mmc = 0x1C and mxe = 0x1D and mm = 0x1E and md = 0x1F
    and ec = 0x20 and b0c = 0x21 and b1c = 0x22 and b2c = 0x23
    and b3c = 0x24 and mm0 = 0x25 and mm1 = 0x26
    let mx n = 2 * n
    let my n = 2 * n + 1
    let mc n = 0x27 + n
  end

  module Sid = struct
    external peek : int -> int = "caml_nonstd_hw_sid_peek"
    external poke : int -> int -> unit = "caml_nonstd_hw_sid_poke"
    let fl = 0 and fh = 1 and pwl = 2 and pwh = 3 and cr = 4 and ad = 5
    and sr = 6
    let voice n = 7 * (n - 1)
    let fcl = 0x15 and fch = 0x16 and resflt = 0x17 and modvol = 0x18
    and potx = 0x19 and poty = 0x1A and osc3 = 0x1B and env3 = 0x1C
  end

  module Cia = struct
    let pra = 0 and prb = 1 and ddra = 2 and ddrb = 3 and talo = 4
    and tahi = 5 and tblo = 6 and tbhi = 7 and tod10 = 8 and todsec = 9
    and todmin = 10 and todhr = 11 and sdr = 12 and icr = 13 and cra = 14
    and crb = 15
  end

  module Cia1 = struct
    external peek : int -> int = "caml_nonstd_hw_cia1_peek"
    external poke : int -> int -> unit = "caml_nonstd_hw_cia1_poke"
  end

  module Cia2 = struct
    external peek : int -> int = "caml_nonstd_hw_cia2_peek"
    external poke : int -> int -> unit = "caml_nonstd_hw_cia2_poke"
  end

  module Userport = struct
    external read : unit -> int = "caml_nonstd_up_read"
    external write : int -> unit = "caml_nonstd_up_write"
    external ddr : unit -> int = "caml_nonstd_up_ddr"
    external set_ddr : int -> unit = "caml_nonstd_up_set_ddr"
    external set_bits : int -> unit = "caml_nonstd_up_set"
    external clear_bits : int -> unit = "caml_nonstd_up_clear"
    external toggle_bits : int -> unit = "caml_nonstd_up_toggle"
    external dir_out : int -> unit = "caml_nonstd_up_dir_out"
    external dir_in : int -> unit = "caml_nonstd_up_dir_in"
    external pa2_read : unit -> bool = "caml_nonstd_up_pa2_read"
    external pa2_write : bool -> unit = "caml_nonstd_up_pa2_write"
    external pa2_output : bool -> unit = "caml_nonstd_up_pa2_dir"
    external flag2 : unit -> bool = "caml_nonstd_up_flag2"
  end

  module Kernal = struct
    external open_file : int -> int -> int -> string -> int
      = "caml_nonstd_kn_open"
    external close : int -> unit = "caml_nonstd_kn_close"
    external chkin : int -> int = "caml_nonstd_kn_chkin"
    external chkout : int -> int = "caml_nonstd_kn_chkout"
    external clrchn : unit -> unit = "caml_nonstd_kn_clrchn"
    external clall : unit -> unit = "caml_nonstd_kn_clall"
    external chrin : unit -> int = "caml_nonstd_kn_chrin"
    external chrout : int -> unit = "caml_nonstd_kn_chrout"
    external readst : unit -> int = "caml_nonstd_kn_readst"
    external load_at : int -> int -> string -> int -> int -> int
      = "caml_nonstd_kn_load"
    external set_range : int -> int -> int -> int -> unit
      = "caml_nonstd_kn_range"
    external save_raw : int -> string -> int = "caml_nonstd_kn_save"

    let err_too_many_files = 1 and err_file_open = 2 and err_file_not_open = 3
    and err_file_not_found = 4 and err_device_not_present = 5
    and err_not_input_file = 6 and err_not_output_file = 7
    and err_missing_file_name = 8 and err_illegal_device = 9

    let st_timeout_write = 0x01 and st_timeout_read = 0x02 and st_eof = 0x40
    and st_device_not_present = 0x80

    let load_end_page () = Mem.peek_view 0xAF
    let load_end_off () = Mem.peek_view 0xAE
    let save ~dev name spage soff epage eoff =
      set_range spage soff epage eoff;
      save_raw dev name
  end

  module Color = struct
    external peek : int -> int = "caml_nonstd_hw_color_peek"
    external poke : int -> int -> unit = "caml_nonstd_hw_color_poke"
  end
end

module Key = struct
  external get : unit -> char = "caml_nonstd_get_key"
  external wait : unit -> char = "caml_nonstd_wait_key"
  external joy : int -> int = "caml_nonstd_joystick"
  let joy_up = 1 and joy_down = 2 and joy_left = 4 and joy_right = 8
  and joy_fire = 16
end

module Screen = struct
  let cols = 40
  let rows = 25

  external unsafe_get : int -> int -> int = "caml_nonstd_scr_peek"
  external unsafe_put : int -> int -> int -> unit = "caml_nonstd_scr_poke"
  external unsafe_get_color : int -> int -> int = "caml_nonstd_scr_color_peek"
  external unsafe_put_color : int -> int -> int -> unit
    = "caml_nonstd_scr_color_poke"
  external unsafe_locate : int -> int -> unit = "caml_nonstd_scr_locate"
  external cursor_pos : unit -> int = "caml_nonstd_scr_cursor"

  let inside x y = x >= 0 && x < 40 && y >= 0 && y < 25

  let get x y =
    if inside x y then unsafe_get x y else invalid_arg "C64.Screen.get"
  let put x y v =
    if inside x y then unsafe_put x y v else invalid_arg "C64.Screen.put"
  let get_color x y =
    if inside x y then unsafe_get_color x y
    else invalid_arg "C64.Screen.get_color"
  let put_color x y v =
    if inside x y then unsafe_put_color x y v
    else invalid_arg "C64.Screen.put_color"
  let locate x y =
    if inside x y then unsafe_locate x y
    else invalid_arg "C64.Screen.locate"
  let cursor () = let p = cursor_pos () in (p land 255, p lsr 8)

  let clear () = print_char '\147'
  let home () = print_char '\019'
  let reverse b = print_char (if b then '\018' else '\146')
  let lower_case b = print_char (if b then '\014' else '\142')
  let text_color c = Hw.Mem.unsafe_poke 646 c
  let border c = Hw.Vic.poke Hw.Vic.ec c
  let background c = Hw.Vic.poke Hw.Vic.b0c c

  let code_of_char c =
    let n = Char.code c in
    if n < 0x20 then 0x20
    else if n < 0x40 then n
    else if n < 0x60 then n - 0x40
    else if n < 0x80 then n - 0x20
    else if n < 0xA0 then 0x20
    else if n < 0xC0 then n - 0x40
    else if n < 0xFF then n - 0x80
    else 0x5E

  let char_of_code code =
    let c = code land 0x7F in
    Char.chr (if c < 0x20 then c + 0x40
              else if c < 0x40 then c
              else if c < 0x60 then c + 0x20
              else c + 0x40)

  let put_char x y c = put x y (code_of_char c)
  let get_char x y = char_of_code (get x y)

  let print_at ?color x y s =
    if not (inside x y) then invalid_arg "C64.Screen.print_at"
    else
      for i = 0 to String.length s - 1 do
        let xx = x + i in
        if xx < 40 then begin
          unsafe_put xx y (code_of_char s.[i]);
          match color with
            Some c -> unsafe_put_color xx y c
          | None -> ()
        end
      done

  let page () = Hw.Mem.peek 648
  let fill code = Hw.Mem.unsafe_fill_at (page ()) 0 1000 code
  let fill_color c = Hw.Mem.unsafe_fill_at 0xD8 0 1000 c

  let scroll_up ?(color = false) () =
    let p = page () in
    Hw.Mem.unsafe_blit_at p 40 p 0 960;
    Hw.Mem.unsafe_fill_at (p + 3) 192 40 32;
    if color then Hw.Mem.unsafe_blit_at 0xD8 40 0xD8 0 960

  let scroll_down ?(color = false) () =
    let p = page () in
    Hw.Mem.unsafe_blit_at p 0 p 40 960;
    Hw.Mem.unsafe_fill_at p 0 40 32;
    if color then Hw.Mem.unsafe_blit_at 0xD8 0 0xD8 40 960
end


module Gfx = struct
  type mode = Hires | Multicolor
  type layout = { bank : int; screen : int; bitmap : int; sprites : int }

  let bank2 = { bank = 2; screen = 0; bitmap = 0x2000; sprites = 0x0400 }
  let bank1 = { bank = 1; screen = 0; bitmap = 0x2000; sprites = 0x0400 }

  external prim_init : int -> int -> int -> int -> unit = "caml_nonstd_gfx_init"
  external prim_exit : unit -> unit = "caml_nonstd_gfx_exit"
  external prim_pen : int -> unit = "caml_nonstd_gfx_pen"
  external plot : int -> int -> unit = "caml_nonstd_gfx_plot"
  external point : int -> int -> int = "caml_nonstd_gfx_point"
  external line : int -> int -> int -> int -> unit = "caml_nonstd_gfx_line"
  external window : int -> int -> int -> int -> unit = "caml_nonstd_gfx_window"
  external unwindow : unit -> unit = "caml_nonstd_gfx_unwindow"

  let cur = ref bank2
  let cur_mode = ref Hires
  let active = ref false

  let width () = if !cur_mode = Hires then 320 else 160
  let height = 200

  let page l = l.bank * 64 + (l.screen lsr 8)
  let bitmap_page () = !cur.bank * 64 + (!cur.bitmap lsr 8)

  let init ?(mode = Hires) l =
    prim_init l.bank l.screen l.bitmap (if mode = Hires then 0 else 1);
    cur := l; cur_mode := mode; active := true

  let exit () = if !active then (prim_exit (); active := false)

  let clear () =
    (* 8000 bytes = 31 pages + 64 *)
    let p = bitmap_page () in
    Hw.Mem.unsafe_fill_at p 0 8000 0

  let fill_screen v =
    Hw.Mem.unsafe_fill_at (page !cur) 0 1000 v

  (* In hires mode the screen matrix byte is (ink lsl 4) lor paper;
     in multicolor it holds colors 1 (high nibble) and 2 (low nibble). *)
  let colors ~ink ~paper = fill_screen (((ink land 15) lsl 4) lor (paper land 15))
  let fill_color v = Hw.Mem.unsafe_fill_at 0xD8 0 1000 v

  let pen p = prim_pen p
  let background c = Hw.Vic.poke Hw.Vic.b0c c

  let hline x1 x2 y = line x1 y x2 y
  let vline x y1 y2 = line x y1 x y2

  let rect x1 y1 x2 y2 =
    hline x1 x2 y1; hline x1 x2 y2; vline x1 y1 y2; vline x2 y1 y2

  let fill_rect x1 y1 x2 y2 =
    let ya = if y1 < y2 then y1 else y2 and yb = if y1 < y2 then y2 else y1 in
    for y = ya to yb do line x1 y x2 y done

  (* midpoint circle, 8-fold symmetry *)
  let circle cx cy r =
    if r < 0 then invalid_arg "C64.Gfx.circle";
    let x = ref r and y = ref 0 and d = ref (1 - r) in
    while !x >= !y do
      let a = !x and b = !y in
      plot (cx + a) (cy + b); plot (cx + b) (cy + a);
      plot (cx - b) (cy + a); plot (cx - a) (cy + b);
      plot (cx - a) (cy - b); plot (cx - b) (cy - a);
      plot (cx + b) (cy - a); plot (cx + a) (cy - b);
      incr y;
      if !d < 0 then d := !d + 2 * !y + 1
      else begin decr x; d := !d + 2 * (!y - !x) + 1 end
    done

  let fill_circle cx cy r =
    if r < 0 then invalid_arg "C64.Gfx.fill_circle";
    let x = ref r and y = ref 0 and d = ref (1 - r) in
    while !x >= !y do
      let a = !x and b = !y in
      hline (cx - a) (cx + a) (cy + b); hline (cx - a) (cx + a) (cy - b);
      hline (cx - b) (cx + b) (cy + a); hline (cx - b) (cx + b) (cy - a);
      incr y;
      if !d < 0 then d := !d + 2 * !y + 1
      else begin decr x; d := !d + 2 * (!y - !x) + 1 end
    done
end

module Sprite = struct
  let lay = ref Gfx.bank2
  let setup l = lay := l
  let layout () = !lay

  let ptr_page () = !lay.Gfx.bank * 64 + (!lay.Gfx.screen lsr 8) + 3
  let chk n = if n < 0 || n > 7 then invalid_arg "C64.Sprite"

  let setb reg n b =
    let v = Hw.Vic.peek reg in
    Hw.Vic.poke reg (if b then v lor (1 lsl n) else v land (lnot (1 lsl n)))

  let page blk = !lay.Gfx.bank * 64 + (blk lsr 2)
  let off blk = (blk land 3) * 64

  let define blk data =
    if blk < 0 || blk > 255 || Array.length data < 63 then
      invalid_arg "C64.Sprite.define";
    let p = page blk and o = off blk in
    for i = 0 to 62 do Hw.Mem.poke_at p (o + i) (data.(i) land 255) done

  let define_string blk s =
    if blk < 0 || blk > 255 || String.length s < 63 then
      invalid_arg "C64.Sprite.define_string";
    let p = page blk and o = off blk in
    for i = 0 to 62 do Hw.Mem.poke_at p (o + i) (Char.code s.[i]) done

  (* 21 rows of 24 chars; any char other than ' ' and '.' sets the pixel *)
  let define_art blk rows =
    if blk < 0 || blk > 255 || Array.length rows < 21 then
      invalid_arg "C64.Sprite.define_art";
    let p = page blk and o = off blk in
    for r = 0 to 20 do
      let row = rows.(r) in
      for b = 0 to 2 do
        let v = ref 0 in
        for i = 0 to 7 do
          let k = b * 8 + i in
          let on = k < String.length row && row.[k] <> ' ' && row.[k] <> '.' in
          v := (!v lsl 1) lor (if on then 1 else 0)
        done;
        Hw.Mem.poke_at p (o + r * 3 + b) !v
      done
    done

  (* multicolor: 21 rows of 12 chars '0'..'3' (pen of each double pixel) *)
  let define_art_mc blk rows =
    if blk < 0 || blk > 255 || Array.length rows < 21 then
      invalid_arg "C64.Sprite.define_art_mc";
    let p = page blk and o = off blk in
    for r = 0 to 20 do
      let row = rows.(r) in
      for b = 0 to 2 do
        let v = ref 0 in
        for i = 0 to 3 do
          let k = b * 4 + i in
          let c = if k < String.length row then Char.code row.[k] - 48 else 0 in
          v := (!v lsl 2) lor (c land 3)
        done;
        Hw.Mem.poke_at p (o + r * 3 + b) !v
      done
    done

  let assign n blk = chk n; Hw.Mem.poke_at (ptr_page ()) (0xF8 + n) blk

  let enable n b = chk n; setb Hw.Vic.me n b
  let multicolor n b = chk n; setb Hw.Vic.mmc n b
  let expand_x n b = chk n; setb Hw.Vic.mxe n b
  let expand_y n b = chk n; setb Hw.Vic.mye n b
  let behind n b = chk n; setb Hw.Vic.mdp n b
  let color n c = chk n; Hw.Vic.poke (Hw.Vic.mc n) c
  let mcolors c1 c2 = Hw.Vic.poke Hw.Vic.mm0 c1; Hw.Vic.poke Hw.Vic.mm1 c2

  let pos n x y =
    chk n;
    if x < 0 || x > 511 then invalid_arg "C64.Sprite.pos";
    Hw.Vic.poke (Hw.Vic.mx n) (x land 255);
    setb Hw.Vic.mx8 n (x > 255);
    Hw.Vic.poke (Hw.Vic.my n) (y land 255)

  let move n x y = pos n (x + 24) (y + 50)

  let hit_sprites () = Hw.Vic.peek Hw.Vic.mm
  let hit_background () = Hw.Vic.peek Hw.Vic.md
end

module Sound = struct
  module Sid = Hw.Sid
  type system = Pal | Ntsc | Pal_n
  type source = Osc3 | Env3
  type dest = Freq of int | Pw of int | Cutoff | Volume | Resonance

  external frame_cycles : unit -> int = "caml_nonstd_snd_frame_cycles"
  external wait_frame : unit -> unit = "caml_nonstd_snd_wait_frame"

  let tri = 0x10 and saw = 0x20 and pulse = 0x40 and noise = 0x80

  let system_of_cycles c =
    (* c is half the frame cycles: PAL-N 10140, PAL 9828, NTSC 8547 *)
    if c >= 10000 then Pal_n else if c >= 9000 then Pal else Ntsc
  let detect () = system_of_cycles (frame_cycles ())
  let sys = ref Pal
  let system () = !sys
  let set_system s = sys := s

  (* clock / 128, and a few derived figures (ints are only 15 bit) *)
  let c2 () = match !sys with Pal -> 7697 | Ntsc -> 7990 | Pal_n -> 7996
  let clock_khz () = match !sys with Pal -> 985 | Ntsc -> 1023 | Pal_n -> 1023
  let max_hz () = match !sys with Pal -> 3848 | Ntsc -> 3994 | Pal_n -> 3997
  let min_mhz () = match !sys with Pal -> 58 | Ntsc -> 60 | Pal_n -> 61

  (* octave 6 (C6..B6) SID values, high and low byte *)
  let pal_h = [| 69;73;78;82;87;92;98;104;110;117;124;131 |]
  let pal_l = [| 156;192;35;200;180;235;114;76;128;18;8;104 |]
  let ntsc_h = [| 67;71;75;79;84;89;94;100;106;112;119;126 |]
  let ntsc_l = [| 15;12;70;191;125;132;214;122;115;200;125;151 |]
  let paln_h = [| 67;70;75;79;84;89;94;100;106;112;119;126 |]
  let paln_l = [| 3;255;56;177;110;116;197;104;96;180;103;129 |]

  let sh = Array.make 32 0
  let shadow r = sh.(r)
  let w r v = sh.(r) <- v; Sid.poke r v

  let chk v = if v < 1 || v > 3 then invalid_arg "C64.Sound.voice"
  let vb v = chk v; Sid.voice v

  let rh = ref 0 and rl = ref 0   (* result of the frequency computations *)

  let note_regs n =
    if n < 0 || n > 95 then invalid_arg "C64.Sound.note";
    let o = n / 12 and k = n mod 12 in
    let th, tl = match !sys with
      | Pal -> pal_h, pal_l | Ntsc -> ntsc_h, ntsc_l | Pal_n -> paln_h, paln_l in
    rh := th.(k); rl := tl.(k);
    if o <= 6 then
      for _ = 1 to 6 - o do
        rl := (!rl lsr 1) lor ((!rh land 1) lsl 7);
        rh := !rh lsr 1
      done
    else begin
      let h = (!rh lsl 1) lor (!rl lsr 7) in
      if h > 255 then (rh := 255; rl := 255)
      else (rh := h; rl := (!rl lsl 1) land 255)
    end

  (* F = hz * 2^17 / (clock/128), 17 fractional bits of hz / c2 *)
  let hz_regs hz =
    if hz < 0 || hz > max_hz () then invalid_arg "C64.Sound.freq_hz";
    let c = c2 () in
    let r = ref hz and qh = ref 0 and ql = ref 0 in
    for _ = 1 to 17 do
      r := !r * 2;
      qh := (!qh lsl 1) lor (!ql lsr 7);
      ql := (!ql lsl 1) land 255;
      if !r >= c then (r := !r - c; ql := !ql lor 1)
    done;
    if !qh > 255 then (rh := 255; rl := 255) else (rh := !qh; rl := !ql)

  (* quarter units: F / 4, in 0..16383 *)
  let f4_of_hz hz =
    if hz < 0 || hz > max_hz () then invalid_arg "C64.Sound.f4_of_hz";
    let c = c2 () in
    let r = ref hz and q = ref 0 in
    for _ = 1 to 15 do
      r := !r * 2; q := !q * 2;
      if !r >= c then (r := !r - c; q := !q + 1)
    done;
    if !q > 16383 then 16383 else !q

  let freq_raw v ~hi ~lo =
    let b = vb v in w b (lo land 255); w (b + 1) (hi land 255)
  let freq_hz v hz = hz_regs hz; freq_raw v ~hi:!rh ~lo:!rl
  let note v n = note_regs n; freq_raw v ~hi:!rh ~lo:!rl
  let freq_f4 v q =
    freq_raw v ~hi:((q lsr 6) land 255) ~lo:((q land 63) lsl 2)

  let ctl v mask b =
    let r = vb v + 4 in
    w r (if b then sh.(r) lor mask else sh.(r) land (lnot mask))
  let gate v b = ctl v 1 b
  let sync v b = ctl v 2 b
  let ring v b = ctl v 4 b
  let test v b = ctl v 8 b
  let waveform v wf =
    let r = vb v + 4 in w r ((sh.(r) land 0x0F) lor (wf land 0xF0))

  let adsr v ~a ~d ~s ~r =
    let b = vb v in
    w (b + 5) (((a land 15) lsl 4) lor (d land 15));
    w (b + 6) (((s land 15) lsl 4) lor (r land 15))
  let pulse_width v p =
    let b = vb v in w (b + 2) (p land 255); w (b + 3) ((p lsr 8) land 15)

  let cutoff c = w Sid.fcl (c land 7); w Sid.fch ((c lsr 3) land 255)
  let resonance r = w Sid.resflt ((sh.(Sid.resflt) land 0x0F) lor ((r land 15) lsl 4))
  (* voice 1..3, or 4 for the external input *)
  let route v b =
    if v < 1 || v > 4 then invalid_arg "C64.Sound.route";
    let m = 1 lsl (v - 1) in
    w Sid.resflt (if b then sh.(Sid.resflt) lor m else sh.(Sid.resflt) land (lnot m))
  let filter_mode ~lp ~bp ~hp =
    let v = sh.(Sid.modvol) land 0x8F in
    w Sid.modvol (v lor (if lp then 0x10 else 0) lor (if bp then 0x20 else 0)
                  lor (if hp then 0x40 else 0))
  let mute_voice3 b =
    let v = sh.(Sid.modvol) in
    w Sid.modvol (if b then v lor 0x80 else v land 0x7F)
  let volume n = w Sid.modvol ((sh.(Sid.modvol) land 0xF0) lor (n land 15))

  let pot_x () = Sid.peek Sid.potx
  let pot_y () = Sid.peek Sid.poty

  let silence () =
    for v = 1 to 3 do gate v false done; volume 0

  let init ?(detect_clock = true) () =
    for r = 0 to 0x18 do w r 0 done;
    if detect_clock then sys := detect ();
    volume 15

  let play v n = note v n; gate v true
  let stop v = gate v false

  (* ---- OSC3 / ENV3: voice 3 as a free LFO / random source ---- *)
  let lfo ?(wave = tri) f =
    if f < 0 || f > 16383 then invalid_arg "C64.Sound.lfo";
    freq_raw 3 ~hi:(f lsr 8) ~lo:(f land 255);
    w (vb 3 + 4) (wave land 0xF0);   (* control reg of voice 3, gate off *)
    mute_voice3 true
  let lfo_raw ?(wave = tri) ~hi ~lo () =
    freq_raw 3 ~hi ~lo; w (vb 3 + 4) (wave land 0xF0); mute_voice3 true
  let random_init () = lfo_raw ~wave:noise ~hi:255 ~lo:255 ()
  let sample = function Osc3 -> Sid.peek Sid.osc3 | Env3 -> Sid.peek Sid.env3
  let random () = Sid.peek Sid.osc3

  (* s in -128..127, d any int in +-16383: s * d / 128 without overflow *)
  let scale s d = s * (d asr 7) + ((s * (d land 127)) asr 7)
  let clamp lo hi x = if x < lo then lo else if x > hi then hi else x

  let modulate src dst ~base ~depth =
    let d = scale (sample src - 128) depth in
    let x = base + d in
    match dst with
    | Freq v -> freq_f4 v (clamp 0 16383 x)
    | Pw v -> pulse_width v (clamp 0 4095 x)
    | Cutoff -> cutoff (clamp 0 2047 x)
    | Volume -> volume (clamp 0 15 x)
    | Resonance -> resonance (clamp 0 15 x)
end

(* ======================================================================== *)
(*                       MICROCONTROLLER LAYER                              *)
(* ======================================================================== *)
module Mcu = struct
  let bad s = invalid_arg ("C64.Mcu." ^ s)
  let pal () = Hw.Mem.peek_view 0x2A6 <> 0
  let chk_pb f p = if p < 0 || p > 7 then bad (f ^ ": pin")

  module Gpio = struct
    type mode = Input | Output
    let chk p = if p < 0 || p > 8 then bad "Gpio: pin"
    let mode p m =
      chk p;
      if p = 8 then Hw.Userport.pa2_output (match m with Output -> true | Input -> false)
      else (match m with
        | Output -> Hw.Userport.dir_out (1 lsl p)
        | Input -> Hw.Userport.dir_in (1 lsl p))
    let write p v =
      chk p;
      if p = 8 then Hw.Userport.pa2_write v
      else if v then Hw.Userport.set_bits (1 lsl p)
      else Hw.Userport.clear_bits (1 lsl p)
    let read p =
      chk p;
      if p = 8 then Hw.Userport.pa2_read ()
      else (Hw.Userport.read () lsr p) land 1 <> 0
    let toggle p =
      chk p;
      if p = 8 then Hw.Userport.pa2_write (not (Hw.Userport.pa2_read ()))
      else Hw.Userport.toggle_bits (1 lsl p)
    let read_port () = Hw.Userport.read ()
    let write_port v = Hw.Userport.write v
  end

  module Time = struct
    external delay_cycles : int -> unit = "caml_nonstd_up_delay"
    external clock_start : unit -> unit = "caml_nonstd_up_clock_start"
    external clock_ticks : unit -> int = "caml_nonstd_up_clock_read"
    external cycles_of_rate : int -> int = "caml_nonstd_up_cycles_of_rate"

    (* 1 us = 0.98525 cycles (PAL) / 1.02273 cycles (NTSC) *)
    let cycles_of_us us =
      if pal () then us - (us lsr 6) else us + (us lsr 6) + (us lsr 7)
    (* inverse; may exceed 16383 for c > 16140 (PAL): callers clamp *)
    let us_of_cycles c =
      if pal () then c + (c lsr 6) else c - (c lsr 5) + (c lsr 7)

    let delay_us us =
      if us < 0 then bad "Time.delay_us";
      let r = ref us in
      while !r > 10000 do
        delay_cycles (cycles_of_us 10000);
        r := !r - 10000
      done;
      delay_cycles (cycles_of_us !r)

    let delay_ms ms =
      if ms < 0 then bad "Time.delay_ms";
      let r = ref ms in
      while !r >= 10 do
        delay_us 10000;
        r := !r - 10
      done;
      delay_us (!r * 1000)

    let ticks_per_ms () = if pal () then 246 else 256
  end

  module Pulse = struct
    external out_raw : int -> int -> int -> unit = "caml_nonstd_up_pulse_out"
    external width_raw : int -> int -> int -> int = "caml_nonstd_up_pulse_width"
    let overhead = 56   (* fixed cycles added by pulse_out *)

    let out ?(level = true) pin ~us =
      chk_pb "Pulse.out" pin;
      let c = Time.cycles_of_us us in
      if us < 0 || c < 0 || c > 16383 + overhead then bad "Pulse.out: us";
      let c = c - overhead in
      out_raw (1 lsl pin) (if level then 1 else 0) (if c < 0 then 0 else c)

    let width ?(level = true) ?(timeout_ms = 100) pin =
      chk_pb "Pulse.width" pin;
      if timeout_ms < 0 || timeout_ms > 4000 then bad "Pulse.width: timeout";
      let c = width_raw (1 lsl pin) (if level then 1 else 0) (timeout_ms * 4) in
      if c < 0 then -1
      else begin
        let u = Time.us_of_cycles c in
        if u < c then 16383 else u
      end
  end

  module Spi = struct
    external xfer : int -> int -> int -> int = "caml_nonstd_up_spi_xfer"
    external buf : int -> int -> bytes -> int -> int -> unit
      = "caml_nonstd_up_spi_buf"

    type t = { cfg : int; delay : int }

    let create ?(sck = 0) ?(mosi = 1) ?(miso = 2) ?(mode = 0) ?(delay = 0) () =
      chk_pb "Spi.create" sck;
      chk_pb "Spi.create" mosi;
      if miso < -1 || miso > 7 then bad "Spi.create: miso";
      if mode < 0 || mode > 3 then bad "Spi.create: mode";
      if delay < 0 || delay > 255 then bad "Spi.create: delay";
      Hw.Userport.dir_out ((1 lsl sck) lor (1 lsl mosi));
      if miso >= 0 then Hw.Userport.dir_in (1 lsl miso);
      let m = if miso < 0 then 0 else miso in
      let cfg =
        sck lor (mosi lsl 3) lor (m lsl 6)
        lor ((mode lsr 1) lsl 9) lor ((mode land 1) lsl 10)
        lor (if miso < 0 then 1 lsl 12 else 0) in
      { cfg; delay }

    let transfer t b = xfer t.cfg t.delay (b land 255)
    let write t b = ignore (xfer t.cfg t.delay (b land 255))
    let read t = xfer t.cfg t.delay 255

    let transfer_bytes t ?(pos = 0) ?len b =
      let n = Bytes.length b in
      let len = match len with Some l -> l | None -> n - pos in
      if pos < 0 || len < 0 || pos > n - len then bad "Spi.transfer_bytes";
      buf t.cfg t.delay b pos len
  end

  module Uart = struct
    external tx : int -> int -> unit = "caml_nonstd_up_uart_tx"
    external rx : int -> int -> int = "caml_nonstd_up_uart_rx"

    type t = { tx_cfg : int; rx_cfg : int }

    let create ?(tx = 2) ?(rx = 3) baud =
      chk_pb "Uart.create" tx;
      chk_pb "Uart.create" rx;
      if baud < 250 || baud > 14000 then bad "Uart.create: baud";
      let cpb = Time.cycles_of_rate baud in
      if cpb < 70 || cpb > 4095 then bad "Uart.create: baud";
      Hw.Userport.set_bits (1 lsl tx);       (* idle = high *)
      Hw.Userport.dir_out (1 lsl tx);
      Hw.Userport.dir_in (1 lsl rx);
      { tx_cfg = tx lor (cpb lsl 3); rx_cfg = rx lor (cpb lsl 3) }

    let write_byte u b = tx u.tx_cfg (b land 255)
    let write_string u s =
      for i = 0 to String.length s - 1 do
        tx u.tx_cfg (Char.code (String.get s i))
      done

    let read_byte ?(timeout_ms = 100) u =
      if timeout_ms < 0 || timeout_ms > 4000 then bad "Uart.read_byte: timeout";
      rx u.rx_cfg (timeout_ms * 4)
  end

  module I2c = struct
    type t = { sda : int; scl : int }   (* pin masks *)

    let create ?(sda = 4) ?(scl = 5) () =
      chk_pb "I2c.create" sda;
      chk_pb "I2c.create" scl;
      if sda = scl then bad "I2c.create: pins";
      let m = (1 lsl sda) lor (1 lsl scl) in
      Hw.Userport.clear_bits m;       (* latch 0: output = drive low *)
      Hw.Userport.dir_in m;           (* released = high *)
      { sda = 1 lsl sda; scl = 1 lsl scl }

    let low m = Hw.Userport.dir_out m
    let rel m = Hw.Userport.dir_in m
    let level t m = Hw.Userport.read () land m <> 0
    let wait () = Time.delay_cycles 20

    (* release SCL and wait for clock stretching (at most ~ 8 ms) *)
    let scl_high t =
      rel t.scl;
      let n = ref 2000 in
      while not (level t t.scl) && !n > 0 do decr n done

    let start t =
      rel t.sda; scl_high t; wait ();
      low t.sda; wait ();
      low t.scl

    let stop t =
      low t.sda; wait ();
      scl_high t; wait ();
      rel t.sda; wait ()

    let write_byte t b =
      for i = 7 downto 0 do
        if (b lsr i) land 1 <> 0 then rel t.sda else low t.sda;
        wait (); scl_high t; wait (); low t.scl
      done;
      rel t.sda; wait (); scl_high t; wait ();
      let ack = not (level t t.sda) in
      low t.scl;
      ack

    let read_byte t ~ack =
      rel t.sda;
      let v = ref 0 in
      for _i = 0 to 7 do
        wait (); scl_high t; wait ();
        v := (!v lsl 1) lor (if level t t.sda then 1 else 0);
        low t.scl
      done;
      if ack then low t.sda else rel t.sda;
      wait (); scl_high t; wait (); low t.scl;
      rel t.sda;
      !v

    let probe t addr =
      start t;
      let a = write_byte t ((addr lsl 1) land 0xFE) in
      stop t;
      a

    let write_reg t addr reg v =
      start t;
      let ok = write_byte t ((addr lsl 1) land 0xFE)
               && write_byte t reg && write_byte t v in
      stop t;
      ok

    let read_reg t addr reg =
      start t;
      if not (write_byte t ((addr lsl 1) land 0xFE) && write_byte t reg)
      then (stop t; -1)
      else begin
        start t;
        if not (write_byte t (((addr lsl 1) land 0xFE) lor 1))
        then (stop t; -1)
        else begin
          let v = read_byte t ~ack:false in
          stop t;
          v
        end
      end
  end

  module Tone = struct
    external start_raw : int -> int -> bool = "caml_nonstd_up_tone"
    external stop_raw : int -> unit = "caml_nonstd_up_tone_stop"
    let start ?(pin = 6) hz = start_raw pin hz
    let stop ?(pin = 6) () = stop_raw pin
  end
end

(* ———————————————————————————————————————————————————————————————————————
   Disk drives and SD2IEC.  Pure OCaml over Hw.Kernal.  No top-level effect
   (the tables are created at the first use, and only then at_exit is
   registered), so that linking C64 for another module costs nothing here.
   Command strings are written in lowercase in the source: the BreadCaml
   preprocessor turns them into the PETSCII codes that DOS wants.
   ——————————————————————————————————————————————————————————————————————— *)

module Disk = struct
  module K = Hw.Kernal

  exception Kernal_error of int
  exception Status_error of int
  exception Dos_error of int * string

  type status = { code : int; message : string; track : int; sector : int }

  let default_device = ref 8

  let devof = function
    | None -> !default_device
    | Some d ->
      if d < 4 || d > 30 then invalid_arg "C64.Disk: device number" else d

  let kerr e = if e <> 0 then raise (Kernal_error e)

  (* Logical files: lfn 2..9 (secondary address = lfn), index = lfn.
     The command channel of device d has lfn 32 + d and stays open until the
     end of the program (closing it would close all the files of the drive). *)
  type state = { busy : bool array; devs : int array; cmd : bool array }

  let state_ref : state option ref = ref None

  let close_everything s =
    for lfn = 2 to 9 do
      if s.busy.(lfn) then (K.close lfn; s.busy.(lfn) <- false)
    done;
    for dev = 4 to 30 do
      if s.cmd.(dev) then (K.close (32 + dev); s.cmd.(dev) <- false)
    done

  let state () =
    match !state_ref with
    | Some s -> s
    | None ->
      let s = { busy = Array.make 10 false; devs = Array.make 10 0;
                cmd = Array.make 31 false } in
      state_ref := Some s;
      at_exit (fun () -> close_everything s);
      s

  let close_all () = close_everything (state ())

  let alloc_lfn dev =
    let s = state () in
    let rec go n =
      if n > 9 then raise (Kernal_error K.err_too_many_files)
      else if s.busy.(n) then go (n + 1)
      else (s.busy.(n) <- true; s.devs.(n) <- dev; n) in
    go 2

  let free_lfn lfn = (state ()).busy.(lfn) <- false

  (* ---- the command / error channel ---- *)

  let ensure_cmd dev =
    let s = state () in
    if not s.cmd.(dev) then begin
      kerr (K.open_file (32 + dev) dev 15 "");
      s.cmd.(dev) <- true
    end

  let forget_command_channel dev =
    let s = state () in
    if s.cmd.(dev) then (K.close (32 + dev); s.cmd.(dev) <- false)

  (* Reads the message up to CR (excluded) from the current input channel. *)
  let read_message () =
    let b = Buffer.create 40 in
    let fin = ref false in
    while not !fin do
      let c = K.chrin () in
      let st = K.readst () in
      if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
      if c = 13 then fin := true
      else begin
        if Buffer.length b < 100 then Buffer.add_char b (Char.chr c);
        if st land K.st_eof <> 0 then fin := true
      end
    done;
    Buffer.contents b

  let parse_status s =
    let n = String.length s in
    let find i =
      let rec go k = if k >= n || s.[k] = ',' then k else go (k + 1) in
      go i in
    let num i j =
      let v = ref 0 in
      for k = i to j - 1 do
        let d = Char.code s.[k] - 48 in
        if d >= 0 && d <= 9 then v := !v * 10 + d
      done;
      !v in
    let a = find 0 in
    let b = find (a + 1) in
    let c = find (b + 1) in
    { code = num 0 a;
      message = (if a >= n then "" else String.sub s (a + 1) (b - a - 1));
      track = (if b >= n then 0 else num (b + 1) c);
      sector = (if c >= n then 0 else num (c + 1) n) }

  let read_status dev =
    ensure_cmd dev;
    kerr (K.chkin (32 + dev));
    let r = read_message () in
    K.clrchn ();
    parse_status r

  let send dev cmd =
    ensure_cmd dev;
    kerr (K.chkout (32 + dev));
    String.iter (fun c -> K.chrout (Char.code c)) cmd;
    K.chrout 13;
    K.clrchn ()

  let status ?dev () = read_status (devof dev)

  let raw_command ?dev cmd =
    let dev = devof dev in
    send dev cmd;
    read_status dev

  let command ?dev cmd =
    let st = raw_command ?dev cmd in
    if st.code >= 20 then raise (Dos_error (st.code, st.message));
    st

  (* Sends [cmd] and returns the raw reply (up to [maxlen] bytes, up to the
     EOI): for the commands that answer with binary data. *)
  let command_read ?dev cmd maxlen =
    let dev = devof dev in
    send dev cmd;
    kerr (K.chkin (32 + dev));
    let b = Buffer.create 16 in
    let fin = ref false in
    while not !fin do
      let c = K.chrin () in
      let st = K.readst () in
      if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
      Buffer.add_char b (Char.chr c);
      if st land K.st_eof <> 0 || Buffer.length b >= maxlen then fin := true
    done;
    K.clrchn ();
    Buffer.contents b

  let scratch ?dev name = (command ?dev ("s:" ^ name)).track
  let rename ?dev ~src dst = ignore (command ?dev ("r:" ^ dst ^ "=" ^ src))
  let copy ?dev ~src dst = ignore (command ?dev ("c:" ^ dst ^ "=" ^ src))
  let validate ?dev () = ignore (command ?dev "v")
  let format ?dev ?id name =
    ignore (command ?dev
              (match id with None -> "n:" ^ name | Some i -> "n:" ^ name ^ "," ^ i))

  (* ---- sequential files ---- *)

  type kind = Seq | Prg | Usr
  type mode = Replace | Create | Append

  let kind_suffix = function Seq -> ",s" | Prg -> ",p" | Usr -> ",u"

  type in_file = { in_lfn : int; in_dev : int;
                   mutable in_open : bool; mutable in_eof : bool }
  type out_file = { out_lfn : int; out_dev : int; mutable out_open : bool }

  let open_gen dev spec =
    ensure_cmd dev;
    let lfn = alloc_lfn dev in
    let e = K.open_file lfn dev lfn spec in
    if e <> 0 then (free_lfn lfn; raise (Kernal_error e));
    let st = (try read_status dev
              with e -> K.close lfn; free_lfn lfn; raise e) in
    if st.code >= 20 then begin
      K.close lfn; free_lfn lfn;
      raise (Dos_error (st.code, st.message))
    end;
    lfn

  let open_in ?dev ?(kind = Seq) name =
    let dev = devof dev in
    let lfn = open_gen dev (name ^ kind_suffix kind ^ ",r") in
    { in_lfn = lfn; in_dev = dev; in_open = true; in_eof = false }

  let open_out ?dev ?(kind = Seq) ?(mode = Replace) name =
    let dev = devof dev in
    let spec = match mode with
      | Replace -> "@0:" ^ name ^ kind_suffix kind ^ ",w"
      | Create -> name ^ kind_suffix kind ^ ",w"
      | Append -> name ^ kind_suffix kind ^ ",a" in
    let lfn = open_gen dev spec in
    { out_lfn = lfn; out_dev = dev; out_open = true }

  let check_in f = if not f.in_open then invalid_arg "C64.Disk: file closed"
  let check_out f = if not f.out_open then invalid_arg "C64.Disk: file closed"

  let close_in f =
    if f.in_open then begin
      f.in_open <- false;
      K.close f.in_lfn;
      free_lfn f.in_lfn
    end

  let close_out f =
    if f.out_open then begin
      f.out_open <- false;
      K.close f.out_lfn;
      free_lfn f.out_lfn;
      let st = read_status f.out_dev in
      if st.code >= 20 then raise (Dos_error (st.code, st.message))
    end

  let in_eof f = f.in_eof

  (* one byte, channel already selected *)
  let rd f =
    let c = K.chrin () in
    let st = K.readst () in
    if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
    if st land K.st_eof <> 0 then f.in_eof <- true;
    c

  let input_byte f =
    check_in f;
    if f.in_eof then raise End_of_file;
    kerr (K.chkin f.in_lfn);
    let c = rd f in
    K.clrchn ();
    c

  let input_char f = Char.chr (input_byte f)

  let input f b pos len =
    check_in f;
    if pos < 0 || len < 0 || pos > Bytes.length b - len then
      invalid_arg "C64.Disk.input";
    if f.in_eof || len = 0 then 0
    else begin
      kerr (K.chkin f.in_lfn);
      let n = ref 0 in
      while !n < len && not f.in_eof do
        Bytes.unsafe_set b (pos + !n) (Char.unsafe_chr (rd f));
        incr n
      done;
      K.clrchn ();
      !n
    end

  type newline = Cr | Lf | Crlf

  let input_line ?(nl = Cr) f =
    check_in f;
    if f.in_eof then raise End_of_file;
    let stop = if nl = Cr then 13 else 10 in
    let b = Buffer.create 40 in
    kerr (K.chkin f.in_lfn);
    let fin = ref false in
    while not !fin do
      let c = rd f in
      if c = stop then fin := true
      else begin
        Buffer.add_char b (Char.chr c);
        if f.in_eof then fin := true
      end
    done;
    K.clrchn ();
    let n = Buffer.length b in
    if nl = Crlf && n > 0 && Buffer.nth b (n - 1) = Char.chr 13 then
      Buffer.sub b 0 (n - 1)
    else Buffer.contents b

  let input_all f =
    let b = Buffer.create 256 in
    let tmp = Bytes.create 64 in
    let rec go () =
      let n = input f tmp 0 64 in
      if n > 0 then (Buffer.add_subbytes b tmp 0 n; go ()) in
    go ();
    Buffer.contents b

  (* output: errors of the drive (disk full...) show up in [close_out] or
     [status]; the bus errors are raised at once. *)
  let wr c =
    K.chrout c;
    let st = K.readst () in
    if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st))

  let output_byte f c =
    check_out f;
    kerr (K.chkout f.out_lfn);
    wr (c land 255);
    K.clrchn ()

  let output_char f c = output_byte f (Char.code c)

  let output_substring f s pos len =
    check_out f;
    if pos < 0 || len < 0 || pos > String.length s - len then
      invalid_arg "C64.Disk.output_substring";
    kerr (K.chkout f.out_lfn);
    for i = pos to pos + len - 1 do
      wr (Char.code (String.unsafe_get s i))
    done;
    K.clrchn ()

  let output_string f s = output_substring f s 0 (String.length s)
  let output_bytes f b = output_string f (Bytes.unsafe_to_string b)

  let output_newline ?(nl = Cr) f =
    check_out f;
    kerr (K.chkout f.out_lfn);
    (match nl with
     | Cr -> wr 13
     | Lf -> wr 10
     | Crlf -> wr 13; wr 10);
    K.clrchn ()

  let read_file ?dev ?kind name =
    let f = open_in ?dev ?kind name in
    let s = (try input_all f with e -> close_in f; raise e) in
    close_in f;
    s

  let write_file ?dev ?kind ?mode name s =
    let f = open_out ?dev ?kind ?mode name in
    (try output_string f s with e -> (try close_out f with _ -> ()); raise e);
    close_out f

  (* ---- memory <-> file ---- *)

  let load_at ?dev name page off =
    kerr (K.load_at (devof dev) 0 name page off);
    (K.load_end_page (), K.load_end_off ())

  let load_prg ?dev name =
    kerr (K.load_at (devof dev) 1 name 0 0);
    (K.load_end_page (), K.load_end_off ())

  let save ?dev ?(replace = true) name spage soff epage eoff =
    let name = if replace then "@0:" ^ name else name in
    kerr (K.save ~dev:(devof dev) name spage soff epage eoff)

  (* ---- directory ---- *)

  type entry_type = DSeq | DPrg | DUsr | DRel | DDel | DDir | DOther of string

  type entry = { name : string; blocks : int32; etype : entry_type;
                 closed : bool; locked : bool }

  type disk_info = { title : string; id : string; free : int32 }

  let entry_type_of_string s =
    if s = "seq" then DSeq
    else if s = "prg" then DPrg
    else if s = "usr" then DUsr
    else if s = "rel" then DRel
    else if s = "del" then DDel
    else if s = "dir" then DDir
    else DOther s

  type line = Header of string * string | Entry of entry | Free of int32
            | Skip

  let parse_line buf n (blocks : int32) =
    let at i = Char.code (Bytes.unsafe_get buf i) in
    let quote from =
      let rec go i = if i >= n then -1 else if at i = 34 then i else go (i + 1) in
      go from in
    let q1 = quote 0 in
    if q1 < 0 then begin
      (* no name: "BLOCKS FREE." *)
      Free blocks
    end else begin
      let q2 = quote (q1 + 1) in
      let q2 = if q2 < 0 then n else q2 in
      if n > 0 && at 0 = 0x12 then begin
        (* header: [rvs on] "TITLE" ID DOS; the title is padded inside the
           quotes with shifted spaces *)
        let e = ref q2 in
        while !e > q1 + 1 && (at (!e - 1) = 0xA0 || at (!e - 1) = 32) do
          decr e
        done;
        let title = Bytes.sub_string buf (q1 + 1) (!e - q1 - 1) in
        let i0 = q2 + 2 in
        let idl = if i0 + 2 <= n then 2 else if i0 < n then n - i0 else 0 in
        Header (title, if idl > 0 then Bytes.sub_string buf i0 idl else "")
      end else begin
        let name = Bytes.sub_string buf (q1 + 1) (q2 - q1 - 1) in
        let i = ref (q2 + 1) in
        while !i < n && at !i = 32 do incr i done;
        let closed = not (!i < n && at !i = 42) in
        if not closed then incr i;
        let ty = if !i + 3 <= n then Bytes.sub_string buf !i 3 else "" in
        let j = !i + 3 in
        let locked = j < n && at j = 60 in
        Entry { name; blocks; etype = entry_type_of_string ty; closed; locked }
      end
    end

  (* Reads a whole listing; one line at a time, so that the callbacks can do
     their own disk I/O. *)
  let scan dev pattern on_line =
    let lfn = alloc_lfn dev in
    let spec =
      if pattern = "" then "$"
      else if String.length pattern > 0 && Char.code pattern.[0] = 61
      then "$" ^ pattern           (* "=p" *)
      else "$:" ^ pattern in
    let e = K.open_file lfn dev 0 spec in
    if e <> 0 then (free_lfn lfn; raise (Kernal_error e));
    let buf = Bytes.create 80 in
    let finish () = K.clrchn (); K.close lfn; free_lfn lfn in
    (try
       kerr (K.chkin lfn);
       ignore (K.chrin ()); ignore (K.chrin ());     (* load address *)
       K.clrchn ();
       let go = ref true in
       while !go do
         kerr (K.chkin lfn);
         let l0 = K.chrin () in
         let l1 = K.chrin () in
         if l0 = 0 && l1 = 0 then (K.clrchn (); go := false)
         else begin
           let b0 = K.chrin () in
           let b1 = K.chrin () in
           let n = ref 0 in
           let c = ref (K.chrin ()) in
           while !c <> 0 do
             if !n < 80 then (Bytes.unsafe_set buf !n (Char.unsafe_chr !c); incr n);
             c := K.chrin ()
           done;
           let st = K.readst () in
           K.clrchn ();
           if st land 0x83 <> 0 then raise (Status_error st);
           (* 16 bit unsigned: more than an OCaml int (15 bits) can hold *)
           let blocks =
             Int32.add (Int32.of_int b0) (Int32.shift_left (Int32.of_int b1) 8) in
           on_line (parse_line buf !n blocks);
           if st land K.st_eof <> 0 then go := false
         end
       done
     with e -> finish (); raise e);
    finish ()

  let dir_iter ?dev ?(pattern = "") f =
    scan (devof dev) pattern
      (function Entry e -> f e | Header _ | Free _ | Skip -> ())

  let dir_fold ?dev ?pattern f init =
    let acc = ref init in
    dir_iter ?dev ?pattern (fun e -> acc := f e !acc);
    !acc

  let disk_info ?dev () =
    let title = ref "" and id = ref "" and free = ref 0l in
    scan (devof dev) ""
      (function
        | Header (t, i) -> title := t; id := i
        | Free n -> free := n
        | Entry _ | Skip -> ());
    { title = !title; id = !id; free = !free }

  let exists ?dev name =
    let found = ref false in
    dir_iter ?dev ~pattern:name (fun _ -> found := true);
    !found
end

module Sd2iec = struct
  (* Commands of the sd2iec firmware (and compatible: uIEC, ...).  They are
     sent on the command channel of the device with [Disk.command]. *)

  let left_arrow = String.make 1 (Char.chr 0x5F)    (* PETSCII "←" *)

  let fold c = if c >= 0xC1 && c <= 0xDA then c - 0x80 else c

  let contains hay needle =
    let n = String.length hay and m = String.length needle in
    let rec at i j =
      j >= m
      || (fold (Char.code hay.[i + j]) = fold (Char.code needle.[j])
          && at i (j + 1)) in
    let rec go i = i + m <= n && (at i 0 || go (i + 1)) in
    go 0

  (* "UI" is a warm reset: it closes the files of the drive.  Call this
     before opening any file. *)
  let detect ?dev () =
    try
      let st = Disk.raw_command ?dev "ui" in
      st.Disk.code = 73
      && (contains st.Disk.message "sd2iec" || contains st.Disk.message "uiec")
    with Disk.Kernal_error _ | Disk.Status_error _ -> false

  (* ---- directories and images ---- *)

  let chdir ?dev name = ignore (Disk.command ?dev ("cd:" ^ name))
  let parent ?dev () = ignore (Disk.command ?dev ("cd" ^ left_arrow))
  let root ?dev () = ignore (Disk.command ?dev "cd//")
  let mkdir ?dev name = ignore (Disk.command ?dev ("md:" ^ name))
  let rmdir ?dev name = ignore (Disk.command ?dev ("rd:" ^ name))

  let mount ?dev image = chdir ?dev image
  let unmount ?dev () = root ?dev (); parent ?dev ()

  let chdir_path ?dev names =
    List.iter (fun n -> chdir ?dev n) names

  (* ---- partitions ---- *)

  let partition ?dev n =
    if n < 1 || n > 254 then invalid_arg "C64.Sd2iec.partition";
    ignore (Disk.command ?dev ("cp" ^ string_of_int n))

  let partition_iter ?dev f =
    Disk.dir_iter ?dev ~pattern:"=p"
      (fun e -> f (Int32.to_int e.Disk.blocks) e.Disk.name)

  (* ---- real time clock ---- *)

  type time = { year : int; month : int; day : int; hour : int;
                minute : int; second : int; weekday : int }

  (* weekday of a date: 0 = Sunday *)
  let weekday_of year month day =
    let t = [| 0; 3; 2; 5; 0; 3; 5; 1; 4; 6; 2; 4 |] in
    let y = if month < 3 then year - 1 else year in
    (y + y / 4 - y / 100 + y / 400 + t.(month - 1) + day) mod 7

  let read_time ?dev () =
    let s = Disk.command_read ?dev "t-rd" 9 in
    if String.length s = 9 && Char.code s.[0] < 7 && Char.code s.[2] >= 1
    then begin
      let b i = Char.code s.[i] in
      let h = (b 4) mod 12 + (if b 7 = 0 then 0 else 12) in
      Some { weekday = b 0; year = b 1 + 1900; month = b 2; day = b 3;
             hour = h; minute = b 5; second = b 6 }
    end else begin
      ignore (Disk.status ?dev ());       (* drop the rest of the message *)
      None
    end

  let set_time ?dev t =
    if t.year < 1980 || t.year > 2079 || t.month < 1 || t.month > 12
       || t.day < 1 || t.day > 31 || t.hour < 0 || t.hour > 23
       || t.minute < 0 || t.minute > 59 || t.second < 0 || t.second > 59
    then invalid_arg "C64.Sd2iec.set_time";
    let h12 = if t.hour mod 12 = 0 then 12 else t.hour mod 12 in
    let bytes = [ weekday_of t.year t.month t.day; t.year - 1900; t.month;
                  t.day; h12; t.minute; t.second;
                  (if t.hour >= 12 then 1 else 0) ] in
    let b = Buffer.create 12 in
    Buffer.add_string b "t-wd";
    List.iter (fun v -> Buffer.add_char b (Char.chr v)) bytes;
    ignore (Disk.command ?dev (Buffer.contents b))

  (* ---- settings ---- *)

  (* The new address is used at once by the drive, but is lost at reset
     unless [save_settings] is called.  Close the files of the device first. *)
  let set_device_address ?dev n =
    if n < 8 || n > 30 then invalid_arg "C64.Sd2iec.set_device_address";
    let d = Disk.devof dev in
    (* no status read: the old address does not answer any more *)
    Disk.send d ("u0>" ^ String.make 1 (Char.chr n));
    Disk.forget_command_channel d

  let save_settings ?dev () = ignore (Disk.command ?dev "xw")
end
