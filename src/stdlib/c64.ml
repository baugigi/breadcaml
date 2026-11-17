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
end
