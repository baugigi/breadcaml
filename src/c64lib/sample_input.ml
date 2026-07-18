exception Mia_Eccezione of string

let () =
  print_endline "fava";
  print_endline "{clr}{rvson}ASCII to PETSCII conversion:{rvsoff}";
  print_endline "UPPERCASE & lowercase are not swapped!";
  print_endline "Underscore: _  -  left arrow: {larr}";
  print_endline "{rvson}{grn} I {wht} T {red} A {lblu}{rvsoff}";
  print_endline "{uarr} Special characters made easy {uarr}";
  raise (Mia_Eccezione "{BLK}Prova Testo")

let x = [`Fava; `Budello; `Rati; `Sbiriguda; `Mentana; `A; `Dumila]

