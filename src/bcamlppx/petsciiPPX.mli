(** [expr_extender] rewrites all ASCII characters in literal char and
    string in expressions with the corresponding PETSCII ones, and
    allows to specify special PETSCII characters with {TAG}s. *)
val expr_extender :
  Ast_mapper.mapper -> Parsetree.expression -> Parsetree.expression

(** [struct_item_extender] is similar to [expr_extender] but operates
    on whole structure blocks. *)
val struct_item_extender :
  Ast_mapper.mapper -> Parsetree.structure_item -> Parsetree.structure_item

(** [sig_item_extender] is similar to [expr_extender] but operates
    on whole signature blocks. *)
val sig_item_extender :
  Ast_mapper.mapper -> Parsetree.signature_item -> Parsetree.signature_item
