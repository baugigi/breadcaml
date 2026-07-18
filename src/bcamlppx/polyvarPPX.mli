exception Too_many_tags

(** [expr_rewriter] operates an all expressions with polymorphic variant tags,
    renaming them so that [Btypes.hash_variant] (the function used by ocamlc to
    compute hashes for their internal representation) returns integers which fit
    in 15 bits. The rewriter uses a database file to save and reload all
    renamings, because it must operate globally on all compilation units.
    @raise [Too_many_tags] when the number of polymorphic variants to rename
      exceeds 503. *)
val expr_rewriter : Ast_mapper.mapper ->
                    Parsetree.expression -> Parsetree.expression

(** [pat_rewriter] is similar to [expr_rewriter] but operates on patterns. *)
val pat_rewriter : Ast_mapper.mapper ->
                   Parsetree.pattern -> Parsetree.pattern

(** [typ_rewriter] is similar to [expr_rewriter] but operates on types. *)
val typ_rewriter : Ast_mapper.mapper ->
                   Parsetree.core_type -> Parsetree.core_type

(** [db_load in_ch] loads the renaming database from channel [in_ch]. *)
val db_load : in_channel -> unit

(** [db_save out_ch] saves the renaming database to channel [out_ch]. *)
val db_save : out_channel -> unit

