(* Stream and Genlex *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let tokens s =
  let lex = Genlex.make_lexer ["+"; "-"; "("; ")"; "let"; "="] in
  let st = lex (Stream.of_string s) in
  let rec go acc =
    match Stream.peek st with
    | None -> List.rev acc
    | Some t -> Stream.junk st; go (t :: acc) in
  go []

let () =
  (* Stream *)
  let s = Stream.of_string "abc" in
  check "peek" (Stream.peek s = Some 'a');
  check "next" (Stream.next s = 'a');
  check "count" (Stream.count s = 1);
  Stream.junk s;
  check "npeek" (Stream.npeek 5 s = ['c']);
  check "next2" (Stream.next s = 'c');
  check "empty" (try Stream.empty s; true with Stream.Failure -> false);
  check "fail" (try ignore (Stream.next s); false with Stream.Failure -> true);
  let l = Stream.of_list [1; 2; 3] in
  check "of_list" (Stream.next l = 1 && Stream.next l = 2 && Stream.next l = 3);
  let f = Stream.from (fun i -> if i < 3 then Some (i * i) else None) in
  check "from" (Stream.next f = 0 && Stream.next f = 1 && Stream.next f = 4
                && Stream.peek f = None);
  (* Genlex *)
  check "int/ident/kwd"
    (tokens "let x = 12 + y"
     = [Genlex.Kwd "let"; Genlex.Ident "x"; Genlex.Kwd "=";
        Genlex.Int 12; Genlex.Kwd "+"; Genlex.Ident "y"]);
  check "float" (tokens "2.5 1e2 1.5e1" =
                 [Genlex.Float 2.5; Genlex.Float 100.0; Genlex.Float 15.0]);
  check "neg" (tokens "-7" = [Genlex.Int (-7)]);
  check "string/char" (tokens "\"a b\" 'c'" =
                       [Genlex.String "a b"; Genlex.Char 'c']);
  check "comment" (tokens "(* hi *) 3 (1)" =
                   [Genlex.Int 3; Genlex.Kwd "("; Genlex.Int 1;
                    Genlex.Kwd ")"]);
  check "error" (try ignore (tokens "'ab'"); false
                 with Stream.Error _ -> true);
  if !failed = 0 then print_string "ALL OK" else print_string "FAILED";
  print_newline ()
