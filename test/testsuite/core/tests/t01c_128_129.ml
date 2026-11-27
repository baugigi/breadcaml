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
type r128 = { mutable x128_0: int; mutable x128_1: int; mutable x128_2: int; mutable x128_3: int; mutable x128_4: int; mutable x128_5: int; mutable x128_6: int; mutable x128_7: int; mutable x128_8: int; mutable x128_9: int; mutable x128_10: int; mutable x128_11: int; mutable x128_12: int; mutable x128_13: int; mutable x128_14: int; mutable x128_15: int; mutable x128_16: int; mutable x128_17: int; mutable x128_18: int; mutable x128_19: int; mutable x128_20: int; mutable x128_21: int; mutable x128_22: int; mutable x128_23: int; mutable x128_24: int; mutable x128_25: int; mutable x128_26: int; mutable x128_27: int; mutable x128_28: int; mutable x128_29: int; mutable x128_30: int; mutable x128_31: int; mutable x128_32: int; mutable x128_33: int; mutable x128_34: int; mutable x128_35: int; mutable x128_36: int; mutable x128_37: int; mutable x128_38: int; mutable x128_39: int; mutable x128_40: int; mutable x128_41: int; mutable x128_42: int; mutable x128_43: int; mutable x128_44: int; mutable x128_45: int; mutable x128_46: int; mutable x128_47: int; mutable x128_48: int; mutable x128_49: int; mutable x128_50: int; mutable x128_51: int; mutable x128_52: int; mutable x128_53: int; mutable x128_54: int; mutable x128_55: int; mutable x128_56: int; mutable x128_57: int; mutable x128_58: int; mutable x128_59: int; mutable x128_60: int; mutable x128_61: int; mutable x128_62: int; mutable x128_63: int; mutable x128_64: int; mutable x128_65: int; mutable x128_66: int; mutable x128_67: int; mutable x128_68: int; mutable x128_69: int; mutable x128_70: int; mutable x128_71: int; mutable x128_72: int; mutable x128_73: int; mutable x128_74: int; mutable x128_75: int; mutable x128_76: int; mutable x128_77: int; mutable x128_78: int; mutable x128_79: int; mutable x128_80: int; mutable x128_81: int; mutable x128_82: int; mutable x128_83: int; mutable x128_84: int; mutable x128_85: int; mutable x128_86: int; mutable x128_87: int; mutable x128_88: int; mutable x128_89: int; mutable x128_90: int; mutable x128_91: int; mutable x128_92: int; mutable x128_93: int; mutable x128_94: int; mutable x128_95: int; mutable x128_96: int; mutable x128_97: int; mutable x128_98: int; mutable x128_99: int; mutable x128_100: int; mutable x128_101: int; mutable x128_102: int; mutable x128_103: int; mutable x128_104: int; mutable x128_105: int; mutable x128_106: int; mutable x128_107: int; mutable x128_108: int; mutable x128_109: int; mutable x128_110: int; mutable x128_111: int; mutable x128_112: int; mutable x128_113: int; mutable x128_114: int; mutable x128_115: int; mutable x128_116: int; mutable x128_117: int; mutable x128_118: int; mutable x128_119: int; mutable x128_120: int; mutable x128_121: int; mutable x128_122: int; mutable x128_123: int; mutable x128_124: int; mutable x128_125: int; mutable x128_126: int; mutable x128_127: int }
let mk128 a = { x128_0 = a + 0; x128_1 = a + 1; x128_2 = a + 2; x128_3 = a + 3; x128_4 = a + 4; x128_5 = a + 5; x128_6 = a + 6; x128_7 = a + 7; x128_8 = a + 8; x128_9 = a + 9; x128_10 = a + 10; x128_11 = a + 11; x128_12 = a + 12; x128_13 = a + 13; x128_14 = a + 14; x128_15 = a + 15; x128_16 = a + 0; x128_17 = a + 1; x128_18 = a + 2; x128_19 = a + 3; x128_20 = a + 4; x128_21 = a + 5; x128_22 = a + 6; x128_23 = a + 7; x128_24 = a + 8; x128_25 = a + 9; x128_26 = a + 10; x128_27 = a + 11; x128_28 = a + 12; x128_29 = a + 13; x128_30 = a + 14; x128_31 = a + 15; x128_32 = a + 0; x128_33 = a + 1; x128_34 = a + 2; x128_35 = a + 3; x128_36 = a + 4; x128_37 = a + 5; x128_38 = a + 6; x128_39 = a + 7; x128_40 = a + 8; x128_41 = a + 9; x128_42 = a + 10; x128_43 = a + 11; x128_44 = a + 12; x128_45 = a + 13; x128_46 = a + 14; x128_47 = a + 15; x128_48 = a + 0; x128_49 = a + 1; x128_50 = a + 2; x128_51 = a + 3; x128_52 = a + 4; x128_53 = a + 5; x128_54 = a + 6; x128_55 = a + 7; x128_56 = a + 8; x128_57 = a + 9; x128_58 = a + 10; x128_59 = a + 11; x128_60 = a + 12; x128_61 = a + 13; x128_62 = a + 14; x128_63 = a + 15; x128_64 = a + 0; x128_65 = a + 1; x128_66 = a + 2; x128_67 = a + 3; x128_68 = a + 4; x128_69 = a + 5; x128_70 = a + 6; x128_71 = a + 7; x128_72 = a + 8; x128_73 = a + 9; x128_74 = a + 10; x128_75 = a + 11; x128_76 = a + 12; x128_77 = a + 13; x128_78 = a + 14; x128_79 = a + 15; x128_80 = a + 0; x128_81 = a + 1; x128_82 = a + 2; x128_83 = a + 3; x128_84 = a + 4; x128_85 = a + 5; x128_86 = a + 6; x128_87 = a + 7; x128_88 = a + 8; x128_89 = a + 9; x128_90 = a + 10; x128_91 = a + 11; x128_92 = a + 12; x128_93 = a + 13; x128_94 = a + 14; x128_95 = a + 15; x128_96 = a + 0; x128_97 = a + 1; x128_98 = a + 2; x128_99 = a + 3; x128_100 = a + 4; x128_101 = a + 5; x128_102 = a + 6; x128_103 = a + 7; x128_104 = a + 8; x128_105 = a + 9; x128_106 = a + 10; x128_107 = a + 11; x128_108 = a + 12; x128_109 = a + 13; x128_110 = a + 14; x128_111 = a + 15; x128_112 = a + 0; x128_113 = a + 1; x128_114 = a + 2; x128_115 = a + 3; x128_116 = a + 4; x128_117 = a + 5; x128_118 = a + 6; x128_119 = a + 7; x128_120 = a + 8; x128_121 = a + 9; x128_122 = a + 10; x128_123 = a + 11; x128_124 = a + 12; x128_125 = a + 13; x128_126 = a + 14; x128_127 = a + 15 }
let sum128 r = r.x128_0 + r.x128_1 + r.x128_2 + r.x128_3 + r.x128_4 + r.x128_5 + r.x128_6 + r.x128_7 + r.x128_8 + r.x128_9 + r.x128_10 + r.x128_11 + r.x128_12 + r.x128_13 + r.x128_14 + r.x128_15 + r.x128_16 + r.x128_17 + r.x128_18 + r.x128_19 + r.x128_20 + r.x128_21 + r.x128_22 + r.x128_23 + r.x128_24 + r.x128_25 + r.x128_26 + r.x128_27 + r.x128_28 + r.x128_29 + r.x128_30 + r.x128_31 + r.x128_32 + r.x128_33 + r.x128_34 + r.x128_35 + r.x128_36 + r.x128_37 + r.x128_38 + r.x128_39 + r.x128_40 + r.x128_41 + r.x128_42 + r.x128_43 + r.x128_44 + r.x128_45 + r.x128_46 + r.x128_47 + r.x128_48 + r.x128_49 + r.x128_50 + r.x128_51 + r.x128_52 + r.x128_53 + r.x128_54 + r.x128_55 + r.x128_56 + r.x128_57 + r.x128_58 + r.x128_59 + r.x128_60 + r.x128_61 + r.x128_62 + r.x128_63 + r.x128_64 + r.x128_65 + r.x128_66 + r.x128_67 + r.x128_68 + r.x128_69 + r.x128_70 + r.x128_71 + r.x128_72 + r.x128_73 + r.x128_74 + r.x128_75 + r.x128_76 + r.x128_77 + r.x128_78 + r.x128_79 + r.x128_80 + r.x128_81 + r.x128_82 + r.x128_83 + r.x128_84 + r.x128_85 + r.x128_86 + r.x128_87 + r.x128_88 + r.x128_89 + r.x128_90 + r.x128_91 + r.x128_92 + r.x128_93 + r.x128_94 + r.x128_95 + r.x128_96 + r.x128_97 + r.x128_98 + r.x128_99 + r.x128_100 + r.x128_101 + r.x128_102 + r.x128_103 + r.x128_104 + r.x128_105 + r.x128_106 + r.x128_107 + r.x128_108 + r.x128_109 + r.x128_110 + r.x128_111 + r.x128_112 + r.x128_113 + r.x128_114 + r.x128_115 + r.x128_116 + r.x128_117 + r.x128_118 + r.x128_119 + r.x128_120 + r.x128_121 + r.x128_122 + r.x128_123 + r.x128_124 + r.x128_125 + r.x128_126 + r.x128_127
let t128 () =
  let r = mk128 5 in
  check "r128 size" (Obj.size (Obj.repr r) = 128);
  check "r128 tag" (Obj.tag (Obj.repr r) = 0);
  check "r128 sum0" (sum128 r = 1600);
  check "r128.x0" (r.x128_0 = 5);
  check "r128.x1" (r.x128_1 = 6);
  check "r128.x2" (r.x128_2 = 7);
  check "r128.x3" (r.x128_3 = 8);
  check "r128.x4" (r.x128_4 = 9);
  check "r128.x64" (r.x128_64 = 5);
  check "r128.x125" (r.x128_125 = 18);
  check "r128.x126" (r.x128_126 = 19);
  check "r128.x127" (r.x128_127 = 20);
  r.x128_0 <- 100;
  r.x128_1 <- 101;
  r.x128_2 <- 102;
  r.x128_3 <- 103;
  r.x128_4 <- 104;
  r.x128_64 <- 101;
  r.x128_125 <- 106;
  r.x128_126 <- 100;
  r.x128_127 <- 101;
  check "r128 sum1" (sum128 r = 2421);
  check "r128.x0 b" (r.x128_0 = 100);
  check "r128.x1 b" (r.x128_1 = 101);
  check "r128.x2 b" (r.x128_2 = 102);
  check "r128.x3 b" (r.x128_3 = 103);
  check "r128.x4 b" (r.x128_4 = 104);
  check "r128.x64 b" (r.x128_64 = 101);
  check "r128.x125 b" (r.x128_125 = 106);
  check "r128.x126 b" (r.x128_126 = 100);
  check "r128.x127 b" (r.x128_127 = 101)
