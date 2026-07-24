let a = "dl{RED}aàs"
let b = "{CLR}ciao" ^ a
let c = 'a'
let d = b ^ "{RVSOFF}"
let e = b ^ [%ascii "{RVSOFF}"]
let f = function
| [%ascii "{clr}gigi"] -> 1
| "{clr}gigi" -> 2
| _ -> 0
