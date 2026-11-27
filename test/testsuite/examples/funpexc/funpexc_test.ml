(* Fun, Printexc *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let ends_with p x =
  let lp = String.length p and lx = String.length x in
  lx >= lp && String.sub x (lx - lp) lp = p

exception E of int * string
exception C

let () =
  (* Fun *)
  check "id" (Fun.id 5 = 5);
  check "const" (Fun.const 1 "x" = 1);
  check "flip" (Fun.flip (-) 1 10 = 9);
  check "negate" (Fun.negate (fun x -> x > 3) 2);
  let log = ref [] in
  let r = Fun.protect ~finally:(fun () -> log := "f" :: !log)
      (fun () -> log := "w" :: !log; 7) in
  check "protect ok" (r = 7 && !log = ["f"; "w"]);
  log := [];
  (try
     ignore (Fun.protect ~finally:(fun () -> log := "f" :: !log)
               (fun () -> raise Not_found));
     check "protect exn" false
   with Not_found -> check "protect exn" (!log = ["f"]));
  (try
     ignore (Fun.protect ~finally:(fun () -> raise C) (fun () -> 1));
     check "finally raised" false
   with Fun.Finally_raised C -> check "finally raised" true);
  (* Printexc *)
  check "Not_found" (Printexc.to_string Not_found = "Not_found");
  check "Failure" (Printexc.to_string (Failure "x") = "Failure(\"x\")");
  check "Invalid_argument"
    (Printexc.to_string (Invalid_argument "y") = "Invalid_argument(\"y\")");
  check "Division_by_zero"
    (Printexc.to_string Division_by_zero = "Division_by_zero");
  check "custom args" (ends_with "E(3, \"a\")" (Printexc.to_string (E (3, "a"))));
  check "custom const" (ends_with "C" (Printexc.to_string C));
  Printexc.register_printer
    (function E (n, _) -> Some ("E#" ^ string_of_int n) | _ -> None);
  check "printer" (Printexc.to_string (E (4, "b")) = "E#4");
  check "printer other" (Printexc.to_string Not_found = "Not_found");
  check "backtrace stubs"
    (not (Printexc.backtrace_status ()) && Printexc.get_backtrace () = "");
  check "print" (try Printexc.print (fun () -> raise C) (); false
                 with C -> true);
  if !failed = 0 then print_string "ALL OK" else print_string "FAILED";
  print_newline ()
