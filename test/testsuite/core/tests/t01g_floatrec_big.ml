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
type f84 = { mutable y84_0: float; mutable y84_1: float; mutable y84_2: float; mutable y84_3: float; mutable y84_4: float; mutable y84_5: float; mutable y84_6: float; mutable y84_7: float; mutable y84_8: float; mutable y84_9: float; mutable y84_10: float; mutable y84_11: float; mutable y84_12: float; mutable y84_13: float; mutable y84_14: float; mutable y84_15: float; mutable y84_16: float; mutable y84_17: float; mutable y84_18: float; mutable y84_19: float; mutable y84_20: float; mutable y84_21: float; mutable y84_22: float; mutable y84_23: float; mutable y84_24: float; mutable y84_25: float; mutable y84_26: float; mutable y84_27: float; mutable y84_28: float; mutable y84_29: float; mutable y84_30: float; mutable y84_31: float; mutable y84_32: float; mutable y84_33: float; mutable y84_34: float; mutable y84_35: float; mutable y84_36: float; mutable y84_37: float; mutable y84_38: float; mutable y84_39: float; mutable y84_40: float; mutable y84_41: float; mutable y84_42: float; mutable y84_43: float; mutable y84_44: float; mutable y84_45: float; mutable y84_46: float; mutable y84_47: float; mutable y84_48: float; mutable y84_49: float; mutable y84_50: float; mutable y84_51: float; mutable y84_52: float; mutable y84_53: float; mutable y84_54: float; mutable y84_55: float; mutable y84_56: float; mutable y84_57: float; mutable y84_58: float; mutable y84_59: float; mutable y84_60: float; mutable y84_61: float; mutable y84_62: float; mutable y84_63: float; mutable y84_64: float; mutable y84_65: float; mutable y84_66: float; mutable y84_67: float; mutable y84_68: float; mutable y84_69: float; mutable y84_70: float; mutable y84_71: float; mutable y84_72: float; mutable y84_73: float; mutable y84_74: float; mutable y84_75: float; mutable y84_76: float; mutable y84_77: float; mutable y84_78: float; mutable y84_79: float; mutable y84_80: float; mutable y84_81: float; mutable y84_82: float; mutable y84_83: float }
let mk84 a = { y84_0 = a +. 0.0; y84_1 = a +. 1.0; y84_2 = a +. 2.0; y84_3 = a +. 3.0; y84_4 = a +. 4.0; y84_5 = a +. 5.0; y84_6 = a +. 6.0; y84_7 = a +. 7.0; y84_8 = a +. 8.0; y84_9 = a +. 9.0; y84_10 = a +. 10.0; y84_11 = a +. 11.0; y84_12 = a +. 12.0; y84_13 = a +. 13.0; y84_14 = a +. 14.0; y84_15 = a +. 15.0; y84_16 = a +. 0.0; y84_17 = a +. 1.0; y84_18 = a +. 2.0; y84_19 = a +. 3.0; y84_20 = a +. 4.0; y84_21 = a +. 5.0; y84_22 = a +. 6.0; y84_23 = a +. 7.0; y84_24 = a +. 8.0; y84_25 = a +. 9.0; y84_26 = a +. 10.0; y84_27 = a +. 11.0; y84_28 = a +. 12.0; y84_29 = a +. 13.0; y84_30 = a +. 14.0; y84_31 = a +. 15.0; y84_32 = a +. 0.0; y84_33 = a +. 1.0; y84_34 = a +. 2.0; y84_35 = a +. 3.0; y84_36 = a +. 4.0; y84_37 = a +. 5.0; y84_38 = a +. 6.0; y84_39 = a +. 7.0; y84_40 = a +. 8.0; y84_41 = a +. 9.0; y84_42 = a +. 10.0; y84_43 = a +. 11.0; y84_44 = a +. 12.0; y84_45 = a +. 13.0; y84_46 = a +. 14.0; y84_47 = a +. 15.0; y84_48 = a +. 0.0; y84_49 = a +. 1.0; y84_50 = a +. 2.0; y84_51 = a +. 3.0; y84_52 = a +. 4.0; y84_53 = a +. 5.0; y84_54 = a +. 6.0; y84_55 = a +. 7.0; y84_56 = a +. 8.0; y84_57 = a +. 9.0; y84_58 = a +. 10.0; y84_59 = a +. 11.0; y84_60 = a +. 12.0; y84_61 = a +. 13.0; y84_62 = a +. 14.0; y84_63 = a +. 15.0; y84_64 = a +. 0.0; y84_65 = a +. 1.0; y84_66 = a +. 2.0; y84_67 = a +. 3.0; y84_68 = a +. 4.0; y84_69 = a +. 5.0; y84_70 = a +. 6.0; y84_71 = a +. 7.0; y84_72 = a +. 8.0; y84_73 = a +. 9.0; y84_74 = a +. 10.0; y84_75 = a +. 11.0; y84_76 = a +. 12.0; y84_77 = a +. 13.0; y84_78 = a +. 14.0; y84_79 = a +. 15.0; y84_80 = a +. 0.0; y84_81 = a +. 1.0; y84_82 = a +. 2.0; y84_83 = a +. 3.0 }
let sum84 r = r.y84_0 +. r.y84_1 +. r.y84_2 +. r.y84_3 +. r.y84_4 +. r.y84_5 +. r.y84_6 +. r.y84_7 +. r.y84_8 +. r.y84_9 +. r.y84_10 +. r.y84_11 +. r.y84_12 +. r.y84_13 +. r.y84_14 +. r.y84_15 +. r.y84_16 +. r.y84_17 +. r.y84_18 +. r.y84_19 +. r.y84_20 +. r.y84_21 +. r.y84_22 +. r.y84_23 +. r.y84_24 +. r.y84_25 +. r.y84_26 +. r.y84_27 +. r.y84_28 +. r.y84_29 +. r.y84_30 +. r.y84_31 +. r.y84_32 +. r.y84_33 +. r.y84_34 +. r.y84_35 +. r.y84_36 +. r.y84_37 +. r.y84_38 +. r.y84_39 +. r.y84_40 +. r.y84_41 +. r.y84_42 +. r.y84_43 +. r.y84_44 +. r.y84_45 +. r.y84_46 +. r.y84_47 +. r.y84_48 +. r.y84_49 +. r.y84_50 +. r.y84_51 +. r.y84_52 +. r.y84_53 +. r.y84_54 +. r.y84_55 +. r.y84_56 +. r.y84_57 +. r.y84_58 +. r.y84_59 +. r.y84_60 +. r.y84_61 +. r.y84_62 +. r.y84_63 +. r.y84_64 +. r.y84_65 +. r.y84_66 +. r.y84_67 +. r.y84_68 +. r.y84_69 +. r.y84_70 +. r.y84_71 +. r.y84_72 +. r.y84_73 +. r.y84_74 +. r.y84_75 +. r.y84_76 +. r.y84_77 +. r.y84_78 +. r.y84_79 +. r.y84_80 +. r.y84_81 +. r.y84_82 +. r.y84_83
let mka84 a = [| a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0 |]
let suma84 x = x.(0) +. x.(1) +. x.(2) +. x.(3) +. x.(4) +. x.(5) +. x.(6) +. x.(7) +. x.(8) +. x.(9) +. x.(10) +. x.(11) +. x.(12) +. x.(13) +. x.(14) +. x.(15) +. x.(16) +. x.(17) +. x.(18) +. x.(19) +. x.(20) +. x.(21) +. x.(22) +. x.(23) +. x.(24) +. x.(25) +. x.(26) +. x.(27) +. x.(28) +. x.(29) +. x.(30) +. x.(31) +. x.(32) +. x.(33) +. x.(34) +. x.(35) +. x.(36) +. x.(37) +. x.(38) +. x.(39) +. x.(40) +. x.(41) +. x.(42) +. x.(43) +. x.(44) +. x.(45) +. x.(46) +. x.(47) +. x.(48) +. x.(49) +. x.(50) +. x.(51) +. x.(52) +. x.(53) +. x.(54) +. x.(55) +. x.(56) +. x.(57) +. x.(58) +. x.(59) +. x.(60) +. x.(61) +. x.(62) +. x.(63) +. x.(64) +. x.(65) +. x.(66) +. x.(67) +. x.(68) +. x.(69) +. x.(70) +. x.(71) +. x.(72) +. x.(73) +. x.(74) +. x.(75) +. x.(76) +. x.(77) +. x.(78) +. x.(79) +. x.(80) +. x.(81) +. x.(82) +. x.(83)
let t84 () =
  let r = mk84 2.0 in
  check "f84 sum0" (sum84 r = 774.0);
  check "f84.y0" (r.y84_0 = 2.0);
  check "f84.y1" (r.y84_1 = 3.0);
  check "f84.y2" (r.y84_2 = 4.0);
  check "f84.y3" (r.y84_3 = 5.0);
  check "f84.y4" (r.y84_4 = 6.0);
  check "f84.y42" (r.y84_42 = 12.0);
  check "f84.y81" (r.y84_81 = 3.0);
  check "f84.y82" (r.y84_82 = 4.0);
  check "f84.y83" (r.y84_83 = 5.0);
  r.y84_0 <- 100.5;
  r.y84_1 <- 101.5;
  r.y84_2 <- 102.5;
  r.y84_3 <- 103.5;
  r.y84_4 <- 104.5;
  r.y84_42 <- 100.5;
  r.y84_81 <- 104.5;
  r.y84_82 <- 105.5;
  r.y84_83 <- 106.5;
  check "f84 sum1" (sum84 r = 1659.5);
  check "f84.y0 b" (r.y84_0 = 100.5);
  check "f84.y1 b" (r.y84_1 = 101.5);
  check "f84.y2 b" (r.y84_2 = 102.5);
  check "f84.y3 b" (r.y84_3 = 103.5);
  check "f84.y4 b" (r.y84_4 = 104.5);
  check "f84.y42 b" (r.y84_42 = 100.5);
  check "f84.y81 b" (r.y84_81 = 104.5);
  check "f84.y82 b" (r.y84_82 = 105.5);
  check "f84.y83 b" (r.y84_83 = 106.5);
  for it = 1 to 40 do checkn "f84 sum loop " it (sum84 r = 1659.5) done;
  let x = mka84 2.0 in
  check "arrlit len 84" (Array.length x = 84);
  check "arrlit sum0 84" (suma84 x = 774.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  x.(2) <- 102.5;
  x.(3) <- 103.5;
  x.(4) <- 104.5;
  x.(42) <- 100.5;
  x.(81) <- 104.5;
  x.(82) <- 105.5;
  x.(83) <- 106.5;
  check "arrlit sum1 84" (suma84 x = 1659.5);
  for it = 1 to 40 do checkn "arrlit loop " it (suma84 x = 1659.5) done
type f85 = { mutable y85_0: float; mutable y85_1: float; mutable y85_2: float; mutable y85_3: float; mutable y85_4: float; mutable y85_5: float; mutable y85_6: float; mutable y85_7: float; mutable y85_8: float; mutable y85_9: float; mutable y85_10: float; mutable y85_11: float; mutable y85_12: float; mutable y85_13: float; mutable y85_14: float; mutable y85_15: float; mutable y85_16: float; mutable y85_17: float; mutable y85_18: float; mutable y85_19: float; mutable y85_20: float; mutable y85_21: float; mutable y85_22: float; mutable y85_23: float; mutable y85_24: float; mutable y85_25: float; mutable y85_26: float; mutable y85_27: float; mutable y85_28: float; mutable y85_29: float; mutable y85_30: float; mutable y85_31: float; mutable y85_32: float; mutable y85_33: float; mutable y85_34: float; mutable y85_35: float; mutable y85_36: float; mutable y85_37: float; mutable y85_38: float; mutable y85_39: float; mutable y85_40: float; mutable y85_41: float; mutable y85_42: float; mutable y85_43: float; mutable y85_44: float; mutable y85_45: float; mutable y85_46: float; mutable y85_47: float; mutable y85_48: float; mutable y85_49: float; mutable y85_50: float; mutable y85_51: float; mutable y85_52: float; mutable y85_53: float; mutable y85_54: float; mutable y85_55: float; mutable y85_56: float; mutable y85_57: float; mutable y85_58: float; mutable y85_59: float; mutable y85_60: float; mutable y85_61: float; mutable y85_62: float; mutable y85_63: float; mutable y85_64: float; mutable y85_65: float; mutable y85_66: float; mutable y85_67: float; mutable y85_68: float; mutable y85_69: float; mutable y85_70: float; mutable y85_71: float; mutable y85_72: float; mutable y85_73: float; mutable y85_74: float; mutable y85_75: float; mutable y85_76: float; mutable y85_77: float; mutable y85_78: float; mutable y85_79: float; mutable y85_80: float; mutable y85_81: float; mutable y85_82: float; mutable y85_83: float; mutable y85_84: float }
let mk85 a = { y85_0 = a +. 0.0; y85_1 = a +. 1.0; y85_2 = a +. 2.0; y85_3 = a +. 3.0; y85_4 = a +. 4.0; y85_5 = a +. 5.0; y85_6 = a +. 6.0; y85_7 = a +. 7.0; y85_8 = a +. 8.0; y85_9 = a +. 9.0; y85_10 = a +. 10.0; y85_11 = a +. 11.0; y85_12 = a +. 12.0; y85_13 = a +. 13.0; y85_14 = a +. 14.0; y85_15 = a +. 15.0; y85_16 = a +. 0.0; y85_17 = a +. 1.0; y85_18 = a +. 2.0; y85_19 = a +. 3.0; y85_20 = a +. 4.0; y85_21 = a +. 5.0; y85_22 = a +. 6.0; y85_23 = a +. 7.0; y85_24 = a +. 8.0; y85_25 = a +. 9.0; y85_26 = a +. 10.0; y85_27 = a +. 11.0; y85_28 = a +. 12.0; y85_29 = a +. 13.0; y85_30 = a +. 14.0; y85_31 = a +. 15.0; y85_32 = a +. 0.0; y85_33 = a +. 1.0; y85_34 = a +. 2.0; y85_35 = a +. 3.0; y85_36 = a +. 4.0; y85_37 = a +. 5.0; y85_38 = a +. 6.0; y85_39 = a +. 7.0; y85_40 = a +. 8.0; y85_41 = a +. 9.0; y85_42 = a +. 10.0; y85_43 = a +. 11.0; y85_44 = a +. 12.0; y85_45 = a +. 13.0; y85_46 = a +. 14.0; y85_47 = a +. 15.0; y85_48 = a +. 0.0; y85_49 = a +. 1.0; y85_50 = a +. 2.0; y85_51 = a +. 3.0; y85_52 = a +. 4.0; y85_53 = a +. 5.0; y85_54 = a +. 6.0; y85_55 = a +. 7.0; y85_56 = a +. 8.0; y85_57 = a +. 9.0; y85_58 = a +. 10.0; y85_59 = a +. 11.0; y85_60 = a +. 12.0; y85_61 = a +. 13.0; y85_62 = a +. 14.0; y85_63 = a +. 15.0; y85_64 = a +. 0.0; y85_65 = a +. 1.0; y85_66 = a +. 2.0; y85_67 = a +. 3.0; y85_68 = a +. 4.0; y85_69 = a +. 5.0; y85_70 = a +. 6.0; y85_71 = a +. 7.0; y85_72 = a +. 8.0; y85_73 = a +. 9.0; y85_74 = a +. 10.0; y85_75 = a +. 11.0; y85_76 = a +. 12.0; y85_77 = a +. 13.0; y85_78 = a +. 14.0; y85_79 = a +. 15.0; y85_80 = a +. 0.0; y85_81 = a +. 1.0; y85_82 = a +. 2.0; y85_83 = a +. 3.0; y85_84 = a +. 4.0 }
let sum85 r = r.y85_0 +. r.y85_1 +. r.y85_2 +. r.y85_3 +. r.y85_4 +. r.y85_5 +. r.y85_6 +. r.y85_7 +. r.y85_8 +. r.y85_9 +. r.y85_10 +. r.y85_11 +. r.y85_12 +. r.y85_13 +. r.y85_14 +. r.y85_15 +. r.y85_16 +. r.y85_17 +. r.y85_18 +. r.y85_19 +. r.y85_20 +. r.y85_21 +. r.y85_22 +. r.y85_23 +. r.y85_24 +. r.y85_25 +. r.y85_26 +. r.y85_27 +. r.y85_28 +. r.y85_29 +. r.y85_30 +. r.y85_31 +. r.y85_32 +. r.y85_33 +. r.y85_34 +. r.y85_35 +. r.y85_36 +. r.y85_37 +. r.y85_38 +. r.y85_39 +. r.y85_40 +. r.y85_41 +. r.y85_42 +. r.y85_43 +. r.y85_44 +. r.y85_45 +. r.y85_46 +. r.y85_47 +. r.y85_48 +. r.y85_49 +. r.y85_50 +. r.y85_51 +. r.y85_52 +. r.y85_53 +. r.y85_54 +. r.y85_55 +. r.y85_56 +. r.y85_57 +. r.y85_58 +. r.y85_59 +. r.y85_60 +. r.y85_61 +. r.y85_62 +. r.y85_63 +. r.y85_64 +. r.y85_65 +. r.y85_66 +. r.y85_67 +. r.y85_68 +. r.y85_69 +. r.y85_70 +. r.y85_71 +. r.y85_72 +. r.y85_73 +. r.y85_74 +. r.y85_75 +. r.y85_76 +. r.y85_77 +. r.y85_78 +. r.y85_79 +. r.y85_80 +. r.y85_81 +. r.y85_82 +. r.y85_83 +. r.y85_84
let mka85 a = [| a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0; a +. 5.0; a +. 6.0; a +. 7.0; a +. 8.0; a +. 9.0; a +. 10.0; a +. 11.0; a +. 12.0; a +. 13.0; a +. 14.0; a +. 15.0; a +. 0.0; a +. 1.0; a +. 2.0; a +. 3.0; a +. 4.0 |]
let suma85 x = x.(0) +. x.(1) +. x.(2) +. x.(3) +. x.(4) +. x.(5) +. x.(6) +. x.(7) +. x.(8) +. x.(9) +. x.(10) +. x.(11) +. x.(12) +. x.(13) +. x.(14) +. x.(15) +. x.(16) +. x.(17) +. x.(18) +. x.(19) +. x.(20) +. x.(21) +. x.(22) +. x.(23) +. x.(24) +. x.(25) +. x.(26) +. x.(27) +. x.(28) +. x.(29) +. x.(30) +. x.(31) +. x.(32) +. x.(33) +. x.(34) +. x.(35) +. x.(36) +. x.(37) +. x.(38) +. x.(39) +. x.(40) +. x.(41) +. x.(42) +. x.(43) +. x.(44) +. x.(45) +. x.(46) +. x.(47) +. x.(48) +. x.(49) +. x.(50) +. x.(51) +. x.(52) +. x.(53) +. x.(54) +. x.(55) +. x.(56) +. x.(57) +. x.(58) +. x.(59) +. x.(60) +. x.(61) +. x.(62) +. x.(63) +. x.(64) +. x.(65) +. x.(66) +. x.(67) +. x.(68) +. x.(69) +. x.(70) +. x.(71) +. x.(72) +. x.(73) +. x.(74) +. x.(75) +. x.(76) +. x.(77) +. x.(78) +. x.(79) +. x.(80) +. x.(81) +. x.(82) +. x.(83) +. x.(84)
let t85 () =
  let r = mk85 2.0 in
  check "f85 sum0" (sum85 r = 780.0);
  check "f85.y0" (r.y85_0 = 2.0);
  check "f85.y1" (r.y85_1 = 3.0);
  check "f85.y2" (r.y85_2 = 4.0);
  check "f85.y3" (r.y85_3 = 5.0);
  check "f85.y4" (r.y85_4 = 6.0);
  check "f85.y42" (r.y85_42 = 12.0);
  check "f85.y82" (r.y85_82 = 4.0);
  check "f85.y83" (r.y85_83 = 5.0);
  check "f85.y84" (r.y85_84 = 6.0);
  r.y85_0 <- 100.5;
  r.y85_1 <- 101.5;
  r.y85_2 <- 102.5;
  r.y85_3 <- 103.5;
  r.y85_4 <- 104.5;
  r.y85_42 <- 100.5;
  r.y85_82 <- 105.5;
  r.y85_83 <- 106.5;
  r.y85_84 <- 100.5;
  check "f85 sum1" (sum85 r = 1658.5);
  check "f85.y0 b" (r.y85_0 = 100.5);
  check "f85.y1 b" (r.y85_1 = 101.5);
  check "f85.y2 b" (r.y85_2 = 102.5);
  check "f85.y3 b" (r.y85_3 = 103.5);
  check "f85.y4 b" (r.y85_4 = 104.5);
  check "f85.y42 b" (r.y85_42 = 100.5);
  check "f85.y82 b" (r.y85_82 = 105.5);
  check "f85.y83 b" (r.y85_83 = 106.5);
  check "f85.y84 b" (r.y85_84 = 100.5);
  for it = 1 to 40 do checkn "f85 sum loop " it (sum85 r = 1658.5) done;
  let x = mka85 2.0 in
  check "arrlit len 85" (Array.length x = 85);
  check "arrlit sum0 85" (suma85 x = 780.0);
  x.(0) <- 100.5;
  x.(1) <- 101.5;
  x.(2) <- 102.5;
  x.(3) <- 103.5;
  x.(4) <- 104.5;
  x.(42) <- 100.5;
  x.(82) <- 105.5;
  x.(83) <- 106.5;
  x.(84) <- 100.5;
  check "arrlit sum1 85" (suma85 x = 1658.5);
  for it = 1 to 40 do checkn "arrlit loop " it (suma85 x = 1658.5) done
let () =
  run "f84" t84;
  run "f85" t85;
  finish "T01G"
