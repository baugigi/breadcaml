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
(* float_of_string / int_of_string must reject strings that are not numbers. *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let good s v = check s (float_of_string_opt s = Some v)
let bad s = check ("bad " ^ s) (float_of_string_opt s = None)

let () =
  good "1.5" 1.5; good "-2" (-2.0); good "0" 0.0; good "-0.0" 0.0;
  good ".5" 0.5; good "5." 5.0; good "1e3" 1000.0; good "0e5" 0.0;
  good "+3" 3.0; good "0." 0.0;
  bad ""; bad "-"; bad "+"; bad "."; bad "abc"; bad "ASDFA"; bad "12abc";
  bad "-0ABC"; bad "1.2.3"; bad "e5"; bad "1 2"; bad "--1";
  check "nan" (match float_of_string_opt "nan" with
               | Some x -> x <> x | None -> false);
  check "inf" (float_of_string_opt "-infinity" = Some neg_infinity);
  check "int ok" (int_of_string_opt "123" = Some 123);
  check "int neg" (int_of_string_opt "-7" = Some (-7));
  check "int bad" (int_of_string_opt "x1" = None);
  check "int bad2" (int_of_string_opt "" = None);
  check "int exn"
    (try ignore (int_of_string "zz"); false with Failure _ -> true);
  check "float exn"
    (try ignore (float_of_string "zz"); false with Failure _ -> true);
  if !failed = 0 then print_string "ALL OK" else print_string "FAILED";
  print_newline ()
