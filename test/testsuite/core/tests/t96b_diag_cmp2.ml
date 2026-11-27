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
let dg s got exp =
  if got <> exp then begin
    incr fails; print_string s; print_string " got="; print_int got;
    print_string " exp="; print_int exp; print_newline ()
  end
let dgb s b = dg s (if b then 1 else 0) 1
let ex s f = try f () with _ -> dg (s ^ " exn") 1 0
type big = C0 of int | C1 of int | C2 of int | C3 of int | C4 of int | C5 of int | C6 of int | C7 of int | C8 of int | C9 of int | C10 of int | C11 of int | C12 of int | C13 of int | C14 of int | C15 of int | C16 of int | C17 of int | C18 of int | C19 of int | C20 of int | C21 of int | C22 of int | C23 of int | C24 of int | C25 of int | C26 of int | C27 of int | C28 of int | C29 of int | C30 of int | C31 of int | C32 of int | C33 of int | C34 of int | C35 of int | C36 of int | C37 of int | C38 of int | C39 of int | C40 of int | C41 of int | C42 of int | C43 of int | C44 of int | C45 of int | C46 of int | C47 of int | C48 of int | C49 of int | C50 of int | C51 of int | C52 of int | C53 of int | C54 of int | C55 of int | C56 of int | C57 of int | C58 of int | C59 of int | C60 of int | C61 of int | C62 of int | C63 of int | C64 of int | C65 of int | C66 of int | C67 of int | C68 of int | C69 of int | C70 of int | C71 of int | C72 of int | C73 of int | C74 of int | C75 of int | C76 of int | C77 of int | C78 of int | C79 of int | C80 of int | C81 of int | C82 of int | C83 of int | C84 of int | C85 of int | C86 of int | C87 of int | C88 of int | C89 of int | C90 of int | C91 of int | C92 of int | C93 of int | C94 of int | C95 of int | C96 of int | C97 of int | C98 of int | C99 of int | C100 of int | C101 of int | C102 of int | C103 of int | C104 of int | C105 of int | C106 of int | C107 of int | C108 of int | C109 of int | C110 of int | C111 of int | C112 of int | C113 of int | C114 of int | C115 of int | C116 of int | C117 of int | C118 of int | C119 of int | C120 of int | C121 of int | C122 of int | C123 of int | C124 of int | C125 of int | C126 of int | C127 of int | C128 of int | C129 of int | C130 of int | C131 of int | C132 of int | C133 of int | C134 of int | C135 of int | C136 of int | C137 of int | C138 of int | C139 of int | C140 of int | C141 of int | C142 of int | C143 of int | C144 of int | C145 of int | C146 of int | C147 of int | C148 of int | C149 of int | C150 of int | C151 of int | C152 of int | C153 of int | C154 of int | C155 of int | C156 of int | C157 of int | C158 of int | C159 of int | C160 of int | C161 of int | C162 of int | C163 of int | C164 of int | C165 of int | C166 of int | C167 of int | C168 of int | C169 of int | C170 of int | C171 of int | C172 of int | C173 of int | C174 of int | C175 of int | C176 of int | C177 of int | C178 of int | C179 of int | C180 of int | C181 of int | C182 of int | C183 of int | C184 of int | C185 of int | C186 of int | C187 of int | C188 of int | C189 of int | C190 of int | C191 of int | C192 of int | C193 of int | C194 of int | C195 of int | C196 of int | C197 of int | C198 of int | C199 of int | C200 of int | C201 of int | C202 of int | C203 of int | C204 of int | C205 of int | C206 of int | C207 of int | C208 of int | C209 of int | C210 of int | C211 of int | C212 of int | C213 of int | C214 of int | C215 of int | C216 of int | C217 of int | C218 of int | C219 of int | C220 of int | C221 of int | C222 of int | C223 of int | C224 of int | C225 of int | C226 of int | C227 of int | C228 of int | C229 of int
let z = ref 0
let sgn c = if c < 0 then -1 else if c > 0 then 1 else 0
let pc a b = sgn (compare a b)
let () =
  ex "t0" (fun () -> dg "tag 229>0" (pc (C229 (1 + !z)) (C0 1)) 1);
  ex "t1" (fun () -> dg "tag 0<229" (pc (C0 1) (C229 (1 + !z))) (-1));
  ex "t2" (fun () -> dg "tag 130>0" (pc (C130 1) (C0 (1 + !z))) 1);
  ex "t3" (fun () -> dg "tag 0<130" (pc (C0 (1 + !z)) (C130 1)) (-1));
  ex "t4" (fun () -> dg "tag 129>2" (pc (C129 (1 + !z)) (C2 1)) 1);
  ex "t5" (fun () -> dg "tag 127>0" (pc (C127 (1 + !z)) (C0 1)) 1);
  ex "t6" (fun () -> dgb "tag <" (C0 1 < C229 (1 + !z)));
  ex "t7" (fun () -> dgb "tag >" (C229 1 > C0 (1 + !z)));
  let a200 = Array.make 200 0 and a10 = Array.make 10 0 in
  let a129 = Array.make 129 5 and a1 = Array.make 1 5 in
  ex "s0" (fun () -> dg "arr 200>10" (pc a200 a10) 1);
  ex "s1" (fun () -> dg "arr 10<200" (pc a10 a200) (-1));
  ex "s2" (fun () -> dg "arr 129>1" (pc a129 a1) 1);
  ex "s3" (fun () -> dg "arr 1<129" (pc a1 a129) (-1));
  ex "s4" (fun () -> dg "arr 200=200" (pc a200 (Array.make 200 0)) 0);
  ex "s5" (fun () -> dgb "arr <" (a10 < a200));
  let s300 = String.make 300 'a' and s10 = String.make 10 'a' in
  ex "r0" (fun () -> dg "str 300>10" (pc s300 s10) 1);
  ex "r1" (fun () -> dg "str 10<300" (pc s10 s300) (-1));
  ex "r2" (fun () -> dg "str 300=300" (pc s300 (String.make 300 'a')) 0);
  ex "r3" (fun () -> dgb "str <" (s10 < s300));
  ex "r4" (fun () -> dgb "str >" (s300 > s10));
  ex "n0" (fun () -> dg "t5 eq" (pc (1, 2, 3, 4, 5) (1, 2, 3, 4, 5 + !z)) 0);
  ex "n1" (fun () -> dg "t5 last" (pc (1, 2, 3, 4, 5) (1, 2, 3, 4, 6 + !z)) (-1));
  ex "n2" (fun () -> dg "t5 4th" (pc (1, 2, 3, 5, 5) (1, 2, 3, 4 + !z, 9)) 1);
  ex "n3" (fun () -> dg "t5 3rd" (pc (1, 2, 3, 9, 9) (1, 2, 4 + !z, 0, 0)) (-1));
  ex "n4" (fun () -> dg "t5 2nd" (pc (1, 3, 0, 0, 0) (1, 2 + !z, 9, 9, 9)) 1);
  ex "n5" (fun () -> dg "t5 1st" (pc (0, 9, 9, 9, 9) (1 + !z, 0, 0, 0, 0)) (-1));
  ex "n6" (fun () -> dg "t3 last" (pc (1, 2, 3) (1, 2, 4 + !z)) (-1));
  ex "n7" (fun () -> dg "t3 mid" (pc (1, 3, 0) (1, 2 + !z, 9)) 1);
  ex "n8" (fun () -> dg "t4 eq" (pc (1, 2, 3, 4) (1, 2, 3, 4 + !z)) 0);
  ex "na" (fun () -> dg "arr4 last" (pc [|1; 2; 3; 4|] [|1; 2; 3; 5 + !z|]) (-1));
  ex "nb" (fun () -> dg "arr4 eq" (pc [|1; 2; 3; 4|] [|1; 2; 3; 4 + !z|]) 0);
  ex "nc" (fun () -> dg "list last" (pc [1; 2; 3; 4] [1; 2; 3; 5 + !z]) (-1));
  ex "nd" (fun () -> dg "list prefix" (pc [1; 2; 3] [1; 2; 3; 4 + !z]) (-1));
  ex "m0" (fun () -> dg "nest eq" (pc ((1, 2, 3), (4, 5, 6)) ((1, 2, 3), (4, 5, 6 + !z))) 0);
  ex "m1" (fun () -> dg "nest lt" (pc ((1, 2, 3), (4, 5, 6)) ((1, 2, 3), (4, 5, 7 + !z))) (-1));
  ex "m2" (fun () -> dg "nest gt" (pc ((1, 2, 3), (4, 5, 6), 7) ((1, 2, 3), (4, 5, 6), 6 + !z)) 1);
  ex "m3" (fun () -> dg "nest in" (pc ((1, 2, 3), 9, 9) ((1, 2, 4 + !z), 0, 0)) (-1));
  ex "m4" (fun () -> dg "list of tup" (pc [(1, 2, 3); (4, 5, 6)] [(1, 2, 3); (4, 5, 7 + !z)]) (-1));
  finish "d_cmp2"
