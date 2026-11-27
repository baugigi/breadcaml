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
