let f = function
| 0 -> 100
| 1 -> 101
| 2 -> 102
| 3 -> 103
| 4 -> 104
| 5 -> 105
| n -> n
;;
print_int (f (read_int ()))
;;
