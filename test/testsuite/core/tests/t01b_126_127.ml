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
type r126 = { mutable x126_0: int; mutable x126_1: int; mutable x126_2: int; mutable x126_3: int; mutable x126_4: int; mutable x126_5: int; mutable x126_6: int; mutable x126_7: int; mutable x126_8: int; mutable x126_9: int; mutable x126_10: int; mutable x126_11: int; mutable x126_12: int; mutable x126_13: int; mutable x126_14: int; mutable x126_15: int; mutable x126_16: int; mutable x126_17: int; mutable x126_18: int; mutable x126_19: int; mutable x126_20: int; mutable x126_21: int; mutable x126_22: int; mutable x126_23: int; mutable x126_24: int; mutable x126_25: int; mutable x126_26: int; mutable x126_27: int; mutable x126_28: int; mutable x126_29: int; mutable x126_30: int; mutable x126_31: int; mutable x126_32: int; mutable x126_33: int; mutable x126_34: int; mutable x126_35: int; mutable x126_36: int; mutable x126_37: int; mutable x126_38: int; mutable x126_39: int; mutable x126_40: int; mutable x126_41: int; mutable x126_42: int; mutable x126_43: int; mutable x126_44: int; mutable x126_45: int; mutable x126_46: int; mutable x126_47: int; mutable x126_48: int; mutable x126_49: int; mutable x126_50: int; mutable x126_51: int; mutable x126_52: int; mutable x126_53: int; mutable x126_54: int; mutable x126_55: int; mutable x126_56: int; mutable x126_57: int; mutable x126_58: int; mutable x126_59: int; mutable x126_60: int; mutable x126_61: int; mutable x126_62: int; mutable x126_63: int; mutable x126_64: int; mutable x126_65: int; mutable x126_66: int; mutable x126_67: int; mutable x126_68: int; mutable x126_69: int; mutable x126_70: int; mutable x126_71: int; mutable x126_72: int; mutable x126_73: int; mutable x126_74: int; mutable x126_75: int; mutable x126_76: int; mutable x126_77: int; mutable x126_78: int; mutable x126_79: int; mutable x126_80: int; mutable x126_81: int; mutable x126_82: int; mutable x126_83: int; mutable x126_84: int; mutable x126_85: int; mutable x126_86: int; mutable x126_87: int; mutable x126_88: int; mutable x126_89: int; mutable x126_90: int; mutable x126_91: int; mutable x126_92: int; mutable x126_93: int; mutable x126_94: int; mutable x126_95: int; mutable x126_96: int; mutable x126_97: int; mutable x126_98: int; mutable x126_99: int; mutable x126_100: int; mutable x126_101: int; mutable x126_102: int; mutable x126_103: int; mutable x126_104: int; mutable x126_105: int; mutable x126_106: int; mutable x126_107: int; mutable x126_108: int; mutable x126_109: int; mutable x126_110: int; mutable x126_111: int; mutable x126_112: int; mutable x126_113: int; mutable x126_114: int; mutable x126_115: int; mutable x126_116: int; mutable x126_117: int; mutable x126_118: int; mutable x126_119: int; mutable x126_120: int; mutable x126_121: int; mutable x126_122: int; mutable x126_123: int; mutable x126_124: int; mutable x126_125: int }
let mk126 a = { x126_0 = a + 0; x126_1 = a + 1; x126_2 = a + 2; x126_3 = a + 3; x126_4 = a + 4; x126_5 = a + 5; x126_6 = a + 6; x126_7 = a + 7; x126_8 = a + 8; x126_9 = a + 9; x126_10 = a + 10; x126_11 = a + 11; x126_12 = a + 12; x126_13 = a + 13; x126_14 = a + 14; x126_15 = a + 15; x126_16 = a + 0; x126_17 = a + 1; x126_18 = a + 2; x126_19 = a + 3; x126_20 = a + 4; x126_21 = a + 5; x126_22 = a + 6; x126_23 = a + 7; x126_24 = a + 8; x126_25 = a + 9; x126_26 = a + 10; x126_27 = a + 11; x126_28 = a + 12; x126_29 = a + 13; x126_30 = a + 14; x126_31 = a + 15; x126_32 = a + 0; x126_33 = a + 1; x126_34 = a + 2; x126_35 = a + 3; x126_36 = a + 4; x126_37 = a + 5; x126_38 = a + 6; x126_39 = a + 7; x126_40 = a + 8; x126_41 = a + 9; x126_42 = a + 10; x126_43 = a + 11; x126_44 = a + 12; x126_45 = a + 13; x126_46 = a + 14; x126_47 = a + 15; x126_48 = a + 0; x126_49 = a + 1; x126_50 = a + 2; x126_51 = a + 3; x126_52 = a + 4; x126_53 = a + 5; x126_54 = a + 6; x126_55 = a + 7; x126_56 = a + 8; x126_57 = a + 9; x126_58 = a + 10; x126_59 = a + 11; x126_60 = a + 12; x126_61 = a + 13; x126_62 = a + 14; x126_63 = a + 15; x126_64 = a + 0; x126_65 = a + 1; x126_66 = a + 2; x126_67 = a + 3; x126_68 = a + 4; x126_69 = a + 5; x126_70 = a + 6; x126_71 = a + 7; x126_72 = a + 8; x126_73 = a + 9; x126_74 = a + 10; x126_75 = a + 11; x126_76 = a + 12; x126_77 = a + 13; x126_78 = a + 14; x126_79 = a + 15; x126_80 = a + 0; x126_81 = a + 1; x126_82 = a + 2; x126_83 = a + 3; x126_84 = a + 4; x126_85 = a + 5; x126_86 = a + 6; x126_87 = a + 7; x126_88 = a + 8; x126_89 = a + 9; x126_90 = a + 10; x126_91 = a + 11; x126_92 = a + 12; x126_93 = a + 13; x126_94 = a + 14; x126_95 = a + 15; x126_96 = a + 0; x126_97 = a + 1; x126_98 = a + 2; x126_99 = a + 3; x126_100 = a + 4; x126_101 = a + 5; x126_102 = a + 6; x126_103 = a + 7; x126_104 = a + 8; x126_105 = a + 9; x126_106 = a + 10; x126_107 = a + 11; x126_108 = a + 12; x126_109 = a + 13; x126_110 = a + 14; x126_111 = a + 15; x126_112 = a + 0; x126_113 = a + 1; x126_114 = a + 2; x126_115 = a + 3; x126_116 = a + 4; x126_117 = a + 5; x126_118 = a + 6; x126_119 = a + 7; x126_120 = a + 8; x126_121 = a + 9; x126_122 = a + 10; x126_123 = a + 11; x126_124 = a + 12; x126_125 = a + 13 }
let sum126 r = r.x126_0 + r.x126_1 + r.x126_2 + r.x126_3 + r.x126_4 + r.x126_5 + r.x126_6 + r.x126_7 + r.x126_8 + r.x126_9 + r.x126_10 + r.x126_11 + r.x126_12 + r.x126_13 + r.x126_14 + r.x126_15 + r.x126_16 + r.x126_17 + r.x126_18 + r.x126_19 + r.x126_20 + r.x126_21 + r.x126_22 + r.x126_23 + r.x126_24 + r.x126_25 + r.x126_26 + r.x126_27 + r.x126_28 + r.x126_29 + r.x126_30 + r.x126_31 + r.x126_32 + r.x126_33 + r.x126_34 + r.x126_35 + r.x126_36 + r.x126_37 + r.x126_38 + r.x126_39 + r.x126_40 + r.x126_41 + r.x126_42 + r.x126_43 + r.x126_44 + r.x126_45 + r.x126_46 + r.x126_47 + r.x126_48 + r.x126_49 + r.x126_50 + r.x126_51 + r.x126_52 + r.x126_53 + r.x126_54 + r.x126_55 + r.x126_56 + r.x126_57 + r.x126_58 + r.x126_59 + r.x126_60 + r.x126_61 + r.x126_62 + r.x126_63 + r.x126_64 + r.x126_65 + r.x126_66 + r.x126_67 + r.x126_68 + r.x126_69 + r.x126_70 + r.x126_71 + r.x126_72 + r.x126_73 + r.x126_74 + r.x126_75 + r.x126_76 + r.x126_77 + r.x126_78 + r.x126_79 + r.x126_80 + r.x126_81 + r.x126_82 + r.x126_83 + r.x126_84 + r.x126_85 + r.x126_86 + r.x126_87 + r.x126_88 + r.x126_89 + r.x126_90 + r.x126_91 + r.x126_92 + r.x126_93 + r.x126_94 + r.x126_95 + r.x126_96 + r.x126_97 + r.x126_98 + r.x126_99 + r.x126_100 + r.x126_101 + r.x126_102 + r.x126_103 + r.x126_104 + r.x126_105 + r.x126_106 + r.x126_107 + r.x126_108 + r.x126_109 + r.x126_110 + r.x126_111 + r.x126_112 + r.x126_113 + r.x126_114 + r.x126_115 + r.x126_116 + r.x126_117 + r.x126_118 + r.x126_119 + r.x126_120 + r.x126_121 + r.x126_122 + r.x126_123 + r.x126_124 + r.x126_125
let t126 () =
  let r = mk126 5 in
  check "r126 size" (Obj.size (Obj.repr r) = 126);
  check "r126 tag" (Obj.tag (Obj.repr r) = 0);
  check "r126 sum0" (sum126 r = 1561);
  check "r126.x0" (r.x126_0 = 5);
  check "r126.x1" (r.x126_1 = 6);
  check "r126.x2" (r.x126_2 = 7);
  check "r126.x3" (r.x126_3 = 8);
  check "r126.x4" (r.x126_4 = 9);
  check "r126.x63" (r.x126_63 = 20);
  check "r126.x123" (r.x126_123 = 16);
  check "r126.x124" (r.x126_124 = 17);
  check "r126.x125" (r.x126_125 = 18);
  r.x126_0 <- 100;
  r.x126_1 <- 101;
  r.x126_2 <- 102;
  r.x126_3 <- 103;
  r.x126_4 <- 104;
  r.x126_63 <- 100;
  r.x126_123 <- 104;
  r.x126_124 <- 105;
  r.x126_125 <- 106;
  check "r126 sum1" (sum126 r = 2380);
  check "r126.x0 b" (r.x126_0 = 100);
  check "r126.x1 b" (r.x126_1 = 101);
  check "r126.x2 b" (r.x126_2 = 102);
  check "r126.x3 b" (r.x126_3 = 103);
  check "r126.x4 b" (r.x126_4 = 104);
  check "r126.x63 b" (r.x126_63 = 100);
  check "r126.x123 b" (r.x126_123 = 104);
  check "r126.x124 b" (r.x126_124 = 105);
  check "r126.x125 b" (r.x126_125 = 106)
