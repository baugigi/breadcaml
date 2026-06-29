module Petscii = struct

  (* cursor movements *)
  let crsr_up  		= '\145'
  let crsr_dn 		= '\017'
  let crsr_lt 		= '\157'
  let crsr_rt 		= '\029'
                       
  (* colours, colors *)
  let black 		= '\144'
  let white 		= '\005'
  let red 		= '\028'
  let cyan 		= '\159'
  let purple 		= '\156'
  let green 		= '\030'
  let l_green 		= '\153'
  let blue 		= '\031'
  let l_blue 		= '\154'
  let yellow 		= '\158'
  let orange 		= '\129'
  let brown 		= '\149'
  let l_red, pink 	= '\150', '\150'
  let gray1, grey1 	= '\151', '\151'
  let gray2, grey2	= '\152', '\152'
  let gray3, grey3	= '\155', '\155'

  (* character sets *)
  let rvs_on 		= '\018'
  let rvs_off 		= '\146'
  let case_lock		= '\008' (* disable CBM-shift *)
  let case_unlock 	= '\009' (* enable CBM-shift *)
  let lo_case 		= '\014' (* lowercase + uppercase set *)
  let up_case 		= '\142' (* uppercase + graphics set *)

  (* function keys *)
  let f1		= '\133'
  let f2		= '\137'
  let f3		= '\134'
  let f4		= '\138'
  let f5		= '\135'
  let f6		= '\139'
  let f7		= '\136'
  let f8		= '\140'

  (* other control codes and glyphs *)
  let null		= '\000'
  let stop 		= '\003'
  let return 		= '\013'
  let sh_return		= '\141'
  let home 		= '\019'
  let clr 		= '\147'
  let del 		= '\020'
  let inst 		= '\148'
  let sh_space 		= '\160'
  let underscore	= '\164'
  let run		= '\131' (* shift + run/stop *)
  let pound		= '\092' (* pound sterling sign *)
  let up_arrow		= '\094' (* upwards arrow *)
  let lt_arrow		= '\095' (* leftwards arrow *)
  let pi 		= '\255' (* Greek Pi symbol *)

end                       
