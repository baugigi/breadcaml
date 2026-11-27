(* Lazy values: computed, forced twice, from_val (also on static
   constants), is_val, exceptions, from_fun, globals, GC stress *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let count = ref 0
let l1 = lazy (incr count; 6 * 7)                 (* global lazy *)
let l_static = Lazy.from_val 1.5                  (* static float: Obj.tag *)
let l_str = Lazy.from_val "static"                (* static string *)
let l_int = Lazy.from_val 3                       (* int: not a block *)

exception Boom

let () =
  check "not forced" (not (Lazy.is_val l1) && !count = 0);
  check "force" (Lazy.force l1 = 42 && !count = 1);
  check "force twice" (Lazy.force l1 = 42 && !count = 1);
  check "is_val" (Lazy.is_val l1);
  check "from_val float" (Lazy.is_val l_static && Lazy.force l_static = 1.5);
  check "from_val string" (Lazy.is_val l_str && Lazy.force l_str = "static");
  check "from_val int" (Lazy.is_val l_int && Lazy.force l_int = 3);
  let n = ref 0 in
  let l2 = lazy (incr n; raise Boom) in
  check "exn 1" (try ignore (Lazy.force l2); false with Boom -> true);
  check "exn 2" (try ignore (Lazy.force l2); false with Boom -> true);
  check "exn once" (!n = 1);
  check "not is_val after exn" (not (Lazy.is_val l2));
  let l3 = Lazy.from_fun (fun () -> "ff") in
  check "from_fun" (not (Lazy.is_val l3) && Lazy.force l3 = "ff");
  let l4 = lazy (let l = lazy 5 in Lazy.force l + 1) in
  check "nested" (Lazy.force l4 = 6);
  let l5 = Lazy.map (fun x -> x + 1) l1 in
  check "map" (Lazy.force l5 = 43);
  (* heap block forwarded; allocate to trigger GCs *)
  let ls = Array.init 50 (fun i -> lazy (i * i)) in
  for _ = 1 to 20 do ignore (Array.make 100 0) done;
  let s = ref 0 in
  Array.iter (fun l -> s := !s + Lazy.force l) ls;
  check "many" (!s = 40425);
  for _ = 1 to 20 do ignore (Array.make 100 0) done;
  check "after gc" (Array.for_all Lazy.is_val ls
                    && Array.fold_left (fun a l -> a + Lazy.force l) 0 ls = 40425);
  let rec l6 = lazy (Lazy.force l6) in
  check "undefined" (try ignore (Lazy.force l6); false
                     with Lazy.Undefined -> true);
  print_string (if !failed = 0 then "ALL OK" else "FAILED");
  print_newline ()