type r127 = { mutable x127_0: int; mutable x127_1: int; mutable x127_2: int; mutable x127_3: int; mutable x127_4: int; mutable x127_5: int; mutable x127_6: int; mutable x127_7: int; mutable x127_8: int; mutable x127_9: int; mutable x127_10: int; mutable x127_11: int; mutable x127_12: int; mutable x127_13: int; mutable x127_14: int; mutable x127_15: int; mutable x127_16: int; mutable x127_17: int; mutable x127_18: int; mutable x127_19: int; mutable x127_20: int; mutable x127_21: int; mutable x127_22: int; mutable x127_23: int; mutable x127_24: int; mutable x127_25: int; mutable x127_26: int; mutable x127_27: int; mutable x127_28: int; mutable x127_29: int; mutable x127_30: int; mutable x127_31: int; mutable x127_32: int; mutable x127_33: int; mutable x127_34: int; mutable x127_35: int; mutable x127_36: int; mutable x127_37: int; mutable x127_38: int; mutable x127_39: int; mutable x127_40: int; mutable x127_41: int; mutable x127_42: int; mutable x127_43: int; mutable x127_44: int; mutable x127_45: int; mutable x127_46: int; mutable x127_47: int; mutable x127_48: int; mutable x127_49: int; mutable x127_50: int; mutable x127_51: int; mutable x127_52: int; mutable x127_53: int; mutable x127_54: int; mutable x127_55: int; mutable x127_56: int; mutable x127_57: int; mutable x127_58: int; mutable x127_59: int; mutable x127_60: int; mutable x127_61: int; mutable x127_62: int; mutable x127_63: int; mutable x127_64: int; mutable x127_65: int; mutable x127_66: int; mutable x127_67: int; mutable x127_68: int; mutable x127_69: int; mutable x127_70: int; mutable x127_71: int; mutable x127_72: int; mutable x127_73: int; mutable x127_74: int; mutable x127_75: int; mutable x127_76: int; mutable x127_77: int; mutable x127_78: int; mutable x127_79: int; mutable x127_80: int; mutable x127_81: int; mutable x127_82: int; mutable x127_83: int; mutable x127_84: int; mutable x127_85: int; mutable x127_86: int; mutable x127_87: int; mutable x127_88: int; mutable x127_89: int; mutable x127_90: int; mutable x127_91: int; mutable x127_92: int; mutable x127_93: int; mutable x127_94: int; mutable x127_95: int; mutable x127_96: int; mutable x127_97: int; mutable x127_98: int; mutable x127_99: int; mutable x127_100: int; mutable x127_101: int; mutable x127_102: int; mutable x127_103: int; mutable x127_104: int; mutable x127_105: int; mutable x127_106: int; mutable x127_107: int; mutable x127_108: int; mutable x127_109: int; mutable x127_110: int; mutable x127_111: int; mutable x127_112: int; mutable x127_113: int; mutable x127_114: int; mutable x127_115: int; mutable x127_116: int; mutable x127_117: int; mutable x127_118: int; mutable x127_119: int; mutable x127_120: int; mutable x127_121: int; mutable x127_122: int; mutable x127_123: int; mutable x127_124: int; mutable x127_125: int; mutable x127_126: int }
let mk127 a = { x127_0 = a + 0; x127_1 = a + 1; x127_2 = a + 2; x127_3 = a + 3; x127_4 = a + 4; x127_5 = a + 5; x127_6 = a + 6; x127_7 = a + 7; x127_8 = a + 8; x127_9 = a + 9; x127_10 = a + 10; x127_11 = a + 11; x127_12 = a + 12; x127_13 = a + 13; x127_14 = a + 14; x127_15 = a + 15; x127_16 = a + 0; x127_17 = a + 1; x127_18 = a + 2; x127_19 = a + 3; x127_20 = a + 4; x127_21 = a + 5; x127_22 = a + 6; x127_23 = a + 7; x127_24 = a + 8; x127_25 = a + 9; x127_26 = a + 10; x127_27 = a + 11; x127_28 = a + 12; x127_29 = a + 13; x127_30 = a + 14; x127_31 = a + 15; x127_32 = a + 0; x127_33 = a + 1; x127_34 = a + 2; x127_35 = a + 3; x127_36 = a + 4; x127_37 = a + 5; x127_38 = a + 6; x127_39 = a + 7; x127_40 = a + 8; x127_41 = a + 9; x127_42 = a + 10; x127_43 = a + 11; x127_44 = a + 12; x127_45 = a + 13; x127_46 = a + 14; x127_47 = a + 15; x127_48 = a + 0; x127_49 = a + 1; x127_50 = a + 2; x127_51 = a + 3; x127_52 = a + 4; x127_53 = a + 5; x127_54 = a + 6; x127_55 = a + 7; x127_56 = a + 8; x127_57 = a + 9; x127_58 = a + 10; x127_59 = a + 11; x127_60 = a + 12; x127_61 = a + 13; x127_62 = a + 14; x127_63 = a + 15; x127_64 = a + 0; x127_65 = a + 1; x127_66 = a + 2; x127_67 = a + 3; x127_68 = a + 4; x127_69 = a + 5; x127_70 = a + 6; x127_71 = a + 7; x127_72 = a + 8; x127_73 = a + 9; x127_74 = a + 10; x127_75 = a + 11; x127_76 = a + 12; x127_77 = a + 13; x127_78 = a + 14; x127_79 = a + 15; x127_80 = a + 0; x127_81 = a + 1; x127_82 = a + 2; x127_83 = a + 3; x127_84 = a + 4; x127_85 = a + 5; x127_86 = a + 6; x127_87 = a + 7; x127_88 = a + 8; x127_89 = a + 9; x127_90 = a + 10; x127_91 = a + 11; x127_92 = a + 12; x127_93 = a + 13; x127_94 = a + 14; x127_95 = a + 15; x127_96 = a + 0; x127_97 = a + 1; x127_98 = a + 2; x127_99 = a + 3; x127_100 = a + 4; x127_101 = a + 5; x127_102 = a + 6; x127_103 = a + 7; x127_104 = a + 8; x127_105 = a + 9; x127_106 = a + 10; x127_107 = a + 11; x127_108 = a + 12; x127_109 = a + 13; x127_110 = a + 14; x127_111 = a + 15; x127_112 = a + 0; x127_113 = a + 1; x127_114 = a + 2; x127_115 = a + 3; x127_116 = a + 4; x127_117 = a + 5; x127_118 = a + 6; x127_119 = a + 7; x127_120 = a + 8; x127_121 = a + 9; x127_122 = a + 10; x127_123 = a + 11; x127_124 = a + 12; x127_125 = a + 13; x127_126 = a + 14 }
let sum127 r = r.x127_0 + r.x127_1 + r.x127_2 + r.x127_3 + r.x127_4 + r.x127_5 + r.x127_6 + r.x127_7 + r.x127_8 + r.x127_9 + r.x127_10 + r.x127_11 + r.x127_12 + r.x127_13 + r.x127_14 + r.x127_15 + r.x127_16 + r.x127_17 + r.x127_18 + r.x127_19 + r.x127_20 + r.x127_21 + r.x127_22 + r.x127_23 + r.x127_24 + r.x127_25 + r.x127_26 + r.x127_27 + r.x127_28 + r.x127_29 + r.x127_30 + r.x127_31 + r.x127_32 + r.x127_33 + r.x127_34 + r.x127_35 + r.x127_36 + r.x127_37 + r.x127_38 + r.x127_39 + r.x127_40 + r.x127_41 + r.x127_42 + r.x127_43 + r.x127_44 + r.x127_45 + r.x127_46 + r.x127_47 + r.x127_48 + r.x127_49 + r.x127_50 + r.x127_51 + r.x127_52 + r.x127_53 + r.x127_54 + r.x127_55 + r.x127_56 + r.x127_57 + r.x127_58 + r.x127_59 + r.x127_60 + r.x127_61 + r.x127_62 + r.x127_63 + r.x127_64 + r.x127_65 + r.x127_66 + r.x127_67 + r.x127_68 + r.x127_69 + r.x127_70 + r.x127_71 + r.x127_72 + r.x127_73 + r.x127_74 + r.x127_75 + r.x127_76 + r.x127_77 + r.x127_78 + r.x127_79 + r.x127_80 + r.x127_81 + r.x127_82 + r.x127_83 + r.x127_84 + r.x127_85 + r.x127_86 + r.x127_87 + r.x127_88 + r.x127_89 + r.x127_90 + r.x127_91 + r.x127_92 + r.x127_93 + r.x127_94 + r.x127_95 + r.x127_96 + r.x127_97 + r.x127_98 + r.x127_99 + r.x127_100 + r.x127_101 + r.x127_102 + r.x127_103 + r.x127_104 + r.x127_105 + r.x127_106 + r.x127_107 + r.x127_108 + r.x127_109 + r.x127_110 + r.x127_111 + r.x127_112 + r.x127_113 + r.x127_114 + r.x127_115 + r.x127_116 + r.x127_117 + r.x127_118 + r.x127_119 + r.x127_120 + r.x127_121 + r.x127_122 + r.x127_123 + r.x127_124 + r.x127_125 + r.x127_126
let t127 () =
  let r = mk127 5 in
  check "r127 size" (Obj.size (Obj.repr r) = 127);
  check "r127 tag" (Obj.tag (Obj.repr r) = 0);
  check "r127 sum0" (sum127 r = 1580);
  check "r127.x0" (r.x127_0 = 5);
  check "r127.x1" (r.x127_1 = 6);
  check "r127.x2" (r.x127_2 = 7);
  check "r127.x3" (r.x127_3 = 8);
  check "r127.x4" (r.x127_4 = 9);
  check "r127.x63" (r.x127_63 = 20);
  check "r127.x124" (r.x127_124 = 17);
  check "r127.x125" (r.x127_125 = 18);
  check "r127.x126" (r.x127_126 = 19);
  r.x127_0 <- 100;
  r.x127_1 <- 101;
  r.x127_2 <- 102;
  r.x127_3 <- 103;
  r.x127_4 <- 104;
  r.x127_63 <- 100;
  r.x127_124 <- 105;
  r.x127_125 <- 106;
  r.x127_126 <- 100;
  check "r127 sum1" (sum127 r = 2392);
  check "r127.x0 b" (r.x127_0 = 100);
  check "r127.x1 b" (r.x127_1 = 101);
  check "r127.x2 b" (r.x127_2 = 102);
  check "r127.x3 b" (r.x127_3 = 103);
  check "r127.x4 b" (r.x127_4 = 104);
  check "r127.x63 b" (r.x127_63 = 100);
  check "r127.x124 b" (r.x127_124 = 105);
  check "r127.x125 b" (r.x127_125 = 106);
  check "r127.x126 b" (r.x127_126 = 100)
let () =
  run "r126" t126;
  run "r127" t127;
  finish "T01B"
