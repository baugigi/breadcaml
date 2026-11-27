(* Printf (reduced): conversions, flags, partial application, %a %t, k*printf,
   unsupported formats.  The ints have 15 bits: %x of -1 is 7fff. *)

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let sp = Printf.sprintf

let () =
  (* integers *)
  check "d" (sp "%d" 42 = "42" && sp "%d" (-7) = "-7" && sp "%d" 0 = "0");
  check "i" (sp "%i" 16383 = "16383" && sp "%i" (-16384) = "-16384");
  check "width" (sp "%5d|" 42 = "   42|" && sp "%-5d|" 42 = "42   |"
                 && sp "%05d" 42 = "00042" && sp "%3d" 12345 = "12345");
  check "width neg" (sp "%05d" (-42) = "-0042" && sp "%5d" (-42) = "  -42");
  check "star" (sp "%*d" 4 7 = "   7" && sp "%-*d|" 4 7 = "7   |");
  check "sign" (sp "%+d" 5 = "+5" && sp "%+d" (-5) = "-5" && sp "% d" 5 = " 5");
  check "prec" (sp "%.3d" 7 = "007");
  check "hex" (sp "%x" 255 = "ff" && sp "%X" 255 = "FF" && sp "%x" 0 = "0"
               && sp "%x" 4096 = "1000");
  check "hex flags" (sp "%#x" 255 = "0xff" && sp "%04x" 255 = "00ff"
                     && sp "%#x" 0 = "0");
  check "oct" (sp "%o" 8 = "10" && sp "%o" 0 = "0" && sp "%#o" 8 = "010");
  check "15 bit" (sp "%x" (-1) = "7fff" && sp "%u" (-1) = "32767"
                  && sp "%u" 5 = "5");
  (* strings, chars, bools *)
  check "s" (sp "%s" "abc" = "abc" && sp "[%s]" "" = "[]");
  check "s width" (sp "%5s|" "ab" = "   ab|" && sp "%-5s|" "ab" = "ab   |");
  check "c" (sp "%c%c" 'x' 'y' = "xy");
  check "S" (sp "%S" "hi" = "\"hi\"");
  check "B" (sp "%B" true = "true" && sp "%b" false = "false");
  check "percent" (sp "100%%" = "100%" && sp "%d%%" 5 = "5%");
  (* floats *)
  check "f" (sp "%f" 1.5 = "1.500000" && sp "%.3f" 2.0 = "2.000"
             && sp "%.0f" 3.0 = "3");
  check "f prec" (sp "%.2f" 3.14159 = "3.14" && sp "%.2f" 12345.678 = "12345.68"
                  && sp "%.2f" 100.0 = "100.00" && sp "%.2f" 0.05 = "0.05");
  check "f neg" (sp "%.2f" (-0.5) = "-0.50" && sp "%8.3f" (-1.5) = "  -1.500"
                 && sp "%+.1f" 2.0 = "+2.0");
  check "f zero" (sp "%.2f" 0.0 = "0.00");
  check "g F" (sp "%g" 1.5 = "1.5" && sp "%F" 2.0 = "2.");
  (* partial application and re-use *)
  let f = Printf.sprintf "<%d,%s>" in
  check "partial" (f 1 "a" ^ f 2 "b" = "<1,a><2,b>");
  let g = Printf.sprintf "%d-%d" 1 in
  check "partial 2" (g 2 ^ g 3 = "1-21-3");
  check "map" (String.concat "," (List.map (Printf.sprintf "%03d") [1; 22; 333])
               = "001,022,333");
  (* %a, %t *)
  check "a" (sp "%a" (fun () s -> s ^ "!") "hi" = "hi!");
  check "t" (sp "%t" (fun () -> "T") = "T");
  (* k functions, buffers *)
  check "ksprintf" (Printf.ksprintf (fun s -> String.length s) "%d%d" 1 2 = 2);
  let b = Buffer.create 16 in
  Printf.bprintf b "%d+%d" 1 2;
  Printf.bprintf b "=%d" 3;
  check "bprintf" (Buffer.contents b = "1+2=3");
  check "ifprintf" (Printf.ifprintf () "%d %s" 1 "x" = ());
  (* unsupported formats raise at the application of the format *)
  check "unsupported e"
    (try ignore (sp "%e" 1.0); false with Invalid_argument _ -> true);
  check "unsupported ld"
    (try ignore (sp "%ld" 1l); false with Invalid_argument _ -> true);
  check "unsupported #d"
    (try ignore (sp "%#d" 1); false with Invalid_argument _ -> true);
  (* printing *)
  Printf.printf "printf: %d %s %.2f\n" 42 "ok" 3.14159;
  print_string (if !failed = 0 then "ALL OK" else "FAILED");
  print_newline ()