type r129 = { mutable x129_0: int; mutable x129_1: int; mutable x129_2: int; mutable x129_3: int; mutable x129_4: int; mutable x129_5: int; mutable x129_6: int; mutable x129_7: int; mutable x129_8: int; mutable x129_9: int; mutable x129_10: int; mutable x129_11: int; mutable x129_12: int; mutable x129_13: int; mutable x129_14: int; mutable x129_15: int; mutable x129_16: int; mutable x129_17: int; mutable x129_18: int; mutable x129_19: int; mutable x129_20: int; mutable x129_21: int; mutable x129_22: int; mutable x129_23: int; mutable x129_24: int; mutable x129_25: int; mutable x129_26: int; mutable x129_27: int; mutable x129_28: int; mutable x129_29: int; mutable x129_30: int; mutable x129_31: int; mutable x129_32: int; mutable x129_33: int; mutable x129_34: int; mutable x129_35: int; mutable x129_36: int; mutable x129_37: int; mutable x129_38: int; mutable x129_39: int; mutable x129_40: int; mutable x129_41: int; mutable x129_42: int; mutable x129_43: int; mutable x129_44: int; mutable x129_45: int; mutable x129_46: int; mutable x129_47: int; mutable x129_48: int; mutable x129_49: int; mutable x129_50: int; mutable x129_51: int; mutable x129_52: int; mutable x129_53: int; mutable x129_54: int; mutable x129_55: int; mutable x129_56: int; mutable x129_57: int; mutable x129_58: int; mutable x129_59: int; mutable x129_60: int; mutable x129_61: int; mutable x129_62: int; mutable x129_63: int; mutable x129_64: int; mutable x129_65: int; mutable x129_66: int; mutable x129_67: int; mutable x129_68: int; mutable x129_69: int; mutable x129_70: int; mutable x129_71: int; mutable x129_72: int; mutable x129_73: int; mutable x129_74: int; mutable x129_75: int; mutable x129_76: int; mutable x129_77: int; mutable x129_78: int; mutable x129_79: int; mutable x129_80: int; mutable x129_81: int; mutable x129_82: int; mutable x129_83: int; mutable x129_84: int; mutable x129_85: int; mutable x129_86: int; mutable x129_87: int; mutable x129_88: int; mutable x129_89: int; mutable x129_90: int; mutable x129_91: int; mutable x129_92: int; mutable x129_93: int; mutable x129_94: int; mutable x129_95: int; mutable x129_96: int; mutable x129_97: int; mutable x129_98: int; mutable x129_99: int; mutable x129_100: int; mutable x129_101: int; mutable x129_102: int; mutable x129_103: int; mutable x129_104: int; mutable x129_105: int; mutable x129_106: int; mutable x129_107: int; mutable x129_108: int; mutable x129_109: int; mutable x129_110: int; mutable x129_111: int; mutable x129_112: int; mutable x129_113: int; mutable x129_114: int; mutable x129_115: int; mutable x129_116: int; mutable x129_117: int; mutable x129_118: int; mutable x129_119: int; mutable x129_120: int; mutable x129_121: int; mutable x129_122: int; mutable x129_123: int; mutable x129_124: int; mutable x129_125: int; mutable x129_126: int; mutable x129_127: int; mutable x129_128: int }
let mk129 a = { x129_0 = a + 0; x129_1 = a + 1; x129_2 = a + 2; x129_3 = a + 3; x129_4 = a + 4; x129_5 = a + 5; x129_6 = a + 6; x129_7 = a + 7; x129_8 = a + 8; x129_9 = a + 9; x129_10 = a + 10; x129_11 = a + 11; x129_12 = a + 12; x129_13 = a + 13; x129_14 = a + 14; x129_15 = a + 15; x129_16 = a + 0; x129_17 = a + 1; x129_18 = a + 2; x129_19 = a + 3; x129_20 = a + 4; x129_21 = a + 5; x129_22 = a + 6; x129_23 = a + 7; x129_24 = a + 8; x129_25 = a + 9; x129_26 = a + 10; x129_27 = a + 11; x129_28 = a + 12; x129_29 = a + 13; x129_30 = a + 14; x129_31 = a + 15; x129_32 = a + 0; x129_33 = a + 1; x129_34 = a + 2; x129_35 = a + 3; x129_36 = a + 4; x129_37 = a + 5; x129_38 = a + 6; x129_39 = a + 7; x129_40 = a + 8; x129_41 = a + 9; x129_42 = a + 10; x129_43 = a + 11; x129_44 = a + 12; x129_45 = a + 13; x129_46 = a + 14; x129_47 = a + 15; x129_48 = a + 0; x129_49 = a + 1; x129_50 = a + 2; x129_51 = a + 3; x129_52 = a + 4; x129_53 = a + 5; x129_54 = a + 6; x129_55 = a + 7; x129_56 = a + 8; x129_57 = a + 9; x129_58 = a + 10; x129_59 = a + 11; x129_60 = a + 12; x129_61 = a + 13; x129_62 = a + 14; x129_63 = a + 15; x129_64 = a + 0; x129_65 = a + 1; x129_66 = a + 2; x129_67 = a + 3; x129_68 = a + 4; x129_69 = a + 5; x129_70 = a + 6; x129_71 = a + 7; x129_72 = a + 8; x129_73 = a + 9; x129_74 = a + 10; x129_75 = a + 11; x129_76 = a + 12; x129_77 = a + 13; x129_78 = a + 14; x129_79 = a + 15; x129_80 = a + 0; x129_81 = a + 1; x129_82 = a + 2; x129_83 = a + 3; x129_84 = a + 4; x129_85 = a + 5; x129_86 = a + 6; x129_87 = a + 7; x129_88 = a + 8; x129_89 = a + 9; x129_90 = a + 10; x129_91 = a + 11; x129_92 = a + 12; x129_93 = a + 13; x129_94 = a + 14; x129_95 = a + 15; x129_96 = a + 0; x129_97 = a + 1; x129_98 = a + 2; x129_99 = a + 3; x129_100 = a + 4; x129_101 = a + 5; x129_102 = a + 6; x129_103 = a + 7; x129_104 = a + 8; x129_105 = a + 9; x129_106 = a + 10; x129_107 = a + 11; x129_108 = a + 12; x129_109 = a + 13; x129_110 = a + 14; x129_111 = a + 15; x129_112 = a + 0; x129_113 = a + 1; x129_114 = a + 2; x129_115 = a + 3; x129_116 = a + 4; x129_117 = a + 5; x129_118 = a + 6; x129_119 = a + 7; x129_120 = a + 8; x129_121 = a + 9; x129_122 = a + 10; x129_123 = a + 11; x129_124 = a + 12; x129_125 = a + 13; x129_126 = a + 14; x129_127 = a + 15; x129_128 = a + 0 }
let sum129 r = r.x129_0 + r.x129_1 + r.x129_2 + r.x129_3 + r.x129_4 + r.x129_5 + r.x129_6 + r.x129_7 + r.x129_8 + r.x129_9 + r.x129_10 + r.x129_11 + r.x129_12 + r.x129_13 + r.x129_14 + r.x129_15 + r.x129_16 + r.x129_17 + r.x129_18 + r.x129_19 + r.x129_20 + r.x129_21 + r.x129_22 + r.x129_23 + r.x129_24 + r.x129_25 + r.x129_26 + r.x129_27 + r.x129_28 + r.x129_29 + r.x129_30 + r.x129_31 + r.x129_32 + r.x129_33 + r.x129_34 + r.x129_35 + r.x129_36 + r.x129_37 + r.x129_38 + r.x129_39 + r.x129_40 + r.x129_41 + r.x129_42 + r.x129_43 + r.x129_44 + r.x129_45 + r.x129_46 + r.x129_47 + r.x129_48 + r.x129_49 + r.x129_50 + r.x129_51 + r.x129_52 + r.x129_53 + r.x129_54 + r.x129_55 + r.x129_56 + r.x129_57 + r.x129_58 + r.x129_59 + r.x129_60 + r.x129_61 + r.x129_62 + r.x129_63 + r.x129_64 + r.x129_65 + r.x129_66 + r.x129_67 + r.x129_68 + r.x129_69 + r.x129_70 + r.x129_71 + r.x129_72 + r.x129_73 + r.x129_74 + r.x129_75 + r.x129_76 + r.x129_77 + r.x129_78 + r.x129_79 + r.x129_80 + r.x129_81 + r.x129_82 + r.x129_83 + r.x129_84 + r.x129_85 + r.x129_86 + r.x129_87 + r.x129_88 + r.x129_89 + r.x129_90 + r.x129_91 + r.x129_92 + r.x129_93 + r.x129_94 + r.x129_95 + r.x129_96 + r.x129_97 + r.x129_98 + r.x129_99 + r.x129_100 + r.x129_101 + r.x129_102 + r.x129_103 + r.x129_104 + r.x129_105 + r.x129_106 + r.x129_107 + r.x129_108 + r.x129_109 + r.x129_110 + r.x129_111 + r.x129_112 + r.x129_113 + r.x129_114 + r.x129_115 + r.x129_116 + r.x129_117 + r.x129_118 + r.x129_119 + r.x129_120 + r.x129_121 + r.x129_122 + r.x129_123 + r.x129_124 + r.x129_125 + r.x129_126 + r.x129_127 + r.x129_128
let t129 () =
  let r = mk129 5 in
  check "r129 size" (Obj.size (Obj.repr r) = 129);
  check "r129 tag" (Obj.tag (Obj.repr r) = 0);
  check "r129 sum0" (sum129 r = 1605);
  check "r129.x0" (r.x129_0 = 5);
  check "r129.x1" (r.x129_1 = 6);
  check "r129.x2" (r.x129_2 = 7);
  check "r129.x3" (r.x129_3 = 8);
  check "r129.x4" (r.x129_4 = 9);
  check "r129.x64" (r.x129_64 = 5);
  check "r129.x126" (r.x129_126 = 19);
  check "r129.x127" (r.x129_127 = 20);
  check "r129.x128" (r.x129_128 = 5);
  r.x129_0 <- 100;
  r.x129_1 <- 101;
  r.x129_2 <- 102;
  r.x129_3 <- 103;
  r.x129_4 <- 104;
  r.x129_64 <- 101;
  r.x129_126 <- 100;
  r.x129_127 <- 101;
  r.x129_128 <- 102;
  check "r129 sum1" (sum129 r = 2435);
  check "r129.x0 b" (r.x129_0 = 100);
  check "r129.x1 b" (r.x129_1 = 101);
  check "r129.x2 b" (r.x129_2 = 102);
  check "r129.x3 b" (r.x129_3 = 103);
  check "r129.x4 b" (r.x129_4 = 104);
  check "r129.x64 b" (r.x129_64 = 101);
  check "r129.x126 b" (r.x129_126 = 100);
  check "r129.x127 b" (r.x129_127 = 101);
  check "r129.x128 b" (r.x129_128 = 102)
let () =
  run "r128" t128;
  run "r129" t129;
  finish "T01C"
