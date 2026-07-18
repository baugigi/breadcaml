(** [a] is an array of 32768 6-char strings such that, for each string [a.(i)],
    [Btype.hash_variant a.(i)] evaluates to a 15-bit integer from [-16384] to
    [16383], and [Btype.hash_variant a.(i) = Btype.hash_variant a.(j)] if and
    only if [i = j].  [Btype.hash_variant : string -> int] is the function used
    by ocamlc to compute hashes for the internal representation of polymorphic
    variants. *)
val a : string array
