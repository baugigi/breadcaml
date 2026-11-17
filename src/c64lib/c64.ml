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
    if c >= 20000 then Pal_n else if c >= 18000 then Pal else Ntsc
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
