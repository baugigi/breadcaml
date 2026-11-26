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
(* Test of the Arg module: parse_argv on explicit arrays, plus Arg.parse on
   Sys.argv (start it as RUN:REM -v,-n,7,file1,file2). *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let verbose = ref false
let n = ref 0
let s = ref ""
let anon = ref []
let f = ref 0.0
let sym = ref ""
let rest = ref []
let pair = ref (0, "")

let reset () =
  verbose := false; n := 0; s := ""; anon := []; f := 0.0; sym := "";
  rest := []; pair := (0, "")

let spec =
  [ "-v", Arg.Set verbose, " verbose";
    "-n", Arg.Set_int n, " <int> number";
    "-s", Arg.Set_string s, " <string> text";
    "-f", Arg.Set_float f, " <float> real";
    "-m", Arg.Symbol (["fast"; "slow"], fun x -> sym := x), " mode";
    "-t", Arg.Tuple [Arg.Set_int n; Arg.Set_string s], " <int> <string>";
    "--", Arg.Rest (fun x -> rest := x :: !rest), " rest" ]

let anon_fun x = anon := x :: !anon
let usage = "test [options] files"

let run args =
  reset ();
  Arg.parse_argv ~current:(ref 0) args spec anon_fun usage

let starts_with p x =
  String.length x >= String.length p && String.sub x 0 (String.length p) = p

let () =
  run [| "prog"; "-v"; "-n"; "42"; "-s"; "abc"; "x"; "y" |];
  check "flags" (!verbose && !n = 42 && !s = "abc" && !anon = ["y"; "x"]);
  run [| "prog"; "-n=7"; "-s=q" |];
  check "key=arg" (!n = 7 && !s = "q" && not !verbose);
  run [| "prog"; "-m"; "slow"; "-f"; "2.5" |];
  check "symbol/float" (!sym = "slow" && !f = 2.5);
  run [| "prog"; "-t"; "5"; "zz" |];
  check "tuple" (!n = 5 && !s = "zz");
  run [| "prog"; "a"; "--"; "-v"; "b" |];
  check "rest" (!anon = ["a"] && !rest = ["b"; "-v"] && not !verbose);
  run [| "prog" |];
  check "empty" (not !verbose && !anon = []);
  (try run [| "prog"; "-z" |]; check "unknown" false
   with Arg.Bad m ->
     check "unknown" (starts_with "prog: unknown option '-z'." m));
  (try run [| "prog"; "-n" |]; check "missing" false
   with Arg.Bad m ->
     check "missing" (starts_with "prog: option '-n' needs an argument." m));
  (try run [| "prog"; "-n"; "x" |]; check "wrong" false
   with Arg.Bad m ->
     check "wrong"
       (starts_with "prog: wrong argument 'x'; option '-n' expects an integer."
          m));
  (try run [| "prog"; "-f"; "x" |]; check "wrong float" false
   with Arg.Bad m ->
     check "wrong float"
       (starts_with "prog: wrong argument 'x'; option '-f' expects a float." m));
  (try run [| "prog"; "-m"; "mid" |]; check "symbol err" false
   with Arg.Bad _ -> check "symbol err" true);
  (try run [| "prog"; "-help" |]; check "help" false
   with Arg.Help m -> check "help" (starts_with "test [options] files" m));
  check "usage_string"
    (starts_with "test [options] files\n  -v  verbose\n"
       (Arg.usage_string spec usage));
  check "align" (List.length (Arg.align spec) = List.length spec + 2);
  Arg.parse spec anon_fun usage;
  print_string "argv: ";
  Array.iter (fun a -> print_string a; print_char ' ') Sys.argv;
  print_newline ();
  print_string "anon: ";
  List.iter (fun a -> print_string a; print_char ' ') (List.rev !anon);
  print_newline ();
  if !failed = 0 then print_string "ALL OK" else print_string "FAILED";
  print_newline ()
