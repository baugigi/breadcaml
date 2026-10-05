
let rec numeri_primi n =
  if n = 0
  then []
  else numeri_primi_aux (pred n) [2]
and numeri_primi_aux n r =
  if n = 0
  then r
  else numeri_primi_aux
         (pred n)
         (primo_successivo (List.hd r + 1) r :: r)
and primo_successivo n l =
  if primo n l
  then n
  else primo_successivo (n+1) l
and primo n = function
  | [] ->
     true
  | e::tl ->
     if n mod e = 0
     then false
     else primo n tl
;;
let p250 = List.rev (numeri_primi 250) in
    List.iteri (fun i p -> print_int i; print_int p; print_newline()) p250
;;
