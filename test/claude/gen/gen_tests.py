#!/usr/bin/env python3
"""Genera la batteria di test BreadCaml.   Uso: gen_tests.py [dir_output]

Ogni file .ml e' un programma autonomo (prelude comune in testa) che stampa
solo le righe "FAIL <nome>" e, in coda, "Txx OK" oppure "Txx FAIL".
I test sono volutamente spezzati in file piccoli: un programma deve entrare
nella RAM del C64 (codice nativo incluso) e un errore di assemblaggio/link su
una primitiva non deve mascherare gli altri. Se un file e' ancora troppo grande,
spezzare ulteriormente le liste qui sotto."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import t_blocks, t_strings, t_code, t_ints, t_misc, t_diag

C = list(range(26))          # indici delle costanti di confronto in t06

TESTS = [
    # ---- T01: MAKEBLOCK/GETFIELD/SETFIELD, blocchi di 1..255 campi ----------
    ("t01a_small",   lambda: t_blocks.t01([1,2,3,4,5,6,7,8,9,10], "T01A", tags=True)),
    ("t01b_126_127", lambda: t_blocks.t01([126, 127], "T01B")),
    ("t01c_128_129", lambda: t_blocks.t01([128, 129], "T01C")),
    ("t01d_254",     lambda: t_blocks.t01([254], "T01D")),
    ("t01e_255",     lambda: t_blocks.t01([255], "T01E")),
    ("t01f_floatrec_small", lambda: t_blocks.t01f([1, 2, 3, 4, 10], "T01F")),
    ("t01g_floatrec_big",   lambda: t_blocks.t01f([84, 85], "T01G")),
    # ---- T02: blocchi grandi vivi attraverso molti GC -----------------------
    ("t02_big_gc",   t_blocks.t02),
    # ---- T03: array ----------------------------------------------------------
    ("t03a_arr_int",   lambda: t_blocks.t03(["int"], "T03A")),
    ("t03b_arr_float", lambda: t_blocks.t03(["float"], "T03B")),
    ("t03c_arr_subs",  lambda: t_blocks.t03(["subs"], "T03C")),
    ("t03d_arr_fsubs", lambda: t_blocks.t03(["fsubs"], "T03D")),
    ("t03e_arr_stress", lambda: t_blocks.t03(["stress"], "T03E")),
    ("t03f_arr_atoms",  lambda: t_blocks.t03(["atoms"], "T03F")),
    # ---- T04: stringhe 0..509 byte -------------------------------------------
    ("t04_strings", t_strings.t04),
    # ---- T05: ambiente delle closure -----------------------------------------
    ("t05a_clo_small", lambda: t_code.t05([1,2,3,4,5,6,7,8,9,16,63,64], [], [], "T05A")),
    ("t05b_clo_big",   lambda: t_code.t05([100,125,126], [], [], "T05B")),
    ("t05c_rec_env_a", lambda: t_code.t05([], [3,4,5,63,100,124], [], "T05C")),
    ("t05d_rec_env_b", lambda: t_code.t05([], [90,110,120], [], "T05D")),
    ("t05f_mrec_small", lambda: t_code.t05([], [], [1,2,3,4,5,16,64,65], "T05F")),
    ("t05g_mrec_100_127", lambda: t_code.t05([], [], [100,127], "T05G")),
    ("t05h_mrec_128",  lambda: t_code.t05([], [], [128], "T05H")),
    # ---- T06: SWITCH, match su interi, rami con costanti, range di char ------
    ("t06a_sw_small", lambda: t_code.t06([2,3,4,5,6,10], [], [], [], False, "T06A")),
    ("t06b_sw_100_127", lambda: t_code.t06([100,127], [], [], [], False, "T06B")),
    ("t06c_sw_128_129", lambda: t_code.t06([128,129], [], [], [], False, "T06C")),
    ("t06d_sw_200",   lambda: t_code.t06([200], [], [], [], False, "T06D")),
    ("t06e_sw_254",   lambda: t_code.t06([254], [], [], [], False, "T06E")),
    ("t06f_sw_255",   lambda: t_code.t06([255], [], [], [], False, "T06F")),
    ("t06g_mix_a",    lambda: t_code.t06([], [(3,3),(10,10)], [], [], False, "T06G")),
    ("t06h_mix_b",    lambda: t_code.t06([], [(127,5),(5,127)], [], [], False, "T06H")),
    ("t06i_mix_c",    lambda: t_code.t06([], [(127,128)], [], [], False, "T06I")),
    ("t06j_mix_d",    lambda: t_code.t06([], [(235,20)], [], [], False, "T06J")),
    ("t06j2_mix_e",   lambda: t_code.t06([], [(2,200)], [], [], False, "T06J2")),
    ("t06k_int_a",    lambda: t_code.t06([], [], [3,5,50], [], False, "T06K")),
    ("t06l_int_b",    lambda: t_code.t06([], [], [127,128], [], False, "T06L")),
    ("t06m_int_c",    lambda: t_code.t06([], [], [129,200], [], False, "T06M")),
    ("t06n_int_d",    lambda: t_code.t06([], [], [255], [], False, "T06N")),
    ("t06o_cmp_a",    lambda: t_code.t06([], [], [], C[0:9], False, "T06O")),
    ("t06p_cmp_b",    lambda: t_code.t06([], [], [], C[9:18], False, "T06P")),
    ("t06q_cmp_c",    lambda: t_code.t06([], [], [], C[18:26], False, "T06Q")),
    ("t06r_misc",     lambda: t_code.t06([], [], [], [], True, "T06R")),
    # ---- T07: pila, APPLY/GRAB/RESTART/APPTERM -------------------------------
    ("t07a_acc_a",  lambda: t_code.t07([8,64,100], [], [], [], False, "T07A")),
    ("t07b_acc_b",  lambda: t_code.t07([110,120,126], [], [], [], False, "T07B")),
    ("t07c_acc_c",  lambda: t_code.t07([124], [], [], [], False, "T07C")),
    ("t07d_pop_200", lambda: t_code.t07pop([200], "T07D")),
    ("t07d2_pop_260", lambda: t_code.t07pop([260], "T07D2")),
    ("t07e_assign_a", lambda: t_code.t07([], [5,126], [], [], False, "T07E")),
    ("t07f_assign_b", lambda: t_code.t07([], [100,125], [], [], False, "T07F")),
    ("t07g_apply_a", lambda: t_code.t07([], [], [1,2,3,4,5,6,7,8,16,31,32], [], False, "T07G")),
    ("t07h_apply_60", lambda: t_code.t07([], [], [60], [], False, "T07H")),
    ("t07i1_apply_full_100", lambda: t_code.t07([], [], [100], [], False, "T07I1", "full")),
    ("t07i2_papply_100", lambda: t_code.t07([], [], [100], [], False, "T07I2", "p1")),
    ("t07i3_papply2_100", lambda: t_code.t07([], [], [100], [], False, "T07I3", "p2")),
    ("t07j1_apply_full_125", lambda: t_code.t07([], [], [125], [], False, "T07J1", "full")),
    ("t07j_apply_125", lambda: t_code.t07([], [], [125], [], False, "T07J")),
    ("t07k_tail_a",  lambda: t_code.t07([], [], [], [2,3,4,5,6,10], False, "T07K")),
    ("t07l_tail_60", lambda: t_code.t07([], [], [], [60], False, "T07L")),
    ("t07m_tail_63", lambda: t_code.t07([], [], [], [63], False, "T07M")),
    ("t07n_misc",    lambda: t_code.t07([], [], [], [], True, "T07N")),
    # ---- T08: interi a 15 bit ------------------------------------------------
    ("t08_int15",    t_ints.t08),
    # ---- T09: eccezioni -------------------------------------------------------
    ("t09a_exn",     lambda: t_code.t09([3, 10], True, "T09A")),
    ("t09b_exn_126", lambda: t_code.t09([110,126], False, "T09B")),
    # ---- T10: Int32 / Int64 -----------------------------------------------------
    ("t10a_int32",   t_ints.t10_32),
    ("t10b_int64",   t_ints.t10_64),
    # ---- T11: confronto polimorfico ---------------------------------------------
    ("t11a_cmp_basic", lambda: t_misc.t11(["basic"], "T11A")),
    ("t11b_cmp_tup",   lambda: t_misc.t11(["tup"], "T11B")),
    ("t11c_cmp_list_arr", lambda: t_misc.t11(["list", "arr"], "T11C")),
    ("t11d_cmp_misc",  lambda: t_misc.t11(["misc"], "T11D")),
    # ---- T12-T14 ---------------------------------------------------------------
    ("t12_floats",   t_ints.t12),
    ("t13_gc_stress", t_misc.t13),
    ("t14a_list_array", lambda: t_misc.t14(["list", "array"], "T14A")),
    ("t14b_buf_str_qs", lambda: t_misc.t14(["buffer", "qs", "string"], "T14B")),
    ("t14c_map",       lambda: t_misc.t14(["map"], "T14C")),
    ("t14d_set",       lambda: t_misc.t14(["set"], "T14D")),
    # ---- sonde di primitive mancanti / dubbie (file separati) ------------------
    ("t90_array_fill",   t_misc.p90_array_fill),
    ("t91_hashtbl_hash", t_misc.p91_hash),
    ("t92_lazy",         t_misc.p92_lazy),
    ("t93_hashtbl_make", t_misc.p93_hashtbl_make),
    ("t94_floatarray",   t_misc.p94_floatarray),
    ("t95_obj",          t_misc.p95_obj),
    # ---- diagnostici: stampano i valori effettivi dove il primo giro ha dato FAIL ----
    ("t96_diag_cmp",    t_diag.d_cmp),
    ("t96b_diag_cmp2",  t_diag.d_cmp2),
    ("t97_diag_float",  t_diag.d_float),
    ("t98_diag_gc",     t_diag.d_gc),
    ("t99_diag_blit",   t_diag.d_blit),
    ("t9a_diag_atoms",  t_diag.d_atoms),
    ("t9b_diag_make",   t_diag.d_make),
]

def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "tests"
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.endswith(".ml"):
            os.remove(os.path.join(out, f))
    tot = 0
    for name, fn in TESTS:
        src = fn()
        path = os.path.join(out, name + ".ml")
        with open(path, "w") as f:
            f.write(src)
        tot += len(src)
        print("%-22s %7d bytes %5d lines" % (name, len(src), src.count("\n")))
    print("%d file, %d byte di sorgente" % (len(TESTS), tot))

if __name__ == "__main__":
    main()
