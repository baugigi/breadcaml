(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f = try f () with _ -> fail (s ^ " EXN")
let raises_inv s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Invalid_argument _ -> () | _ -> fail (s ^ " BADEXN")
let raises_dz s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Division_by_zero -> () | _ -> fail (s ^ " BADEXN")
let finish t =
  print_string t;
  if !fails = 0 then print_string " OK" else print_string " FAIL";
  print_newline ()
(* ---- fine prelude ---- *)
let vals = [| 0l; 1l; (-1l); 2l; (-2l); 3l; 7l; 255l; 256l; 65535l; 65536l; 2147483647l; (-2147483648l); 2147483646l; (-2147483647l); 305419896l; (-559038737l); 1431655765l; (-1431655766l) |]
let row f a =
  let c = ref 0 in
  for j = 0 to 18 do
    let r = f a vals.(j) in
    c := (!c * 7 + Int32.to_int (Int32.logand r 16383l) * 1 + Int32.to_int (Int32.logand (Int32.shift_right_logical r 14) 16383l) * 3 + Int32.to_int (Int32.logand (Int32.shift_right_logical r 28) 16383l) * 11) land 16383
  done;
  !c
let chk name f e =
  for i = 0 to 18 do
    if row f vals.(i) <> e.(i) then fail (name ^ " row " ^ string_of_int i)
  done
let e_add = [| 13588; 4290; 11500; 13467; 16147; 4244; 120; 6576; 13737; 16174; 13104; 11108; 10636; 13163; 9242; 4256; 11001; 15066; 10352 |]
let e_sub = [| 10925; 6278; 8837; 2481; 1751; 9084; 11902; 12328; 16287; 15225; 9494; 11789; 11317; 13183; 9262; 11204; 13815; 12073; 7359 |]
let e_mul = [| 0; 13588; 10925; 11193; 88; 197; 2724; 1701; 10671; 9267; 11260; 5229; 13136; 9736; 2900; 11636; 13374; 13382; 13566 |]
let e_and = [| 0; 9086; 13588; 16254; 4502; 8956; 11672; 14640; 12032; 6373; 236; 8324; 5264; 15622; 14350; 10396; 8775; 7530; 6058 |]
let e_or = [| 13588; 11663; 6041; 11656; 7966; 9731; 2891; 6379; 16148; 15351; 980; 3729; 15900; 5654; 13975; 7614; 1389; 13533; 6096 |]
let e_xor = [| 13588; 2577; 8837; 11786; 3464; 775; 7603; 8123; 4116; 8978; 744; 11789; 10636; 6416; 16009; 13602; 8998; 6003; 38 |]
let e_div = [| 0; 7336; 104; 13014; 9290; 7363; 3503; 4838; 5315; 8455; 4575; 8396; 7494; 14542; 9431; 15992; 4035; 184; 2091 |]
let e_rem = [| 0; 10816; 4672; 12144; 4864; 12027; 10815; 2514; 7682; 12224; 4743; 8559; 3358; 14919; 12129; 2922; 13679; 12160; 8874 |]
let e_shl = [| 0; 2862; 7509; 15164; 4647; 1642; 610; 15970; 12176; 4753; 2296; 6517; 992; 3655; 3854; 2316; 9357; 14031; 9862 |]
let e_shr = [| 0; 756; 6041; 15824; 5285; 196; 8347; 711; 8930; 1185; 551; 2907; 3134; 2151; 3890; 16320; 5605; 15322; 7103 |]
let e_shru = [| 0; 756; 6996; 15824; 6240; 196; 8347; 711; 8930; 1185; 551; 2907; 4089; 2151; 4845; 16320; 6560; 15322; 8058 |]
let e_neg = [| 0; 6041; 7161; 15264; 14322; 8103; 12227; 5771; 14994; 5066; 14289; 14737; 7576; 5514; 14849; 8780; 242; 5727; 14636 |]
let e_lognot = [| 6041; 15264; 0; 8103; 7161; 942; 5066; 14994; 7833; 14289; 2029; 7576; 14849; 14737; 7688; 1619; 9465; 14950; 7475 |]
let e_cmp = [| 10632; 11346; 88; 5186; 8232; 12082; 2904; 6274; 9096; 4818; 8888; 2818; 4456; 13490; 14072; 450; 8424; 16050; 16312 |]
let e_succ = [| 7161; 14322; 0; 5099; 6041; 12260; 8136; 14592; 5369; 4012; 11173; 7576; 14737; 14849; 5514; 11583; 3737; 14636; 5727 |]
let e_pred = [| 6041; 0; 15264; 7161; 8103; 14322; 10198; 270; 7431; 975; 8136; 7688; 14849; 527; 7576; 13645; 5799; 314; 7789 |]
let basic () =
  check "i32 add" (Int32.to_int (Int32.add 100l 200l) = 300);
  check "i32 sub" (Int32.to_int (Int32.sub 100l 300l) = -200);
  check "i32 mul" (Int32.to_int (Int32.mul 100l 100l) = 10000);
  check "i32 div" (Int32.to_int (Int32.div 100l 7l) = 14);
  check "i32 rem" (Int32.to_int (Int32.rem 100l 7l) = 2);
  check "i32 div neg" (Int32.to_int (Int32.div (-100l) 7l) = -14);
  check "i32 rem neg" (Int32.to_int (Int32.rem (-100l) 7l) = -2);
  check "i32 div by neg" (Int32.to_int (Int32.div 100l (-7l)) = -14);
  check "i32 shl" (Int32.to_int (Int32.shift_left 1l 10) = 1024);
  check "i32 shr" (Int32.to_int (Int32.shift_right 4096l 4) = 256);
  check "i32 shr neg" (Int32.to_int (Int32.shift_right (-4096l) 4) = -256);
  check "i32 shru 28" (Int32.to_int (Int32.shift_right_logical (-1l) 28) = 15);
  check "i32 shl 31" (Int32.compare (Int32.shift_left 1l 31) (-2147483648l) = 0);
  check "i32 min/-1" (Int32.compare (Int32.div (-2147483648l) (-1l)) (-2147483648l) = 0);
  check "i32 min rem -1" (Int32.to_int (Int32.rem (-2147483648l) (-1l)) = 0);
  raises_dz "i32 div0" (fun () -> Int32.div 5l (Int32.sub 3l 3l));
  raises_dz "i32 rem0" (fun () -> Int32.rem 5l (Int32.sub 3l 3l));
  check "i32 max+1" (Int32.compare (Int32.add 2147483647l 1l) (-2147483648l) = 0);
  check "i32 min-1" (Int32.compare (Int32.sub (-2147483648l) 1l) 2147483647l = 0);
  check "i32 mul ovf" (Int32.compare (Int32.mul 65536l 65536l) 0l = 0);
  check "i32 mul 46341" (Int32.compare (Int32.mul 46341l 46341l) (-2147479015l) = 0)
let conv () =
  let l = [0; 1; -1; 2; 127; 128; 255; 256; 16383; -16384; -16383; 8192; -8193] in
  List.iter (fun n ->
    checkn "i32 of_int/to_int " n (Int32.to_int (Int32.of_int n) = n)) l;
  check "i32 of_int -1 hi" (Int32.to_int (Int32.shift_right_logical (Int32.of_int (-1)) 28) = 15);
  check "i32 of_int -1 eq" (Int32.compare (Int32.of_int (-1)) (-1l) = 0);
  check "i32 of_int min" (Int32.compare (Int32.of_int (-16384)) (-16384l) = 0);
  check "i32 of_int max" (Int32.compare (Int32.of_int 16383) 16383l = 0);
  check "i32 cmp 0 min" (Int32.compare 0l (-2147483648l) > 0 && Int32.compare (-2147483648l) 0l < 0);
  check "i32 cmp top+128" (Int32.compare 2130706432l (-16777216l) > 0 && Int32.compare (-16777216l) 2130706432l < 0);
  check "i32 cmp 1 min+1" (Int32.compare 1l (-2147483647l) > 0 && Int32.compare 5l (-2147483643l) > 0);
  check "i32 to_int low15" (Int32.to_int 65537l = 1);
  check "i32 to_int low15b" (Int32.to_int 32768l = 0 && Int32.to_int 16384l = -16384)
let tostr () =
  check "i32 to_string 0" (String.equal (Int32.to_string 0l) "0");
  check "i32 to_string 1" (String.equal (Int32.to_string 1l) "1");
  check "i32 to_string -1" (String.equal (Int32.to_string (-1l)) "-1");
  check "i32 to_string 12345" (String.equal (Int32.to_string 12345l) "12345");
  check "i32 to_string -12345" (String.equal (Int32.to_string (-12345l)) "-12345");
  check "i32 to_string 99999" (String.equal (Int32.to_string 99999l) "99999");
  check "i32 to_string 65536" (String.equal (Int32.to_string 65536l) "65536");
  check "i32 to_string 2147483647" (String.equal (Int32.to_string 2147483647l) "2147483647");
  check "i32 to_string -2147483648" (String.equal (Int32.to_string (-2147483648l)) "-2147483648");
  ()
let ofloat () =
  check "i32 of_float 0.0" (Int32.compare (Int32.of_float 0.0) 0l = 0);
  check "i32 of_float 1.0" (Int32.compare (Int32.of_float 1.0) 1l = 0);
  check "i32 of_float -1.0" (Int32.compare (Int32.of_float (-1.0)) (-1l) = 0);
  check "i32 of_float 2.5" (Int32.compare (Int32.of_float 2.5) 2l = 0);
  check "i32 of_float -2.5" (Int32.compare (Int32.of_float (-2.5)) (-2l) = 0);
  check "i32 of_float 0.99" (Int32.compare (Int32.of_float 0.99) 0l = 0);
  check "i32 of_float -0.99" (Int32.compare (Int32.of_float (-0.99)) 0l = 0);
  check "i32 of_float 255.0" (Int32.compare (Int32.of_float 255.0) 255l = 0);
  check "i32 of_float 65536.0" (Int32.compare (Int32.of_float 65536.0) 65536l = 0);
  check "i32 of_float 1000000000.0" (Int32.compare (Int32.of_float 1000000000.0) 1000000000l = 0);
  check "i32 of_float -1000000000.0" (Int32.compare (Int32.of_float (-1000000000.0)) (-1000000000l) = 0);
  check "i32 of_float 2147483647.0" (Int32.compare (Int32.of_float 2147483647.0) 2147483647l = 0);
  check "i32 of_float -2147483648.0" (Int32.compare (Int32.of_float (-2147483648.0)) (-2147483648l) = 0);
  check "i32 of_float 123456.75" (Int32.compare (Int32.of_float 123456.75) 123456l = 0);
  ()
let () =
  run "basic" basic;
  run "conv" conv;
  run "tostr" tostr;
  run "ofloat" ofloat;
  run "add" (fun () -> chk "Int32 add" (fun a b -> Int32.add a b) e_add);
  run "sub" (fun () -> chk "Int32 sub" (fun a b -> Int32.sub a b) e_sub);
  run "mul" (fun () -> chk "Int32 mul" (fun a b -> Int32.mul a b) e_mul);
  run "and" (fun () -> chk "Int32 and" (fun a b -> Int32.logand a b) e_and);
  run "or" (fun () -> chk "Int32 or" (fun a b -> Int32.logor a b) e_or);
  run "xor" (fun () -> chk "Int32 xor" (fun a b -> Int32.logxor a b) e_xor);
  run "div" (fun () -> chk "Int32 div" (fun a b -> if Int32.compare b 0l = 0 then 0l else Int32.div a b) e_div);
  run "rem" (fun () -> chk "Int32 rem" (fun a b -> if Int32.compare b 0l = 0 then 0l else Int32.rem a b) e_rem);
  run "shl" (fun () -> chk "Int32 shl" (fun a b -> Int32.shift_left a (Int32.to_int b land 31)) e_shl);
  run "shr" (fun () -> chk "Int32 shr" (fun a b -> Int32.shift_right a (Int32.to_int b land 31)) e_shr);
  run "shru" (fun () -> chk "Int32 shru" (fun a b -> Int32.shift_right_logical a (Int32.to_int b land 31)) e_shru);
  run "neg" (fun () -> chk "Int32 neg" (fun a _ -> Int32.neg a) e_neg);
  run "lognot" (fun () -> chk "Int32 lognot" (fun a _ -> Int32.lognot a) e_lognot);
  run "cmp" (fun () -> chk "Int32 cmp" (fun a b -> Int32.of_int (Int32.compare a b)) e_cmp);
  run "succ" (fun () -> chk "Int32 succ" (fun a _ -> Int32.succ a) e_succ);
  run "pred" (fun () -> chk "Int32 pred" (fun a _ -> Int32.pred a) e_pred);
  finish "T10A"
