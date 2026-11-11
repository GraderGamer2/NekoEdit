.intel_syntax noprefix

# Bounded, dependency-free XKB text-v1 reader. It parses keycodes, symbols,
# per-group key types, 32-bit modifier masks, virtual-modifier encodings,
# per-entry preserve[] masks, and a limited xkb_compat subset for
# keysym/modmap matching, virtualModifier assignment, and per-key repeat.
# General stateful key actions remain compositor-owned.

.section .rodata
.Lxkb_section_keycodes: .asciz "xkb_keycodes"
.Lxkb_section_symbols:  .asciz "xkb_symbols"
.Lxkb_word_key:         .asciz "key"
.Lxkb_word_type:        .asciz "type"
.Lxkb_word_symbols:     .asciz "symbols"
.Lxkb_section_types:    .asciz "xkb_types"
.Lxkb_section_compat:   .asciz "xkb_compat"
.Lxkb_word_interpret:   .asciz "interpret"
.Lxkb_word_virtual_modifier: .asciz "virtualModifier"
.Lxkb_word_use_mod_map_mods: .asciz "useModMapMods"
.Lxkb_word_repeat:       .asciz "repeat"
.Lxkb_word_true:         .asciz "True"
.Lxkb_word_false:        .asciz "False"
.Lxkb_compat_any:       .asciz "Any"
.Lxkb_compat_no_symbol: .asciz "NoSymbol"
.Lxkb_compat_anyofornone: .asciz "AnyOfOrNone"
.Lxkb_compat_anyof:     .asciz "AnyOf"
.Lxkb_compat_noneof:    .asciz "NoneOf"
.Lxkb_compat_allof:     .asciz "AllOf"
.Lxkb_compat_exactly:   .asciz "Exactly"
.Lxkb_compat_level1:    .asciz "level1"
.Lxkb_compat_any_level: .asciz "any"
.Lxkb_word_virtual_modifiers: .asciz "virtual_modifiers"
.Lxkb_word_map:         .asciz "map"
.Lxkb_word_modifiers:   .asciz "modifiers"
.Lxkb_word_preserve:    .asciz "preserve"
.Lxkb_word_level_name:  .asciz "level_name"
.Lxkb_word_key_virtual_modifiers: .asciz "virtualModifiers"
.Lxkb_word_modifier_map: .asciz "modifier_map"
.Lxkb_word_mod_map:     .asciz "mod_map"
.Lxkb_word_modmap:      .asciz "modmap"
.Lxkb_mod_shift:        .asciz "Shift"
.Lxkb_mod_lock:         .asciz "Lock"
.Lxkb_mod_control:      .asciz "Control"
.Lxkb_mod_mod1:         .asciz "Mod1"
.Lxkb_mod_mod2:         .asciz "Mod2"
.Lxkb_mod_mod3:         .asciz "Mod3"
.Lxkb_mod_mod4:         .asciz "Mod4"
.Lxkb_mod_mod5:         .asciz "Mod5"
.Lxkb_mod_level_three:  .asciz "LevelThree"
.Lxkb_mod_level_five:   .asciz "LevelFive"
.Lxkb_mod_num_lock:     .asciz "NumLock"
.Lxkb_sym_shift_l:      .asciz "Shift_L"
.Lxkb_sym_shift_r:      .asciz "Shift_R"
.Lxkb_sym_control_l:    .asciz "Control_L"
.Lxkb_sym_control_r:    .asciz "Control_R"
.Lxkb_sym_caps_lock:    .asciz "Caps_Lock"
.Lxkb_sym_meta_l:       .asciz "Meta_L"
.Lxkb_sym_meta_r:       .asciz "Meta_R"
.Lxkb_sym_alt_l:        .asciz "Alt_L"
.Lxkb_sym_alt_r:        .asciz "Alt_R"
.Lxkb_sym_super_l:      .asciz "Super_L"
.Lxkb_sym_super_r:      .asciz "Super_R"
.Lxkb_sym_hyper_l:      .asciz "Hyper_L"
.Lxkb_sym_hyper_r:      .asciz "Hyper_R"
.Lxkb_sym_num_lock:     .asciz "Num_Lock"
.Lxkb_sym_scroll_lock:  .asciz "Scroll_Lock"
.Lxkb_sym_mode_switch:  .asciz "Mode_switch"
.Lxkb_sym_iso3_shift:   .asciz "ISO_Level3_Shift"
.Lxkb_sym_iso3_latch:   .asciz "ISO_Level3_Latch"
.Lxkb_sym_iso3_lock:    .asciz "ISO_Level3_Lock"
.Lxkb_sym_iso5_shift:   .asciz "ISO_Level5_Shift"
.Lxkb_sym_iso5_latch:   .asciz "ISO_Level5_Latch"
.Lxkb_sym_iso5_lock:    .asciz "ISO_Level5_Lock"
.Lxkb_sym_shift_lock:  .asciz "Shift_Lock"
.Lxkb_sym_iso_lock:    .asciz "ISO_Lock"
.Lxkb_sym_iso2_latch:  .asciz "ISO_Level2_Latch"
.Lxkb_sym_iso_group_shift: .asciz "ISO_Group_Shift"
.Lxkb_sym_greek_switch: .asciz "Greek_switch"
.Lxkb_sym_script_switch: .asciz "script_switch"
.Lxkb_sym_iso_group_latch: .asciz "ISO_Group_Latch"
.Lxkb_sym_iso_group_lock: .asciz "ISO_Group_Lock"
.Lxkb_sym_iso_next_group: .asciz "ISO_Next_Group"
.Lxkb_sym_iso_next_group_lock: .asciz "ISO_Next_Group_Lock"
.Lxkb_sym_iso_prev_group: .asciz "ISO_Prev_Group"
.Lxkb_sym_iso_prev_group_lock: .asciz "ISO_Prev_Group_Lock"
.Lxkb_sym_iso_first_group: .asciz "ISO_First_Group"
.Lxkb_sym_iso_first_group_lock: .asciz "ISO_First_Group_Lock"
.Lxkb_sym_iso_last_group: .asciz "ISO_Last_Group"
.Lxkb_sym_iso_last_group_lock: .asciz "ISO_Last_Group_Lock"
.Lxkb_mod_none:         .asciz "None"
.Lxkb_mod_none_lower:   .asciz "none"
.Lxkb_mod_all:          .asciz "all"
.Lxkb_type_one_level:    .asciz "ONE_LEVEL"
.Lxkb_type_alphabetic:  .asciz "ALPHABETIC"
.Lxkb_type_four_level:  .asciz "FOUR_LEVEL"
.Lxkb_type_eight_level: .asciz "EIGHT_LEVEL"
.Lxkb_type_three_level: .asciz "THREE_LEVEL"
.Lxkb_type_separate:    .asciz "SEPARATE_CAPS_AND_SHIFT_ALPHABETIC"
.Lxkb_type_keypad:      .asciz "KEYPAD"

# Encoded as: one-byte name length, name bytes, one-byte ASCII value.
.Lxkb_ascii_symbols:
    .byte 5
    .ascii "comma"
    .byte 44
    .byte 6
    .ascii "period"
    .byte 46
    .byte 5
    .ascii "slash"
    .byte 47
    .byte 5
    .ascii "minus"
    .byte 45
    .byte 5
    .ascii "equal"
    .byte 61
    .byte 4
    .ascii "plus"
    .byte 43
    .byte 9
    .ascii "semicolon"
    .byte 59
    .byte 10
    .ascii "apostrophe"
    .byte 39
    .byte 10
    .ascii "quoteright"
    .byte 39
    .byte 5
    .ascii "grave"
    .byte 96
    .byte 9
    .ascii "quoteleft"
    .byte 96
    .byte 9
    .ascii "backslash"
    .byte 92
    .byte 11
    .ascii "bracketleft"
    .byte 91
    .byte 12
    .ascii "bracketright"
    .byte 93
    .byte 9
    .ascii "braceleft"
    .byte 123
    .byte 10
    .ascii "braceright"
    .byte 125
    .byte 4
    .ascii "less"
    .byte 60
    .byte 7
    .ascii "greater"
    .byte 62
    .byte 8
    .ascii "question"
    .byte 63
    .byte 6
    .ascii "exclam"
    .byte 33
    .byte 2
    .ascii "at"
    .byte 64
    .byte 10
    .ascii "numbersign"
    .byte 35
    .byte 6
    .ascii "dollar"
    .byte 36
    .byte 7
    .ascii "percent"
    .byte 37
    .byte 11
    .ascii "asciicircum"
    .byte 94
    .byte 9
    .ascii "ampersand"
    .byte 38
    .byte 8
    .ascii "asterisk"
    .byte 42
    .byte 9
    .ascii "parenleft"
    .byte 40
    .byte 10
    .ascii "parenright"
    .byte 41
    .byte 10
    .ascii "underscore"
    .byte 95
    .byte 8
    .ascii "quotedbl"
    .byte 34
    .byte 5
    .ascii "colon"
    .byte 58
    .byte 3
    .ascii "bar"
    .byte 124
    .byte 10
    .ascii "asciitilde"
    .byte 126
    .byte 5
    .ascii "space"
    .byte 32
    .byte 0

# Selected common X11/XKB named non-ASCII keysyms. Record encoding:
# one-byte name length, exact case-sensitive symbol name, uint32 Unicode scalar.
# X.Org Unicode-annotated named keysyms plus current xorgproto 2026.1 aliases.
# Record format: one-byte name length, exact case-sensitive name, uint32 scalar/action marker.
.Lxkb_unicode_symbols:
.byte 2
.ascii "AE"
.long 0xc6
.byte 6
.ascii "Aacute"
.long 0xc1
.byte 9
.ascii "Abelowdot"
.long 0x1ea0
.byte 6
.ascii "Abreve"
.long 0x102
.byte 11
.ascii "Abreveacute"
.long 0x1eae
.byte 14
.ascii "Abrevebelowdot"
.long 0x1eb6
.byte 11
.ascii "Abrevegrave"
.long 0x1eb0
.byte 10
.ascii "Abrevehook"
.long 0x1eb2
.byte 11
.ascii "Abrevetilde"
.long 0x1eb4
.byte 11
.ascii "Acircumflex"
.long 0xc2
.byte 16
.ascii "Acircumflexacute"
.long 0x1ea4
.byte 19
.ascii "Acircumflexbelowdot"
.long 0x1eac
.byte 16
.ascii "Acircumflexgrave"
.long 0x1ea6
.byte 15
.ascii "Acircumflexhook"
.long 0x1ea8
.byte 16
.ascii "Acircumflextilde"
.long 0x1eaa
.byte 10
.ascii "Adiaeresis"
.long 0xc4
.byte 6
.ascii "Agrave"
.long 0xc0
.byte 5
.ascii "Ahook"
.long 0x1ea2
.byte 7
.ascii "Amacron"
.long 0x100
.byte 7
.ascii "Aogonek"
.long 0x104
.byte 8
.ascii "Arabic_0"
.long 0x660
.byte 8
.ascii "Arabic_1"
.long 0x661
.byte 8
.ascii "Arabic_2"
.long 0x662
.byte 8
.ascii "Arabic_3"
.long 0x663
.byte 8
.ascii "Arabic_4"
.long 0x664
.byte 8
.ascii "Arabic_5"
.long 0x665
.byte 8
.ascii "Arabic_6"
.long 0x666
.byte 8
.ascii "Arabic_7"
.long 0x667
.byte 8
.ascii "Arabic_8"
.long 0x668
.byte 8
.ascii "Arabic_9"
.long 0x669
.byte 10
.ascii "Arabic_ain"
.long 0x639
.byte 11
.ascii "Arabic_alef"
.long 0x627
.byte 18
.ascii "Arabic_alefmaksura"
.long 0x649
.byte 10
.ascii "Arabic_beh"
.long 0x628
.byte 12
.ascii "Arabic_comma"
.long 0x60c
.byte 10
.ascii "Arabic_dad"
.long 0x636
.byte 10
.ascii "Arabic_dal"
.long 0x62f
.byte 12
.ascii "Arabic_damma"
.long 0x64f
.byte 15
.ascii "Arabic_dammatan"
.long 0x64c
.byte 11
.ascii "Arabic_ddal"
.long 0x688
.byte 16
.ascii "Arabic_farsi_yeh"
.long 0x6cc
.byte 12
.ascii "Arabic_fatha"
.long 0x64e
.byte 15
.ascii "Arabic_fathatan"
.long 0x64b
.byte 10
.ascii "Arabic_feh"
.long 0x641
.byte 15
.ascii "Arabic_fullstop"
.long 0x6d4
.byte 10
.ascii "Arabic_gaf"
.long 0x6af
.byte 12
.ascii "Arabic_ghain"
.long 0x63a
.byte 9
.ascii "Arabic_ha"
.long 0x647
.byte 10
.ascii "Arabic_hah"
.long 0x62d
.byte 12
.ascii "Arabic_hamza"
.long 0x621
.byte 18
.ascii "Arabic_hamza_above"
.long 0x654
.byte 18
.ascii "Arabic_hamza_below"
.long 0x655
.byte 18
.ascii "Arabic_hamzaonalef"
.long 0x623
.byte 17
.ascii "Arabic_hamzaonwaw"
.long 0x624
.byte 17
.ascii "Arabic_hamzaonyeh"
.long 0x626
.byte 21
.ascii "Arabic_hamzaunderalef"
.long 0x625
.byte 10
.ascii "Arabic_heh"
.long 0x647
.byte 22
.ascii "Arabic_heh_doachashmee"
.long 0x6be
.byte 15
.ascii "Arabic_heh_goal"
.long 0x6c1
.byte 11
.ascii "Arabic_jeem"
.long 0x62c
.byte 10
.ascii "Arabic_jeh"
.long 0x698
.byte 10
.ascii "Arabic_kaf"
.long 0x643
.byte 12
.ascii "Arabic_kasra"
.long 0x650
.byte 15
.ascii "Arabic_kasratan"
.long 0x64d
.byte 12
.ascii "Arabic_keheh"
.long 0x6a9
.byte 11
.ascii "Arabic_khah"
.long 0x62e
.byte 10
.ascii "Arabic_lam"
.long 0x644
.byte 18
.ascii "Arabic_madda_above"
.long 0x653
.byte 18
.ascii "Arabic_maddaonalef"
.long 0x622
.byte 11
.ascii "Arabic_meem"
.long 0x645
.byte 11
.ascii "Arabic_noon"
.long 0x646
.byte 18
.ascii "Arabic_noon_ghunna"
.long 0x6ba
.byte 10
.ascii "Arabic_peh"
.long 0x67e
.byte 14
.ascii "Arabic_percent"
.long 0x66a
.byte 10
.ascii "Arabic_qaf"
.long 0x642
.byte 20
.ascii "Arabic_question_mark"
.long 0x61f
.byte 9
.ascii "Arabic_ra"
.long 0x631
.byte 11
.ascii "Arabic_rreh"
.long 0x691
.byte 10
.ascii "Arabic_sad"
.long 0x635
.byte 11
.ascii "Arabic_seen"
.long 0x633
.byte 16
.ascii "Arabic_semicolon"
.long 0x61b
.byte 13
.ascii "Arabic_shadda"
.long 0x651
.byte 12
.ascii "Arabic_sheen"
.long 0x634
.byte 12
.ascii "Arabic_sukun"
.long 0x652
.byte 23
.ascii "Arabic_superscript_alef"
.long 0x670
.byte 10
.ascii "Arabic_tah"
.long 0x637
.byte 14
.ascii "Arabic_tatweel"
.long 0x640
.byte 12
.ascii "Arabic_tcheh"
.long 0x686
.byte 10
.ascii "Arabic_teh"
.long 0x62a
.byte 17
.ascii "Arabic_tehmarbuta"
.long 0x629
.byte 11
.ascii "Arabic_thal"
.long 0x630
.byte 11
.ascii "Arabic_theh"
.long 0x62b
.byte 11
.ascii "Arabic_tteh"
.long 0x679
.byte 10
.ascii "Arabic_veh"
.long 0x6a4
.byte 10
.ascii "Arabic_waw"
.long 0x648
.byte 10
.ascii "Arabic_yeh"
.long 0x64a
.byte 16
.ascii "Arabic_yeh_baree"
.long 0x6d2
.byte 10
.ascii "Arabic_zah"
.long 0x638
.byte 11
.ascii "Arabic_zain"
.long 0x632
.byte 5
.ascii "Aring"
.long 0xc5
.byte 11
.ascii "Armenian_AT"
.long 0x538
.byte 12
.ascii "Armenian_AYB"
.long 0x531
.byte 12
.ascii "Armenian_BEN"
.long 0x532
.byte 12
.ascii "Armenian_CHA"
.long 0x549
.byte 11
.ascii "Armenian_DA"
.long 0x534
.byte 12
.ascii "Armenian_DZA"
.long 0x541
.byte 10
.ascii "Armenian_E"
.long 0x537
.byte 11
.ascii "Armenian_FE"
.long 0x556
.byte 13
.ascii "Armenian_GHAT"
.long 0x542
.byte 12
.ascii "Armenian_GIM"
.long 0x533
.byte 11
.ascii "Armenian_HI"
.long 0x545
.byte 11
.ascii "Armenian_HO"
.long 0x540
.byte 12
.ascii "Armenian_INI"
.long 0x53b
.byte 11
.ascii "Armenian_JE"
.long 0x54b
.byte 11
.ascii "Armenian_KE"
.long 0x554
.byte 12
.ascii "Armenian_KEN"
.long 0x53f
.byte 12
.ascii "Armenian_KHE"
.long 0x53d
.byte 13
.ascii "Armenian_LYUN"
.long 0x53c
.byte 12
.ascii "Armenian_MEN"
.long 0x544
.byte 11
.ascii "Armenian_NU"
.long 0x546
.byte 10
.ascii "Armenian_O"
.long 0x555
.byte 11
.ascii "Armenian_PE"
.long 0x54a
.byte 13
.ascii "Armenian_PYUR"
.long 0x553
.byte 11
.ascii "Armenian_RA"
.long 0x54c
.byte 11
.ascii "Armenian_RE"
.long 0x550
.byte 11
.ascii "Armenian_SE"
.long 0x54d
.byte 12
.ascii "Armenian_SHA"
.long 0x547
.byte 13
.ascii "Armenian_TCHE"
.long 0x543
.byte 11
.ascii "Armenian_TO"
.long 0x539
.byte 12
.ascii "Armenian_TSA"
.long 0x53e
.byte 12
.ascii "Armenian_TSO"
.long 0x551
.byte 13
.ascii "Armenian_TYUN"
.long 0x54f
.byte 12
.ascii "Armenian_VEV"
.long 0x54e
.byte 11
.ascii "Armenian_VO"
.long 0x548
.byte 13
.ascii "Armenian_VYUN"
.long 0x552
.byte 13
.ascii "Armenian_YECH"
.long 0x535
.byte 11
.ascii "Armenian_ZA"
.long 0x536
.byte 12
.ascii "Armenian_ZHE"
.long 0x53a
.byte 15
.ascii "Armenian_accent"
.long 0x55b
.byte 15
.ascii "Armenian_amanak"
.long 0x55c
.byte 19
.ascii "Armenian_apostrophe"
.long 0x55a
.byte 11
.ascii "Armenian_at"
.long 0x568
.byte 12
.ascii "Armenian_ayb"
.long 0x561
.byte 12
.ascii "Armenian_ben"
.long 0x562
.byte 12
.ascii "Armenian_but"
.long 0x55d
.byte 12
.ascii "Armenian_cha"
.long 0x579
.byte 11
.ascii "Armenian_da"
.long 0x564
.byte 12
.ascii "Armenian_dza"
.long 0x571
.byte 10
.ascii "Armenian_e"
.long 0x567
.byte 15
.ascii "Armenian_exclam"
.long 0x55c
.byte 11
.ascii "Armenian_fe"
.long 0x586
.byte 18
.ascii "Armenian_full_stop"
.long 0x589
.byte 13
.ascii "Armenian_ghat"
.long 0x572
.byte 12
.ascii "Armenian_gim"
.long 0x563
.byte 11
.ascii "Armenian_hi"
.long 0x575
.byte 11
.ascii "Armenian_ho"
.long 0x570
.byte 15
.ascii "Armenian_hyphen"
.long 0x58a
.byte 12
.ascii "Armenian_ini"
.long 0x56b
.byte 11
.ascii "Armenian_je"
.long 0x57b
.byte 11
.ascii "Armenian_ke"
.long 0x584
.byte 12
.ascii "Armenian_ken"
.long 0x56f
.byte 12
.ascii "Armenian_khe"
.long 0x56d
.byte 20
.ascii "Armenian_ligature_ew"
.long 0x587
.byte 13
.ascii "Armenian_lyun"
.long 0x56c
.byte 12
.ascii "Armenian_men"
.long 0x574
.byte 11
.ascii "Armenian_nu"
.long 0x576
.byte 10
.ascii "Armenian_o"
.long 0x585
.byte 15
.ascii "Armenian_paruyk"
.long 0x55e
.byte 11
.ascii "Armenian_pe"
.long 0x57a
.byte 13
.ascii "Armenian_pyur"
.long 0x583
.byte 17
.ascii "Armenian_question"
.long 0x55e
.byte 11
.ascii "Armenian_ra"
.long 0x57c
.byte 11
.ascii "Armenian_re"
.long 0x580
.byte 11
.ascii "Armenian_se"
.long 0x57d
.byte 24
.ascii "Armenian_separation_mark"
.long 0x55d
.byte 12
.ascii "Armenian_sha"
.long 0x577
.byte 15
.ascii "Armenian_shesht"
.long 0x55b
.byte 13
.ascii "Armenian_tche"
.long 0x573
.byte 11
.ascii "Armenian_to"
.long 0x569
.byte 12
.ascii "Armenian_tsa"
.long 0x56e
.byte 12
.ascii "Armenian_tso"
.long 0x581
.byte 13
.ascii "Armenian_tyun"
.long 0x57f
.byte 17
.ascii "Armenian_verjaket"
.long 0x589
.byte 12
.ascii "Armenian_vev"
.long 0x57e
.byte 11
.ascii "Armenian_vo"
.long 0x578
.byte 13
.ascii "Armenian_vyun"
.long 0x582
.byte 13
.ascii "Armenian_yech"
.long 0x565
.byte 17
.ascii "Armenian_yentamna"
.long 0x58a
.byte 11
.ascii "Armenian_za"
.long 0x566
.byte 12
.ascii "Armenian_zhe"
.long 0x56a
.byte 6
.ascii "Atilde"
.long 0xc3
.byte 9
.ascii "Babovedot"
.long 0x1e02
.byte 19
.ascii "Byelorussian_SHORTU"
.long 0x40e
.byte 19
.ascii "Byelorussian_shortu"
.long 0x45e
.byte 9
.ascii "Cabovedot"
.long 0x10a
.byte 6
.ascii "Cacute"
.long 0x106
.byte 6
.ascii "Ccaron"
.long 0x10c
.byte 8
.ascii "Ccedilla"
.long 0xc7
.byte 11
.ascii "Ccircumflex"
.long 0x108
.byte 9
.ascii "ColonSign"
.long 0x20a1
.byte 12
.ascii "CruzeiroSign"
.long 0x20a2
.byte 10
.ascii "Cyrillic_A"
.long 0x410
.byte 11
.ascii "Cyrillic_BE"
.long 0x411
.byte 12
.ascii "Cyrillic_CHE"
.long 0x427
.byte 22
.ascii "Cyrillic_CHE_descender"
.long 0x4b6
.byte 23
.ascii "Cyrillic_CHE_vertstroke"
.long 0x4b8
.byte 11
.ascii "Cyrillic_DE"
.long 0x414
.byte 13
.ascii "Cyrillic_DZHE"
.long 0x40f
.byte 10
.ascii "Cyrillic_E"
.long 0x42d
.byte 11
.ascii "Cyrillic_EF"
.long 0x424
.byte 11
.ascii "Cyrillic_EL"
.long 0x41b
.byte 11
.ascii "Cyrillic_EM"
.long 0x41c
.byte 11
.ascii "Cyrillic_EN"
.long 0x41d
.byte 21
.ascii "Cyrillic_EN_descender"
.long 0x4a2
.byte 11
.ascii "Cyrillic_ER"
.long 0x420
.byte 11
.ascii "Cyrillic_ES"
.long 0x421
.byte 12
.ascii "Cyrillic_GHE"
.long 0x413
.byte 16
.ascii "Cyrillic_GHE_bar"
.long 0x492
.byte 11
.ascii "Cyrillic_HA"
.long 0x425
.byte 17
.ascii "Cyrillic_HARDSIGN"
.long 0x42a
.byte 21
.ascii "Cyrillic_HA_descender"
.long 0x4b2
.byte 10
.ascii "Cyrillic_I"
.long 0x418
.byte 11
.ascii "Cyrillic_IE"
.long 0x415
.byte 11
.ascii "Cyrillic_IO"
.long 0x401
.byte 17
.ascii "Cyrillic_I_macron"
.long 0x4e2
.byte 11
.ascii "Cyrillic_JE"
.long 0x408
.byte 11
.ascii "Cyrillic_KA"
.long 0x41a
.byte 21
.ascii "Cyrillic_KA_descender"
.long 0x49a
.byte 22
.ascii "Cyrillic_KA_vertstroke"
.long 0x49c
.byte 12
.ascii "Cyrillic_LJE"
.long 0x409
.byte 12
.ascii "Cyrillic_NJE"
.long 0x40a
.byte 10
.ascii "Cyrillic_O"
.long 0x41e
.byte 14
.ascii "Cyrillic_O_bar"
.long 0x4e8
.byte 11
.ascii "Cyrillic_PE"
.long 0x41f
.byte 14
.ascii "Cyrillic_SCHWA"
.long 0x4d8
.byte 12
.ascii "Cyrillic_SHA"
.long 0x428
.byte 14
.ascii "Cyrillic_SHCHA"
.long 0x429
.byte 13
.ascii "Cyrillic_SHHA"
.long 0x4ba
.byte 15
.ascii "Cyrillic_SHORTI"
.long 0x419
.byte 17
.ascii "Cyrillic_SOFTSIGN"
.long 0x42c
.byte 11
.ascii "Cyrillic_TE"
.long 0x422
.byte 12
.ascii "Cyrillic_TSE"
.long 0x426
.byte 10
.ascii "Cyrillic_U"
.long 0x423
.byte 17
.ascii "Cyrillic_U_macron"
.long 0x4ee
.byte 19
.ascii "Cyrillic_U_straight"
.long 0x4ae
.byte 23
.ascii "Cyrillic_U_straight_bar"
.long 0x4b0
.byte 11
.ascii "Cyrillic_VE"
.long 0x412
.byte 11
.ascii "Cyrillic_YA"
.long 0x42f
.byte 13
.ascii "Cyrillic_YERU"
.long 0x42b
.byte 11
.ascii "Cyrillic_YU"
.long 0x42e
.byte 11
.ascii "Cyrillic_ZE"
.long 0x417
.byte 12
.ascii "Cyrillic_ZHE"
.long 0x416
.byte 22
.ascii "Cyrillic_ZHE_descender"
.long 0x496
.byte 10
.ascii "Cyrillic_a"
.long 0x430
.byte 11
.ascii "Cyrillic_be"
.long 0x431
.byte 12
.ascii "Cyrillic_che"
.long 0x447
.byte 22
.ascii "Cyrillic_che_descender"
.long 0x4b7
.byte 23
.ascii "Cyrillic_che_vertstroke"
.long 0x4b9
.byte 11
.ascii "Cyrillic_de"
.long 0x434
.byte 13
.ascii "Cyrillic_dzhe"
.long 0x45f
.byte 10
.ascii "Cyrillic_e"
.long 0x44d
.byte 11
.ascii "Cyrillic_ef"
.long 0x444
.byte 11
.ascii "Cyrillic_el"
.long 0x43b
.byte 11
.ascii "Cyrillic_em"
.long 0x43c
.byte 11
.ascii "Cyrillic_en"
.long 0x43d
.byte 21
.ascii "Cyrillic_en_descender"
.long 0x4a3
.byte 11
.ascii "Cyrillic_er"
.long 0x440
.byte 11
.ascii "Cyrillic_es"
.long 0x441
.byte 12
.ascii "Cyrillic_ghe"
.long 0x433
.byte 16
.ascii "Cyrillic_ghe_bar"
.long 0x493
.byte 11
.ascii "Cyrillic_ha"
.long 0x445
.byte 21
.ascii "Cyrillic_ha_descender"
.long 0x4b3
.byte 17
.ascii "Cyrillic_hardsign"
.long 0x44a
.byte 10
.ascii "Cyrillic_i"
.long 0x438
.byte 17
.ascii "Cyrillic_i_macron"
.long 0x4e3
.byte 11
.ascii "Cyrillic_ie"
.long 0x435
.byte 11
.ascii "Cyrillic_io"
.long 0x451
.byte 11
.ascii "Cyrillic_je"
.long 0x458
.byte 11
.ascii "Cyrillic_ka"
.long 0x43a
.byte 21
.ascii "Cyrillic_ka_descender"
.long 0x49b
.byte 22
.ascii "Cyrillic_ka_vertstroke"
.long 0x49d
.byte 12
.ascii "Cyrillic_lje"
.long 0x459
.byte 12
.ascii "Cyrillic_nje"
.long 0x45a
.byte 10
.ascii "Cyrillic_o"
.long 0x43e
.byte 14
.ascii "Cyrillic_o_bar"
.long 0x4e9
.byte 11
.ascii "Cyrillic_pe"
.long 0x43f
.byte 14
.ascii "Cyrillic_schwa"
.long 0x4d9
.byte 12
.ascii "Cyrillic_sha"
.long 0x448
.byte 14
.ascii "Cyrillic_shcha"
.long 0x449
.byte 13
.ascii "Cyrillic_shha"
.long 0x4bb
.byte 15
.ascii "Cyrillic_shorti"
.long 0x439
.byte 17
.ascii "Cyrillic_softsign"
.long 0x44c
.byte 11
.ascii "Cyrillic_te"
.long 0x442
.byte 12
.ascii "Cyrillic_tse"
.long 0x446
.byte 10
.ascii "Cyrillic_u"
.long 0x443
.byte 17
.ascii "Cyrillic_u_macron"
.long 0x4ef
.byte 19
.ascii "Cyrillic_u_straight"
.long 0x4af
.byte 23
.ascii "Cyrillic_u_straight_bar"
.long 0x4b1
.byte 11
.ascii "Cyrillic_ve"
.long 0x432
.byte 11
.ascii "Cyrillic_ya"
.long 0x44f
.byte 13
.ascii "Cyrillic_yeru"
.long 0x44b
.byte 11
.ascii "Cyrillic_yu"
.long 0x44e
.byte 11
.ascii "Cyrillic_ze"
.long 0x437
.byte 12
.ascii "Cyrillic_zhe"
.long 0x436
.byte 22
.ascii "Cyrillic_zhe_descender"
.long 0x497
.byte 9
.ascii "Dabovedot"
.long 0x1e0a
.byte 6
.ascii "Dcaron"
.long 0x10e
.byte 8
.ascii "DongSign"
.long 0x20ab
.byte 7
.ascii "Dstroke"
.long 0x110
.byte 3
.ascii "ENG"
.long 0x14a
.byte 3
.ascii "ETH"
.long 0xd0
.byte 3
.ascii "EZH"
.long 0x1b7
.byte 9
.ascii "Eabovedot"
.long 0x116
.byte 6
.ascii "Eacute"
.long 0xc9
.byte 9
.ascii "Ebelowdot"
.long 0x1eb8
.byte 6
.ascii "Ecaron"
.long 0x11a
.byte 11
.ascii "Ecircumflex"
.long 0xca
.byte 16
.ascii "Ecircumflexacute"
.long 0x1ebe
.byte 19
.ascii "Ecircumflexbelowdot"
.long 0x1ec6
.byte 16
.ascii "Ecircumflexgrave"
.long 0x1ec0
.byte 15
.ascii "Ecircumflexhook"
.long 0x1ec2
.byte 16
.ascii "Ecircumflextilde"
.long 0x1ec4
.byte 7
.ascii "EcuSign"
.long 0x20a0
.byte 10
.ascii "Ediaeresis"
.long 0xcb
.byte 6
.ascii "Egrave"
.long 0xc8
.byte 5
.ascii "Ehook"
.long 0x1eba
.byte 7
.ascii "Emacron"
.long 0x112
.byte 7
.ascii "Eogonek"
.long 0x118
.byte 3
.ascii "Eth"
.long 0xd0
.byte 6
.ascii "Etilde"
.long 0x1ebc
.byte 8
.ascii "EuroSign"
.long 0x20ac
.byte 10
.ascii "FFrancSign"
.long 0x20a3
.byte 9
.ascii "Fabovedot"
.long 0x1e1e
.byte 7
.ascii "Farsi_0"
.long 0x6f0
.byte 7
.ascii "Farsi_1"
.long 0x6f1
.byte 7
.ascii "Farsi_2"
.long 0x6f2
.byte 7
.ascii "Farsi_3"
.long 0x6f3
.byte 7
.ascii "Farsi_4"
.long 0x6f4
.byte 7
.ascii "Farsi_5"
.long 0x6f5
.byte 7
.ascii "Farsi_6"
.long 0x6f6
.byte 7
.ascii "Farsi_7"
.long 0x6f7
.byte 7
.ascii "Farsi_8"
.long 0x6f8
.byte 7
.ascii "Farsi_9"
.long 0x6f9
.byte 9
.ascii "Farsi_yeh"
.long 0x6cc
.byte 9
.ascii "Gabovedot"
.long 0x120
.byte 6
.ascii "Gbreve"
.long 0x11e
.byte 6
.ascii "Gcaron"
.long 0x1e6
.byte 8
.ascii "Gcedilla"
.long 0x122
.byte 11
.ascii "Gcircumflex"
.long 0x11c
.byte 11
.ascii "Georgian_an"
.long 0x10d0
.byte 12
.ascii "Georgian_ban"
.long 0x10d1
.byte 12
.ascii "Georgian_can"
.long 0x10ea
.byte 13
.ascii "Georgian_char"
.long 0x10ed
.byte 13
.ascii "Georgian_chin"
.long 0x10e9
.byte 12
.ascii "Georgian_cil"
.long 0x10ec
.byte 12
.ascii "Georgian_don"
.long 0x10d3
.byte 11
.ascii "Georgian_en"
.long 0x10d4
.byte 11
.ascii "Georgian_fi"
.long 0x10f6
.byte 12
.ascii "Georgian_gan"
.long 0x10d2
.byte 13
.ascii "Georgian_ghan"
.long 0x10e6
.byte 12
.ascii "Georgian_hae"
.long 0x10f0
.byte 12
.ascii "Georgian_har"
.long 0x10f4
.byte 11
.ascii "Georgian_he"
.long 0x10f1
.byte 12
.ascii "Georgian_hie"
.long 0x10f2
.byte 12
.ascii "Georgian_hoe"
.long 0x10f5
.byte 11
.ascii "Georgian_in"
.long 0x10d8
.byte 13
.ascii "Georgian_jhan"
.long 0x10ef
.byte 12
.ascii "Georgian_jil"
.long 0x10eb
.byte 12
.ascii "Georgian_kan"
.long 0x10d9
.byte 13
.ascii "Georgian_khar"
.long 0x10e5
.byte 12
.ascii "Georgian_las"
.long 0x10da
.byte 12
.ascii "Georgian_man"
.long 0x10db
.byte 12
.ascii "Georgian_nar"
.long 0x10dc
.byte 11
.ascii "Georgian_on"
.long 0x10dd
.byte 12
.ascii "Georgian_par"
.long 0x10de
.byte 13
.ascii "Georgian_phar"
.long 0x10e4
.byte 12
.ascii "Georgian_qar"
.long 0x10e7
.byte 12
.ascii "Georgian_rae"
.long 0x10e0
.byte 12
.ascii "Georgian_san"
.long 0x10e1
.byte 13
.ascii "Georgian_shin"
.long 0x10e8
.byte 12
.ascii "Georgian_tan"
.long 0x10d7
.byte 12
.ascii "Georgian_tar"
.long 0x10e2
.byte 11
.ascii "Georgian_un"
.long 0x10e3
.byte 12
.ascii "Georgian_vin"
.long 0x10d5
.byte 11
.ascii "Georgian_we"
.long 0x10f3
.byte 12
.ascii "Georgian_xan"
.long 0x10ee
.byte 12
.ascii "Georgian_zen"
.long 0x10d6
.byte 13
.ascii "Georgian_zhar"
.long 0x10df
.byte 11
.ascii "Greek_ALPHA"
.long 0x391
.byte 17
.ascii "Greek_ALPHAaccent"
.long 0x386
.byte 10
.ascii "Greek_BETA"
.long 0x392
.byte 9
.ascii "Greek_CHI"
.long 0x3a7
.byte 11
.ascii "Greek_DELTA"
.long 0x394
.byte 13
.ascii "Greek_EPSILON"
.long 0x395
.byte 19
.ascii "Greek_EPSILONaccent"
.long 0x388
.byte 9
.ascii "Greek_ETA"
.long 0x397
.byte 15
.ascii "Greek_ETAaccent"
.long 0x389
.byte 11
.ascii "Greek_GAMMA"
.long 0x393
.byte 10
.ascii "Greek_IOTA"
.long 0x399
.byte 16
.ascii "Greek_IOTAaccent"
.long 0x38a
.byte 19
.ascii "Greek_IOTAdiaeresis"
.long 0x3aa
.byte 18
.ascii "Greek_IOTAdieresis"
.long 0x3aa
.byte 11
.ascii "Greek_KAPPA"
.long 0x39a
.byte 12
.ascii "Greek_LAMBDA"
.long 0x39b
.byte 11
.ascii "Greek_LAMDA"
.long 0x39b
.byte 8
.ascii "Greek_MU"
.long 0x39c
.byte 8
.ascii "Greek_NU"
.long 0x39d
.byte 11
.ascii "Greek_OMEGA"
.long 0x3a9
.byte 17
.ascii "Greek_OMEGAaccent"
.long 0x38f
.byte 13
.ascii "Greek_OMICRON"
.long 0x39f
.byte 19
.ascii "Greek_OMICRONaccent"
.long 0x38c
.byte 9
.ascii "Greek_PHI"
.long 0x3a6
.byte 8
.ascii "Greek_PI"
.long 0x3a0
.byte 9
.ascii "Greek_PSI"
.long 0x3a8
.byte 9
.ascii "Greek_RHO"
.long 0x3a1
.byte 11
.ascii "Greek_SIGMA"
.long 0x3a3
.byte 9
.ascii "Greek_TAU"
.long 0x3a4
.byte 11
.ascii "Greek_THETA"
.long 0x398
.byte 13
.ascii "Greek_UPSILON"
.long 0x3a5
.byte 19
.ascii "Greek_UPSILONaccent"
.long 0x38e
.byte 21
.ascii "Greek_UPSILONdieresis"
.long 0x3ab
.byte 8
.ascii "Greek_XI"
.long 0x39e
.byte 10
.ascii "Greek_ZETA"
.long 0x396
.byte 20
.ascii "Greek_accentdieresis"
.long 0x385
.byte 11
.ascii "Greek_alpha"
.long 0x3b1
.byte 17
.ascii "Greek_alphaaccent"
.long 0x3ac
.byte 10
.ascii "Greek_beta"
.long 0x3b2
.byte 9
.ascii "Greek_chi"
.long 0x3c7
.byte 11
.ascii "Greek_delta"
.long 0x3b4
.byte 13
.ascii "Greek_epsilon"
.long 0x3b5
.byte 19
.ascii "Greek_epsilonaccent"
.long 0x3ad
.byte 9
.ascii "Greek_eta"
.long 0x3b7
.byte 15
.ascii "Greek_etaaccent"
.long 0x3ae
.byte 21
.ascii "Greek_finalsmallsigma"
.long 0x3c2
.byte 11
.ascii "Greek_gamma"
.long 0x3b3
.byte 14
.ascii "Greek_horizbar"
.long 0x2015
.byte 10
.ascii "Greek_iota"
.long 0x3b9
.byte 16
.ascii "Greek_iotaaccent"
.long 0x3af
.byte 24
.ascii "Greek_iotaaccentdieresis"
.long 0x390
.byte 18
.ascii "Greek_iotadieresis"
.long 0x3ca
.byte 11
.ascii "Greek_kappa"
.long 0x3ba
.byte 12
.ascii "Greek_lambda"
.long 0x3bb
.byte 11
.ascii "Greek_lamda"
.long 0x3bb
.byte 8
.ascii "Greek_mu"
.long 0x3bc
.byte 8
.ascii "Greek_nu"
.long 0x3bd
.byte 11
.ascii "Greek_omega"
.long 0x3c9
.byte 17
.ascii "Greek_omegaaccent"
.long 0x3ce
.byte 13
.ascii "Greek_omicron"
.long 0x3bf
.byte 19
.ascii "Greek_omicronaccent"
.long 0x3cc
.byte 9
.ascii "Greek_phi"
.long 0x3c6
.byte 8
.ascii "Greek_pi"
.long 0x3c0
.byte 9
.ascii "Greek_psi"
.long 0x3c8
.byte 9
.ascii "Greek_rho"
.long 0x3c1
.byte 11
.ascii "Greek_sigma"
.long 0x3c3
.byte 9
.ascii "Greek_tau"
.long 0x3c4
.byte 11
.ascii "Greek_theta"
.long 0x3b8
.byte 13
.ascii "Greek_upsilon"
.long 0x3c5
.byte 19
.ascii "Greek_upsilonaccent"
.long 0x3cd
.byte 27
.ascii "Greek_upsilonaccentdieresis"
.long 0x3b0
.byte 21
.ascii "Greek_upsilondieresis"
.long 0x3cb
.byte 8
.ascii "Greek_xi"
.long 0x3be
.byte 10
.ascii "Greek_zeta"
.long 0x3b6
.byte 8
.ascii "Hangul_A"
.long 0x314f
.byte 9
.ascii "Hangul_AE"
.long 0x3150
.byte 12
.ascii "Hangul_AraeA"
.long 0x318d
.byte 13
.ascii "Hangul_AraeAE"
.long 0x318e
.byte 12
.ascii "Hangul_Cieuc"
.long 0x314a
.byte 13
.ascii "Hangul_Dikeud"
.long 0x3137
.byte 8
.ascii "Hangul_E"
.long 0x3154
.byte 9
.ascii "Hangul_EO"
.long 0x3153
.byte 9
.ascii "Hangul_EU"
.long 0x3161
.byte 12
.ascii "Hangul_Hieuh"
.long 0x314e
.byte 8
.ascii "Hangul_I"
.long 0x3163
.byte 12
.ascii "Hangul_Ieung"
.long 0x3147
.byte 14
.ascii "Hangul_J_Cieuc"
.long 0x11be
.byte 15
.ascii "Hangul_J_Dikeud"
.long 0x11ae
.byte 14
.ascii "Hangul_J_Hieuh"
.long 0x11c2
.byte 14
.ascii "Hangul_J_Ieung"
.long 0x11bc
.byte 14
.ascii "Hangul_J_Jieuj"
.long 0x11bd
.byte 15
.ascii "Hangul_J_Khieuq"
.long 0x11bf
.byte 15
.ascii "Hangul_J_Kiyeog"
.long 0x11a8
.byte 19
.ascii "Hangul_J_KiyeogSios"
.long 0x11aa
.byte 26
.ascii "Hangul_J_KkogjiDalrinIeung"
.long 0x11f0
.byte 14
.ascii "Hangul_J_Mieum"
.long 0x11b7
.byte 14
.ascii "Hangul_J_Nieun"
.long 0x11ab
.byte 19
.ascii "Hangul_J_NieunHieuh"
.long 0x11ad
.byte 19
.ascii "Hangul_J_NieunJieuj"
.long 0x11ac
.byte 16
.ascii "Hangul_J_PanSios"
.long 0x11eb
.byte 15
.ascii "Hangul_J_Phieuf"
.long 0x11c1
.byte 14
.ascii "Hangul_J_Pieub"
.long 0x11b8
.byte 18
.ascii "Hangul_J_PieubSios"
.long 0x11b9
.byte 14
.ascii "Hangul_J_Rieul"
.long 0x11af
.byte 19
.ascii "Hangul_J_RieulHieuh"
.long 0x11b6
.byte 20
.ascii "Hangul_J_RieulKiyeog"
.long 0x11b0
.byte 19
.ascii "Hangul_J_RieulMieum"
.long 0x11b1
.byte 20
.ascii "Hangul_J_RieulPhieuf"
.long 0x11b5
.byte 19
.ascii "Hangul_J_RieulPieub"
.long 0x11b2
.byte 18
.ascii "Hangul_J_RieulSios"
.long 0x11b3
.byte 19
.ascii "Hangul_J_RieulTieut"
.long 0x11b4
.byte 13
.ascii "Hangul_J_Sios"
.long 0x11ba
.byte 20
.ascii "Hangul_J_SsangKiyeog"
.long 0x11a9
.byte 18
.ascii "Hangul_J_SsangSios"
.long 0x11bb
.byte 14
.ascii "Hangul_J_Tieut"
.long 0x11c0
.byte 20
.ascii "Hangul_J_YeorinHieuh"
.long 0x11f9
.byte 12
.ascii "Hangul_Jieuj"
.long 0x3148
.byte 13
.ascii "Hangul_Khieuq"
.long 0x314b
.byte 13
.ascii "Hangul_Kiyeog"
.long 0x3131
.byte 17
.ascii "Hangul_KiyeogSios"
.long 0x3133
.byte 24
.ascii "Hangul_KkogjiDalrinIeung"
.long 0x3181
.byte 12
.ascii "Hangul_Mieum"
.long 0x3141
.byte 12
.ascii "Hangul_Nieun"
.long 0x3134
.byte 17
.ascii "Hangul_NieunHieuh"
.long 0x3136
.byte 17
.ascii "Hangul_NieunJieuj"
.long 0x3135
.byte 8
.ascii "Hangul_O"
.long 0x3157
.byte 9
.ascii "Hangul_OE"
.long 0x315a
.byte 14
.ascii "Hangul_PanSios"
.long 0x317f
.byte 13
.ascii "Hangul_Phieuf"
.long 0x314d
.byte 12
.ascii "Hangul_Pieub"
.long 0x3142
.byte 16
.ascii "Hangul_PieubSios"
.long 0x3144
.byte 12
.ascii "Hangul_Rieul"
.long 0x3139
.byte 17
.ascii "Hangul_RieulHieuh"
.long 0x3140
.byte 18
.ascii "Hangul_RieulKiyeog"
.long 0x313a
.byte 17
.ascii "Hangul_RieulMieum"
.long 0x313b
.byte 18
.ascii "Hangul_RieulPhieuf"
.long 0x313f
.byte 17
.ascii "Hangul_RieulPieub"
.long 0x313c
.byte 16
.ascii "Hangul_RieulSios"
.long 0x313d
.byte 17
.ascii "Hangul_RieulTieut"
.long 0x313e
.byte 23
.ascii "Hangul_RieulYeorinHieuh"
.long 0x316d
.byte 11
.ascii "Hangul_Sios"
.long 0x3145
.byte 18
.ascii "Hangul_SsangDikeud"
.long 0x3138
.byte 17
.ascii "Hangul_SsangJieuj"
.long 0x3149
.byte 18
.ascii "Hangul_SsangKiyeog"
.long 0x3132
.byte 17
.ascii "Hangul_SsangPieub"
.long 0x3143
.byte 16
.ascii "Hangul_SsangSios"
.long 0x3146
.byte 24
.ascii "Hangul_SunkyeongeumMieum"
.long 0x3171
.byte 25
.ascii "Hangul_SunkyeongeumPhieuf"
.long 0x3184
.byte 24
.ascii "Hangul_SunkyeongeumPieub"
.long 0x3178
.byte 12
.ascii "Hangul_Tieut"
.long 0x314c
.byte 8
.ascii "Hangul_U"
.long 0x315c
.byte 9
.ascii "Hangul_WA"
.long 0x3158
.byte 10
.ascii "Hangul_WAE"
.long 0x3159
.byte 9
.ascii "Hangul_WE"
.long 0x315e
.byte 10
.ascii "Hangul_WEO"
.long 0x315d
.byte 9
.ascii "Hangul_WI"
.long 0x315f
.byte 9
.ascii "Hangul_YA"
.long 0x3151
.byte 10
.ascii "Hangul_YAE"
.long 0x3152
.byte 9
.ascii "Hangul_YE"
.long 0x3156
.byte 10
.ascii "Hangul_YEO"
.long 0x3155
.byte 9
.ascii "Hangul_YI"
.long 0x3162
.byte 9
.ascii "Hangul_YO"
.long 0x315b
.byte 9
.ascii "Hangul_YU"
.long 0x3160
.byte 18
.ascii "Hangul_YeorinHieuh"
.long 0x3186
.byte 11
.ascii "Hcircumflex"
.long 0x124
.byte 7
.ascii "Hstroke"
.long 0x126
.byte 9
.ascii "Iabovedot"
.long 0x130
.byte 6
.ascii "Iacute"
.long 0xcd
.byte 9
.ascii "Ibelowdot"
.long 0x1eca
.byte 6
.ascii "Ibreve"
.long 0x12c
.byte 11
.ascii "Icircumflex"
.long 0xce
.byte 10
.ascii "Idiaeresis"
.long 0xcf
.byte 6
.ascii "Igrave"
.long 0xcc
.byte 5
.ascii "Ihook"
.long 0x1ec8
.byte 7
.ascii "Imacron"
.long 0x12a
.byte 7
.ascii "Iogonek"
.long 0x12e
.byte 6
.ascii "Itilde"
.long 0x128
.byte 11
.ascii "Jcircumflex"
.long 0x134
.byte 8
.ascii "Kcedilla"
.long 0x136
.byte 10
.ascii "Korean_Won"
.long 0x20a9
.byte 6
.ascii "Lacute"
.long 0x139
.byte 9
.ascii "Lbelowdot"
.long 0x1e36
.byte 6
.ascii "Lcaron"
.long 0x13d
.byte 8
.ascii "Lcedilla"
.long 0x13b
.byte 8
.ascii "LiraSign"
.long 0x20a4
.byte 7
.ascii "Lstroke"
.long 0x141
.byte 9
.ascii "Mabovedot"
.long 0x1e40
.byte 13
.ascii "Macedonia_DSE"
.long 0x405
.byte 13
.ascii "Macedonia_GJE"
.long 0x403
.byte 13
.ascii "Macedonia_KJE"
.long 0x40c
.byte 13
.ascii "Macedonia_dse"
.long 0x455
.byte 13
.ascii "Macedonia_gje"
.long 0x453
.byte 13
.ascii "Macedonia_kje"
.long 0x45c
.byte 8
.ascii "MillSign"
.long 0x20a5
.byte 9
.ascii "Multi_key"
.long 0x110007
.byte 6
.ascii "Nacute"
.long 0x143
.byte 9
.ascii "NairaSign"
.long 0x20a6
.byte 6
.ascii "Ncaron"
.long 0x147
.byte 8
.ascii "Ncedilla"
.long 0x145
.byte 13
.ascii "NewSheqelSign"
.long 0x20aa
.byte 6
.ascii "Ntilde"
.long 0xd1
.byte 2
.ascii "OE"
.long 0x152
.byte 6
.ascii "Oacute"
.long 0xd3
.byte 7
.ascii "Obarred"
.long 0x19f
.byte 9
.ascii "Obelowdot"
.long 0x1ecc
.byte 6
.ascii "Ocaron"
.long 0x1d1
.byte 11
.ascii "Ocircumflex"
.long 0xd4
.byte 16
.ascii "Ocircumflexacute"
.long 0x1ed0
.byte 19
.ascii "Ocircumflexbelowdot"
.long 0x1ed8
.byte 16
.ascii "Ocircumflexgrave"
.long 0x1ed2
.byte 15
.ascii "Ocircumflexhook"
.long 0x1ed4
.byte 16
.ascii "Ocircumflextilde"
.long 0x1ed6
.byte 10
.ascii "Odiaeresis"
.long 0xd6
.byte 12
.ascii "Odoubleacute"
.long 0x150
.byte 6
.ascii "Ograve"
.long 0xd2
.byte 5
.ascii "Ohook"
.long 0x1ece
.byte 5
.ascii "Ohorn"
.long 0x1a0
.byte 10
.ascii "Ohornacute"
.long 0x1eda
.byte 13
.ascii "Ohornbelowdot"
.long 0x1ee2
.byte 10
.ascii "Ohorngrave"
.long 0x1edc
.byte 9
.ascii "Ohornhook"
.long 0x1ede
.byte 10
.ascii "Ohorntilde"
.long 0x1ee0
.byte 7
.ascii "Omacron"
.long 0x14c
.byte 8
.ascii "Ooblique"
.long 0xd8
.byte 6
.ascii "Oslash"
.long 0xd8
.byte 6
.ascii "Otilde"
.long 0xd5
.byte 9
.ascii "Pabovedot"
.long 0x1e56
.byte 10
.ascii "PesetaSign"
.long 0x20a7
.byte 6
.ascii "Racute"
.long 0x154
.byte 6
.ascii "Rcaron"
.long 0x158
.byte 8
.ascii "Rcedilla"
.long 0x156
.byte 9
.ascii "RupeeSign"
.long 0x20a8
.byte 5
.ascii "SCHWA"
.long 0x18f
.byte 6
.ascii "SSHARP"
.long 0x1e9e
.byte 9
.ascii "Sabovedot"
.long 0x1e60
.byte 6
.ascii "Sacute"
.long 0x15a
.byte 6
.ascii "Scaron"
.long 0x160
.byte 8
.ascii "Scedilla"
.long 0x15e
.byte 11
.ascii "Scircumflex"
.long 0x15c
.byte 11
.ascii "Serbian_DJE"
.long 0x402
.byte 11
.ascii "Serbian_DZE"
.long 0x40f
.byte 10
.ascii "Serbian_JE"
.long 0x408
.byte 11
.ascii "Serbian_LJE"
.long 0x409
.byte 11
.ascii "Serbian_NJE"
.long 0x40a
.byte 12
.ascii "Serbian_TSHE"
.long 0x40b
.byte 11
.ascii "Serbian_dje"
.long 0x452
.byte 11
.ascii "Serbian_dze"
.long 0x45f
.byte 10
.ascii "Serbian_je"
.long 0x458
.byte 11
.ascii "Serbian_lje"
.long 0x459
.byte 11
.ascii "Serbian_nje"
.long 0x45a
.byte 12
.ascii "Serbian_tshe"
.long 0x45b
.byte 6
.ascii "Sinh_a"
.long 0xd85
.byte 7
.ascii "Sinh_aa"
.long 0xd86
.byte 8
.ascii "Sinh_aa2"
.long 0xdcf
.byte 7
.ascii "Sinh_ae"
.long 0xd87
.byte 8
.ascii "Sinh_ae2"
.long 0xdd0
.byte 8
.ascii "Sinh_aee"
.long 0xd88
.byte 9
.ascii "Sinh_aee2"
.long 0xdd1
.byte 7
.ascii "Sinh_ai"
.long 0xd93
.byte 8
.ascii "Sinh_ai2"
.long 0xddb
.byte 7
.ascii "Sinh_al"
.long 0xdca
.byte 7
.ascii "Sinh_au"
.long 0xd96
.byte 8
.ascii "Sinh_au2"
.long 0xdde
.byte 7
.ascii "Sinh_ba"
.long 0xdb6
.byte 8
.ascii "Sinh_bha"
.long 0xdb7
.byte 7
.ascii "Sinh_ca"
.long 0xda0
.byte 8
.ascii "Sinh_cha"
.long 0xda1
.byte 8
.ascii "Sinh_dda"
.long 0xda9
.byte 9
.ascii "Sinh_ddha"
.long 0xdaa
.byte 8
.ascii "Sinh_dha"
.long 0xdaf
.byte 9
.ascii "Sinh_dhha"
.long 0xdb0
.byte 6
.ascii "Sinh_e"
.long 0xd91
.byte 7
.ascii "Sinh_e2"
.long 0xdd9
.byte 7
.ascii "Sinh_ee"
.long 0xd92
.byte 8
.ascii "Sinh_ee2"
.long 0xdda
.byte 7
.ascii "Sinh_fa"
.long 0xdc6
.byte 7
.ascii "Sinh_ga"
.long 0xd9c
.byte 8
.ascii "Sinh_gha"
.long 0xd9d
.byte 7
.ascii "Sinh_h2"
.long 0xd83
.byte 7
.ascii "Sinh_ha"
.long 0xdc4
.byte 6
.ascii "Sinh_i"
.long 0xd89
.byte 7
.ascii "Sinh_i2"
.long 0xdd2
.byte 7
.ascii "Sinh_ii"
.long 0xd8a
.byte 8
.ascii "Sinh_ii2"
.long 0xdd3
.byte 7
.ascii "Sinh_ja"
.long 0xda2
.byte 8
.ascii "Sinh_jha"
.long 0xda3
.byte 9
.ascii "Sinh_jnya"
.long 0xda5
.byte 7
.ascii "Sinh_ka"
.long 0xd9a
.byte 8
.ascii "Sinh_kha"
.long 0xd9b
.byte 15
.ascii "Sinh_kunddaliya"
.long 0xdf4
.byte 7
.ascii "Sinh_la"
.long 0xdbd
.byte 8
.ascii "Sinh_lla"
.long 0xdc5
.byte 7
.ascii "Sinh_lu"
.long 0xd8f
.byte 8
.ascii "Sinh_lu2"
.long 0xddf
.byte 8
.ascii "Sinh_luu"
.long 0xd90
.byte 9
.ascii "Sinh_luu2"
.long 0xdf3
.byte 7
.ascii "Sinh_ma"
.long 0xdb8
.byte 8
.ascii "Sinh_mba"
.long 0xdb9
.byte 7
.ascii "Sinh_na"
.long 0xdb1
.byte 9
.ascii "Sinh_ndda"
.long 0xdac
.byte 9
.ascii "Sinh_ndha"
.long 0xdb3
.byte 7
.ascii "Sinh_ng"
.long 0xd82
.byte 8
.ascii "Sinh_ng2"
.long 0xd9e
.byte 8
.ascii "Sinh_nga"
.long 0xd9f
.byte 8
.ascii "Sinh_nja"
.long 0xda6
.byte 8
.ascii "Sinh_nna"
.long 0xdab
.byte 8
.ascii "Sinh_nya"
.long 0xda4
.byte 6
.ascii "Sinh_o"
.long 0xd94
.byte 7
.ascii "Sinh_o2"
.long 0xddc
.byte 7
.ascii "Sinh_oo"
.long 0xd95
.byte 8
.ascii "Sinh_oo2"
.long 0xddd
.byte 7
.ascii "Sinh_pa"
.long 0xdb4
.byte 8
.ascii "Sinh_pha"
.long 0xdb5
.byte 7
.ascii "Sinh_ra"
.long 0xdbb
.byte 7
.ascii "Sinh_ri"
.long 0xd8d
.byte 8
.ascii "Sinh_rii"
.long 0xd8e
.byte 8
.ascii "Sinh_ru2"
.long 0xdd8
.byte 9
.ascii "Sinh_ruu2"
.long 0xdf2
.byte 7
.ascii "Sinh_sa"
.long 0xdc3
.byte 8
.ascii "Sinh_sha"
.long 0xdc1
.byte 9
.ascii "Sinh_ssha"
.long 0xdc2
.byte 8
.ascii "Sinh_tha"
.long 0xdad
.byte 9
.ascii "Sinh_thha"
.long 0xdae
.byte 8
.ascii "Sinh_tta"
.long 0xda7
.byte 9
.ascii "Sinh_ttha"
.long 0xda8
.byte 6
.ascii "Sinh_u"
.long 0xd8b
.byte 7
.ascii "Sinh_u2"
.long 0xdd4
.byte 7
.ascii "Sinh_uu"
.long 0xd8c
.byte 8
.ascii "Sinh_uu2"
.long 0xdd6
.byte 7
.ascii "Sinh_va"
.long 0xdc0
.byte 7
.ascii "Sinh_ya"
.long 0xdba
.byte 5
.ascii "THORN"
.long 0xde
.byte 9
.ascii "Tabovedot"
.long 0x1e6a
.byte 6
.ascii "Tcaron"
.long 0x164
.byte 8
.ascii "Tcedilla"
.long 0x162
.byte 9
.ascii "Thai_baht"
.long 0xe3f
.byte 13
.ascii "Thai_bobaimai"
.long 0xe1a
.byte 12
.ascii "Thai_chochan"
.long 0xe08
.byte 13
.ascii "Thai_chochang"
.long 0xe0a
.byte 13
.ascii "Thai_choching"
.long 0xe09
.byte 12
.ascii "Thai_chochoe"
.long 0xe0c
.byte 12
.ascii "Thai_dochada"
.long 0xe0e
.byte 10
.ascii "Thai_dodek"
.long 0xe14
.byte 9
.ascii "Thai_fofa"
.long 0xe1d
.byte 10
.ascii "Thai_fofan"
.long 0xe1f
.byte 10
.ascii "Thai_hohip"
.long 0xe2b
.byte 13
.ascii "Thai_honokhuk"
.long 0xe2e
.byte 12
.ascii "Thai_khokhai"
.long 0xe02
.byte 12
.ascii "Thai_khokhon"
.long 0xe05
.byte 13
.ascii "Thai_khokhuat"
.long 0xe03
.byte 13
.ascii "Thai_khokhwai"
.long 0xe04
.byte 15
.ascii "Thai_khorakhang"
.long 0xe06
.byte 10
.ascii "Thai_kokai"
.long 0xe01
.byte 16
.ascii "Thai_lakkhangyao"
.long 0xe45
.byte 12
.ascii "Thai_lekchet"
.long 0xe57
.byte 10
.ascii "Thai_lekha"
.long 0xe55
.byte 11
.ascii "Thai_lekhok"
.long 0xe56
.byte 11
.ascii "Thai_lekkao"
.long 0xe59
.byte 12
.ascii "Thai_leknung"
.long 0xe51
.byte 12
.ascii "Thai_lekpaet"
.long 0xe58
.byte 11
.ascii "Thai_leksam"
.long 0xe53
.byte 10
.ascii "Thai_leksi"
.long 0xe54
.byte 12
.ascii "Thai_leksong"
.long 0xe52
.byte 11
.ascii "Thai_leksun"
.long 0xe50
.byte 12
.ascii "Thai_lochula"
.long 0xe2c
.byte 11
.ascii "Thai_loling"
.long 0xe25
.byte 7
.ascii "Thai_lu"
.long 0xe26
.byte 16
.ascii "Thai_maichattawa"
.long 0xe4b
.byte 10
.ascii "Thai_maiek"
.long 0xe48
.byte 15
.ascii "Thai_maihanakat"
.long 0xe31
.byte 22
.ascii "Thai_maihanakat_maitho"
.long 0xe3e
.byte 14
.ascii "Thai_maitaikhu"
.long 0xe47
.byte 11
.ascii "Thai_maitho"
.long 0xe49
.byte 11
.ascii "Thai_maitri"
.long 0xe4a
.byte 13
.ascii "Thai_maiyamok"
.long 0xe46
.byte 9
.ascii "Thai_moma"
.long 0xe21
.byte 11
.ascii "Thai_ngongu"
.long 0xe07
.byte 13
.ascii "Thai_nikhahit"
.long 0xe4d
.byte 10
.ascii "Thai_nonen"
.long 0xe13
.byte 9
.ascii "Thai_nonu"
.long 0xe19
.byte 9
.ascii "Thai_oang"
.long 0xe2d
.byte 14
.ascii "Thai_paiyannoi"
.long 0xe2f
.byte 12
.ascii "Thai_phinthu"
.long 0xe3a
.byte 12
.ascii "Thai_phophan"
.long 0xe1e
.byte 13
.ascii "Thai_phophung"
.long 0xe1c
.byte 15
.ascii "Thai_phosamphao"
.long 0xe20
.byte 10
.ascii "Thai_popla"
.long 0xe1b
.byte 10
.ascii "Thai_rorua"
.long 0xe23
.byte 7
.ascii "Thai_ru"
.long 0xe24
.byte 10
.ascii "Thai_saraa"
.long 0xe30
.byte 11
.ascii "Thai_saraaa"
.long 0xe32
.byte 11
.ascii "Thai_saraae"
.long 0xe41
.byte 19
.ascii "Thai_saraaimaimalai"
.long 0xe44
.byte 18
.ascii "Thai_saraaimaimuan"
.long 0xe43
.byte 11
.ascii "Thai_saraam"
.long 0xe33
.byte 10
.ascii "Thai_sarae"
.long 0xe40
.byte 10
.ascii "Thai_sarai"
.long 0xe34
.byte 11
.ascii "Thai_saraii"
.long 0xe35
.byte 10
.ascii "Thai_sarao"
.long 0xe42
.byte 10
.ascii "Thai_sarau"
.long 0xe38
.byte 11
.ascii "Thai_saraue"
.long 0xe36
.byte 12
.ascii "Thai_sarauee"
.long 0xe37
.byte 11
.ascii "Thai_sarauu"
.long 0xe39
.byte 11
.ascii "Thai_sorusi"
.long 0xe29
.byte 11
.ascii "Thai_sosala"
.long 0xe28
.byte 9
.ascii "Thai_soso"
.long 0xe0b
.byte 10
.ascii "Thai_sosua"
.long 0xe2a
.byte 16
.ascii "Thai_thanthakhat"
.long 0xe4c
.byte 18
.ascii "Thai_thonangmontho"
.long 0xe11
.byte 15
.ascii "Thai_thophuthao"
.long 0xe12
.byte 14
.ascii "Thai_thothahan"
.long 0xe17
.byte 12
.ascii "Thai_thothan"
.long 0xe10
.byte 13
.ascii "Thai_thothong"
.long 0xe18
.byte 13
.ascii "Thai_thothung"
.long 0xe16
.byte 12
.ascii "Thai_topatak"
.long 0xe0f
.byte 10
.ascii "Thai_totao"
.long 0xe15
.byte 11
.ascii "Thai_wowaen"
.long 0xe27
.byte 10
.ascii "Thai_yoyak"
.long 0xe22
.byte 11
.ascii "Thai_yoying"
.long 0xe0d
.byte 5
.ascii "Thorn"
.long 0xde
.byte 6
.ascii "Tslash"
.long 0x166
.byte 6
.ascii "Uacute"
.long 0xda
.byte 9
.ascii "Ubelowdot"
.long 0x1ee4
.byte 6
.ascii "Ubreve"
.long 0x16c
.byte 11
.ascii "Ucircumflex"
.long 0xdb
.byte 10
.ascii "Udiaeresis"
.long 0xdc
.byte 12
.ascii "Udoubleacute"
.long 0x170
.byte 6
.ascii "Ugrave"
.long 0xd9
.byte 5
.ascii "Uhook"
.long 0x1ee6
.byte 5
.ascii "Uhorn"
.long 0x1af
.byte 10
.ascii "Uhornacute"
.long 0x1ee8
.byte 13
.ascii "Uhornbelowdot"
.long 0x1ef0
.byte 10
.ascii "Uhorngrave"
.long 0x1eea
.byte 9
.ascii "Uhornhook"
.long 0x1eec
.byte 10
.ascii "Uhorntilde"
.long 0x1eee
.byte 25
.ascii "Ukrainian_GHE_WITH_UPTURN"
.long 0x490
.byte 11
.ascii "Ukrainian_I"
.long 0x406
.byte 12
.ascii "Ukrainian_IE"
.long 0x404
.byte 12
.ascii "Ukrainian_YI"
.long 0x407
.byte 25
.ascii "Ukrainian_ghe_with_upturn"
.long 0x491
.byte 11
.ascii "Ukrainian_i"
.long 0x456
.byte 12
.ascii "Ukrainian_ie"
.long 0x454
.byte 12
.ascii "Ukrainian_yi"
.long 0x457
.byte 10
.ascii "Ukranian_I"
.long 0x406
.byte 11
.ascii "Ukranian_JE"
.long 0x404
.byte 11
.ascii "Ukranian_YI"
.long 0x407
.byte 10
.ascii "Ukranian_i"
.long 0x456
.byte 11
.ascii "Ukranian_je"
.long 0x454
.byte 11
.ascii "Ukranian_yi"
.long 0x457
.byte 7
.ascii "Umacron"
.long 0x16a
.byte 7
.ascii "Uogonek"
.long 0x172
.byte 5
.ascii "Uring"
.long 0x16e
.byte 6
.ascii "Utilde"
.long 0x168
.byte 6
.ascii "Wacute"
.long 0x1e82
.byte 11
.ascii "Wcircumflex"
.long 0x174
.byte 10
.ascii "Wdiaeresis"
.long 0x1e84
.byte 6
.ascii "Wgrave"
.long 0x1e80
.byte 7
.ascii "WonSign"
.long 0x20a9
.byte 15
.ascii "XF86XK_Numeric0"
.long 0x30
.byte 15
.ascii "XF86XK_Numeric1"
.long 0x31
.byte 15
.ascii "XF86XK_Numeric2"
.long 0x32
.byte 15
.ascii "XF86XK_Numeric3"
.long 0x33
.byte 15
.ascii "XF86XK_Numeric4"
.long 0x34
.byte 15
.ascii "XF86XK_Numeric5"
.long 0x35
.byte 15
.ascii "XF86XK_Numeric6"
.long 0x36
.byte 15
.ascii "XF86XK_Numeric7"
.long 0x37
.byte 15
.ascii "XF86XK_Numeric8"
.long 0x38
.byte 15
.ascii "XF86XK_Numeric9"
.long 0x39
.byte 19
.ascii "XF86XK_NumericPound"
.long 0x23
.byte 18
.ascii "XF86XK_NumericStar"
.long 0x2a
.byte 9
.ascii "Xabovedot"
.long 0x1e8a
.byte 6
.ascii "Yacute"
.long 0xdd
.byte 9
.ascii "Ybelowdot"
.long 0x1ef4
.byte 11
.ascii "Ycircumflex"
.long 0x176
.byte 10
.ascii "Ydiaeresis"
.long 0x178
.byte 6
.ascii "Ygrave"
.long 0x1ef2
.byte 5
.ascii "Yhook"
.long 0x1ef6
.byte 6
.ascii "Ytilde"
.long 0x1ef8
.byte 9
.ascii "Zabovedot"
.long 0x17b
.byte 6
.ascii "Zacute"
.long 0x179
.byte 6
.ascii "Zcaron"
.long 0x17d
.byte 7
.ascii "Zstroke"
.long 0x1b5
.byte 6
.ascii "aacute"
.long 0xe1
.byte 9
.ascii "abelowdot"
.long 0x1ea1
.byte 8
.ascii "abovedot"
.long 0x2d9
.byte 6
.ascii "abreve"
.long 0x103
.byte 11
.ascii "abreveacute"
.long 0x1eaf
.byte 14
.ascii "abrevebelowdot"
.long 0x1eb7
.byte 11
.ascii "abrevegrave"
.long 0x1eb1
.byte 10
.ascii "abrevehook"
.long 0x1eb3
.byte 11
.ascii "abrevetilde"
.long 0x1eb5
.byte 11
.ascii "acircumflex"
.long 0xe2
.byte 16
.ascii "acircumflexacute"
.long 0x1ea5
.byte 19
.ascii "acircumflexbelowdot"
.long 0x1ead
.byte 16
.ascii "acircumflexgrave"
.long 0x1ea7
.byte 15
.ascii "acircumflexhook"
.long 0x1ea9
.byte 16
.ascii "acircumflextilde"
.long 0x1eab
.byte 5
.ascii "acute"
.long 0xb4
.byte 10
.ascii "adiaeresis"
.long 0xe4
.byte 2
.ascii "ae"
.long 0xe6
.byte 6
.ascii "agrave"
.long 0xe0
.byte 5
.ascii "ahook"
.long 0x1ea3
.byte 7
.ascii "amacron"
.long 0x101
.byte 7
.ascii "aogonek"
.long 0x105
.byte 8
.ascii "approxeq"
.long 0x2248
.byte 11
.ascii "approximate"
.long 0x223c
.byte 5
.ascii "aring"
.long 0xe5
.byte 6
.ascii "atilde"
.long 0xe3
.byte 9
.ascii "babovedot"
.long 0x1e03
.byte 11
.ascii "ballotcross"
.long 0x2717
.byte 7
.ascii "because"
.long 0x2235
.byte 11
.ascii "botintegral"
.long 0x2321
.byte 13
.ascii "botleftparens"
.long 0x239d
.byte 16
.ascii "botleftsqbracket"
.long 0x23a3
.byte 14
.ascii "botrightparens"
.long 0x23a0
.byte 17
.ascii "botrightsqbracket"
.long 0x23a6
.byte 4
.ascii "bott"
.long 0x2534
.byte 13
.ascii "braille_blank"
.long 0x2800
.byte 14
.ascii "braille_dots_1"
.long 0x2801
.byte 15
.ascii "braille_dots_12"
.long 0x2803
.byte 16
.ascii "braille_dots_123"
.long 0x2807
.byte 17
.ascii "braille_dots_1234"
.long 0x280f
.byte 18
.ascii "braille_dots_12345"
.long 0x281f
.byte 19
.ascii "braille_dots_123456"
.long 0x283f
.byte 20
.ascii "braille_dots_1234567"
.long 0x287f
.byte 21
.ascii "braille_dots_12345678"
.long 0x28ff
.byte 20
.ascii "braille_dots_1234568"
.long 0x28bf
.byte 19
.ascii "braille_dots_123457"
.long 0x285f
.byte 20
.ascii "braille_dots_1234578"
.long 0x28df
.byte 19
.ascii "braille_dots_123458"
.long 0x289f
.byte 18
.ascii "braille_dots_12346"
.long 0x282f
.byte 19
.ascii "braille_dots_123467"
.long 0x286f
.byte 20
.ascii "braille_dots_1234678"
.long 0x28ef
.byte 19
.ascii "braille_dots_123468"
.long 0x28af
.byte 18
.ascii "braille_dots_12347"
.long 0x284f
.byte 19
.ascii "braille_dots_123478"
.long 0x28cf
.byte 18
.ascii "braille_dots_12348"
.long 0x288f
.byte 17
.ascii "braille_dots_1235"
.long 0x2817
.byte 18
.ascii "braille_dots_12356"
.long 0x2837
.byte 19
.ascii "braille_dots_123567"
.long 0x2877
.byte 20
.ascii "braille_dots_1235678"
.long 0x28f7
.byte 19
.ascii "braille_dots_123568"
.long 0x28b7
.byte 18
.ascii "braille_dots_12357"
.long 0x2857
.byte 19
.ascii "braille_dots_123578"
.long 0x28d7
.byte 18
.ascii "braille_dots_12358"
.long 0x2897
.byte 17
.ascii "braille_dots_1236"
.long 0x2827
.byte 18
.ascii "braille_dots_12367"
.long 0x2867
.byte 19
.ascii "braille_dots_123678"
.long 0x28e7
.byte 18
.ascii "braille_dots_12368"
.long 0x28a7
.byte 17
.ascii "braille_dots_1237"
.long 0x2847
.byte 18
.ascii "braille_dots_12378"
.long 0x28c7
.byte 17
.ascii "braille_dots_1238"
.long 0x2887
.byte 16
.ascii "braille_dots_124"
.long 0x280b
.byte 17
.ascii "braille_dots_1245"
.long 0x281b
.byte 18
.ascii "braille_dots_12456"
.long 0x283b
.byte 19
.ascii "braille_dots_124567"
.long 0x287b
.byte 20
.ascii "braille_dots_1245678"
.long 0x28fb
.byte 19
.ascii "braille_dots_124568"
.long 0x28bb
.byte 18
.ascii "braille_dots_12457"
.long 0x285b
.byte 19
.ascii "braille_dots_124578"
.long 0x28db
.byte 18
.ascii "braille_dots_12458"
.long 0x289b
.byte 17
.ascii "braille_dots_1246"
.long 0x282b
.byte 18
.ascii "braille_dots_12467"
.long 0x286b
.byte 19
.ascii "braille_dots_124678"
.long 0x28eb
.byte 18
.ascii "braille_dots_12468"
.long 0x28ab
.byte 17
.ascii "braille_dots_1247"
.long 0x284b
.byte 18
.ascii "braille_dots_12478"
.long 0x28cb
.byte 17
.ascii "braille_dots_1248"
.long 0x288b
.byte 16
.ascii "braille_dots_125"
.long 0x2813
.byte 17
.ascii "braille_dots_1256"
.long 0x2833
.byte 18
.ascii "braille_dots_12567"
.long 0x2873
.byte 19
.ascii "braille_dots_125678"
.long 0x28f3
.byte 18
.ascii "braille_dots_12568"
.long 0x28b3
.byte 17
.ascii "braille_dots_1257"
.long 0x2853
.byte 18
.ascii "braille_dots_12578"
.long 0x28d3
.byte 17
.ascii "braille_dots_1258"
.long 0x2893
.byte 16
.ascii "braille_dots_126"
.long 0x2823
.byte 17
.ascii "braille_dots_1267"
.long 0x2863
.byte 18
.ascii "braille_dots_12678"
.long 0x28e3
.byte 17
.ascii "braille_dots_1268"
.long 0x28a3
.byte 16
.ascii "braille_dots_127"
.long 0x2843
.byte 17
.ascii "braille_dots_1278"
.long 0x28c3
.byte 16
.ascii "braille_dots_128"
.long 0x2883
.byte 15
.ascii "braille_dots_13"
.long 0x2805
.byte 16
.ascii "braille_dots_134"
.long 0x280d
.byte 17
.ascii "braille_dots_1345"
.long 0x281d
.byte 18
.ascii "braille_dots_13456"
.long 0x283d
.byte 19
.ascii "braille_dots_134567"
.long 0x287d
.byte 20
.ascii "braille_dots_1345678"
.long 0x28fd
.byte 19
.ascii "braille_dots_134568"
.long 0x28bd
.byte 18
.ascii "braille_dots_13457"
.long 0x285d
.byte 19
.ascii "braille_dots_134578"
.long 0x28dd
.byte 18
.ascii "braille_dots_13458"
.long 0x289d
.byte 17
.ascii "braille_dots_1346"
.long 0x282d
.byte 18
.ascii "braille_dots_13467"
.long 0x286d
.byte 19
.ascii "braille_dots_134678"
.long 0x28ed
.byte 18
.ascii "braille_dots_13468"
.long 0x28ad
.byte 17
.ascii "braille_dots_1347"
.long 0x284d
.byte 18
.ascii "braille_dots_13478"
.long 0x28cd
.byte 17
.ascii "braille_dots_1348"
.long 0x288d
.byte 16
.ascii "braille_dots_135"
.long 0x2815
.byte 17
.ascii "braille_dots_1356"
.long 0x2835
.byte 18
.ascii "braille_dots_13567"
.long 0x2875
.byte 19
.ascii "braille_dots_135678"
.long 0x28f5
.byte 18
.ascii "braille_dots_13568"
.long 0x28b5
.byte 17
.ascii "braille_dots_1357"
.long 0x2855
.byte 18
.ascii "braille_dots_13578"
.long 0x28d5
.byte 17
.ascii "braille_dots_1358"
.long 0x2895
.byte 16
.ascii "braille_dots_136"
.long 0x2825
.byte 17
.ascii "braille_dots_1367"
.long 0x2865
.byte 18
.ascii "braille_dots_13678"
.long 0x28e5
.byte 17
.ascii "braille_dots_1368"
.long 0x28a5
.byte 16
.ascii "braille_dots_137"
.long 0x2845
.byte 17
.ascii "braille_dots_1378"
.long 0x28c5
.byte 16
.ascii "braille_dots_138"
.long 0x2885
.byte 15
.ascii "braille_dots_14"
.long 0x2809
.byte 16
.ascii "braille_dots_145"
.long 0x2819
.byte 17
.ascii "braille_dots_1456"
.long 0x2839
.byte 18
.ascii "braille_dots_14567"
.long 0x2879
.byte 19
.ascii "braille_dots_145678"
.long 0x28f9
.byte 18
.ascii "braille_dots_14568"
.long 0x28b9
.byte 17
.ascii "braille_dots_1457"
.long 0x2859
.byte 18
.ascii "braille_dots_14578"
.long 0x28d9
.byte 17
.ascii "braille_dots_1458"
.long 0x2899
.byte 16
.ascii "braille_dots_146"
.long 0x2829
.byte 17
.ascii "braille_dots_1467"
.long 0x2869
.byte 18
.ascii "braille_dots_14678"
.long 0x28e9
.byte 17
.ascii "braille_dots_1468"
.long 0x28a9
.byte 16
.ascii "braille_dots_147"
.long 0x2849
.byte 17
.ascii "braille_dots_1478"
.long 0x28c9
.byte 16
.ascii "braille_dots_148"
.long 0x2889
.byte 15
.ascii "braille_dots_15"
.long 0x2811
.byte 16
.ascii "braille_dots_156"
.long 0x2831
.byte 17
.ascii "braille_dots_1567"
.long 0x2871
.byte 18
.ascii "braille_dots_15678"
.long 0x28f1
.byte 17
.ascii "braille_dots_1568"
.long 0x28b1
.byte 16
.ascii "braille_dots_157"
.long 0x2851
.byte 17
.ascii "braille_dots_1578"
.long 0x28d1
.byte 16
.ascii "braille_dots_158"
.long 0x2891
.byte 15
.ascii "braille_dots_16"
.long 0x2821
.byte 16
.ascii "braille_dots_167"
.long 0x2861
.byte 17
.ascii "braille_dots_1678"
.long 0x28e1
.byte 16
.ascii "braille_dots_168"
.long 0x28a1
.byte 15
.ascii "braille_dots_17"
.long 0x2841
.byte 16
.ascii "braille_dots_178"
.long 0x28c1
.byte 15
.ascii "braille_dots_18"
.long 0x2881
.byte 14
.ascii "braille_dots_2"
.long 0x2802
.byte 15
.ascii "braille_dots_23"
.long 0x2806
.byte 16
.ascii "braille_dots_234"
.long 0x280e
.byte 17
.ascii "braille_dots_2345"
.long 0x281e
.byte 18
.ascii "braille_dots_23456"
.long 0x283e
.byte 19
.ascii "braille_dots_234567"
.long 0x287e
.byte 20
.ascii "braille_dots_2345678"
.long 0x28fe
.byte 19
.ascii "braille_dots_234568"
.long 0x28be
.byte 18
.ascii "braille_dots_23457"
.long 0x285e
.byte 19
.ascii "braille_dots_234578"
.long 0x28de
.byte 18
.ascii "braille_dots_23458"
.long 0x289e
.byte 17
.ascii "braille_dots_2346"
.long 0x282e
.byte 18
.ascii "braille_dots_23467"
.long 0x286e
.byte 19
.ascii "braille_dots_234678"
.long 0x28ee
.byte 18
.ascii "braille_dots_23468"
.long 0x28ae
.byte 17
.ascii "braille_dots_2347"
.long 0x284e
.byte 18
.ascii "braille_dots_23478"
.long 0x28ce
.byte 17
.ascii "braille_dots_2348"
.long 0x288e
.byte 16
.ascii "braille_dots_235"
.long 0x2816
.byte 17
.ascii "braille_dots_2356"
.long 0x2836
.byte 18
.ascii "braille_dots_23567"
.long 0x2876
.byte 19
.ascii "braille_dots_235678"
.long 0x28f6
.byte 18
.ascii "braille_dots_23568"
.long 0x28b6
.byte 17
.ascii "braille_dots_2357"
.long 0x2856
.byte 18
.ascii "braille_dots_23578"
.long 0x28d6
.byte 17
.ascii "braille_dots_2358"
.long 0x2896
.byte 16
.ascii "braille_dots_236"
.long 0x2826
.byte 17
.ascii "braille_dots_2367"
.long 0x2866
.byte 18
.ascii "braille_dots_23678"
.long 0x28e6
.byte 17
.ascii "braille_dots_2368"
.long 0x28a6
.byte 16
.ascii "braille_dots_237"
.long 0x2846
.byte 17
.ascii "braille_dots_2378"
.long 0x28c6
.byte 16
.ascii "braille_dots_238"
.long 0x2886
.byte 15
.ascii "braille_dots_24"
.long 0x280a
.byte 16
.ascii "braille_dots_245"
.long 0x281a
.byte 17
.ascii "braille_dots_2456"
.long 0x283a
.byte 18
.ascii "braille_dots_24567"
.long 0x287a
.byte 19
.ascii "braille_dots_245678"
.long 0x28fa
.byte 18
.ascii "braille_dots_24568"
.long 0x28ba
.byte 17
.ascii "braille_dots_2457"
.long 0x285a
.byte 18
.ascii "braille_dots_24578"
.long 0x28da
.byte 17
.ascii "braille_dots_2458"
.long 0x289a
.byte 16
.ascii "braille_dots_246"
.long 0x282a
.byte 17
.ascii "braille_dots_2467"
.long 0x286a
.byte 18
.ascii "braille_dots_24678"
.long 0x28ea
.byte 17
.ascii "braille_dots_2468"
.long 0x28aa
.byte 16
.ascii "braille_dots_247"
.long 0x284a
.byte 17
.ascii "braille_dots_2478"
.long 0x28ca
.byte 16
.ascii "braille_dots_248"
.long 0x288a
.byte 15
.ascii "braille_dots_25"
.long 0x2812
.byte 16
.ascii "braille_dots_256"
.long 0x2832
.byte 17
.ascii "braille_dots_2567"
.long 0x2872
.byte 18
.ascii "braille_dots_25678"
.long 0x28f2
.byte 17
.ascii "braille_dots_2568"
.long 0x28b2
.byte 16
.ascii "braille_dots_257"
.long 0x2852
.byte 17
.ascii "braille_dots_2578"
.long 0x28d2
.byte 16
.ascii "braille_dots_258"
.long 0x2892
.byte 15
.ascii "braille_dots_26"
.long 0x2822
.byte 16
.ascii "braille_dots_267"
.long 0x2862
.byte 17
.ascii "braille_dots_2678"
.long 0x28e2
.byte 16
.ascii "braille_dots_268"
.long 0x28a2
.byte 15
.ascii "braille_dots_27"
.long 0x2842
.byte 16
.ascii "braille_dots_278"
.long 0x28c2
.byte 15
.ascii "braille_dots_28"
.long 0x2882
.byte 14
.ascii "braille_dots_3"
.long 0x2804
.byte 15
.ascii "braille_dots_34"
.long 0x280c
.byte 16
.ascii "braille_dots_345"
.long 0x281c
.byte 17
.ascii "braille_dots_3456"
.long 0x283c
.byte 18
.ascii "braille_dots_34567"
.long 0x287c
.byte 19
.ascii "braille_dots_345678"
.long 0x28fc
.byte 18
.ascii "braille_dots_34568"
.long 0x28bc
.byte 17
.ascii "braille_dots_3457"
.long 0x285c
.byte 18
.ascii "braille_dots_34578"
.long 0x28dc
.byte 17
.ascii "braille_dots_3458"
.long 0x289c
.byte 16
.ascii "braille_dots_346"
.long 0x282c
.byte 17
.ascii "braille_dots_3467"
.long 0x286c
.byte 18
.ascii "braille_dots_34678"
.long 0x28ec
.byte 17
.ascii "braille_dots_3468"
.long 0x28ac
.byte 16
.ascii "braille_dots_347"
.long 0x284c
.byte 17
.ascii "braille_dots_3478"
.long 0x28cc
.byte 16
.ascii "braille_dots_348"
.long 0x288c
.byte 15
.ascii "braille_dots_35"
.long 0x2814
.byte 16
.ascii "braille_dots_356"
.long 0x2834
.byte 17
.ascii "braille_dots_3567"
.long 0x2874
.byte 18
.ascii "braille_dots_35678"
.long 0x28f4
.byte 17
.ascii "braille_dots_3568"
.long 0x28b4
.byte 16
.ascii "braille_dots_357"
.long 0x2854
.byte 17
.ascii "braille_dots_3578"
.long 0x28d4
.byte 16
.ascii "braille_dots_358"
.long 0x2894
.byte 15
.ascii "braille_dots_36"
.long 0x2824
.byte 16
.ascii "braille_dots_367"
.long 0x2864
.byte 17
.ascii "braille_dots_3678"
.long 0x28e4
.byte 16
.ascii "braille_dots_368"
.long 0x28a4
.byte 15
.ascii "braille_dots_37"
.long 0x2844
.byte 16
.ascii "braille_dots_378"
.long 0x28c4
.byte 15
.ascii "braille_dots_38"
.long 0x2884
.byte 14
.ascii "braille_dots_4"
.long 0x2808
.byte 15
.ascii "braille_dots_45"
.long 0x2818
.byte 16
.ascii "braille_dots_456"
.long 0x2838
.byte 17
.ascii "braille_dots_4567"
.long 0x2878
.byte 18
.ascii "braille_dots_45678"
.long 0x28f8
.byte 17
.ascii "braille_dots_4568"
.long 0x28b8
.byte 16
.ascii "braille_dots_457"
.long 0x2858
.byte 17
.ascii "braille_dots_4578"
.long 0x28d8
.byte 16
.ascii "braille_dots_458"
.long 0x2898
.byte 15
.ascii "braille_dots_46"
.long 0x2828
.byte 16
.ascii "braille_dots_467"
.long 0x2868
.byte 17
.ascii "braille_dots_4678"
.long 0x28e8
.byte 16
.ascii "braille_dots_468"
.long 0x28a8
.byte 15
.ascii "braille_dots_47"
.long 0x2848
.byte 16
.ascii "braille_dots_478"
.long 0x28c8
.byte 15
.ascii "braille_dots_48"
.long 0x2888
.byte 14
.ascii "braille_dots_5"
.long 0x2810
.byte 15
.ascii "braille_dots_56"
.long 0x2830
.byte 16
.ascii "braille_dots_567"
.long 0x2870
.byte 17
.ascii "braille_dots_5678"
.long 0x28f0
.byte 16
.ascii "braille_dots_568"
.long 0x28b0
.byte 15
.ascii "braille_dots_57"
.long 0x2850
.byte 16
.ascii "braille_dots_578"
.long 0x28d0
.byte 15
.ascii "braille_dots_58"
.long 0x2890
.byte 14
.ascii "braille_dots_6"
.long 0x2820
.byte 15
.ascii "braille_dots_67"
.long 0x2860
.byte 16
.ascii "braille_dots_678"
.long 0x28e0
.byte 15
.ascii "braille_dots_68"
.long 0x28a0
.byte 14
.ascii "braille_dots_7"
.long 0x2840
.byte 15
.ascii "braille_dots_78"
.long 0x28c0
.byte 14
.ascii "braille_dots_8"
.long 0x2880
.byte 5
.ascii "breve"
.long 0x2d8
.byte 9
.ascii "brokenbar"
.long 0xa6
.byte 6
.ascii "bullet"
.long 0x2022
.byte 9
.ascii "cabovedot"
.long 0x10b
.byte 6
.ascii "cacute"
.long 0x107
.byte 6
.ascii "careof"
.long 0x2105
.byte 5
.ascii "caret"
.long 0x2038
.byte 5
.ascii "caron"
.long 0x2c7
.byte 6
.ascii "ccaron"
.long 0x10d
.byte 8
.ascii "ccedilla"
.long 0xe7
.byte 11
.ascii "ccircumflex"
.long 0x109
.byte 7
.ascii "cedilla"
.long 0xb8
.byte 4
.ascii "cent"
.long 0xa2
.byte 12
.ascii "checkerboard"
.long 0x2592
.byte 9
.ascii "checkmark"
.long 0x2713
.byte 6
.ascii "circle"
.long 0x25cb
.byte 4
.ascii "club"
.long 0x2663
.byte 15
.ascii "combining_acute"
.long 0x301
.byte 18
.ascii "combining_belowdot"
.long 0x323
.byte 15
.ascii "combining_grave"
.long 0x300
.byte 14
.ascii "combining_hook"
.long 0x309
.byte 15
.ascii "combining_tilde"
.long 0x303
.byte 10
.ascii "containsas"
.long 0x220b
.byte 9
.ascii "copyright"
.long 0xa9
.byte 2
.ascii "cr"
.long 0x240d
.byte 13
.ascii "crossinglines"
.long 0x253c
.byte 8
.ascii "cuberoot"
.long 0x221b
.byte 8
.ascii "currency"
.long 0xa4
.byte 9
.ascii "dabovedot"
.long 0x1e0b
.byte 6
.ascii "dagger"
.long 0x2020
.byte 6
.ascii "dcaron"
.long 0x10f
.byte 15
.ascii "dead_abovecomma"
.long 0x110016
.byte 13
.ascii "dead_abovedot"
.long 0x11000a
.byte 23
.ascii "dead_abovereversedcomma"
.long 0x110017
.byte 14
.ascii "dead_abovering"
.long 0x11000b
.byte 22
.ascii "dead_aboveverticalline"
.long 0x110022
.byte 10
.ascii "dead_acute"
.long 0x110002
.byte 15
.ascii "dead_apostrophe"
.long 0x110002
.byte 15
.ascii "dead_belowbreve"
.long 0x11001d
.byte 20
.ascii "dead_belowcircumflex"
.long 0x11001b
.byte 15
.ascii "dead_belowcomma"
.long 0x110020
.byte 19
.ascii "dead_belowdiaeresis"
.long 0x11001e
.byte 13
.ascii "dead_belowdot"
.long 0x110012
.byte 16
.ascii "dead_belowmacron"
.long 0x11001a
.byte 14
.ascii "dead_belowring"
.long 0x110019
.byte 15
.ascii "dead_belowtilde"
.long 0x11001c
.byte 22
.ascii "dead_belowverticalline"
.long 0x110023
.byte 10
.ascii "dead_breve"
.long 0x110009
.byte 10
.ascii "dead_caron"
.long 0x11000d
.byte 12
.ascii "dead_cedilla"
.long 0x110006
.byte 15
.ascii "dead_circumflex"
.long 0x110003
.byte 10
.ascii "dead_dasia"
.long 0x110017
.byte 14
.ascii "dead_diaeresis"
.long 0x110005
.byte 16
.ascii "dead_doubleacute"
.long 0x11000c
.byte 16
.ascii "dead_doublegrave"
.long 0x110018
.byte 10
.ascii "dead_grave"
.long 0x110001
.byte 9
.ascii "dead_hook"
.long 0x110013
.byte 9
.ascii "dead_horn"
.long 0x110014
.byte 18
.ascii "dead_invertedbreve"
.long 0x11001f
.byte 9
.ascii "dead_iota"
.long 0x11000f
.byte 23
.ascii "dead_longsolidusoverlay"
.long 0x110024
.byte 12
.ascii "dead_lowline"
.long 0x110021
.byte 11
.ascii "dead_macron"
.long 0x110008
.byte 11
.ascii "dead_ogonek"
.long 0x11000e
.byte 16
.ascii "dead_perispomeni"
.long 0x110004
.byte 10
.ascii "dead_psili"
.long 0x110016
.byte 21
.ascii "dead_semivoiced_sound"
.long 0x110011
.byte 11
.ascii "dead_stroke"
.long 0x110015
.byte 10
.ascii "dead_tilde"
.long 0x110004
.byte 17
.ascii "dead_voiced_sound"
.long 0x110010
.byte 6
.ascii "degree"
.long 0xb0
.byte 9
.ascii "diaeresis"
.long 0xa8
.byte 7
.ascii "diamond"
.long 0x2666
.byte 10
.ascii "digitspace"
.long 0x2007
.byte 9
.ascii "dintegral"
.long 0x222c
.byte 8
.ascii "division"
.long 0xf7
.byte 15
.ascii "doubbaselinedot"
.long 0x2025
.byte 11
.ascii "doubleacute"
.long 0x2dd
.byte 12
.ascii "doubledagger"
.long 0x2021
.byte 18
.ascii "doublelowquotemark"
.long 0x201e
.byte 9
.ascii "downarrow"
.long 0x2193
.byte 9
.ascii "downcaret"
.long 0x2228
.byte 8
.ascii "downshoe"
.long 0x222a
.byte 9
.ascii "downstile"
.long 0x230a
.byte 8
.ascii "downtack"
.long 0x22a4
.byte 7
.ascii "dstroke"
.long 0x111
.byte 9
.ascii "eabovedot"
.long 0x117
.byte 6
.ascii "eacute"
.long 0xe9
.byte 9
.ascii "ebelowdot"
.long 0x1eb9
.byte 6
.ascii "ecaron"
.long 0x11b
.byte 11
.ascii "ecircumflex"
.long 0xea
.byte 16
.ascii "ecircumflexacute"
.long 0x1ebf
.byte 19
.ascii "ecircumflexbelowdot"
.long 0x1ec7
.byte 16
.ascii "ecircumflexgrave"
.long 0x1ec1
.byte 15
.ascii "ecircumflexhook"
.long 0x1ec3
.byte 16
.ascii "ecircumflextilde"
.long 0x1ec5
.byte 10
.ascii "ediaeresis"
.long 0xeb
.byte 6
.ascii "egrave"
.long 0xe8
.byte 5
.ascii "ehook"
.long 0x1ebb
.byte 14
.ascii "eightsubscript"
.long 0x2088
.byte 13
.ascii "eightsuperior"
.long 0x2078
.byte 9
.ascii "elementof"
.long 0x2208
.byte 8
.ascii "ellipsis"
.long 0x2026
.byte 8
.ascii "em3space"
.long 0x2004
.byte 8
.ascii "em4space"
.long 0x2005
.byte 7
.ascii "emacron"
.long 0x113
.byte 6
.ascii "emdash"
.long 0x2014
.byte 14
.ascii "emfilledcircle"
.long 0x25cf
.byte 12
.ascii "emfilledrect"
.long 0x25ae
.byte 12
.ascii "emopencircle"
.long 0x25cb
.byte 15
.ascii "emopenrectangle"
.long 0x25af
.byte 8
.ascii "emptyset"
.long 0x2205
.byte 7
.ascii "emspace"
.long 0x2003
.byte 6
.ascii "endash"
.long 0x2013
.byte 18
.ascii "enfilledcircbullet"
.long 0x2022
.byte 16
.ascii "enfilledsqbullet"
.long 0x25aa
.byte 3
.ascii "eng"
.long 0x14b
.byte 16
.ascii "enopencircbullet"
.long 0x25e6
.byte 18
.ascii "enopensquarebullet"
.long 0x25ab
.byte 7
.ascii "enspace"
.long 0x2002
.byte 7
.ascii "eogonek"
.long 0x119
.byte 3
.ascii "eth"
.long 0xf0
.byte 6
.ascii "etilde"
.long 0x1ebd
.byte 10
.ascii "exclamdown"
.long 0xa1
.byte 3
.ascii "ezh"
.long 0x292
.byte 9
.ascii "fabovedot"
.long 0x1e1f
.byte 12
.ascii "femalesymbol"
.long 0x2640
.byte 2
.ascii "ff"
.long 0x240c
.byte 7
.ascii "figdash"
.long 0x2012
.byte 19
.ascii "filledlefttribullet"
.long 0x25c0
.byte 16
.ascii "filledrectbullet"
.long 0x25ac
.byte 20
.ascii "filledrighttribullet"
.long 0x25b6
.byte 19
.ascii "filledtribulletdown"
.long 0x25bc
.byte 17
.ascii "filledtribulletup"
.long 0x25b2
.byte 11
.ascii "fiveeighths"
.long 0x215d
.byte 10
.ascii "fivesixths"
.long 0x215a
.byte 13
.ascii "fivesubscript"
.long 0x2085
.byte 12
.ascii "fivesuperior"
.long 0x2075
.byte 10
.ascii "fourfifths"
.long 0x2158
.byte 13
.ascii "foursubscript"
.long 0x2084
.byte 12
.ascii "foursuperior"
.long 0x2074
.byte 10
.ascii "fourthroot"
.long 0x221c
.byte 8
.ascii "function"
.long 0x192
.byte 9
.ascii "gabovedot"
.long 0x121
.byte 6
.ascii "gbreve"
.long 0x11f
.byte 6
.ascii "gcaron"
.long 0x1e7
.byte 8
.ascii "gcedilla"
.long 0x123
.byte 11
.ascii "gcircumflex"
.long 0x11d
.byte 16
.ascii "greaterthanequal"
.long 0x2265
.byte 13
.ascii "guillemetleft"
.long 0xab
.byte 14
.ascii "guillemetright"
.long 0xbb
.byte 13
.ascii "guillemotleft"
.long 0xab
.byte 14
.ascii "guillemotright"
.long 0xbb
.byte 9
.ascii "hairspace"
.long 0x200a
.byte 11
.ascii "hcircumflex"
.long 0x125
.byte 5
.ascii "heart"
.long 0x2665
.byte 12
.ascii "hebrew_aleph"
.long 0x5d0
.byte 11
.ascii "hebrew_ayin"
.long 0x5e2
.byte 10
.ascii "hebrew_bet"
.long 0x5d1
.byte 11
.ascii "hebrew_beth"
.long 0x5d1
.byte 11
.ascii "hebrew_chet"
.long 0x5d7
.byte 12
.ascii "hebrew_dalet"
.long 0x5d3
.byte 13
.ascii "hebrew_daleth"
.long 0x5d3
.byte 20
.ascii "hebrew_doublelowline"
.long 0x2017
.byte 16
.ascii "hebrew_finalkaph"
.long 0x5da
.byte 15
.ascii "hebrew_finalmem"
.long 0x5dd
.byte 15
.ascii "hebrew_finalnun"
.long 0x5df
.byte 14
.ascii "hebrew_finalpe"
.long 0x5e3
.byte 16
.ascii "hebrew_finalzade"
.long 0x5e5
.byte 16
.ascii "hebrew_finalzadi"
.long 0x5e5
.byte 12
.ascii "hebrew_gimel"
.long 0x5d2
.byte 13
.ascii "hebrew_gimmel"
.long 0x5d2
.byte 9
.ascii "hebrew_he"
.long 0x5d4
.byte 10
.ascii "hebrew_het"
.long 0x5d7
.byte 11
.ascii "hebrew_kaph"
.long 0x5db
.byte 10
.ascii "hebrew_kuf"
.long 0x5e7
.byte 12
.ascii "hebrew_lamed"
.long 0x5dc
.byte 10
.ascii "hebrew_mem"
.long 0x5de
.byte 10
.ascii "hebrew_nun"
.long 0x5e0
.byte 9
.ascii "hebrew_pe"
.long 0x5e4
.byte 11
.ascii "hebrew_qoph"
.long 0x5e7
.byte 11
.ascii "hebrew_resh"
.long 0x5e8
.byte 13
.ascii "hebrew_samech"
.long 0x5e1
.byte 13
.ascii "hebrew_samekh"
.long 0x5e1
.byte 11
.ascii "hebrew_shin"
.long 0x5e9
.byte 10
.ascii "hebrew_taf"
.long 0x5ea
.byte 10
.ascii "hebrew_taw"
.long 0x5ea
.byte 10
.ascii "hebrew_tet"
.long 0x5d8
.byte 11
.ascii "hebrew_teth"
.long 0x5d8
.byte 10
.ascii "hebrew_waw"
.long 0x5d5
.byte 10
.ascii "hebrew_yod"
.long 0x5d9
.byte 11
.ascii "hebrew_zade"
.long 0x5e6
.byte 11
.ascii "hebrew_zadi"
.long 0x5e6
.byte 11
.ascii "hebrew_zain"
.long 0x5d6
.byte 12
.ascii "hebrew_zayin"
.long 0x5d6
.byte 14
.ascii "horizconnector"
.long 0x2500
.byte 14
.ascii "horizlinescan1"
.long 0x23ba
.byte 14
.ascii "horizlinescan3"
.long 0x23bb
.byte 14
.ascii "horizlinescan5"
.long 0x2500
.byte 14
.ascii "horizlinescan7"
.long 0x23bc
.byte 14
.ascii "horizlinescan9"
.long 0x23bd
.byte 7
.ascii "hstroke"
.long 0x127
.byte 2
.ascii "ht"
.long 0x2409
.byte 6
.ascii "hyphen"
.long 0xad
.byte 6
.ascii "iacute"
.long 0xed
.byte 9
.ascii "ibelowdot"
.long 0x1ecb
.byte 6
.ascii "ibreve"
.long 0x12d
.byte 11
.ascii "icircumflex"
.long 0xee
.byte 9
.ascii "identical"
.long 0x2261
.byte 10
.ascii "idiaeresis"
.long 0xef
.byte 8
.ascii "idotless"
.long 0x131
.byte 8
.ascii "ifonlyif"
.long 0x21d4
.byte 6
.ascii "igrave"
.long 0xec
.byte 5
.ascii "ihook"
.long 0x1ec9
.byte 7
.ascii "imacron"
.long 0x12b
.byte 7
.ascii "implies"
.long 0x21d2
.byte 10
.ascii "includedin"
.long 0x2282
.byte 8
.ascii "includes"
.long 0x2283
.byte 8
.ascii "infinity"
.long 0x221e
.byte 8
.ascii "integral"
.long 0x222b
.byte 12
.ascii "intersection"
.long 0x2229
.byte 7
.ascii "iogonek"
.long 0x12f
.byte 6
.ascii "itilde"
.long 0x129
.byte 11
.ascii "jcircumflex"
.long 0x135
.byte 3
.ascii "jot"
.long 0x2218
.byte 6
.ascii "kana_A"
.long 0x30a2
.byte 8
.ascii "kana_CHI"
.long 0x30c1
.byte 6
.ascii "kana_E"
.long 0x30a8
.byte 7
.ascii "kana_FU"
.long 0x30d5
.byte 7
.ascii "kana_HA"
.long 0x30cf
.byte 7
.ascii "kana_HE"
.long 0x30d8
.byte 7
.ascii "kana_HI"
.long 0x30d2
.byte 7
.ascii "kana_HO"
.long 0x30db
.byte 7
.ascii "kana_HU"
.long 0x30d5
.byte 6
.ascii "kana_I"
.long 0x30a4
.byte 7
.ascii "kana_KA"
.long 0x30ab
.byte 7
.ascii "kana_KE"
.long 0x30b1
.byte 7
.ascii "kana_KI"
.long 0x30ad
.byte 7
.ascii "kana_KO"
.long 0x30b3
.byte 7
.ascii "kana_KU"
.long 0x30af
.byte 7
.ascii "kana_MA"
.long 0x30de
.byte 7
.ascii "kana_ME"
.long 0x30e1
.byte 7
.ascii "kana_MI"
.long 0x30df
.byte 7
.ascii "kana_MO"
.long 0x30e2
.byte 7
.ascii "kana_MU"
.long 0x30e0
.byte 6
.ascii "kana_N"
.long 0x30f3
.byte 7
.ascii "kana_NA"
.long 0x30ca
.byte 7
.ascii "kana_NE"
.long 0x30cd
.byte 7
.ascii "kana_NI"
.long 0x30cb
.byte 7
.ascii "kana_NO"
.long 0x30ce
.byte 7
.ascii "kana_NU"
.long 0x30cc
.byte 6
.ascii "kana_O"
.long 0x30aa
.byte 7
.ascii "kana_RA"
.long 0x30e9
.byte 7
.ascii "kana_RE"
.long 0x30ec
.byte 7
.ascii "kana_RI"
.long 0x30ea
.byte 7
.ascii "kana_RO"
.long 0x30ed
.byte 7
.ascii "kana_RU"
.long 0x30eb
.byte 7
.ascii "kana_SA"
.long 0x30b5
.byte 7
.ascii "kana_SE"
.long 0x30bb
.byte 8
.ascii "kana_SHI"
.long 0x30b7
.byte 7
.ascii "kana_SO"
.long 0x30bd
.byte 7
.ascii "kana_SU"
.long 0x30b9
.byte 7
.ascii "kana_TA"
.long 0x30bf
.byte 7
.ascii "kana_TE"
.long 0x30c6
.byte 7
.ascii "kana_TI"
.long 0x30c1
.byte 7
.ascii "kana_TO"
.long 0x30c8
.byte 8
.ascii "kana_TSU"
.long 0x30c4
.byte 7
.ascii "kana_TU"
.long 0x30c4
.byte 6
.ascii "kana_U"
.long 0x30a6
.byte 7
.ascii "kana_WA"
.long 0x30ef
.byte 7
.ascii "kana_WO"
.long 0x30f2
.byte 7
.ascii "kana_YA"
.long 0x30e4
.byte 7
.ascii "kana_YO"
.long 0x30e8
.byte 7
.ascii "kana_YU"
.long 0x30e6
.byte 6
.ascii "kana_a"
.long 0x30a1
.byte 19
.ascii "kana_closingbracket"
.long 0x300d
.byte 10
.ascii "kana_comma"
.long 0x3001
.byte 16
.ascii "kana_conjunctive"
.long 0x30fb
.byte 6
.ascii "kana_e"
.long 0x30a7
.byte 13
.ascii "kana_fullstop"
.long 0x3002
.byte 6
.ascii "kana_i"
.long 0x30a3
.byte 14
.ascii "kana_middledot"
.long 0x30fb
.byte 6
.ascii "kana_o"
.long 0x30a9
.byte 19
.ascii "kana_openingbracket"
.long 0x300c
.byte 8
.ascii "kana_tsu"
.long 0x30c3
.byte 7
.ascii "kana_tu"
.long 0x30c3
.byte 6
.ascii "kana_u"
.long 0x30a5
.byte 7
.ascii "kana_ya"
.long 0x30e3
.byte 7
.ascii "kana_yo"
.long 0x30e7
.byte 7
.ascii "kana_yu"
.long 0x30e5
.byte 5
.ascii "kappa"
.long 0x138
.byte 8
.ascii "kcedilla"
.long 0x137
.byte 3
.ascii "kra"
.long 0x138
.byte 6
.ascii "lacute"
.long 0x13a
.byte 10
.ascii "latincross"
.long 0x271d
.byte 9
.ascii "lbelowdot"
.long 0x1e37
.byte 6
.ascii "lcaron"
.long 0x13e
.byte 8
.ascii "lcedilla"
.long 0x13c
.byte 16
.ascii "leftanglebracket"
.long 0x2329
.byte 9
.ascii "leftarrow"
.long 0x2190
.byte 19
.ascii "leftdoublequotemark"
.long 0x201c
.byte 20
.ascii "leftmiddlecurlybrace"
.long 0x23a8
.byte 16
.ascii "leftopentriangle"
.long 0x25c1
.byte 11
.ascii "leftpointer"
.long 0x261c
.byte 11
.ascii "leftradical"
.long 0x23b7
.byte 8
.ascii "leftshoe"
.long 0x2282
.byte 24
.ascii "leftsingleanglequotemark"
.long 0x2039
.byte 19
.ascii "leftsinglequotemark"
.long 0x2018
.byte 5
.ascii "leftt"
.long 0x251c
.byte 8
.ascii "lefttack"
.long 0x22a3
.byte 13
.ascii "lessthanequal"
.long 0x2264
.byte 2
.ascii "lf"
.long 0x240a
.byte 10
.ascii "logicaland"
.long 0x2227
.byte 9
.ascii "logicalor"
.long 0x2228
.byte 13
.ascii "lowleftcorner"
.long 0x2514
.byte 14
.ascii "lowrightcorner"
.long 0x2518
.byte 7
.ascii "lstroke"
.long 0x142
.byte 9
.ascii "mabovedot"
.long 0x1e41
.byte 6
.ascii "macron"
.long 0xaf
.byte 10
.ascii "malesymbol"
.long 0x2642
.byte 12
.ascii "maltesecross"
.long 0x2720
.byte 9
.ascii "masculine"
.long 0xba
.byte 7
.ascii "minutes"
.long 0x2032
.byte 2
.ascii "mu"
.long 0xb5
.byte 8
.ascii "multiply"
.long 0xd7
.byte 11
.ascii "musicalflat"
.long 0x266d
.byte 12
.ascii "musicalsharp"
.long 0x266f
.byte 5
.ascii "nabla"
.long 0x2207
.byte 6
.ascii "nacute"
.long 0x144
.byte 6
.ascii "ncaron"
.long 0x148
.byte 8
.ascii "ncedilla"
.long 0x146
.byte 13
.ascii "ninesubscript"
.long 0x2089
.byte 12
.ascii "ninesuperior"
.long 0x2079
.byte 2
.ascii "nl"
.long 0x2424
.byte 12
.ascii "nobreakspace"
.long 0xa0
.byte 11
.ascii "notapproxeq"
.long 0x2247
.byte 12
.ascii "notelementof"
.long 0x2209
.byte 8
.ascii "notequal"
.long 0x2260
.byte 12
.ascii "notidentical"
.long 0x2262
.byte 7
.ascii "notsign"
.long 0xac
.byte 6
.ascii "ntilde"
.long 0xf1
.byte 10
.ascii "numerosign"
.long 0x2116
.byte 6
.ascii "oacute"
.long 0xf3
.byte 7
.ascii "obarred"
.long 0x275
.byte 9
.ascii "obelowdot"
.long 0x1ecd
.byte 6
.ascii "ocaron"
.long 0x1d2
.byte 11
.ascii "ocircumflex"
.long 0xf4
.byte 16
.ascii "ocircumflexacute"
.long 0x1ed1
.byte 19
.ascii "ocircumflexbelowdot"
.long 0x1ed9
.byte 16
.ascii "ocircumflexgrave"
.long 0x1ed3
.byte 15
.ascii "ocircumflexhook"
.long 0x1ed5
.byte 16
.ascii "ocircumflextilde"
.long 0x1ed7
.byte 10
.ascii "odiaeresis"
.long 0xf6
.byte 12
.ascii "odoubleacute"
.long 0x151
.byte 2
.ascii "oe"
.long 0x153
.byte 6
.ascii "ogonek"
.long 0x2db
.byte 6
.ascii "ograve"
.long 0xf2
.byte 5
.ascii "ohook"
.long 0x1ecf
.byte 5
.ascii "ohorn"
.long 0x1a1
.byte 10
.ascii "ohornacute"
.long 0x1edb
.byte 13
.ascii "ohornbelowdot"
.long 0x1ee3
.byte 10
.ascii "ohorngrave"
.long 0x1edd
.byte 9
.ascii "ohornhook"
.long 0x1edf
.byte 10
.ascii "ohorntilde"
.long 0x1ee1
.byte 7
.ascii "omacron"
.long 0x14d
.byte 9
.ascii "oneeighth"
.long 0x215b
.byte 8
.ascii "onefifth"
.long 0x2155
.byte 7
.ascii "onehalf"
.long 0xbd
.byte 10
.ascii "onequarter"
.long 0xbc
.byte 8
.ascii "onesixth"
.long 0x2159
.byte 12
.ascii "onesubscript"
.long 0x2081
.byte 11
.ascii "onesuperior"
.long 0xb9
.byte 8
.ascii "onethird"
.long 0x2153
.byte 8
.ascii "ooblique"
.long 0xf8
.byte 14
.ascii "openrectbullet"
.long 0x25ad
.byte 8
.ascii "openstar"
.long 0x2606
.byte 17
.ascii "opentribulletdown"
.long 0x25bd
.byte 15
.ascii "opentribulletup"
.long 0x25b3
.byte 11
.ascii "ordfeminine"
.long 0xaa
.byte 12
.ascii "ordmasculine"
.long 0xba
.byte 6
.ascii "oslash"
.long 0xf8
.byte 6
.ascii "otilde"
.long 0xf5
.byte 7
.ascii "overbar"
.long 0xaf
.byte 8
.ascii "overline"
.long 0x203e
.byte 9
.ascii "pabovedot"
.long 0x1e57
.byte 9
.ascii "paragraph"
.long 0xb6
.byte 16
.ascii "partdifferential"
.long 0x2202
.byte 17
.ascii "partialderivative"
.long 0x2202
.byte 14
.ascii "periodcentered"
.long 0xb7
.byte 8
.ascii "permille"
.long 0x2030
.byte 19
.ascii "phonographcopyright"
.long 0x2117
.byte 9
.ascii "plusminus"
.long 0xb1
.byte 12
.ascii "prescription"
.long 0x211e
.byte 14
.ascii "prolongedsound"
.long 0x30fc
.byte 10
.ascii "punctspace"
.long 0x2008
.byte 4
.ascii "quad"
.long 0x2395
.byte 12
.ascii "questiondown"
.long 0xbf
.byte 6
.ascii "racute"
.long 0x155
.byte 7
.ascii "radical"
.long 0x221a
.byte 6
.ascii "rcaron"
.long 0x159
.byte 8
.ascii "rcedilla"
.long 0x157
.byte 10
.ascii "registered"
.long 0xae
.byte 17
.ascii "rightanglebracket"
.long 0x232a
.byte 10
.ascii "rightarrow"
.long 0x2192
.byte 20
.ascii "rightdoublequotemark"
.long 0x201d
.byte 21
.ascii "rightmiddlecurlybrace"
.long 0x23ac
.byte 17
.ascii "rightopentriangle"
.long 0x25b7
.byte 12
.ascii "rightpointer"
.long 0x261e
.byte 9
.ascii "rightshoe"
.long 0x2283
.byte 25
.ascii "rightsingleanglequotemark"
.long 0x203a
.byte 20
.ascii "rightsinglequotemark"
.long 0x2019
.byte 6
.ascii "rightt"
.long 0x2524
.byte 9
.ascii "righttack"
.long 0x22a2
.byte 9
.ascii "sabovedot"
.long 0x1e61
.byte 6
.ascii "sacute"
.long 0x15b
.byte 6
.ascii "scaron"
.long 0x161
.byte 8
.ascii "scedilla"
.long 0x15f
.byte 5
.ascii "schwa"
.long 0x259
.byte 11
.ascii "scircumflex"
.long 0x15d
.byte 7
.ascii "seconds"
.long 0x2033
.byte 7
.ascii "section"
.long 0xa7
.byte 15
.ascii "semivoicedsound"
.long 0x309c
.byte 12
.ascii "seveneighths"
.long 0x215e
.byte 14
.ascii "sevensubscript"
.long 0x2087
.byte 13
.ascii "sevensuperior"
.long 0x2077
.byte 13
.ascii "signaturemark"
.long 0x2613
.byte 11
.ascii "signifblank"
.long 0x2423
.byte 12
.ascii "similarequal"
.long 0x2243
.byte 18
.ascii "singlelowquotemark"
.long 0x201a
.byte 12
.ascii "sixsubscript"
.long 0x2086
.byte 11
.ascii "sixsuperior"
.long 0x2076
.byte 12
.ascii "soliddiamond"
.long 0x25c6
.byte 10
.ascii "squareroot"
.long 0x221a
.byte 6
.ascii "ssharp"
.long 0xdf
.byte 8
.ascii "sterling"
.long 0xa3
.byte 8
.ascii "stricteq"
.long 0x2263
.byte 9
.ascii "tabovedot"
.long 0x1e6b
.byte 6
.ascii "tcaron"
.long 0x165
.byte 8
.ascii "tcedilla"
.long 0x163
.byte 9
.ascii "telephone"
.long 0x260e
.byte 17
.ascii "telephonerecorder"
.long 0x2315
.byte 9
.ascii "therefore"
.long 0x2234
.byte 9
.ascii "thinspace"
.long 0x2009
.byte 5
.ascii "thorn"
.long 0xfe
.byte 12
.ascii "threeeighths"
.long 0x215c
.byte 11
.ascii "threefifths"
.long 0x2157
.byte 13
.ascii "threequarters"
.long 0xbe
.byte 14
.ascii "threesubscript"
.long 0x2083
.byte 13
.ascii "threesuperior"
.long 0xb3
.byte 9
.ascii "tintegral"
.long 0x222d
.byte 11
.ascii "topintegral"
.long 0x2320
.byte 13
.ascii "topleftparens"
.long 0x239b
.byte 14
.ascii "topleftradical"
.long 0x250c
.byte 16
.ascii "topleftsqbracket"
.long 0x23a1
.byte 14
.ascii "toprightparens"
.long 0x239e
.byte 17
.ascii "toprightsqbracket"
.long 0x23a4
.byte 4
.ascii "topt"
.long 0x252c
.byte 9
.ascii "trademark"
.long 0x2122
.byte 6
.ascii "tslash"
.long 0x167
.byte 9
.ascii "twofifths"
.long 0x2156
.byte 12
.ascii "twosubscript"
.long 0x2082
.byte 11
.ascii "twosuperior"
.long 0xb2
.byte 9
.ascii "twothirds"
.long 0x2154
.byte 6
.ascii "uacute"
.long 0xfa
.byte 9
.ascii "ubelowdot"
.long 0x1ee5
.byte 6
.ascii "ubreve"
.long 0x16d
.byte 11
.ascii "ucircumflex"
.long 0xfb
.byte 10
.ascii "udiaeresis"
.long 0xfc
.byte 12
.ascii "udoubleacute"
.long 0x171
.byte 6
.ascii "ugrave"
.long 0xf9
.byte 5
.ascii "uhook"
.long 0x1ee7
.byte 5
.ascii "uhorn"
.long 0x1b0
.byte 10
.ascii "uhornacute"
.long 0x1ee9
.byte 13
.ascii "uhornbelowdot"
.long 0x1ef1
.byte 10
.ascii "uhorngrave"
.long 0x1eeb
.byte 9
.ascii "uhornhook"
.long 0x1eed
.byte 10
.ascii "uhorntilde"
.long 0x1eef
.byte 7
.ascii "umacron"
.long 0x16b
.byte 5
.ascii "union"
.long 0x222a
.byte 7
.ascii "uogonek"
.long 0x173
.byte 7
.ascii "uparrow"
.long 0x2191
.byte 7
.ascii "upcaret"
.long 0x2227
.byte 12
.ascii "upleftcorner"
.long 0x250c
.byte 13
.ascii "uprightcorner"
.long 0x2510
.byte 6
.ascii "upshoe"
.long 0x2229
.byte 7
.ascii "upstile"
.long 0x2308
.byte 6
.ascii "uptack"
.long 0x22a5
.byte 5
.ascii "uring"
.long 0x16f
.byte 6
.ascii "utilde"
.long 0x169
.byte 9
.ascii "variation"
.long 0x221d
.byte 7
.ascii "vertbar"
.long 0x2502
.byte 13
.ascii "vertconnector"
.long 0x2502
.byte 11
.ascii "voicedsound"
.long 0x309b
.byte 2
.ascii "vt"
.long 0x240b
.byte 6
.ascii "wacute"
.long 0x1e83
.byte 11
.ascii "wcircumflex"
.long 0x175
.byte 10
.ascii "wdiaeresis"
.long 0x1e85
.byte 6
.ascii "wgrave"
.long 0x1e81
.byte 9
.ascii "xabovedot"
.long 0x1e8b
.byte 6
.ascii "yacute"
.long 0xfd
.byte 9
.ascii "ybelowdot"
.long 0x1ef5
.byte 11
.ascii "ycircumflex"
.long 0x177
.byte 10
.ascii "ydiaeresis"
.long 0xff
.byte 3
.ascii "yen"
.long 0xa5
.byte 6
.ascii "ygrave"
.long 0x1ef3
.byte 5
.ascii "yhook"
.long 0x1ef7
.byte 6
.ascii "ytilde"
.long 0x1ef9
.byte 9
.ascii "zabovedot"
.long 0x17c
.byte 6
.ascii "zacute"
.long 0x17a
.byte 6
.ascii "zcaron"
.long 0x17e
.byte 13
.ascii "zerosubscript"
.long 0x2080
.byte 12
.ascii "zerosuperior"
.long 0x2070
.byte 7
.ascii "zstroke"
.long 0x1b6
.byte 0

.Lxkb_builtin_type_names:
.Lxkb_builtin_type_0: .asciz "TWO_LEVEL"
    .zero 64 - (. - .Lxkb_builtin_type_0)
.Lxkb_builtin_type_1: .asciz "ALPHABETIC"
    .zero 64 - (. - .Lxkb_builtin_type_1)
.Lxkb_builtin_type_2: .asciz "ONE_LEVEL"
    .zero 64 - (. - .Lxkb_builtin_type_2)
.Lxkb_builtin_type_3: .asciz "FOUR_LEVEL"
    .zero 64 - (. - .Lxkb_builtin_type_3)
.Lxkb_builtin_type_4: .asciz "KEYPAD"
    .zero 64 - (. - .Lxkb_builtin_type_4)
.Lxkb_builtin_type_5: .asciz "SEPARATE_CAPS_AND_SHIFT_ALPHABETIC"
    .zero 64 - (. - .Lxkb_builtin_type_5)

.section .bss
.balign 16
.Lxkb_text_ptr:         .quad 0
.Lxkb_text_end:         .quad 0
.Lxkb_token_length:     .long 0
.Lxkb_token_kind:       .long 0
.Lxkb_depth:            .long 0
.Lxkb_keycode:          .long 0
.Lxkb_group:            .long 0
.Lxkb_level:            .long 0
.Lxkb_type_flags:       .long 0
.Lxkb_key_block_first:  .long 0
.Lxkb_symbol_count:     .long 0
.Lxkb_alpha_key_count:  .long 0
.Lxkb_number:           .long 0
.Lxkb_keyname_tmp:      .zero 4
.Lxkb_keyname_alias:    .zero 4
.Lxkb_type_id:          .long 0
.Lxkb_type_group:       .long 0
.Lxkb_type_tmp_mask:    .long 0
.Lxkb_type_tmp_level:   .long 0
.Lxkb_type_tmp_preserve: .long 0
.Lxkb_type_map_slot:    .long 0
.Lxkb_mask_delimiter:   .long 0
.Lxkb_mask_accum:       .long 0
.Lxkb_vmod_index:       .long 0
.Lxkb_group_index:      .long 0
.Lxkb_level_three_index: .long 0
.Lxkb_num_lock_index:   .long 0
.Lxkb_keysym_tmp:       .long 0
.Lxkb_pending_modmap_count: .long 0
.Lxkb_token:            .zero 64
.balign 16
.global xkb_key_names
xkb_key_names:          .zero 1024        # 256 XKB keycodes, four-byte names
.global xkb_ascii_levels
xkb_ascii_levels:       .zero 32768       # 256 codes * 4 groups * 8 levels plus guard space
.balign 16
.global xkb_unicode_levels
xkb_unicode_levels:     .zero 131072      # uint32 scalars; 256 * 4 groups * 8 levels plus guard space
.global xkb_keysym_levels
xkb_keysym_levels:      .zero 131072      # raw modifier keysyms; same key/group/level indexing
.global xkb_key_types
xkb_key_types:          .zero 256         # legacy family flags retained for diagnostics
.global xkb_group_types
xkb_group_types:        .zero 1024        # 256 keys * 4 groups; 0xff means infer default
.global xkb_group_symbol_counts
xkb_group_symbol_counts: .zero 1024
.global xkb_type_names
xkb_type_names:         .zero 4096        # 64 type names * 64 bytes
.global xkb_type_modifiers
xkb_type_modifiers:     .zero 256         # 64 effective 32-bit modifier masks
.global xkb_type_map_counts
xkb_type_map_counts:    .zero 64
.global xkb_type_map_masks
xkb_type_map_masks:     .zero 8192        # 64 types * 32 exact modifier combinations
.global xkb_type_map_levels
xkb_type_map_levels:    .zero 2048        # 64 types * 32 one-byte LevelN values
.global xkb_type_map_preserves
xkb_type_map_preserves: .zero 8192        # 64 types * 32 preserved 32-bit masks
.global xkb_virtual_names
xkb_virtual_names:     .zero 1536        # 24 virtual modifier names * 64 bytes
.global xkb_virtual_count
xkb_virtual_count:     .long 0
.global xkb_virtual_masks
xkb_virtual_masks:    .zero 96         # explicit plus implicit effective 32-bit encodings
.global xkb_key_real_masks
xkb_key_real_masks:   .zero 1024       # 256 keys * one real modifier map
.global xkb_key_virtual_maps
xkb_key_virtual_maps: .zero 1024       # 256 keys * 32-bit virtual modifier map
.global xkb_key_real_map_kinds
xkb_key_real_map_kinds: .zero 256      # 1=keycode target, 2=keysym target
.global xkb_key_real_map_targets
xkb_key_real_map_targets: .zero 1024   # exact original target for modifier_map None
xkb_pending_modmap_targets: .zero 1024 # 256 deferred modifier_map targets
xkb_pending_modmap_masks: .zero 1024
xkb_pending_modmap_kinds: .zero 256    # 1=keycode target, 2=keysym target
.global xkb_key_virtual_explicit
xkb_key_virtual_explicit: .zero 256      # direct key property overrides compat vmods
.global xkb_key_repeat_flags
xkb_key_repeat_flags: .zero 256           # resolved key-wide policy; base-less keys remain false
.global xkb_key_repeat_explicit
xkb_key_repeat_explicit: .zero 256        # direct key repeat setting overrides compat
.global xkb_compat_default_repeat
xkb_compat_default_repeat: .zero 4        # xkb_compat interpret.repeat defaults to False
.global xkb_compat_rule_count
xkb_compat_rule_count: .long 0
.global xkb_compat_rules
xkb_compat_rules: .zero 2048             # 128 records * 16 bytes
.Lxkb_compat_tmp_keysym: .long 0
.Lxkb_compat_tmp_mask: .long 0
.Lxkb_compat_tmp_vmod: .long 0
.Lxkb_compat_tmp_predicate: .long 0
.Lxkb_compat_tmp_scope: .long 0
.Lxkb_compat_tmp_valid: .long 0
.Lxkb_compat_tmp_repeat: .zero 4
.global xkb_level_three_mask
xkb_level_three_mask:  .long 0           # initialized by xkb_reset_keymap
.global xkb_num_lock_mask
xkb_num_lock_mask:     .long 0           # initialized by xkb_reset_keymap
.global xkb_type_count
xkb_type_count:        .long 0
.global xkb_keymap_ready
xkb_keymap_ready:       .long 0
.global xkb_parse_error_stage
xkb_parse_error_stage:  .long 0
.global xkb_parse_error_offset
xkb_parse_error_offset: .long 0
.global xkb_parse_error_token_length
xkb_parse_error_token_length: .long 0
.global xkb_parse_error_token
xkb_parse_error_token:  .zero 64
.global xkb_parse_error_symbol_count
xkb_parse_error_symbol_count: .long 0
.global xkb_parse_error_alpha_count
xkb_parse_error_alpha_count: .long 0
.Lxkb_parse_stage:      .long 0

.section .text
.global xkb_reset_keymap
.type xkb_reset_keymap, @function
xkb_reset_keymap:
    push rdi
    push rsi
    push rcx
    xor eax, eax
    lea rdi, [rip + xkb_key_names]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_ascii_levels]
    mov ecx, 32768
    rep stosb
    lea rdi, [rip + xkb_unicode_levels]
    mov ecx, 131072
    rep stosb
    lea rdi, [rip + xkb_keysym_levels]
    mov ecx, 131072
    rep stosb
    lea rdi, [rip + xkb_key_types]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_group_symbol_counts]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_type_names]
    mov ecx, 4096
    rep stosb
    lea rdi, [rip + xkb_type_modifiers]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_type_map_counts]
    mov ecx, 64
    rep stosb
    lea rdi, [rip + xkb_type_map_masks]
    mov ecx, 8192
    rep stosb
    lea rdi, [rip + xkb_type_map_levels]
    mov ecx, 2048
    rep stosb
    lea rdi, [rip + xkb_type_map_preserves]
    mov ecx, 8192
    rep stosb
    lea rdi, [rip + xkb_virtual_names]
    mov ecx, 1536
    rep stosb
    lea rdi, [rip + xkb_virtual_masks]
    mov ecx, 96
    rep stosb
    lea rdi, [rip + xkb_key_real_masks]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_key_virtual_maps]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_key_real_map_kinds]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_key_real_map_targets]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_pending_modmap_targets]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_pending_modmap_masks]
    mov ecx, 1024
    rep stosb
    lea rdi, [rip + xkb_pending_modmap_kinds]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_key_virtual_explicit]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_key_repeat_flags]
    mov ecx, 256
    rep stosb
    lea rdi, [rip + xkb_key_repeat_explicit]
    mov ecx, 256
    rep stosb
    mov dword ptr [rip + xkb_compat_default_repeat], 0
    mov dword ptr [rip + xkb_compat_rule_count], 0
    lea rdi, [rip + xkb_compat_rules]
    mov ecx, 2048
    rep stosb
    mov dword ptr [rip + .Lxkb_compat_tmp_keysym], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_mask], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_vmod], -1
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_scope], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_valid], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_repeat], 0
    mov dword ptr [rip + .Lxkb_pending_modmap_count], 0
    mov dword ptr [rip + .Lxkb_keysym_tmp], 0
    lea rdi, [rip + xkb_group_types]
    mov al, 255
    mov ecx, 1024
    rep stosb
    lea rsi, [rip + .Lxkb_builtin_type_names]
    lea rdi, [rip + xkb_type_names]
    mov ecx, 384
    rep movsb
    mov dword ptr [rip + xkb_type_count], 6
    mov dword ptr [rip + xkb_type_modifiers + 0], 1
    mov dword ptr [rip + xkb_type_modifiers + 4], 3
    mov dword ptr [rip + xkb_type_modifiers + 8], 0
    mov dword ptr [rip + xkb_type_modifiers + 12], 129
    mov dword ptr [rip + xkb_type_modifiers + 16], 17
    mov dword ptr [rip + xkb_type_modifiers + 20], 131
    mov byte ptr [rip + xkb_type_map_counts + 0], 1
    mov byte ptr [rip + xkb_type_map_counts + 1], 2
    mov byte ptr [rip + xkb_type_map_counts + 2], 1
    mov byte ptr [rip + xkb_type_map_counts + 3], 3
    mov byte ptr [rip + xkb_type_map_counts + 4], 3
    mov byte ptr [rip + xkb_type_map_counts + 5], 6
    mov dword ptr [rip + xkb_type_map_masks + 0], 1
    mov dword ptr [rip + xkb_type_map_masks + 128], 1
    mov dword ptr [rip + xkb_type_map_masks + 132], 2
    mov dword ptr [rip + xkb_type_map_masks + 256], 0
    mov dword ptr [rip + xkb_type_map_masks + 384], 1
    mov dword ptr [rip + xkb_type_map_masks + 388], 128
    mov dword ptr [rip + xkb_type_map_masks + 392], 129
    mov dword ptr [rip + xkb_type_map_masks + 512], 1
    mov dword ptr [rip + xkb_type_map_masks + 516], 16
    mov dword ptr [rip + xkb_type_map_masks + 520], 17
    mov dword ptr [rip + xkb_type_map_masks + 640], 1
    mov dword ptr [rip + xkb_type_map_masks + 644], 2
    mov dword ptr [rip + xkb_type_map_masks + 648], 128
    mov dword ptr [rip + xkb_type_map_masks + 652], 129
    mov dword ptr [rip + xkb_type_map_masks + 656], 130
    mov dword ptr [rip + xkb_type_map_masks + 660], 131
    mov byte ptr [rip + xkb_type_map_levels + 0], 2
    mov byte ptr [rip + xkb_type_map_levels + 32], 2
    mov byte ptr [rip + xkb_type_map_levels + 33], 2
    mov byte ptr [rip + xkb_type_map_levels + 64], 1
    mov byte ptr [rip + xkb_type_map_levels + 96], 2
    mov byte ptr [rip + xkb_type_map_levels + 97], 3
    mov byte ptr [rip + xkb_type_map_levels + 98], 4
    mov byte ptr [rip + xkb_type_map_levels + 128], 2
    mov byte ptr [rip + xkb_type_map_levels + 129], 2
    mov byte ptr [rip + xkb_type_map_levels + 130], 1
    mov byte ptr [rip + xkb_type_map_levels + 160], 2
    mov byte ptr [rip + xkb_type_map_levels + 161], 4
    mov byte ptr [rip + xkb_type_map_levels + 162], 3
    mov byte ptr [rip + xkb_type_map_levels + 163], 4
    mov byte ptr [rip + xkb_type_map_levels + 164], 3
    mov byte ptr [rip + xkb_type_map_levels + 165], 3
    mov dword ptr [rip + xkb_virtual_count], 0
    mov dword ptr [rip + xkb_level_three_mask], 128
    mov dword ptr [rip + xkb_num_lock_mask], 16
    mov dword ptr [rip + .Lxkb_level_three_index], -1
    mov dword ptr [rip + .Lxkb_num_lock_index], -1
    mov dword ptr [rip + .Lxkb_vmod_index], 0
    mov dword ptr [rip + xkb_keymap_ready], 0
    mov dword ptr [rip + .Lxkb_key_block_first], 0
    mov dword ptr [rip + .Lxkb_symbol_count], 0
    mov dword ptr [rip + .Lxkb_alpha_key_count], 0
    pop rcx
    pop rsi
    pop rdi
    ret
.size xkb_reset_keymap, . - xkb_reset_keymap

# Returns token kind in EAX: 0=end, 1=word/string, 2=<KEYNAME>, punctuation=ASCII.
# Token contents are copied to .Lxkb_token (truncated safely at 63 bytes).
.type .Lxkb_next_token, @function
.Lxkb_next_token:
    push rbx
    push r12
    push r13
    push r14
    push r15
    lea rdi, [rip + .Lxkb_token]
    xor eax, eax
    mov ecx, 64
    rep stosb
    mov dword ptr [rip + .Lxkb_token_length], 0
    mov dword ptr [rip + .Lxkb_token_kind], 0
.Lxkb_skip:
    mov rbx, qword ptr [rip + .Lxkb_text_ptr]
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_token_eof
    movzx eax, byte ptr [rbx]
    test eax, eax
    jz .Lxkb_token_eof
    cmp eax, 33
    jae .Lxkb_check_comment
    inc rbx
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip
.Lxkb_check_comment:
    cmp al, '#'
    je .Lxkb_skip_line_comment
    cmp al, '/'
    jne .Lxkb_begin_token
    lea r12, [rbx + 1]
    cmp r12, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_begin_token
    movzx eax, byte ptr [r12]
    cmp al, '/'
    je .Lxkb_skip_line_comment
    cmp al, '*'
    je .Lxkb_skip_block_comment
    jmp .Lxkb_begin_token
.Lxkb_skip_line_comment:
    mov rbx, qword ptr [rip + .Lxkb_text_ptr]
.Lxkb_line_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_line_done
    movzx eax, byte ptr [rbx]
    inc rbx
    cmp al, 10
    jne .Lxkb_line_loop
.Lxkb_line_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip
.Lxkb_skip_block_comment:
    add rbx, 2
.Lxkb_block_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_block_done
    movzx eax, byte ptr [rbx]
    cmp al, '*'
    jne .Lxkb_block_advance
    lea r12, [rbx + 1]
    cmp r12, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_block_advance
    cmp byte ptr [r12], '/'
    je .Lxkb_block_end
.Lxkb_block_advance:
    inc rbx
    jmp .Lxkb_block_loop
.Lxkb_block_end:
    add rbx, 2
.Lxkb_block_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    jmp .Lxkb_skip

.Lxkb_begin_token:
    mov r12, rbx
    movzx eax, byte ptr [rbx]
    cmp al, '<'
    je .Lxkb_collect_keyname
    cmp al, '"'
    je .Lxkb_collect_quote
    # XKB identifiers and numeric literals contain ASCII letters, digits,
    # and underscores. Hyphens are punctuation outside quoted strings.
    cmp al, 'A'
    jb .Lxkb_check_lower
    cmp al, 'Z'
    jbe .Lxkb_collect_word
.Lxkb_check_lower:
    cmp al, 'a'
    jb .Lxkb_check_digit
    cmp al, 'z'
    jbe .Lxkb_collect_word
.Lxkb_check_digit:
    cmp al, '0'
    jb .Lxkb_check_underscore
    cmp al, '9'
    jbe .Lxkb_collect_word
.Lxkb_check_underscore:
    cmp al, '_'
    je .Lxkb_collect_word
    # Single-character punctuation token.
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi], al
    mov dword ptr [rip + .Lxkb_token_length], 1
    mov dword ptr [rip + .Lxkb_token_kind], eax
    inc rbx
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, dword ptr [rip + .Lxkb_token_kind]
    jmp .Lxkb_token_done

.Lxkb_collect_word:
    mov dword ptr [rip + .Lxkb_token_kind], 1
.Lxkb_word_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_word_done
    movzx eax, byte ptr [rbx]
    cmp al, 'A'
    jb .Lxkb_word_lower
    cmp al, 'Z'
    jbe .Lxkb_word_copy
.Lxkb_word_lower:
    cmp al, 'a'
    jb .Lxkb_word_digit
    cmp al, 'z'
    jbe .Lxkb_word_copy
.Lxkb_word_digit:
    cmp al, '0'
    jb .Lxkb_word_underscore
    cmp al, '9'
    jbe .Lxkb_word_copy
.Lxkb_word_underscore:
    cmp al, '_'
    jne .Lxkb_word_done
.Lxkb_word_copy:
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_word_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_word_skip_copy:
    inc rbx
    jmp .Lxkb_word_loop
.Lxkb_word_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 1
    jmp .Lxkb_token_done

.Lxkb_collect_keyname:
    inc rbx
    mov dword ptr [rip + .Lxkb_token_kind], 2
.Lxkb_keyname_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_keyname_done
    movzx eax, byte ptr [rbx]
    cmp al, '>'
    je .Lxkb_keyname_end
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_keyname_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_keyname_skip_copy:
    inc rbx
    jmp .Lxkb_keyname_loop
.Lxkb_keyname_end:
    inc rbx
.Lxkb_keyname_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 2
    jmp .Lxkb_token_done

.Lxkb_collect_quote:
    inc rbx
    mov dword ptr [rip + .Lxkb_token_kind], 1
.Lxkb_quote_loop:
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_quote_done
    movzx eax, byte ptr [rbx]
    cmp al, '"'
    je .Lxkb_quote_end
    cmp al, '\\'
    jne .Lxkb_quote_copy
    # Escaped bytes are not needed for the supported type/symbol names.
    inc rbx
    cmp rbx, qword ptr [rip + .Lxkb_text_end]
    jae .Lxkb_quote_done
    movzx eax, byte ptr [rbx]
.Lxkb_quote_copy:
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jae .Lxkb_quote_skip_copy
    lea rdi, [rip + .Lxkb_token]
    mov byte ptr [rdi + rcx], al
    inc ecx
    mov dword ptr [rip + .Lxkb_token_length], ecx
.Lxkb_quote_skip_copy:
    inc rbx
    jmp .Lxkb_quote_loop
.Lxkb_quote_end:
    inc rbx
.Lxkb_quote_done:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    mov eax, 1
.Lxkb_token_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.Lxkb_token_eof:
    mov qword ptr [rip + .Lxkb_text_ptr], rbx
    xor eax, eax
    jmp .Lxkb_token_done
.size .Lxkb_next_token, . - .Lxkb_next_token

# RDI points to a NUL-terminated expected token; EAX=1 for equality.
.type .Lxkb_token_is, @function
.Lxkb_token_is:
    push rbx
    push r12
    mov rbx, rdi
    lea r12, [rip + .Lxkb_token]
.Lxkb_token_cmp:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r12]
    jne .Lxkb_token_ne
    test al, al
    jz .Lxkb_token_eq
    inc rbx
    inc r12
    jmp .Lxkb_token_cmp
.Lxkb_token_eq:
    mov eax, 1
    jmp .Lxkb_token_cmp_done
.Lxkb_token_ne:
    xor eax, eax
.Lxkb_token_cmp_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_token_is, . - .Lxkb_token_is

# Convert current decimal token to EAX; EDX=1 if valid, else EDX=0.
.type .Lxkb_parse_decimal, @function
.Lxkb_parse_decimal:
    push rbx
    push r12
    lea rbx, [rip + .Lxkb_token]
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    test ecx, ecx
    jz .Lxkb_decimal_bad
    xor eax, eax
    xor r12d, r12d
.Lxkb_decimal_loop:
    movzx edx, byte ptr [rbx + r12]
    cmp dl, '0'
    jb .Lxkb_decimal_bad
    cmp dl, '9'
    ja .Lxkb_decimal_bad
    imul eax, eax, 10
    sub edx, '0'
    add eax, edx
    cmp eax, 65535
    ja .Lxkb_decimal_bad
    inc r12d
    cmp r12d, ecx
    jb .Lxkb_decimal_loop
    mov edx, 1
    jmp .Lxkb_decimal_done
.Lxkb_decimal_bad:
    xor eax, eax
    xor edx, edx
.Lxkb_decimal_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_decimal, . - .Lxkb_parse_decimal

# Current token is Group1..Group4; EAX=zero-based group or -1.
.type .Lxkb_parse_group, @function
.Lxkb_parse_group:
    push rbx
    cmp dword ptr [rip + .Lxkb_token_length], 6
    jb .Lxkb_group_bad
    lea rbx, [rip + .Lxkb_token]
    cmp dword ptr [rbx], 0x756f7247   # "Grou"
    jne .Lxkb_group_bad
    cmp byte ptr [rbx + 4], 'p'
    jne .Lxkb_group_bad
    movzx eax, byte ptr [rbx + 5]
    cmp al, '1'
    jb .Lxkb_group_bad
    cmp al, '4'
    ja .Lxkb_group_bad
    sub eax, '1'
    jmp .Lxkb_group_done
.Lxkb_group_bad:
    mov eax, -1
.Lxkb_group_done:
    pop rbx
    ret
.size .Lxkb_parse_group, . - .Lxkb_parse_group

# Search xkb_key_names for the four-byte .Lxkb_keyname_tmp; EAX=keycode or 0.
.type .Lxkb_find_keycode, @function
.Lxkb_find_keycode:
    push rbx
    push r12
    mov r12d, 8
.Lxkb_find_keycode_loop:
    cmp r12d, 256
    jae .Lxkb_find_keycode_missing
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rbx]
    cmp eax, dword ptr [rip + .Lxkb_keyname_tmp]
    je .Lxkb_find_keycode_found
    inc r12d
    jmp .Lxkb_find_keycode_loop
.Lxkb_find_keycode_found:
    mov eax, r12d
    jmp .Lxkb_find_keycode_done
.Lxkb_find_keycode_missing:
    xor eax, eax
.Lxkb_find_keycode_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_find_keycode, . - .Lxkb_find_keycode

# Parse xkb_keycodes entries of the form <NAME> = decimal;.
.type .Lxkb_parse_keycodes, @function
.Lxkb_parse_keycodes:
    push rbx
    push r12
    push r13
    push r14
    push r15
.Lxkb_find_keycodes_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    lea rdi, [rip + .Lxkb_section_keycodes]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_find_keycodes_section
.Lxkb_find_keycodes_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    cmp eax, '{'
    jne .Lxkb_find_keycodes_open
    mov dword ptr [rip + .Lxkb_depth], 1
.Lxkb_keycodes_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_keycodes_fail
    cmp eax, '{'
    je .Lxkb_keycodes_nested_open
    cmp eax, '}'
    je .Lxkb_keycodes_close
    cmp eax, 2
    jne .Lxkb_keycodes_loop
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_keycodes_loop
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 2
    je .Lxkb_keycodes_alias
    call .Lxkb_parse_decimal
    test edx, edx
    jz .Lxkb_keycodes_loop
    cmp eax, 8
    jb .Lxkb_keycodes_loop
    cmp eax, 255
    ja .Lxkb_keycodes_loop
    mov r12d, eax
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    mov dword ptr [rbx], eax
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_alias:
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_alias], eax
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    push rax
    mov eax, dword ptr [rip + .Lxkb_keyname_alias]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_find_keycode
    mov r12d, eax
    pop rax
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    test r12d, r12d
    jz .Lxkb_keycodes_loop
    lea rbx, [rip + xkb_key_names]
    lea rbx, [rbx + r12*4]
    mov eax, dword ptr [rip + .Lxkb_keyname_tmp]
    mov dword ptr [rbx], eax
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_nested_open:
    inc dword ptr [rip + .Lxkb_depth]
    jmp .Lxkb_keycodes_loop
.Lxkb_keycodes_close:
    dec dword ptr [rip + .Lxkb_depth]
    jnz .Lxkb_keycodes_loop
    xor eax, eax
    jmp .Lxkb_keycodes_done
.Lxkb_keycodes_fail:
    mov eax, -1
.Lxkb_keycodes_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_keycodes, . - .Lxkb_parse_keycodes

# Return type flags for the current type token in EAX.
# Search the current token for a case-sensitive NUL-terminated substring.
# RDI=needle; EAX=1 when found.
.type .Lxkb_token_contains, @function
.Lxkb_token_contains:
    push rbx
    push r12
    push r13
    mov r12, rdi
    lea rbx, [rip + .Lxkb_token]
.Lxkb_contains_outer:
    mov al, byte ptr [rbx]
    test al, al
    jz .Lxkb_contains_no
    mov r13, rbx
    mov rdi, r12
.Lxkb_contains_inner:
    mov dl, byte ptr [rdi]
    test dl, dl
    jz .Lxkb_contains_yes
    cmp dl, byte ptr [r13]
    jne .Lxkb_contains_next
    inc rdi
    inc r13
    jmp .Lxkb_contains_inner
.Lxkb_contains_next:
    inc rbx
    jmp .Lxkb_contains_outer
.Lxkb_contains_yes:
    mov eax, 1
    jmp .Lxkb_contains_done
.Lxkb_contains_no:
    xor eax, eax
.Lxkb_contains_done:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_token_contains, . - .Lxkb_token_contains

# Resolve the current token to a previously declared XKB type; EAX=-1 if absent.
.type .Lxkb_find_type, @function
.Lxkb_find_type:
    push rbx
    push r12
    push r13
    push r14
    xor r12d, r12d
    mov r13d, dword ptr [rip + xkb_type_count]
.Lxkb_find_type_loop:
    cmp r12d, r13d
    jae .Lxkb_find_type_missing
    mov eax, r12d
    shl eax, 6
    lea rbx, [rip + xkb_type_names]
    add rbx, rax
    lea r14, [rip + .Lxkb_token]
    mov ecx, 64
.Lxkb_find_type_compare:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r14]
    jne .Lxkb_find_type_next
    test al, al
    jz .Lxkb_find_type_found
    inc rbx
    inc r14
    dec ecx
    jnz .Lxkb_find_type_compare
.Lxkb_find_type_next:
    inc r12d
    jmp .Lxkb_find_type_loop
.Lxkb_find_type_found:
    mov eax, r12d
    jmp .Lxkb_find_type_done
.Lxkb_find_type_missing:
    mov eax, -1
.Lxkb_find_type_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_find_type, . - .Lxkb_find_type

# Register the current token as a virtual-modifier name. EAX=index or -1.
.type .Lxkb_register_virtual, @function
.Lxkb_register_virtual:
    push rbx
    push r12
    push r13
    push r14
    mov r12d, dword ptr [rip + xkb_virtual_count]
    xor r13d, r13d
.Lxkb_register_virtual_find:
    cmp r13d, r12d
    jae .Lxkb_register_virtual_add
    mov eax, r13d
    shl eax, 6
    lea rbx, [rip + xkb_virtual_names]
    add rbx, rax
    lea r14, [rip + .Lxkb_token]
    mov ecx, 64
.Lxkb_register_virtual_compare:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r14]
    jne .Lxkb_register_virtual_next
    test al, al
    jz .Lxkb_register_virtual_found
    inc rbx
    inc r14
    dec ecx
    jnz .Lxkb_register_virtual_compare
.Lxkb_register_virtual_next:
    inc r13d
    jmp .Lxkb_register_virtual_find
.Lxkb_register_virtual_found:
    # A repeated declaration must not overwrite an explicit encoding already
    # parsed from an earlier section.
    mov eax, r13d
    jmp .Lxkb_register_virtual_done
.Lxkb_register_virtual_add:
    cmp r12d, 24
    jae .Lxkb_register_virtual_fail
    mov eax, r12d
    shl eax, 6
    lea rbx, [rip + xkb_virtual_names]
    add rbx, rax
    lea r14, [rip + .Lxkb_token]
    mov ecx, 64
.Lxkb_register_virtual_copy:
    mov al, byte ptr [r14]
    mov byte ptr [rbx], al
    inc r14
    inc rbx
    dec ecx
    jnz .Lxkb_register_virtual_copy
    mov eax, r12d
    inc r12d
    mov dword ptr [rip + xkb_virtual_count], r12d
    mov r13d, eax
    mov ecx, r13d
    shl ecx, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov dword ptr [rbx + rcx], 0
    jmp .Lxkb_register_virtual_note_special
.Lxkb_register_virtual_note_special:
    lea rdi, [rip + .Lxkb_mod_level_three]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_register_virtual_check_numlock
    mov dword ptr [rip + .Lxkb_level_three_index], r13d
    mov dword ptr [rip + xkb_level_three_mask], 128
    mov eax, r13d
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov dword ptr [rbx + rax], 128
    jmp .Lxkb_register_virtual_added
.Lxkb_register_virtual_check_numlock:
    lea rdi, [rip + .Lxkb_mod_num_lock]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_register_virtual_added
    mov dword ptr [rip + .Lxkb_num_lock_index], r13d
    mov dword ptr [rip + xkb_num_lock_mask], 16
    mov eax, r13d
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov dword ptr [rbx + rax], 16
.Lxkb_register_virtual_added:
    mov eax, r13d
    jmp .Lxkb_register_virtual_done
.Lxkb_register_virtual_fail:
    mov eax, -1
.Lxkb_register_virtual_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_register_virtual, . - .Lxkb_register_virtual

# Find a previously declared virtual modifier by the current token.
# EAX=index or -1. Unlike register_virtual this never creates a declaration.
.type .Lxkb_find_virtual, @function
.Lxkb_find_virtual:
    push rbx
    push r12
    push r13
    push r14
    xor r12d, r12d
    mov r13d, dword ptr [rip + xkb_virtual_count]
.Lxkb_find_virtual_loop:
    cmp r12d, r13d
    jae .Lxkb_find_virtual_missing
    mov eax, r12d
    shl eax, 6
    lea rbx, [rip + xkb_virtual_names]
    add rbx, rax
    lea r14, [rip + .Lxkb_token]
    mov ecx, 64
.Lxkb_find_virtual_compare:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r14]
    jne .Lxkb_find_virtual_next
    test al, al
    jz .Lxkb_find_virtual_found
    inc rbx
    inc r14
    dec ecx
    jnz .Lxkb_find_virtual_compare
.Lxkb_find_virtual_next:
    inc r12d
    jmp .Lxkb_find_virtual_loop
.Lxkb_find_virtual_found:
    mov eax, r12d
    jmp .Lxkb_find_virtual_done
.Lxkb_find_virtual_missing:
    mov eax, -1
.Lxkb_find_virtual_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_find_virtual, . - .Lxkb_find_virtual

# Scan all sections before parsing types so virtual modifier indices reflect
# declaration order across the complete text-v1 keymap.
# Parse one explicit virtual-modifier encoding. Accept real modifier names,
# numeric masks, or none, joined by '+'. Stop after ',' or ';' and return the
# delimiter in EDX; the virtual modifier's declaration index remains separate
# from the effective wire mask.
.type .Lxkb_parse_vmod_encoding, @function
.Lxkb_parse_vmod_encoding:
    push rbx
    push r12
    push r13
    push r14
    xor r12d, r12d
    xor r13d, r13d
.Lxkb_vmod_encoding_loop:
    call .Lxkb_next_token
    cmp eax, '+'
    je .Lxkb_vmod_encoding_loop
    cmp eax, ','
    je .Lxkb_vmod_encoding_comma
    cmp eax, ';'
    je .Lxkb_vmod_encoding_semicolon
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_vmod_encoding_fail
    call .Lxkb_modifier_bit
    test edx, edx
    jz .Lxkb_vmod_encoding_fail
    or r12d, eax
    inc r13d
    jmp .Lxkb_vmod_encoding_loop
.Lxkb_vmod_encoding_comma:
    cmp r13d, 0
    je .Lxkb_vmod_encoding_fail
    mov edx, ','
    jmp .Lxkb_vmod_encoding_done
.Lxkb_vmod_encoding_semicolon:
    cmp r13d, 0
    je .Lxkb_vmod_encoding_fail
    mov edx, ';'
.Lxkb_vmod_encoding_done:
    mov eax, r12d
    mov ecx, 1
    jmp .Lxkb_vmod_encoding_exit
.Lxkb_vmod_encoding_fail:
    xor eax, eax
    xor edx, edx
    xor ecx, ecx
.Lxkb_vmod_encoding_exit:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_vmod_encoding, . - .Lxkb_parse_vmod_encoding

.type .Lxkb_parse_virtual_modifiers, @function
.Lxkb_parse_virtual_modifiers:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, qword ptr [rip + .Lxkb_text_ptr]
.Lxkb_vmod_scan:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_vmod_scan_done
    lea rdi, [rip + .Lxkb_word_virtual_modifiers]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_vmod_scan
.Lxkb_vmod_name:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_vmod_scan_done
    cmp eax, ';'
    je .Lxkb_vmod_scan
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_vmod_statement_skip
    call .Lxkb_register_virtual
    test eax, eax
    js .Lxkb_vmod_scan_fail
    mov dword ptr [rip + .Lxkb_vmod_index], eax
.Lxkb_vmod_after_name:
    call .Lxkb_next_token
    cmp eax, ';'
    je .Lxkb_vmod_scan
    cmp eax, ','
    je .Lxkb_vmod_name
    cmp eax, '='
    jne .Lxkb_vmod_statement_skip
    call .Lxkb_parse_vmod_encoding
    test ecx, ecx
    jz .Lxkb_vmod_scan_fail
    mov r15d, edx
    mov ecx, dword ptr [rip + .Lxkb_vmod_index]
    mov edx, ecx
    shl edx, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov dword ptr [rbx + rdx], eax
    cmp ecx, dword ptr [rip + .Lxkb_level_three_index]
    jne .Lxkb_vmod_not_level_three
    mov dword ptr [rip + xkb_level_three_mask], eax
.Lxkb_vmod_not_level_three:
    cmp ecx, dword ptr [rip + .Lxkb_num_lock_index]
    jne .Lxkb_vmod_encoding_complete
    mov dword ptr [rip + xkb_num_lock_mask], eax
.Lxkb_vmod_encoding_complete:
    cmp r15d, ','
    je .Lxkb_vmod_name
    jmp .Lxkb_vmod_scan
.Lxkb_vmod_statement_skip:
    cmp eax, ';'
    je .Lxkb_vmod_scan
    call .Lxkb_next_token
    jmp .Lxkb_vmod_statement_skip
.Lxkb_vmod_scan_fail:
    mov eax, -1
    jmp .Lxkb_vmod_scan_done_restore
.Lxkb_vmod_scan_done:
    xor eax, eax
.Lxkb_vmod_scan_done_restore:
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_virtual_modifiers, . - .Lxkb_parse_virtual_modifiers

# Convert a modifier name token into its 32-bit XKB modifier bit.
# Rebase built-in fallback type maps after virtual modifier declarations
# have supplied the effective XKB 32-bit masks for LevelThree and NumLock.
.type .Lxkb_rebase_builtin_types, @function
.Lxkb_rebase_builtin_types:
    mov eax, dword ptr [rip + xkb_level_three_mask]
    mov ecx, eax
    or ecx, 1
    mov dword ptr [rip + xkb_type_modifiers + 12], ecx
    mov dword ptr [rip + xkb_type_map_masks + 388], eax
    mov ecx, eax
    or ecx, 1
    mov dword ptr [rip + xkb_type_map_masks + 392], ecx

    mov eax, dword ptr [rip + xkb_num_lock_mask]
    mov ecx, eax
    or ecx, 1
    mov dword ptr [rip + xkb_type_modifiers + 16], ecx
    mov dword ptr [rip + xkb_type_map_masks + 516], eax
    mov ecx, eax
    or ecx, 1
    mov dword ptr [rip + xkb_type_map_masks + 520], ecx

    mov eax, dword ptr [rip + xkb_level_three_mask]
    mov ecx, eax
    or ecx, 3
    mov dword ptr [rip + xkb_type_modifiers + 20], ecx
    mov ecx, eax
    or ecx, 1
    mov dword ptr [rip + xkb_type_map_masks + 648], eax
    mov dword ptr [rip + xkb_type_map_masks + 652], ecx
    mov ecx, eax
    or ecx, 2
    mov dword ptr [rip + xkb_type_map_masks + 656], ecx
    mov ecx, eax
    or ecx, 3
    mov dword ptr [rip + xkb_type_map_masks + 660], ecx
    ret
.size .Lxkb_rebase_builtin_types, . - .Lxkb_rebase_builtin_types

# Parse an unsigned 32-bit decimal or 0x-prefixed modifier mask.
# EAX=mask, EDX=1 on success. Overflow and malformed literals fail closed.
.type .Lxkb_parse_mask_literal, @function
.Lxkb_parse_mask_literal:
    push rbx
    push r12
    push r13
    push r14
    push r15
    lea rbx, [rip + .Lxkb_token]
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    test ecx, ecx
    jz .Lxkb_mask_literal_bad
    mov r15d, ecx
    mov r13d, 10
    xor r12d, r12d
    cmp ecx, 3
    jb .Lxkb_mask_literal_loop
    cmp byte ptr [rbx], '0'
    jne .Lxkb_mask_literal_loop
    mov al, byte ptr [rbx + 1]
    cmp al, 'x'
    je .Lxkb_mask_literal_hex
    cmp al, 'X'
    jne .Lxkb_mask_literal_loop
.Lxkb_mask_literal_hex:
    mov r13d, 16
    add rbx, 2
    sub r15d, 2
.Lxkb_mask_literal_loop:
    xor eax, eax
    mov r12d, 0
.Lxkb_mask_literal_digit:
    movzx r14d, byte ptr [rbx + r12]
    cmp r14b, '0'
    jb .Lxkb_mask_literal_bad
    cmp r14b, '9'
    jbe .Lxkb_mask_literal_decimal_digit
    cmp r13d, 16
    jne .Lxkb_mask_literal_bad
    cmp r14b, 'a'
    jb .Lxkb_mask_literal_upper_hex
    cmp r14b, 'f'
    jbe .Lxkb_mask_literal_lower_hex
.Lxkb_mask_literal_upper_hex:
    cmp r14b, 'A'
    jb .Lxkb_mask_literal_bad
    cmp r14b, 'F'
    ja .Lxkb_mask_literal_bad
    sub r14d, 'A'
    add r14d, 10
    jmp .Lxkb_mask_literal_accumulate
.Lxkb_mask_literal_lower_hex:
    sub r14d, 'a'
    add r14d, 10
    jmp .Lxkb_mask_literal_accumulate
.Lxkb_mask_literal_decimal_digit:
    sub r14d, '0'
.Lxkb_mask_literal_accumulate:
    mov ecx, r13d
    mul ecx
    test edx, edx
    jnz .Lxkb_mask_literal_bad
    add eax, r14d
    jc .Lxkb_mask_literal_bad
    inc r12d
    cmp r12d, r15d
    jb .Lxkb_mask_literal_digit
    mov edx, 1
    jmp .Lxkb_mask_literal_done
.Lxkb_mask_literal_bad:
    xor eax, eax
    xor edx, edx
.Lxkb_mask_literal_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_mask_literal, . - .Lxkb_parse_mask_literal

.type .Lxkb_modifier_bit, @function
.Lxkb_modifier_bit:
    push rbx
    push r12
    push r13
    push r14
    push r15
    movzx eax, byte ptr [rip + .Lxkb_token]
    cmp al, '0'
    jb .Lxkb_modifier_named
    cmp al, '9'
    ja .Lxkb_modifier_named
    call .Lxkb_parse_mask_literal
    test edx, edx
    jnz .Lxkb_modifier_done
    jmp .Lxkb_modifier_unknown_return
.Lxkb_modifier_named:
    lea rdi, [rip + .Lxkb_mod_shift]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_shift
    lea rdi, [rip + .Lxkb_mod_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_lock
    lea rdi, [rip + .Lxkb_mod_control]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_control
    lea rdi, [rip + .Lxkb_mod_mod1]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_mod1
    lea rdi, [rip + .Lxkb_mod_mod2]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_mod2
    lea rdi, [rip + .Lxkb_mod_mod3]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_mod3
    lea rdi, [rip + .Lxkb_mod_mod4]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_mod4
    lea rdi, [rip + .Lxkb_mod_mod5]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_mod5
    lea rdi, [rip + .Lxkb_mod_none]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_none
    lea rdi, [rip + .Lxkb_mod_none_lower]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_none
    lea rdi, [rip + .Lxkb_mod_all]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_all
    lea rdi, [rip + .Lxkb_mod_level_three]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_level_three
    lea rdi, [rip + .Lxkb_mod_num_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_num_lock
    xor r12d, r12d
    mov r13d, dword ptr [rip + xkb_virtual_count]
.Lxkb_modifier_virtual_loop:
    cmp r12d, r13d
    jae .Lxkb_modifier_unknown
    mov eax, r12d
    shl eax, 6
    lea rbx, [rip + xkb_virtual_names]
    add rbx, rax
    lea r14, [rip + .Lxkb_token]
    mov ecx, 64
.Lxkb_modifier_virtual_compare:
    mov al, byte ptr [rbx]
    cmp al, byte ptr [r14]
    jne .Lxkb_modifier_virtual_next
    test al, al
    jz .Lxkb_modifier_virtual_found
    inc rbx
    inc r14
    dec ecx
    jnz .Lxkb_modifier_virtual_compare
.Lxkb_modifier_virtual_next:
    inc r12d
    jmp .Lxkb_modifier_virtual_loop
.Lxkb_modifier_virtual_found:
    # The declaration index is only an internal name-table index. The
    # compositor's XKB state uses the virtual modifier's effective encoding,
    # which may be a real modifier mask, a canonical high bit, or zero.
    mov eax, r12d
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov eax, dword ptr [rbx + rax]
    jmp .Lxkb_modifier_done
    # Undeclared convenience fallback only; declared LevelFive uses its own
    # keymap-wide virtual bit through the lookup above.
.Lxkb_modifier_shift:       mov eax, 1; jmp .Lxkb_modifier_done
.Lxkb_modifier_lock:        mov eax, 2; jmp .Lxkb_modifier_done
.Lxkb_modifier_control:     mov eax, 4; jmp .Lxkb_modifier_done
.Lxkb_modifier_mod1:        mov eax, 8; jmp .Lxkb_modifier_done
.Lxkb_modifier_mod2:        mov eax, 16; jmp .Lxkb_modifier_done
.Lxkb_modifier_mod3:        mov eax, 32; jmp .Lxkb_modifier_done
.Lxkb_modifier_mod4:        mov eax, 64; jmp .Lxkb_modifier_done
.Lxkb_modifier_mod5:        mov eax, 128; jmp .Lxkb_modifier_done
.Lxkb_modifier_level_three:
    mov eax, dword ptr [rip + xkb_level_three_mask]
    jmp .Lxkb_modifier_done
.Lxkb_modifier_num_lock:
    mov eax, dword ptr [rip + xkb_num_lock_mask]
    jmp .Lxkb_modifier_done
.Lxkb_modifier_level_five:
    mov eax, 32
    jmp .Lxkb_modifier_done
.Lxkb_modifier_none:        xor eax, eax; jmp .Lxkb_modifier_done
.Lxkb_modifier_all:         mov eax, -1; jmp .Lxkb_modifier_done
.Lxkb_modifier_unknown:
    lea rdi, [rip + .Lxkb_mod_level_five]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_modifier_unknown_return
    mov eax, 32
    jmp .Lxkb_modifier_done
.Lxkb_modifier_done:
    mov edx, 1                 # EDX distinguishes a valid mask from failure
    jmp .Lxkb_modifier_exit
.Lxkb_modifier_unknown_return:
    xor eax, eax
    xor edx, edx
.Lxkb_modifier_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_modifier_bit, . - .Lxkb_modifier_bit

# Parse a plus-separated modifier list through the requested delimiter in EDI.
.type .Lxkb_parse_modmask, @function
.Lxkb_parse_modmask:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    xor r13d, r13d
.Lxkb_modmask_loop:
    call .Lxkb_next_token
    cmp eax, r12d
    je .Lxkb_modmask_done
    cmp eax, '+'
    je .Lxkb_modmask_loop
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_modmask_bad
    call .Lxkb_modifier_bit
    test edx, edx
    jz .Lxkb_modmask_bad
    or r13d, eax
    jmp .Lxkb_modmask_loop
.Lxkb_modmask_bad:
    xor eax, eax
    xor edx, edx
    jmp .Lxkb_modmask_exit
.Lxkb_modmask_done:
    mov eax, r13d
    mov edx, 1
.Lxkb_modmask_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_modmask, . - .Lxkb_parse_modmask

.type .Lxkb_parse_level_number, @function
.Lxkb_parse_level_number:
    cmp dword ptr [rip + .Lxkb_token_length], 1
    jne .Lxkb_level_number_long
    movzx eax, byte ptr [rip + .Lxkb_token]
    cmp al, '1'
    jb .Lxkb_level_number_bad
    cmp al, '8'
    ja .Lxkb_level_number_bad
    sub eax, '0'
    ret
.Lxkb_level_number_long:
    cmp dword ptr [rip + .Lxkb_token_length], 6
    jne .Lxkb_level_number_bad
    lea rdx, [rip + .Lxkb_token]
    cmp dword ptr [rdx], 0x6576654c
    jne .Lxkb_level_number_bad
    cmp byte ptr [rdx + 4], 'l'
    jne .Lxkb_level_number_bad
    movzx eax, byte ptr [rdx + 5]
    cmp al, '1'
    jb .Lxkb_level_number_bad
    cmp al, '8'
    ja .Lxkb_level_number_bad
    sub eax, '0'
    ret
.Lxkb_level_number_bad:
    mov eax, -1
    ret
.size .Lxkb_parse_level_number, . - .Lxkb_parse_level_number

# Parse one xkb_types type body into the bounded exact modifier-to-level table.
.type .Lxkb_parse_type_body, @function
.Lxkb_parse_type_body:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    lea rbx, [rip + xkb_type_map_counts]
    mov byte ptr [rbx + r12], 0
.Lxkb_type_body_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_type_body_fail
    cmp eax, '}'
    je .Lxkb_type_body_done
    lea rdi, [rip + .Lxkb_word_modifiers]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_type_body_modifiers
    lea rdi, [rip + .Lxkb_word_map]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_type_body_map
    lea rdi, [rip + .Lxkb_word_preserve]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_type_body_preserve
.Lxkb_type_body_skip_statement:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_type_body_fail
    cmp eax, ';'
    jne .Lxkb_type_body_skip_statement
    jmp .Lxkb_type_body_loop

.Lxkb_type_body_modifiers:
.Lxkb_type_body_modifiers_equals:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_type_body_fail
    cmp eax, '='
    jne .Lxkb_type_body_modifiers_equals
    mov edi, ';'
    call .Lxkb_parse_modmask
    test edx, edx
    jz .Lxkb_type_body_fail
    mov edx, r12d
    shl edx, 2
    lea rbx, [rip + xkb_type_modifiers]
    mov dword ptr [rbx + rdx], eax
    jmp .Lxkb_type_body_loop

.Lxkb_type_body_map:
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_type_body_fail
    mov edi, ']'
    call .Lxkb_parse_modmask
    test edx, edx
    jz .Lxkb_type_body_fail
    mov dword ptr [rip + .Lxkb_type_tmp_mask], eax
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_type_body_fail
    call .Lxkb_next_token
    call .Lxkb_parse_level_number
    test eax, eax
    jle .Lxkb_type_body_fail
    mov dword ptr [rip + .Lxkb_type_tmp_level], eax
    call .Lxkb_next_token
    cmp eax, ';'
    jne .Lxkb_type_body_fail
    lea rbx, [rip + xkb_type_map_counts]
    movzx r13d, byte ptr [rbx + r12]
    mov eax, r12d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_masks]
    add rbx, rax
    xor r14d, r14d
.Lxkb_type_body_map_find:
    cmp r14d, r13d
    jae .Lxkb_type_body_map_append
    mov edx, r14d
    shl edx, 2
    mov eax, dword ptr [rip + .Lxkb_type_tmp_mask]
    cmp dword ptr [rbx + rdx], eax
    je .Lxkb_type_body_map_store
    inc r14d
    jmp .Lxkb_type_body_map_find
.Lxkb_type_body_map_append:
    cmp r13d, 32
    jae .Lxkb_type_body_fail
    mov edx, r13d
    shl edx, 2
    mov eax, dword ptr [rip + .Lxkb_type_tmp_mask]
    mov dword ptr [rbx + rdx], eax
    mov eax, r12d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_preserves]
    add rbx, rax
    mov edx, r13d
    shl edx, 2
    mov dword ptr [rbx + rdx], 0
    mov r14d, r13d
    inc r13d
    lea rbx, [rip + xkb_type_map_counts]
    mov byte ptr [rbx + r12], r13b
.Lxkb_type_body_map_store:
    mov eax, r12d
    shl eax, 5
    lea rbx, [rip + xkb_type_map_levels]
    add rbx, rax
    mov eax, dword ptr [rip + .Lxkb_type_tmp_level]
    mov byte ptr [rbx + r14], al
    jmp .Lxkb_type_body_loop

.Lxkb_type_body_preserve:
    # preserve[<modifier combination>] = <modifier mask>; if no map[] entry
    # exists yet, create the specification's implicit Level1 entry. A later
    # map[] declaration updates that entry instead of appending a duplicate.
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_type_body_fail
    mov edi, ']'
    call .Lxkb_parse_modmask
    test edx, edx
    jz .Lxkb_type_body_fail
    mov dword ptr [rip + .Lxkb_type_tmp_mask], eax
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_type_body_fail
    mov edi, ';'
    call .Lxkb_parse_modmask
    test edx, edx
    jz .Lxkb_type_body_fail
    mov dword ptr [rip + .Lxkb_type_tmp_preserve], eax
    lea rbx, [rip + xkb_type_map_counts]
    movzx r13d, byte ptr [rbx + r12]
    mov eax, r12d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_masks]
    add rbx, rax
    xor r14d, r14d
.Lxkb_type_body_preserve_find:
    cmp r14d, r13d
    jae .Lxkb_type_body_preserve_append
    mov edx, r14d
    shl edx, 2
    mov eax, dword ptr [rip + .Lxkb_type_tmp_mask]
    cmp dword ptr [rbx + rdx], eax
    je .Lxkb_type_body_preserve_store
    inc r14d
    jmp .Lxkb_type_body_preserve_find
.Lxkb_type_body_preserve_append:
    cmp r13d, 32
    jae .Lxkb_type_body_fail
    mov edx, r13d
    shl edx, 2
    mov eax, dword ptr [rip + .Lxkb_type_tmp_mask]
    mov dword ptr [rbx + rdx], eax
    mov eax, r12d
    shl eax, 5
    lea rbx, [rip + xkb_type_map_levels]
    add rbx, rax
    mov byte ptr [rbx + r13], 1
    mov r14d, r13d
    inc r13d
    lea rbx, [rip + xkb_type_map_counts]
    mov byte ptr [rbx + r12], r13b
.Lxkb_type_body_preserve_store:
    mov eax, r12d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_preserves]
    add rbx, rax
    mov edx, r14d
    shl edx, 2
    mov eax, dword ptr [rip + .Lxkb_type_tmp_preserve]
    mov dword ptr [rbx + rdx], eax
    jmp .Lxkb_type_body_loop

.Lxkb_type_body_done:
    # XKB requires preserved modifiers to be part of the type's modifiers.
    mov eax, r12d
    shl eax, 2
    lea rbx, [rip + xkb_type_modifiers]
    mov r8d, dword ptr [rbx + rax]
    lea rbx, [rip + xkb_type_map_counts]
    movzx r13d, byte ptr [rbx + r12]
    mov eax, r12d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_preserves]
    add rbx, rax
    xor r14d, r14d
.Lxkb_type_body_validate_preserve:
    cmp r14d, r13d
    jae .Lxkb_type_body_done_valid
    mov edx, r14d
    shl edx, 2
    mov eax, dword ptr [rbx + rdx]
    mov ecx, r8d
    not ecx
    test eax, ecx
    jnz .Lxkb_type_body_fail
    inc r14d
    jmp .Lxkb_type_body_validate_preserve
.Lxkb_type_body_done_valid:
    xor eax, eax
    jmp .Lxkb_type_body_exit
.Lxkb_type_body_fail:
    mov eax, -1
.Lxkb_type_body_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_type_body, . - .Lxkb_parse_type_body

.type .Lxkb_parse_types, @function
.Lxkb_parse_types:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, qword ptr [rip + .Lxkb_text_ptr]
.Lxkb_types_find_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_missing
    lea rdi, [rip + .Lxkb_section_types]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_types_find_section
.Lxkb_types_find_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_fail
    cmp eax, '{'
    jne .Lxkb_types_find_open
.Lxkb_types_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_fail
    cmp eax, '}'
    je .Lxkb_types_done
    cmp eax, ';'
    je .Lxkb_types_loop
    cmp dword ptr [rip + .Lxkb_token_length], 4
    jne .Lxkb_types_skip_statement
    lea rdi, [rip + .Lxkb_token]
    cmp dword ptr [rdi], 0x65707974
    jne .Lxkb_types_skip_statement
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_fail
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_types_fail
    call .Lxkb_find_type
    cmp eax, -1
    jne .Lxkb_types_type_found
    mov r12d, dword ptr [rip + xkb_type_count]
    cmp r12d, 64
    jae .Lxkb_types_fail
    mov eax, r12d
    shl eax, 6
    lea rbx, [rip + xkb_type_names]
    add rbx, rax
    lea rsi, [rip + .Lxkb_token]
    mov ecx, 64
    mov rdi, rbx
    rep movsb
    inc r12d
    mov dword ptr [rip + xkb_type_count], r12d
    dec r12d
    jmp .Lxkb_types_have_type
.Lxkb_types_type_found:
    mov r12d, eax
    mov eax, r12d
    shl eax, 7
    lea rdi, [rip + xkb_type_map_masks]
    add rdi, rax
    xor eax, eax
    mov ecx, 128
    rep stosb
    mov eax, r12d
    shl eax, 5
    lea rdi, [rip + xkb_type_map_levels]
    add rdi, rax
    xor eax, eax
    mov ecx, 32
    rep stosb
    lea rbx, [rip + xkb_type_map_counts]
    mov byte ptr [rbx + r12], 0
    lea rbx, [rip + xkb_type_modifiers]
    mov dword ptr [rbx + r12*4], 0
.Lxkb_types_have_type:
.Lxkb_types_find_type_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_fail
    cmp eax, '{'
    jne .Lxkb_types_find_type_open
    mov edi, r12d
    call .Lxkb_parse_type_body
    test eax, eax
    js .Lxkb_types_fail
    jmp .Lxkb_types_loop
.Lxkb_types_skip_statement:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_types_fail
    cmp eax, ';'
    jne .Lxkb_types_skip_statement
    jmp .Lxkb_types_loop
.Lxkb_types_missing:
    # The section is optional; preserve the cursor so xkb_symbols can still
    # be found and conventional built-in type records remain available.
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    xor eax, eax
    jmp .Lxkb_types_exit
.Lxkb_types_done:
    xor eax, eax
    jmp .Lxkb_types_exit
.Lxkb_types_fail:
    mov eax, -1
.Lxkb_types_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_types, . - .Lxkb_parse_types

.type .Lxkb_classify_type, @function
.Lxkb_classify_type:
    push rbx
    xor ebx, ebx
    # ONE_LEVEL key types ignore Shift, Lock, and LevelThree. Keep this
    # distinction instead of treating every non-alphabetic type as TWO_LEVEL.
    lea rdi, [rip + .Lxkb_type_one_level]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_type_check_alpha
    mov ebx, 4
    jmp .Lxkb_type_done
.Lxkb_type_check_alpha:
    lea rdi, [rip + .Lxkb_type_alphabetic]
    call .Lxkb_token_contains
    test eax, eax
    jz .Lxkb_type_check_level3
    or ebx, 1
.Lxkb_type_check_level3:
    lea rdi, [rip + .Lxkb_type_four_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_eight_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_three_level]
    call .Lxkb_token_contains
    test eax, eax
    jnz .Lxkb_type_level3
    lea rdi, [rip + .Lxkb_type_separate]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_type_check_keypad
    or ebx, 16
    jmp .Lxkb_type_check_keypad
.Lxkb_type_level3:
    or ebx, 2
.Lxkb_type_check_keypad:
    lea rdi, [rip + .Lxkb_type_keypad]
    call .Lxkb_token_contains
    test eax, eax
    jz .Lxkb_type_done
    or ebx, 8
.Lxkb_type_done:
    mov eax, ebx
    pop rbx
    ret
.size .Lxkb_classify_type, . - .Lxkb_classify_type

# Convert current keysym token to printable ASCII in EAX, otherwise zero.
.type .Lxkb_keysym_ascii, @function
.Lxkb_keysym_ascii:
    push rbx
    push r12
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 1
    jne .Lxkb_keysym_named
    lea rbx, [rip + .Lxkb_token]
    movzx eax, byte ptr [rbx]
    cmp eax, 32
    jb .Lxkb_keysym_none
    cmp eax, 126
    ja .Lxkb_keysym_none
    jmp .Lxkb_keysym_done
.Lxkb_keysym_named:
    lea rbx, [rip + .Lxkb_ascii_symbols]
.Lxkb_ascii_table_loop:
    movzx ecx, byte ptr [rbx]
    test ecx, ecx
    jz .Lxkb_keysym_none
    mov r12d, ecx                # Preserve the table record length on every path.
    cmp ecx, dword ptr [rip + .Lxkb_token_length]
    jne .Lxkb_ascii_table_next
    lea rsi, [rbx + 1]
    lea rdi, [rip + .Lxkb_token]
    mov edx, ecx
    repe cmpsb
    je .Lxkb_ascii_table_found
.Lxkb_ascii_table_next:
    # REP CMPSB consumes RCX on a partial match; never use it to step records.
    lea rbx, [rbx + r12 + 2]
    jmp .Lxkb_ascii_table_loop
.Lxkb_ascii_table_found:
    movzx eax, byte ptr [rbx + r12 + 1]
    jmp .Lxkb_keysym_done
.Lxkb_keysym_none:
    xor eax, eax
.Lxkb_keysym_done:
    pop r12
    pop rbx
    ret
.size .Lxkb_keysym_ascii, . - .Lxkb_keysym_ascii

# Convert a printable ASCII or XKB Unicode keysym token to a Unicode scalar.
# XKB's Uxxxx/Uxxxxx/Uxxxxxx forms are accepted; invalid scalars return zero.
# Map the modifier keysyms used by XKB modifier_map into raw keysym IDs.
# This table is intentionally limited to common modifier/system keysyms;
# unsupported names return zero and are not guessed.
.type .Lxkb_keysym_modifier_id, @function
.Lxkb_keysym_modifier_id:
    lea rdi, [rip + .Lxkb_sym_shift_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_shift_l
    lea rdi, [rip + .Lxkb_sym_shift_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_shift_r
    lea rdi, [rip + .Lxkb_sym_control_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_control_l
    lea rdi, [rip + .Lxkb_sym_control_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_control_r
    lea rdi, [rip + .Lxkb_sym_caps_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_caps_lock
    lea rdi, [rip + .Lxkb_sym_meta_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_meta_l
    lea rdi, [rip + .Lxkb_sym_meta_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_meta_r
    lea rdi, [rip + .Lxkb_sym_alt_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_alt_l
    lea rdi, [rip + .Lxkb_sym_alt_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_alt_r
    lea rdi, [rip + .Lxkb_sym_super_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_super_l
    lea rdi, [rip + .Lxkb_sym_super_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_super_r
    lea rdi, [rip + .Lxkb_sym_hyper_l]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_hyper_l
    lea rdi, [rip + .Lxkb_sym_hyper_r]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_hyper_r
    lea rdi, [rip + .Lxkb_sym_num_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_num_lock
    lea rdi, [rip + .Lxkb_sym_scroll_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_scroll_lock
    lea rdi, [rip + .Lxkb_sym_mode_switch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_mode_switch
    lea rdi, [rip + .Lxkb_sym_iso3_shift]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso3_shift
    lea rdi, [rip + .Lxkb_sym_iso3_latch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso3_latch
    lea rdi, [rip + .Lxkb_sym_iso3_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso3_lock
    lea rdi, [rip + .Lxkb_sym_iso5_shift]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso5_shift
    lea rdi, [rip + .Lxkb_sym_iso5_latch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso5_latch
    lea rdi, [rip + .Lxkb_sym_iso5_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso5_lock

    lea rdi, [rip + .Lxkb_sym_shift_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_shift_lock
    lea rdi, [rip + .Lxkb_sym_iso_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_lock
    lea rdi, [rip + .Lxkb_sym_iso2_latch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso2_latch
    lea rdi, [rip + .Lxkb_sym_iso_group_shift]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_group_shift
    lea rdi, [rip + .Lxkb_sym_greek_switch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_group_shift
    lea rdi, [rip + .Lxkb_sym_script_switch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_group_shift
    lea rdi, [rip + .Lxkb_sym_iso_group_latch]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_group_latch
    lea rdi, [rip + .Lxkb_sym_iso_group_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_group_lock
    lea rdi, [rip + .Lxkb_sym_iso_next_group]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_next_group
    lea rdi, [rip + .Lxkb_sym_iso_next_group_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_next_group_lock
    lea rdi, [rip + .Lxkb_sym_iso_prev_group]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_prev_group
    lea rdi, [rip + .Lxkb_sym_iso_prev_group_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_prev_group_lock
    lea rdi, [rip + .Lxkb_sym_iso_first_group]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_first_group
    lea rdi, [rip + .Lxkb_sym_iso_first_group_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_first_group_lock
    lea rdi, [rip + .Lxkb_sym_iso_last_group]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_last_group
    lea rdi, [rip + .Lxkb_sym_iso_last_group_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_keysym_id_iso_last_group_lock
    xor eax, eax
    ret
.Lxkb_keysym_id_shift_l:      mov eax, 0xffe1; ret
.Lxkb_keysym_id_shift_r:      mov eax, 0xffe2; ret
.Lxkb_keysym_id_control_l:    mov eax, 0xffe3; ret
.Lxkb_keysym_id_control_r:    mov eax, 0xffe4; ret
.Lxkb_keysym_id_caps_lock:    mov eax, 0xffe5; ret
.Lxkb_keysym_id_meta_l:       mov eax, 0xffe7; ret
.Lxkb_keysym_id_meta_r:       mov eax, 0xffe8; ret
.Lxkb_keysym_id_alt_l:        mov eax, 0xffe9; ret
.Lxkb_keysym_id_alt_r:        mov eax, 0xffea; ret
.Lxkb_keysym_id_super_l:      mov eax, 0xffeb; ret
.Lxkb_keysym_id_super_r:      mov eax, 0xffec; ret
.Lxkb_keysym_id_hyper_l:      mov eax, 0xffed; ret
.Lxkb_keysym_id_hyper_r:      mov eax, 0xffee; ret
.Lxkb_keysym_id_num_lock:     mov eax, 0xff7f; ret
.Lxkb_keysym_id_scroll_lock:  mov eax, 0xff14; ret
.Lxkb_keysym_id_mode_switch:  mov eax, 0xff7e; ret
.Lxkb_keysym_id_iso3_shift:   mov eax, 0xfe03; ret
.Lxkb_keysym_id_iso3_latch:   mov eax, 0xfe04; ret
.Lxkb_keysym_id_iso3_lock:    mov eax, 0xfe05; ret
.Lxkb_keysym_id_iso5_shift:   mov eax, 0xfe11; ret
.Lxkb_keysym_id_iso5_latch:   mov eax, 0xfe12; ret
.Lxkb_keysym_id_iso5_lock:    mov eax, 0xfe13; ret
.Lxkb_keysym_id_shift_lock:   mov eax, 0xffe6; ret
.Lxkb_keysym_id_iso_lock:     mov eax, 0xfe01; ret
.Lxkb_keysym_id_iso2_latch:   mov eax, 0xfe02; ret
.Lxkb_keysym_id_iso_group_shift: mov eax, 0xff7e; ret
.Lxkb_keysym_id_iso_group_latch: mov eax, 0xfe06; ret
.Lxkb_keysym_id_iso_group_lock:  mov eax, 0xfe07; ret
.Lxkb_keysym_id_iso_next_group:  mov eax, 0xfe08; ret
.Lxkb_keysym_id_iso_next_group_lock: mov eax, 0xfe09; ret
.Lxkb_keysym_id_iso_prev_group:  mov eax, 0xfe0a; ret
.Lxkb_keysym_id_iso_prev_group_lock: mov eax, 0xfe0b; ret
.Lxkb_keysym_id_iso_first_group: mov eax, 0xfe0c; ret
.Lxkb_keysym_id_iso_first_group_lock: mov eax, 0xfe0d; ret
.Lxkb_keysym_id_iso_last_group:  mov eax, 0xfe0e; ret
.Lxkb_keysym_id_iso_last_group_lock: mov eax, 0xfe0f; ret
.size .Lxkb_keysym_modifier_id, . - .Lxkb_keysym_modifier_id

.type .Lxkb_keysym_unicode, @function
.Lxkb_keysym_unicode:
    push rbx
    push r12
    push r13
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 5
    jb .Lxkb_unicode_ascii
    cmp ecx, 7
    ja .Lxkb_unicode_ascii
    lea rbx, [rip + .Lxkb_token]
    cmp byte ptr [rbx], 'U'
    jne .Lxkb_unicode_ascii
    inc rbx
    lea r13d, [rcx - 1]
    xor r12d, r12d
.Lxkb_unicode_hex_loop:
    movzx eax, byte ptr [rbx]
    cmp al, '0'
    jb .Lxkb_unicode_hex_lower
    cmp al, '9'
    jbe .Lxkb_unicode_hex_digit
.Lxkb_unicode_hex_lower:
    cmp al, 'a'
    jb .Lxkb_unicode_hex_upper
    cmp al, 'f'
    jbe .Lxkb_unicode_hex_alpha
.Lxkb_unicode_hex_upper:
    cmp al, 'A'
    jb .Lxkb_unicode_invalid
    cmp al, 'F'
    ja .Lxkb_unicode_invalid
    sub eax, 'A' - 10
    jmp .Lxkb_unicode_hex_accumulate
.Lxkb_unicode_hex_alpha:
    sub eax, 'a' - 10
    jmp .Lxkb_unicode_hex_accumulate
.Lxkb_unicode_hex_digit:
    sub eax, '0'
.Lxkb_unicode_hex_accumulate:
    shl r12d, 4
    add r12d, eax
    inc rbx
    dec r13d
    jnz .Lxkb_unicode_hex_loop
    cmp r12d, 0x10ffff
    ja .Lxkb_unicode_invalid
    cmp r12d, 0x20
    jb .Lxkb_unicode_invalid
    cmp r12d, 0x7f
    jb .Lxkb_unicode_valid
    cmp r12d, 0x9f
    jbe .Lxkb_unicode_invalid
    cmp r12d, 0xd800
    jb .Lxkb_unicode_valid
    cmp r12d, 0xdfff
    jbe .Lxkb_unicode_invalid
.Lxkb_unicode_valid:
    mov eax, r12d
    jmp .Lxkb_unicode_done
.Lxkb_unicode_ascii:
    call .Lxkb_keysym_ascii
    test eax, eax
    jnz .Lxkb_unicode_done
    call .Lxkb_keysym_named_unicode
    jmp .Lxkb_unicode_done
.Lxkb_unicode_invalid:
    xor eax, eax
.Lxkb_unicode_done:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_keysym_unicode, . - .Lxkb_keysym_unicode

# RDI=keysym name bytes; ESI=length (1..63). EAX=Unicode scalar or zero.
# Reuse the XKB parser's bounded resolver without leaving its shared tokenizer
# scratch modified when the native Compose importer calls back into it.
.global xkb_keysym_name_to_unicode
.type xkb_keysym_name_to_unicode, @function
xkb_keysym_name_to_unicode:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 64
    test rdi, rdi
    jz .Lxkb_name_unicode_bad
    test esi, esi
    jz .Lxkb_name_unicode_bad
    cmp esi, 63
    ja .Lxkb_name_unicode_bad
    mov r12, rdi
    mov r13d, esi
    mov r15d, dword ptr [rip + .Lxkb_token_length]
    lea rdi, [rsp]
    lea rsi, [rip + .Lxkb_token]
    mov ecx, 64
    rep movsb
    # The 63-byte maximum keeps the NUL terminator inside .Lxkb_token.
    lea rdi, [rip + .Lxkb_token]
    mov rsi, r12
    mov ecx, r13d
    rep movsb
    mov byte ptr [rdi], 0
    mov dword ptr [rip + .Lxkb_token_length], r13d
    call .Lxkb_keysym_unicode
    mov r14d, eax
    lea rsi, [rsp]
    lea rdi, [rip + .Lxkb_token]
    mov ecx, 64
    rep movsb
    mov dword ptr [rip + .Lxkb_token_length], r15d
    mov eax, r14d
    jmp .Lxkb_name_unicode_done
.Lxkb_name_unicode_bad:
    xor eax, eax
.Lxkb_name_unicode_done:
    add rsp, 64
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_keysym_name_to_unicode, . - xkb_keysym_name_to_unicode

# Resolve a bounded set of common named X11/XKB Unicode keysyms.
# EAX is the mapped scalar, or zero when the token is not in this alias table.
.type .Lxkb_keysym_named_unicode, @function
.Lxkb_keysym_named_unicode:
    push rbx
    push r12
    push r13
    mov r13d, dword ptr [rip + .Lxkb_token_length]
    lea rbx, [rip + .Lxkb_unicode_symbols]
.Lxkb_named_unicode_loop:
    movzx eax, byte ptr [rbx]
    test eax, eax
    jz .Lxkb_named_unicode_none
    mov r12d, eax
    cmp r12d, r13d
    jne .Lxkb_named_unicode_next
    lea rsi, [rbx + 1]
    lea rdi, [rip + .Lxkb_token]
    mov ecx, r12d
    repe cmpsb
    je .Lxkb_named_unicode_found
.Lxkb_named_unicode_next:
    lea rbx, [rbx + r12 + 5]
    jmp .Lxkb_named_unicode_loop
.Lxkb_named_unicode_found:
    mov eax, dword ptr [rbx + r12 + 1]
    jmp .Lxkb_named_unicode_done
.Lxkb_named_unicode_none:
    xor eax, eax
.Lxkb_named_unicode_done:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_keysym_named_unicode, . - .Lxkb_keysym_named_unicode

# Parse the symbols array following symbols[GroupN] = [ ... ].
.type .Lxkb_parse_symbol_array, @function
.Lxkb_parse_symbol_array:
    push rbx
    push r12
    push r13
    push r14
    # Caller has just consumed "symbols".
    mov dword ptr [rip + .Lxkb_group], 0
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_symbol_array_expect_equals
    call .Lxkb_next_token
    call .Lxkb_parse_group
    test eax, eax
    js .Lxkb_symbol_array_group_default
    mov dword ptr [rip + .Lxkb_group], eax
.Lxkb_symbol_array_group_default:
    call .Lxkb_next_token
    cmp eax, ']'
    jne .Lxkb_symbol_array_fail
    call .Lxkb_next_token
.Lxkb_symbol_array_expect_equals:
    cmp eax, '='
    jne .Lxkb_symbol_array_fail
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_symbol_array_fail
    mov dword ptr [rip + .Lxkb_level], 0
.Lxkb_symbol_array_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbol_array_fail
    cmp eax, ']'
    je .Lxkb_symbol_array_success
    cmp eax, ','
    je .Lxkb_symbol_array_loop
    call .Lxkb_keysym_modifier_id
    mov dword ptr [rip + .Lxkb_keysym_tmp], eax
    call .Lxkb_keysym_unicode
    mov r12d, eax
    mov eax, dword ptr [rip + .Lxkb_level]
    cmp eax, 8
    jae .Lxkb_symbol_array_advance
    mov r13d, dword ptr [rip + .Lxkb_keycode]
    mov r14d, dword ptr [rip + .Lxkb_group]
    shl r13d, 5
    lea eax, [r13d + r14d*8]
    add eax, dword ptr [rip + .Lxkb_level]
    lea rbx, [rip + xkb_unicode_levels]
    mov dword ptr [rbx + rax*4], r12d
    lea rbx, [rip + xkb_keysym_levels]
    mov edx, dword ptr [rip + .Lxkb_keysym_tmp]
    mov dword ptr [rbx + rax*4], edx
    # Keep the byte table for ASCII lookup; Unicode scalars share the same
    # key/group/eight-level cell layout.
    lea rbx, [rip + xkb_ascii_levels]
    add rbx, r13
    lea rbx, [rbx + r14*8]
    mov eax, dword ptr [rip + .Lxkb_level]
    cmp r12d, 0x7e
    ja .Lxkb_symbol_array_ascii_done
    mov byte ptr [rbx + rax], r12b
.Lxkb_symbol_array_ascii_done:
    test r12d, r12d
    jz .Lxkb_symbol_array_advance
    inc dword ptr [rip + .Lxkb_symbol_count]
    lea rbx, [rip + xkb_group_symbol_counts]
    mov eax, dword ptr [rip + .Lxkb_keycode]
    shl eax, 2
    add eax, dword ptr [rip + .Lxkb_group]
    inc byte ptr [rbx + rax]
.Lxkb_symbol_array_advance:
    inc dword ptr [rip + .Lxkb_level]
    jmp .Lxkb_symbol_array_loop
.Lxkb_symbol_array_success:
    xor eax, eax
    jmp .Lxkb_symbol_array_done
.Lxkb_symbol_array_fail:
    mov eax, -1
.Lxkb_symbol_array_done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_symbol_array, . - .Lxkb_parse_symbol_array

# Parse the shorthand XKB form: key <NAME> { [ symbol, shifted_symbol ] }.
# The opening '[' has already been consumed. Reuse the same bounded symbol
# array parser with Group1 and level zero as the starting position.
.type .Lxkb_parse_inline_symbol_array, @function
.Lxkb_parse_inline_symbol_array:
    push rbx
    push r12
    push r13
    push r14
    mov dword ptr [rip + .Lxkb_group], 0
    mov dword ptr [rip + .Lxkb_level], 0
    jmp .Lxkb_symbol_array_loop
.size .Lxkb_parse_inline_symbol_array, . - .Lxkb_parse_inline_symbol_array

# Parse attributes inside one key <NAME> { ... } block.
.type .Lxkb_parse_key_block, @function
.Lxkb_parse_key_block:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov dword ptr [rip + .Lxkb_key_block_first], 1
.Lxkb_key_block_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_key_block_fail
    cmp eax, '}'
    je .Lxkb_key_block_done
    # xkbcomp emits common two-level keys in shorthand form:
    # key <AE01> { [ 1, exclam ] };. Only treat '[' as symbols when it is
    # the first token in the key block; later arrays may describe actions.
    cmp dword ptr [rip + .Lxkb_key_block_first], 1
    jne .Lxkb_key_block_not_first
    mov dword ptr [rip + .Lxkb_key_block_first], 0
    cmp eax, '['
    je .Lxkb_key_block_inline_symbols
.Lxkb_key_block_not_first:
    lea rdi, [rip + .Lxkb_word_type]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_type
    lea rdi, [rip + .Lxkb_word_symbols]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_symbols
    lea rdi, [rip + .Lxkb_word_key_virtual_modifiers]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_virtual_modifiers
    lea rdi, [rip + .Lxkb_word_repeat]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_repeat
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_virtual_modifiers:
    # Direct key-level virtualModifiers property. Names must already have been
    # declared in the keymap's virtual_modifiers statements.
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_key_block_fail
    # Explicit key-level virtualModifiers overrides xkb_compat interpretations.
    mov eax, dword ptr [rip + .Lxkb_keycode]
    lea rbx, [rip + xkb_key_virtual_explicit]
    mov byte ptr [rbx + rax], 1
.Lxkb_key_block_virtual_modifiers_next:
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_key_block_fail
    call .Lxkb_find_virtual
    test eax, eax
    js .Lxkb_key_block_fail
    mov ecx, eax
    mov eax, dword ptr [rip + .Lxkb_keycode]
    shl eax, 2
    lea rbx, [rip + xkb_key_virtual_maps]
    mov edx, 1
    shl edx, cl
    or dword ptr [rbx + rax], edx
.Lxkb_key_block_virtual_modifiers_delimiter:
    call .Lxkb_next_token
    cmp eax, '+'
    je .Lxkb_key_block_virtual_modifiers_next
    cmp eax, ','
    je .Lxkb_key_block_loop
    cmp eax, '}'
    je .Lxkb_key_block_done
    jmp .Lxkb_key_block_fail


.Lxkb_key_block_repeat:
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_key_block_fail
    call .Lxkb_next_token
    lea rdi, [rip + .Lxkb_word_true]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_key_block_repeat_true
    lea rdi, [rip + .Lxkb_word_false]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_key_block_fail
    xor r12d, r12d
    jmp .Lxkb_key_block_repeat_store
.Lxkb_key_block_repeat_true:
    mov r12d, 1
.Lxkb_key_block_repeat_store:
    mov eax, dword ptr [rip + .Lxkb_keycode]
    lea rbx, [rip + xkb_key_repeat_flags]
    mov byte ptr [rbx + rax], r12b
    lea rbx, [rip + xkb_key_repeat_explicit]
    mov byte ptr [rbx + rax], 1
    call .Lxkb_next_token
    cmp eax, ','
    je .Lxkb_key_block_loop
    cmp eax, '}'
    je .Lxkb_key_block_done
    jmp .Lxkb_key_block_fail

.Lxkb_key_block_type:
    mov dword ptr [rip + .Lxkb_type_group], -1
    call .Lxkb_next_token
    cmp eax, '['
    jne .Lxkb_key_block_type_expect_equals
    call .Lxkb_next_token
    call .Lxkb_parse_group
    test eax, eax
    js .Lxkb_key_block_fail
    mov dword ptr [rip + .Lxkb_type_group], eax
    call .Lxkb_next_token
    cmp eax, ']'
    jne .Lxkb_key_block_fail
    call .Lxkb_next_token
.Lxkb_key_block_type_expect_equals:
    cmp eax, '='
    jne .Lxkb_key_block_fail
    call .Lxkb_next_token
    call .Lxkb_classify_type
    mov dword ptr [rip + .Lxkb_type_flags], eax
    call .Lxkb_find_type
    cmp eax, -1
    jne .Lxkb_key_block_type_resolved
    # Older keymaps sometimes use a compound conventional name whose
    # canonical type body is not repeated in the serialized type section.
    mov eax, dword ptr [rip + .Lxkb_type_flags]
    test eax, 4
    jnz .Lxkb_key_block_type_one_level
    test eax, 8
    jnz .Lxkb_key_block_type_keypad
    test eax, 16
    jnz .Lxkb_key_block_type_separate
    test eax, 2
    jnz .Lxkb_key_block_type_four
    test eax, 1
    jnz .Lxkb_key_block_type_alpha
    # A genuinely unknown type must not be silently treated as TWO_LEVEL.
    # Reject this keymap so the caller can keep the known-good US fallback.
    jmp .Lxkb_key_block_fail
.Lxkb_key_block_type_one_level:
    mov eax, 2
    jmp .Lxkb_key_block_type_resolved
.Lxkb_key_block_type_keypad:
    mov eax, 4
    jmp .Lxkb_key_block_type_resolved
.Lxkb_key_block_type_separate:
    mov eax, 5
    jmp .Lxkb_key_block_type_resolved
.Lxkb_key_block_type_four:
    mov eax, 3
    jmp .Lxkb_key_block_type_resolved
.Lxkb_key_block_type_alpha:
    mov eax, 1
.Lxkb_key_block_type_resolved:
    mov dword ptr [rip + .Lxkb_type_id], eax
    mov eax, dword ptr [rip + .Lxkb_keycode]
    lea rbx, [rip + xkb_key_types]
    mov ecx, dword ptr [rip + .Lxkb_type_flags]
    mov byte ptr [rbx + rax], cl
    mov r13d, eax
    shl r13d, 2
    mov r12d, dword ptr [rip + .Lxkb_type_id]
    mov edx, dword ptr [rip + .Lxkb_type_group]
    cmp edx, -1
    jne .Lxkb_key_block_type_single_group
    xor edx, edx
.Lxkb_key_block_type_all_groups:
    lea rbx, [rip + xkb_group_types]
    mov eax, r13d
    add eax, edx
    mov byte ptr [rbx + rax], r12b
    inc edx
    cmp edx, 4
    jb .Lxkb_key_block_type_all_groups
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_type_single_group:
    lea rbx, [rip + xkb_group_types]
    mov eax, r13d
    add eax, edx
    mov byte ptr [rbx + rax], r12b
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_symbols:
    call .Lxkb_parse_symbol_array
    test eax, eax
    js .Lxkb_key_block_fail
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_inline_symbols:
    call .Lxkb_parse_inline_symbol_array
    test eax, eax
    js .Lxkb_key_block_fail
    jmp .Lxkb_key_block_loop
.Lxkb_key_block_done:
    # A key type belongs to a group. Explicit type[GroupN] assignments above
    # win; otherwise infer ONE_LEVEL, ALPHABETIC, or TWO_LEVEL independently
    # from each group's parsed symbols.
    mov r15d, dword ptr [rip + .Lxkb_keycode]
    xor r14d, r14d
.Lxkb_key_block_infer_group:
    cmp r14d, 4
    jae .Lxkb_key_block_infer_done
    lea rbx, [rip + xkb_group_types]
    mov eax, r15d
    shl eax, 2
    add eax, r14d
    cmp byte ptr [rbx + rax], 255
    jne .Lxkb_key_block_infer_next
    lea rbx, [rip + xkb_group_symbol_counts]
    movzx ecx, byte ptr [rbx + rax]
    mov r12d, 0
    cmp ecx, 1
    je .Lxkb_key_block_infer_one
    cmp ecx, 2
    jb .Lxkb_key_block_infer_store
    mov eax, r15d
    shl eax, 5
    lea eax, [rax + r14*8]
    lea rbx, [rip + xkb_unicode_levels]
    mov edx, dword ptr [rbx + rax*4]
    cmp edx, 'a'
    jb .Lxkb_key_block_infer_store
    cmp edx, 'z'
    ja .Lxkb_key_block_infer_store
    mov ecx, dword ptr [rbx + rax*4 + 4]
    cmp ecx, 'A'
    jb .Lxkb_key_block_infer_store
    cmp ecx, 'Z'
    ja .Lxkb_key_block_infer_store
    sub edx, 'a'
    sub ecx, 'A'
    cmp edx, ecx
    jne .Lxkb_key_block_infer_store
    mov r12d, 1
    jmp .Lxkb_key_block_infer_store
.Lxkb_key_block_infer_one:
    mov r12d, 2
.Lxkb_key_block_infer_store:
    lea rbx, [rip + xkb_group_types]
    mov eax, r15d
    shl eax, 2
    add eax, r14d
    mov byte ptr [rbx + rax], r12b
    cmp r14d, 0
    jne .Lxkb_key_block_infer_next
    cmp r12d, 1
    jne .Lxkb_key_block_infer_next
    lea rbx, [rip + xkb_key_types]
    mov byte ptr [rbx + r15], 1
.Lxkb_key_block_infer_next:
    inc r14d
    jmp .Lxkb_key_block_infer_group
.Lxkb_key_block_infer_done:
    # Count alphabetic keys from their actual Group1 symbols, not from the
    # conventional type name/ID. Real layouts commonly assign types such as
    # FOUR_LEVEL_ALPHABETIC or a user-defined type to letter keys.
    mov eax, r15d
    shl eax, 5
    lea rbx, [rip + xkb_ascii_levels]
    movzx edx, byte ptr [rbx + rax]
    cmp edx, 'a'
    jb .Lxkb_key_block_return
    cmp edx, 'z'
    ja .Lxkb_key_block_return
    movzx ecx, byte ptr [rbx + rax + 1]
    cmp ecx, 'A'
    jb .Lxkb_key_block_return
    cmp ecx, 'Z'
    ja .Lxkb_key_block_return
    sub edx, 'a'
    sub ecx, 'A'
    cmp edx, ecx
    jne .Lxkb_key_block_return
    inc dword ptr [rip + .Lxkb_alpha_key_count]
.Lxkb_key_block_return:
    xor eax, eax
    jmp .Lxkb_key_block_exit
.Lxkb_key_block_fail:
    mov eax, -1
.Lxkb_key_block_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_key_block, . - .Lxkb_parse_key_block

# Queue direct keycode and recognized indirect keysym real-modifier bindings:
# modifier_map Mod5 { <RALT>, <RCTL> }; modifier_map Mod1 { Alt_L };.
# EAX=0 on success, negative on malformed input.
# Resolve an indirect modifier_map keysym using XKB's specified ordering:
# lowest group first, then lowest level, then lowest keycode.
# EDI=raw keysym; EAX=matching keycode or zero.
.type .Lxkb_find_key_for_keysym, @function
.Lxkb_find_key_for_keysym:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r15d, edi
    xor r12d, r12d
.Lxkb_find_keysym_group:
    cmp r12d, 4
    jae .Lxkb_find_keysym_missing
    xor r13d, r13d
.Lxkb_find_keysym_level:
    cmp r13d, 8
    jae .Lxkb_find_keysym_next_group
    mov r14d, 8
.Lxkb_find_keysym_key:
    cmp r14d, 256
    jae .Lxkb_find_keysym_next_level
    mov eax, r14d
    shl eax, 5
    lea eax, [rax + r12*8]
    add eax, r13d
    lea rbx, [rip + xkb_keysym_levels]
    cmp dword ptr [rbx + rax*4], r15d
    je .Lxkb_find_keysym_found
    inc r14d
    jmp .Lxkb_find_keysym_key
.Lxkb_find_keysym_next_level:
    inc r13d
    jmp .Lxkb_find_keysym_level
.Lxkb_find_keysym_next_group:
    inc r12d
    jmp .Lxkb_find_keysym_group
.Lxkb_find_keysym_found:
    mov eax, r14d
    jmp .Lxkb_find_keysym_done
.Lxkb_find_keysym_missing:
    xor eax, eax
.Lxkb_find_keysym_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_find_key_for_keysym, . - .Lxkb_find_key_for_keysym

.type .Lxkb_parse_modifier_map, @function
.Lxkb_parse_modifier_map:
    push rbx
    push r12
    push r13
    push r14
    push r15
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_modifier_map_fail
    lea rdi, [rip + .Lxkb_mod_none]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_map_none
    lea rdi, [rip + .Lxkb_mod_none_lower]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_modifier_map_none
    call .Lxkb_modifier_bit
    test edx, edx
    jz .Lxkb_modifier_map_fail
    mov r12d, eax
    test r12d, 0xffffff00
    jnz .Lxkb_modifier_map_fail
    test r12d, r12d
    jz .Lxkb_modifier_map_fail
    lea eax, [r12 - 1]
    test eax, r12d
    jnz .Lxkb_modifier_map_fail
    jmp .Lxkb_modifier_map_find_open
.Lxkb_modifier_map_none:
    xor r12d, r12d
.Lxkb_modifier_map_find_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_modifier_map_fail
    cmp eax, '{'
    jne .Lxkb_modifier_map_find_open
.Lxkb_modifier_map_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_modifier_map_fail
    cmp eax, '}'
    je .Lxkb_modifier_map_done
    cmp eax, ','
    je .Lxkb_modifier_map_loop
    cmp dword ptr [rip + .Lxkb_token_kind], 2
    jne .Lxkb_modifier_map_keysym
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_find_keycode
    test eax, eax
    jz .Lxkb_modifier_map_loop
    mov r13d, eax
    mov r14d, 1
    jmp .Lxkb_modifier_map_queue
.Lxkb_modifier_map_keysym:
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_modifier_map_loop
    call .Lxkb_keysym_modifier_id
    test eax, eax
    jz .Lxkb_modifier_map_loop
    mov r13d, eax
    mov r14d, 2
.Lxkb_modifier_map_queue:
    mov r15d, dword ptr [rip + .Lxkb_pending_modmap_count]
    cmp r15d, 256
    jae .Lxkb_modifier_map_fail
    mov eax, r15d
    shl eax, 2
    lea rbx, [rip + xkb_pending_modmap_targets]
    mov dword ptr [rbx + rax], r13d
    lea rbx, [rip + xkb_pending_modmap_masks]
    mov dword ptr [rbx + rax], r12d
    lea rbx, [rip + xkb_pending_modmap_kinds]
    mov byte ptr [rbx + r15], r14b
    inc r15d
    mov dword ptr [rip + .Lxkb_pending_modmap_count], r15d
    jmp .Lxkb_modifier_map_loop
.Lxkb_modifier_map_done:
    xor eax, eax
    jmp .Lxkb_modifier_map_exit
.Lxkb_modifier_map_fail:
    mov eax, -1
.Lxkb_modifier_map_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_modifier_map, . - .Lxkb_parse_modifier_map


# Aggregate each key's real modifier map into the effective encodings of all
# virtual modifiers in that key's virtual map.
# Resolve direct keycode and indirect keysym modifier_map targets after
# every key's symbols have been parsed. None deletion is exact-target sensitive.
.type .Lxkb_resolve_modifier_maps, @function
.Lxkb_resolve_modifier_maps:
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rbp
    xor r12d, r12d
    mov r15d, dword ptr [rip + .Lxkb_pending_modmap_count]
.Lxkb_resolve_modmap_loop:
    cmp r12d, r15d
    jae .Lxkb_resolve_modmap_done
    mov eax, r12d
    shl eax, 2
    lea rbx, [rip + xkb_pending_modmap_targets]
    mov r13d, dword ptr [rbx + rax]
    lea rbx, [rip + xkb_pending_modmap_masks]
    mov r14d, dword ptr [rbx + rax]
    lea rbx, [rip + xkb_pending_modmap_kinds]
    movzx ebp, byte ptr [rbx + r12]
    cmp ebp, 1
    je .Lxkb_resolve_modmap_direct
    cmp ebp, 2
    jne .Lxkb_resolve_modmap_fail
    mov edi, r13d
    call .Lxkb_find_key_for_keysym
    test eax, eax
    jz .Lxkb_resolve_modmap_next
    mov r13d, eax
.Lxkb_resolve_modmap_direct:
    mov eax, r13d
    shl eax, 2
    lea rbx, [rip + xkb_key_real_masks]
    mov edx, dword ptr [rbx + rax]
    lea rbx, [rip + xkb_key_real_map_kinds]
    movzx ecx, byte ptr [rbx + r13]
    lea rbx, [rip + xkb_key_real_map_targets]
    mov esi, dword ptr [rbx + rax]
    test r14d, r14d
    jnz .Lxkb_resolve_modmap_set
    # None removes a prior entry only when the original target kind and
    # value exactly match; keycode and keysym targets never alias.
    cmp ebp, 1
    je .Lxkb_resolve_modmap_none_keycode
    cmp ebp, 2
    jne .Lxkb_resolve_modmap_next
    cmp ecx, 2
    jne .Lxkb_resolve_modmap_next
    mov eax, r12d
    shl eax, 2
    lea rbx, [rip + xkb_pending_modmap_targets]
    mov esi, dword ptr [rbx + rax]
    lea rbx, [rip + xkb_key_real_map_targets]
    cmp dword ptr [rbx + r13*4], esi
    jne .Lxkb_resolve_modmap_next
    jmp .Lxkb_resolve_modmap_delete
.Lxkb_resolve_modmap_none_keycode:
    cmp ecx, 1
    jne .Lxkb_resolve_modmap_next
    cmp esi, r13d
    jne .Lxkb_resolve_modmap_next
.Lxkb_resolve_modmap_delete:
    mov eax, r13d
    shl eax, 2
    lea rbx, [rip + xkb_key_real_masks]
    mov dword ptr [rbx + rax], 0
    lea rbx, [rip + xkb_key_real_map_kinds]
    mov byte ptr [rbx + r13], 0
    lea rbx, [rip + xkb_key_real_map_targets]
    mov dword ptr [rbx + rax], 0
    jmp .Lxkb_resolve_modmap_next
.Lxkb_resolve_modmap_set:
    test edx, edx
    jz .Lxkb_resolve_modmap_store
    cmp edx, r14d
    jne .Lxkb_resolve_modmap_fail
    # An identical mask from another alias does not replace the first exact
    # target; this preserves deterministic None matching.
    jmp .Lxkb_resolve_modmap_next
.Lxkb_resolve_modmap_store:
    mov eax, r13d
    shl eax, 2
    lea rbx, [rip + xkb_key_real_masks]
    mov dword ptr [rbx + rax], r14d
    lea rbx, [rip + xkb_key_real_map_kinds]
    mov byte ptr [rbx + r13], bpl
    lea rbx, [rip + xkb_key_real_map_targets]
    mov ecx, r12d
    shl ecx, 2
    lea rdx, [rip + xkb_pending_modmap_targets]
    mov ecx, dword ptr [rdx + rcx]
    mov dword ptr [rbx + rax], ecx
.Lxkb_resolve_modmap_next:
    inc r12d
    jmp .Lxkb_resolve_modmap_loop
.Lxkb_resolve_modmap_done:
    xor eax, eax
    jmp .Lxkb_resolve_modmap_exit
.Lxkb_resolve_modmap_fail:
    mov eax, -1
.Lxkb_resolve_modmap_exit:
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_resolve_modifier_maps, . - .Lxkb_resolve_modifier_maps


# Skip an unsupported statement while respecting nested action/indicator blocks.
# EAX=0 at ';', 1 when the containing section/rule '}' is consumed, -1 at EOF.
.type .Lxkb_compat_skip_statement, @function
.Lxkb_compat_skip_statement:
    push r12
    xor r12d, r12d
.Lxkb_compat_skip_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_compat_skip_fail
    cmp eax, '{'
    je .Lxkb_compat_skip_open
    cmp eax, '}'
    je .Lxkb_compat_skip_close
    cmp eax, ';'
    jne .Lxkb_compat_skip_loop
    test r12d, r12d
    jnz .Lxkb_compat_skip_loop
    xor eax, eax
    jmp .Lxkb_compat_skip_done
.Lxkb_compat_skip_open:
    inc r12d
    cmp r12d, 16
    ja .Lxkb_compat_skip_fail
    jmp .Lxkb_compat_skip_loop
.Lxkb_compat_skip_close:
    test r12d, r12d
    jz .Lxkb_compat_skip_section_close
    dec r12d
    jmp .Lxkb_compat_skip_loop
.Lxkb_compat_skip_section_close:
    mov eax, 1
    jmp .Lxkb_compat_skip_done
.Lxkb_compat_skip_fail:
    mov eax, -1
.Lxkb_compat_skip_done:
    pop r12
    ret
.size .Lxkb_compat_skip_statement, . - .Lxkb_compat_skip_statement

# Resolve a real-modifier token used by an xkb_compat predicate.
# EAX=mask, EDX=1 on success; virtual names and numeric masks are rejected.
.type .Lxkb_compat_real_modifier_bit, @function
.Lxkb_compat_real_modifier_bit:
    lea rdi, [rip + .Lxkb_mod_shift]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_shift
    lea rdi, [rip + .Lxkb_mod_lock]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_lock
    lea rdi, [rip + .Lxkb_mod_control]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_control
    lea rdi, [rip + .Lxkb_mod_mod1]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_mod1
    lea rdi, [rip + .Lxkb_mod_mod2]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_mod2
    lea rdi, [rip + .Lxkb_mod_mod3]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_mod3
    lea rdi, [rip + .Lxkb_mod_mod4]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_mod4
    lea rdi, [rip + .Lxkb_mod_mod5]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_mod5
    lea rdi, [rip + .Lxkb_mod_all]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_all
    lea rdi, [rip + .Lxkb_mod_none]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_none
    lea rdi, [rip + .Lxkb_mod_none_lower]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_real_none
    xor eax, eax
    xor edx, edx
    ret
.Lxkb_compat_real_shift:   mov eax, 1; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_lock:    mov eax, 2; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_control: mov eax, 4; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_mod1:    mov eax, 8; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_mod2:    mov eax, 16; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_mod3:    mov eax, 32; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_mod4:    mov eax, 64; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_mod5:    mov eax, 128; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_all:     mov eax, 255; jmp .Lxkb_compat_real_ok
.Lxkb_compat_real_none:    xor eax, eax
.Lxkb_compat_real_ok:
    mov edx, 1
    ret
.size .Lxkb_compat_real_modifier_bit, . - .Lxkb_compat_real_modifier_bit

# Parse the parenthesized real-modifier mask of AnyOf/NoneOf/AllOf/Exactly.
.type .Lxkb_compat_parse_real_mask, @function
.Lxkb_compat_parse_real_mask:
    push rbx
    push r12
    push r13
    xor r12d, r12d
    xor r13d, r13d
.Lxkb_compat_real_mask_loop:
    call .Lxkb_next_token
    cmp eax, ')'
    je .Lxkb_compat_real_mask_done
    cmp eax, '+'
    je .Lxkb_compat_real_mask_loop
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_compat_real_mask_fail
    call .Lxkb_compat_real_modifier_bit
    test edx, edx
    jz .Lxkb_compat_real_mask_fail
    or r12d, eax
    inc r13d
    jmp .Lxkb_compat_real_mask_loop
.Lxkb_compat_real_mask_done:
    test r13d, r13d
    jz .Lxkb_compat_real_mask_fail
    mov eax, r12d
    mov edx, 1
    jmp .Lxkb_compat_real_mask_exit
.Lxkb_compat_real_mask_fail:
    xor eax, eax
    xor edx, edx
.Lxkb_compat_real_mask_exit:
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_compat_parse_real_mask, . - .Lxkb_compat_parse_real_mask

# Parse one interpret body. Unknown attributes (notably general actions) are
# skipped as nested statements, but virtualModifier and useModMapMods are kept.
.type .Lxkb_compat_parse_body, @function
.Lxkb_compat_parse_body:
.Lxkb_compat_body_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_compat_body_fail
    cmp eax, '}'
    je .Lxkb_compat_body_done
    lea rdi, [rip + .Lxkb_word_virtual_modifier]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_body_virtual_modifier
    lea rdi, [rip + .Lxkb_word_use_mod_map_mods]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_body_use_modmap
    lea rdi, [rip + .Lxkb_word_repeat]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_body_repeat
    call .Lxkb_compat_skip_statement
    cmp eax, 1
    je .Lxkb_compat_body_done
    test eax, eax
    js .Lxkb_compat_body_fail
    jmp .Lxkb_compat_body_loop
.Lxkb_compat_body_virtual_modifier:
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_compat_body_fail
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_compat_body_fail
    call .Lxkb_find_virtual
    test eax, eax
    js .Lxkb_compat_body_fail
    cmp dword ptr [rip + .Lxkb_compat_tmp_vmod], -1
    jne .Lxkb_compat_body_fail
    mov dword ptr [rip + .Lxkb_compat_tmp_vmod], eax
    call .Lxkb_compat_skip_statement
    cmp eax, 1
    je .Lxkb_compat_body_done
    test eax, eax
    js .Lxkb_compat_body_fail
    jmp .Lxkb_compat_body_loop
.Lxkb_compat_body_use_modmap:
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_compat_body_fail
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_compat_body_fail
    lea rdi, [rip + .Lxkb_compat_level1]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_body_scope_level1
    lea rdi, [rip + .Lxkb_compat_any_level]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_compat_body_fail
    mov dword ptr [rip + .Lxkb_compat_tmp_scope], 0
    jmp .Lxkb_compat_body_scope_done
.Lxkb_compat_body_scope_level1:
    mov dword ptr [rip + .Lxkb_compat_tmp_scope], 1
.Lxkb_compat_body_scope_done:
    call .Lxkb_compat_skip_statement
    cmp eax, 1
    je .Lxkb_compat_body_done
    test eax, eax
    js .Lxkb_compat_body_fail
    jmp .Lxkb_compat_body_loop
.Lxkb_compat_body_repeat:
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_compat_body_fail
    call .Lxkb_next_token
    lea rdi, [rip + .Lxkb_word_true]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_body_repeat_true
    lea rdi, [rip + .Lxkb_word_false]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_compat_body_fail
    xor eax, eax
    jmp .Lxkb_compat_body_repeat_store
.Lxkb_compat_body_repeat_true:
    mov eax, 1
.Lxkb_compat_body_repeat_store:
    mov dword ptr [rip + .Lxkb_compat_tmp_repeat], eax
    call .Lxkb_compat_skip_statement
    cmp eax, 1
    je .Lxkb_compat_body_done
    test eax, eax
    js .Lxkb_compat_body_fail
    jmp .Lxkb_compat_body_loop
.Lxkb_compat_body_done:
    xor eax, eax
    ret
.Lxkb_compat_body_fail:
    mov eax, -1
    ret
.size .Lxkb_compat_parse_body, . - .Lxkb_compat_parse_body

# Parse one "interpret keysym + predicate { ... }" rule.
.type .Lxkb_compat_parse_interpret, @function
.Lxkb_compat_parse_interpret:
    mov dword ptr [rip + .Lxkb_compat_tmp_keysym], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_mask], 255
    mov dword ptr [rip + .Lxkb_compat_tmp_vmod], -1
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_scope], 0
    mov dword ptr [rip + .Lxkb_compat_tmp_valid], 1
    mov eax, dword ptr [rip + xkb_compat_default_repeat]
    mov dword ptr [rip + .Lxkb_compat_tmp_repeat], eax
    call .Lxkb_next_token
    cmp eax, '.'
    je .Lxkb_compat_interpret_global_property
    cmp eax, '{'
    je .Lxkb_compat_interpret_body
    cmp eax, '+'
    je .Lxkb_compat_interpret_predicate
    cmp dword ptr [rip + .Lxkb_token_kind], 1
    jne .Lxkb_compat_interpret_fail
    lea rdi, [rip + .Lxkb_compat_any]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_keysym_done
    lea rdi, [rip + .Lxkb_compat_no_symbol]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_keysym_done
    call .Lxkb_keysym_modifier_id
    test eax, eax
    jnz .Lxkb_compat_interpret_store_keysym
    # This parser intentionally stores only modifier keysyms; unsupported
    # keysym interpretations are skipped, never treated as wildcards.
    mov dword ptr [rip + .Lxkb_compat_tmp_valid], 0
    jmp .Lxkb_compat_interpret_keysym_done
.Lxkb_compat_interpret_store_keysym:
    mov dword ptr [rip + .Lxkb_compat_tmp_keysym], eax
.Lxkb_compat_interpret_keysym_done:
    call .Lxkb_next_token
    cmp eax, '{'
    je .Lxkb_compat_interpret_body
    cmp eax, '+'
    jne .Lxkb_compat_interpret_fail
.Lxkb_compat_interpret_predicate:
    call .Lxkb_next_token
    cmp eax, '('
    je .Lxkb_compat_interpret_predicate_implicit_exactly
    lea rdi, [rip + .Lxkb_compat_any]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_any
    lea rdi, [rip + .Lxkb_compat_anyofornone]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_anyofornone
    lea rdi, [rip + .Lxkb_compat_anyof]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_anyof
    lea rdi, [rip + .Lxkb_compat_noneof]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_noneof
    lea rdi, [rip + .Lxkb_compat_allof]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_allof
    lea rdi, [rip + .Lxkb_compat_exactly]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_predicate_exactly
    jmp .Lxkb_compat_interpret_fail
.Lxkb_compat_interpret_predicate_any:
    # Any is the AnyOf(all) alias.
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 1
    mov dword ptr [rip + .Lxkb_compat_tmp_mask], 255
    jmp .Lxkb_compat_interpret_predicate_expect_body
.Lxkb_compat_interpret_predicate_anyofornone:
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 0
    jmp .Lxkb_compat_interpret_predicate_parenthesis
.Lxkb_compat_interpret_predicate_anyof:
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 1
    jmp .Lxkb_compat_interpret_predicate_parenthesis
.Lxkb_compat_interpret_predicate_noneof:
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 2
    jmp .Lxkb_compat_interpret_predicate_parenthesis
.Lxkb_compat_interpret_predicate_allof:
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 3
    jmp .Lxkb_compat_interpret_predicate_parenthesis
.Lxkb_compat_interpret_predicate_exactly:
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 4
    jmp .Lxkb_compat_interpret_predicate_parenthesis
.Lxkb_compat_interpret_predicate_implicit_exactly:
    # XKB shorthand: omitting the operator before (mask) means Exactly(mask).
    mov dword ptr [rip + .Lxkb_compat_tmp_predicate], 4
    jmp .Lxkb_compat_interpret_predicate_parse_mask
.Lxkb_compat_interpret_predicate_parenthesis:
    call .Lxkb_next_token
    cmp eax, '('
    jne .Lxkb_compat_interpret_fail
.Lxkb_compat_interpret_predicate_parse_mask:
    call .Lxkb_compat_parse_real_mask
    test edx, edx
    jz .Lxkb_compat_interpret_fail
    mov dword ptr [rip + .Lxkb_compat_tmp_mask], eax
.Lxkb_compat_interpret_predicate_expect_body:
    call .Lxkb_next_token
    cmp eax, '{'
    jne .Lxkb_compat_interpret_fail
.Lxkb_compat_interpret_body:
    call .Lxkb_compat_parse_body
    test eax, eax
    js .Lxkb_compat_interpret_fail
    cmp dword ptr [rip + .Lxkb_compat_tmp_valid], 0
    je .Lxkb_compat_interpret_success
    mov ecx, dword ptr [rip + xkb_compat_rule_count]
    cmp ecx, 128
    jae .Lxkb_compat_interpret_fail
    mov eax, ecx
    shl eax, 4
    lea rbx, [rip + xkb_compat_rules]
    add rbx, rax
    mov eax, dword ptr [rip + .Lxkb_compat_tmp_keysym]
    mov dword ptr [rbx], eax
    mov eax, dword ptr [rip + .Lxkb_compat_tmp_mask]
    mov dword ptr [rbx + 4], eax
    mov eax, dword ptr [rip + .Lxkb_compat_tmp_vmod]
    mov dword ptr [rbx + 8], eax
    mov al, byte ptr [rip + .Lxkb_compat_tmp_predicate]
    mov byte ptr [rbx + 12], al
    mov al, byte ptr [rip + .Lxkb_compat_tmp_scope]
    mov byte ptr [rbx + 13], al
    mov al, byte ptr [rip + .Lxkb_compat_tmp_repeat]
    mov byte ptr [rbx + 14], al
    inc ecx
    mov dword ptr [rip + xkb_compat_rule_count], ecx
.Lxkb_compat_interpret_success:
    xor eax, eax
    ret
.Lxkb_compat_interpret_global_property:
    # Section-level interpret.repeat supplies the default inherited by rules.
    call .Lxkb_next_token
    lea rdi, [rip + .Lxkb_word_repeat]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_compat_interpret_fail
    call .Lxkb_next_token
    cmp eax, '='
    jne .Lxkb_compat_interpret_fail
    call .Lxkb_next_token
    lea rdi, [rip + .Lxkb_word_true]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_interpret_global_true
    lea rdi, [rip + .Lxkb_word_false]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_compat_interpret_fail
    xor eax, eax
    jmp .Lxkb_compat_interpret_global_store
.Lxkb_compat_interpret_global_true:
    mov eax, 1
.Lxkb_compat_interpret_global_store:
    mov dword ptr [rip + xkb_compat_default_repeat], eax
    call .Lxkb_compat_skip_statement
    ret
.Lxkb_compat_interpret_fail:
    mov eax, -1
    ret
.size .Lxkb_compat_parse_interpret, . - .Lxkb_compat_parse_interpret

# Parse the optional xkb_compat component after key symbols are available.
.type .Lxkb_parse_compat, @function
.Lxkb_parse_compat:
    push rbx
.Lxkb_compat_find_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_compat_parse_done
    lea rdi, [rip + .Lxkb_section_compat]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_compat_find_open
    jmp .Lxkb_compat_find_section
.Lxkb_compat_find_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_compat_parse_fail
    cmp eax, '{'
    jne .Lxkb_compat_find_open
.Lxkb_compat_parse_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_compat_parse_fail
    cmp eax, '}'
    je .Lxkb_compat_parse_done
    cmp eax, ';'
    je .Lxkb_compat_parse_loop
    lea rdi, [rip + .Lxkb_word_interpret]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_parse_compat_interpret_rule
    call .Lxkb_compat_skip_statement
    cmp eax, 1
    je .Lxkb_compat_parse_done
    test eax, eax
    js .Lxkb_compat_parse_fail
    jmp .Lxkb_compat_parse_loop
.Lxkb_parse_compat_interpret_rule:
    call .Lxkb_compat_parse_interpret
    cmp eax, 1
    je .Lxkb_compat_parse_done
    test eax, eax
    js .Lxkb_compat_parse_fail
    jmp .Lxkb_compat_parse_loop
.Lxkb_compat_parse_done:
    xor eax, eax
    jmp .Lxkb_compat_parse_exit
.Lxkb_compat_parse_fail:
    mov eax, -1
.Lxkb_compat_parse_exit:
    pop rbx
    ret
.size .Lxkb_parse_compat, . - .Lxkb_parse_compat

# Apply the best matching interpretation to each represented keysym level.
# Specific keysyms outrank wildcard rules; predicate rank breaks those ties.
# Equal-specificity ties retain the first declaration. Explicit key vmods win.
.type .Lxkb_apply_compat_virtual_maps, @function
.Lxkb_apply_compat_virtual_maps:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov r12d, 8
.Lxkb_compat_apply_key_loop:
    cmp r12d, 256
    jae .Lxkb_compat_apply_done
    xor r13d, r13d
.Lxkb_compat_apply_group_loop:
    cmp r13d, 4
    jae .Lxkb_compat_apply_next_key
    xor r14d, r14d
.Lxkb_compat_apply_level_loop:
    cmp r14d, 8
    jae .Lxkb_compat_apply_next_group
    mov eax, r12d
    shl eax, 5
    lea eax, [rax + r13*8]
    add eax, r14d
    lea rsi, [rip + xkb_keysym_levels]
    mov r8d, dword ptr [rsi + rax*4]
    lea rsi, [rip + xkb_unicode_levels]
    mov edx, dword ptr [rsi + rax*4]
    or edx, r8d
    jz .Lxkb_compat_apply_next_level
    # DEFAULT_INTERPRET_KEY_REPEAT applies only when Group1/Level1 contains
    # a symbol. A key without that base symbol retains DEFAULT_KEY_REPEAT=0.
    # Explicit per-key repeat declarations override both defaults and rules.
    test r13d, r13d
    jnz .Lxkb_compat_apply_repeat_default_done
    test r14d, r14d
    jnz .Lxkb_compat_apply_repeat_default_done
    lea rsi, [rip + xkb_key_repeat_explicit]
    cmp byte ptr [rsi + r12], 0
    jne .Lxkb_compat_apply_repeat_default_done
    lea rsi, [rip + xkb_key_repeat_flags]
    mov byte ptr [rsi + r12], 1
.Lxkb_compat_apply_repeat_default_done:
    mov eax, r12d
    shl eax, 2
    lea rsi, [rip + xkb_key_real_masks]
    mov r9d, dword ptr [rsi + rax]
    mov ebp, -1
    mov ebx, -1
    mov r10d, -1
    xor r15d, r15d
.Lxkb_compat_apply_rule_loop:
    cmp r15d, dword ptr [rip + xkb_compat_rule_count]
    jae .Lxkb_compat_apply_rule_done
    mov eax, r15d
    shl eax, 4
    lea rsi, [rip + xkb_compat_rules]
    add rsi, rax
    mov eax, dword ptr [rsi]
    test eax, eax
    jz .Lxkb_compat_apply_scope
    cmp eax, r8d
    jne .Lxkb_compat_apply_next_rule
.Lxkb_compat_apply_scope:
    cmp byte ptr [rsi + 13], 1
    jne .Lxkb_compat_apply_predicate
    test r13d, r13d
    jnz .Lxkb_compat_apply_next_rule
    test r14d, r14d
    jnz .Lxkb_compat_apply_next_rule
.Lxkb_compat_apply_predicate:
    movzx ecx, byte ptr [rsi + 12]
    mov edx, dword ptr [rsi + 4]
    cmp ecx, 0
    je .Lxkb_compat_apply_anyofornone
    cmp ecx, 1
    je .Lxkb_compat_apply_anyof
    cmp ecx, 2
    je .Lxkb_compat_apply_noneof
    cmp ecx, 3
    je .Lxkb_compat_apply_allof
    cmp ecx, 4
    je .Lxkb_compat_apply_exactly
    jmp .Lxkb_compat_apply_next_rule
.Lxkb_compat_apply_anyofornone:
    test r9d, r9d
    jz .Lxkb_compat_apply_match
    mov eax, r9d
    and eax, edx
    test eax, eax
    jnz .Lxkb_compat_apply_match
    jmp .Lxkb_compat_apply_next_rule
.Lxkb_compat_apply_anyof:
    mov eax, r9d
    and eax, edx
    test eax, eax
    jz .Lxkb_compat_apply_next_rule
    jmp .Lxkb_compat_apply_match
.Lxkb_compat_apply_noneof:
    mov eax, r9d
    and eax, edx
    test eax, eax
    jnz .Lxkb_compat_apply_next_rule
    jmp .Lxkb_compat_apply_match
.Lxkb_compat_apply_allof:
    mov eax, r9d
    and eax, edx
    cmp eax, edx
    jne .Lxkb_compat_apply_next_rule
    jmp .Lxkb_compat_apply_match
.Lxkb_compat_apply_exactly:
    cmp r9d, edx
    jne .Lxkb_compat_apply_next_rule
.Lxkb_compat_apply_match:
    xor ecx, ecx
    cmp dword ptr [rsi], 0
    je .Lxkb_compat_apply_score
    mov ecx, 16
.Lxkb_compat_apply_score:
    movzx eax, byte ptr [rsi + 12]
    add ecx, eax
    cmp ecx, ebp
    jle .Lxkb_compat_apply_next_rule
    mov ebp, ecx
    mov ebx, dword ptr [rsi + 8]
    movzx r10d, byte ptr [rsi + 14]
.Lxkb_compat_apply_next_rule:
    inc r15d
    jmp .Lxkb_compat_apply_rule_loop
.Lxkb_compat_apply_rule_done:
    # Direct key virtualModifiers overrides only compatibility vmod output.
    # It must not suppress a separate compatibility repeat interpretation.
    cmp ebx, -1
    je .Lxkb_compat_apply_repeat
    cmp ebx, 24
    jae .Lxkb_compat_apply_repeat
    mov eax, r12d
    lea rsi, [rip + xkb_key_virtual_explicit]
    cmp byte ptr [rsi + rax], 0
    jne .Lxkb_compat_apply_repeat
    mov ecx, ebx
    mov edx, 1
    shl edx, cl
    mov eax, r12d
    shl eax, 2
    lea rsi, [rip + xkb_key_virtual_maps]
    or dword ptr [rsi + rax], edx
.Lxkb_compat_apply_repeat:
    # Compatibility repeat is key-wide but determined from Group1/Level1.
    test r13d, r13d
    jnz .Lxkb_compat_apply_next_level
    test r14d, r14d
    jnz .Lxkb_compat_apply_next_level
    cmp r10d, -1
    je .Lxkb_compat_apply_next_level
    mov eax, r12d
    lea rsi, [rip + xkb_key_repeat_explicit]
    cmp byte ptr [rsi + rax], 0
    jne .Lxkb_compat_apply_next_level
    lea rsi, [rip + xkb_key_repeat_flags]
    mov byte ptr [rsi + rax], r10b
.Lxkb_compat_apply_next_level:
    inc r14d
    jmp .Lxkb_compat_apply_level_loop
.Lxkb_compat_apply_next_group:
    inc r13d
    jmp .Lxkb_compat_apply_group_loop
.Lxkb_compat_apply_next_key:
    inc r12d
    jmp .Lxkb_compat_apply_key_loop
.Lxkb_compat_apply_done:
    xor eax, eax
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret
.size .Lxkb_apply_compat_virtual_maps, . - .Lxkb_apply_compat_virtual_maps

.type .Lxkb_apply_virtual_modifier_maps, @function
.Lxkb_apply_virtual_modifier_maps:
    push rbx
    push r12
    push r13
    push r14
    push r15
    call .Lxkb_resolve_modifier_maps
    test eax, eax
    js .Lxkb_apply_vmod_fail
    call .Lxkb_apply_compat_virtual_maps
    test eax, eax
    js .Lxkb_apply_vmod_fail
    mov r12d, 8
.Lxkb_apply_vmod_key_loop:
    cmp r12d, 256
    jae .Lxkb_apply_vmod_special_masks
    mov eax, r12d
    shl eax, 2
    lea rbx, [rip + xkb_key_real_masks]
    mov r13d, dword ptr [rbx + rax]
    test r13d, r13d
    jz .Lxkb_apply_vmod_next_key
    lea rbx, [rip + xkb_key_virtual_maps]
    mov r14d, dword ptr [rbx + rax]
    xor r15d, r15d
.Lxkb_apply_vmod_bit_loop:
    cmp r15d, dword ptr [rip + xkb_virtual_count]
    jae .Lxkb_apply_vmod_next_key
    bt r14d, r15d
    jnc .Lxkb_apply_vmod_next_bit
    mov eax, r15d
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    or dword ptr [rbx + rax], r13d
.Lxkb_apply_vmod_next_bit:
    inc r15d
    jmp .Lxkb_apply_vmod_bit_loop
.Lxkb_apply_vmod_next_key:
    inc r12d
    jmp .Lxkb_apply_vmod_key_loop
.Lxkb_apply_vmod_special_masks:
    mov eax, dword ptr [rip + .Lxkb_level_three_index]
    cmp eax, -1
    je .Lxkb_apply_vmod_numlock
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov edx, dword ptr [rbx + rax]
    mov dword ptr [rip + xkb_level_three_mask], edx
.Lxkb_apply_vmod_numlock:
    mov eax, dword ptr [rip + .Lxkb_num_lock_index]
    cmp eax, -1
    je .Lxkb_apply_vmod_done
    shl eax, 2
    lea rbx, [rip + xkb_virtual_masks]
    mov edx, dword ptr [rbx + rax]
    mov dword ptr [rip + xkb_num_lock_mask], edx
.Lxkb_apply_vmod_done:
    xor eax, eax
    jmp .Lxkb_apply_vmod_exit
.Lxkb_apply_vmod_fail:
    mov eax, -1
.Lxkb_apply_vmod_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_apply_virtual_modifier_maps, . - .Lxkb_apply_virtual_modifier_maps

# Parse xkb_symbols key definitions.
.type .Lxkb_parse_symbols, @function
.Lxkb_parse_symbols:
    push rbx
    push r12
    push r13
    push r14
    push r15
.Lxkb_find_symbols_section:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    lea rdi, [rip + .Lxkb_section_symbols]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_find_symbols_section
.Lxkb_find_symbols_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_find_symbols_open
.Lxkb_symbols_loop:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '}'
    je .Lxkb_symbols_done
    lea rdi, [rip + .Lxkb_word_modifier_map]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_symbols_modifier_map
    lea rdi, [rip + .Lxkb_word_mod_map]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_symbols_modifier_map
    lea rdi, [rip + .Lxkb_word_modmap]
    call .Lxkb_token_is
    test eax, eax
    jnz .Lxkb_symbols_modifier_map
    lea rdi, [rip + .Lxkb_word_key]
    call .Lxkb_token_is
    test eax, eax
    jz .Lxkb_symbols_loop
    call .Lxkb_next_token
    cmp dword ptr [rip + .Lxkb_token_kind], 2
    jne .Lxkb_symbols_loop
    mov eax, dword ptr [rip + .Lxkb_token]
    mov dword ptr [rip + .Lxkb_keyname_tmp], eax
    call .Lxkb_find_keycode
    test eax, eax
    jz .Lxkb_symbols_skip_key
    mov dword ptr [rip + .Lxkb_keycode], eax
.Lxkb_symbols_find_key_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_symbols_find_key_open
    call .Lxkb_parse_key_block
    test eax, eax
    js .Lxkb_symbols_fail
    jmp .Lxkb_symbols_loop
.Lxkb_symbols_modifier_map:
    call .Lxkb_parse_modifier_map
    test eax, eax
    js .Lxkb_symbols_fail
    jmp .Lxkb_symbols_loop
.Lxkb_symbols_skip_key:
    # Unknown key name: consume through the next closing brace without
    # modifying any valid entry.
.Lxkb_symbols_skip_key_open:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '{'
    jne .Lxkb_symbols_skip_key_open
.Lxkb_symbols_skip_key_body:
    call .Lxkb_next_token
    test eax, eax
    jz .Lxkb_symbols_fail
    cmp eax, '}'
    jne .Lxkb_symbols_skip_key_body
    jmp .Lxkb_symbols_loop
.Lxkb_symbols_done:
    # Do not activate a partially understood map (for example one isolated
    # punctuation key). Require a reasonable ASCII symbol population; normal
    # desktop layouts contain many more entries than this minimum.
    cmp dword ptr [rip + .Lxkb_symbol_count], 16
    jb .Lxkb_symbols_fail
    cmp dword ptr [rip + .Lxkb_alpha_key_count], 12
    jb .Lxkb_symbols_fail
    mov dword ptr [rip + xkb_keymap_ready], 1
    xor eax, eax
    jmp .Lxkb_symbols_exit
.Lxkb_symbols_fail:
    mov eax, -1
.Lxkb_symbols_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_parse_symbols, . - .Lxkb_parse_symbols

# RDI=text, ESI=size. Returns zero when at least one keycode/symbol pair is
# usable, otherwise negative. Invalid/unsupported maps leave the fallback live.
.global xkb_parse_keymap
.type xkb_parse_keymap, @function
xkb_parse_keymap:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13d, esi
    call xkb_reset_keymap
    mov dword ptr [rip + xkb_parse_error_stage], 0
    mov dword ptr [rip + xkb_parse_error_offset], 0
    mov dword ptr [rip + xkb_parse_error_token_length], 0
    mov dword ptr [rip + xkb_parse_error_symbol_count], 0
    mov dword ptr [rip + xkb_parse_error_alpha_count], 0
    lea rdi, [rip + xkb_parse_error_token]
    xor eax, eax
    mov ecx, 64
    rep stosb
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    lea rax, [r12 + r13]
    mov qword ptr [rip + .Lxkb_text_end], rax
    mov dword ptr [rip + .Lxkb_parse_stage], 1
    call .Lxkb_parse_virtual_modifiers
    test eax, eax
    js .Lxkb_parse_keymap_fail
    call .Lxkb_rebase_builtin_types
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    mov dword ptr [rip + .Lxkb_parse_stage], 2
    call .Lxkb_parse_keycodes
    test eax, eax
    js .Lxkb_parse_keymap_fail
    # xkb_types is optional; when present, actual modifiers/map entries
    # replace conventional defaults before key groups resolve their types.
    mov dword ptr [rip + .Lxkb_parse_stage], 3
    call .Lxkb_parse_types
    test eax, eax
    js .Lxkb_parse_keymap_fail
    mov dword ptr [rip + .Lxkb_parse_stage], 4
    call .Lxkb_parse_symbols
    test eax, eax
    js .Lxkb_parse_keymap_fail
    # Compatibility rules are evaluated after all key/group/level keysyms and
    # real modifier maps are available.
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    mov dword ptr [rip + .Lxkb_parse_stage], 5
    call .Lxkb_parse_compat
    test eax, eax
    js .Lxkb_parse_keymap_fail
    # Resolve explicit plus key-bound/compatibility virtual-modifier maps.
    mov dword ptr [rip + .Lxkb_parse_stage], 6
    call .Lxkb_apply_virtual_modifier_maps
    test eax, eax
    js .Lxkb_parse_keymap_fail
    call .Lxkb_rebase_builtin_types
    # Reparse declared types now that implicit virtual-modifier encodings are
    # known, so their effective masks include both explicit and implicit maps.
    mov qword ptr [rip + .Lxkb_text_ptr], r12
    mov dword ptr [rip + .Lxkb_parse_stage], 7
    call .Lxkb_parse_types
    test eax, eax
    js .Lxkb_parse_keymap_fail
    mov dword ptr [rip + xkb_parse_error_stage], 0
    xor eax, eax
    jmp .Lxkb_parse_keymap_done
.Lxkb_parse_keymap_fail:
    mov eax, dword ptr [rip + .Lxkb_symbol_count]
    mov dword ptr [rip + xkb_parse_error_symbol_count], eax
    mov eax, dword ptr [rip + .Lxkb_alpha_key_count]
    mov dword ptr [rip + xkb_parse_error_alpha_count], eax
    mov eax, dword ptr [rip + .Lxkb_parse_stage]
    mov dword ptr [rip + xkb_parse_error_stage], eax
    mov rax, qword ptr [rip + .Lxkb_text_ptr]
    sub rax, r12
    mov dword ptr [rip + xkb_parse_error_offset], eax
    mov ecx, dword ptr [rip + .Lxkb_token_length]
    cmp ecx, 63
    jbe .Lxkb_parse_error_token_length_ok
    mov ecx, 63
.Lxkb_parse_error_token_length_ok:
    mov dword ptr [rip + xkb_parse_error_token_length], ecx
    lea rsi, [rip + .Lxkb_token]
    lea rdi, [rip + xkb_parse_error_token]
    rep movsb
    mov byte ptr [rdi], 0
    call xkb_reset_keymap
    mov rax, -1
.Lxkb_parse_keymap_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_parse_keymap, . - xkb_parse_keymap

# RDI=internal XKB keycode, ESI=32-bit XKB modifier-index mask, EDX=group.
# Return zero-based level by exact lookup in the key group's declared type.
.type .Lxkb_select_level, @function
.Lxkb_select_level:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    cmp r14d, 3
    jbe .Lxkb_select_group_ok
    xor r14d, r14d
.Lxkb_select_group_ok:
    mov eax, r12d
    shl eax, 2
    add eax, r14d
    lea rbx, [rip + xkb_group_types]
    movzx r15d, byte ptr [rbx + rax]
    cmp r15d, 64
    jb .Lxkb_select_type_ok
    xor r15d, r15d
.Lxkb_select_type_ok:
    lea rbx, [rip + xkb_type_modifiers]
    mov eax, r15d
    shl eax, 2
    mov r9d, dword ptr [rbx + rax]
    mov eax, r9d
    and eax, r13d
    mov r13d, eax
    xor r8d, r8d
    lea rbx, [rip + xkb_type_map_counts]
    movzx r14d, byte ptr [rbx + r15]
    test r14d, r14d
    jz .Lxkb_select_default
    mov eax, r15d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_masks]
    add rbx, rax
    xor r12d, r12d
.Lxkb_select_map_loop:
    cmp r12d, r14d
    jae .Lxkb_select_default
    mov eax, r12d
    shl eax, 2
    cmp dword ptr [rbx + rax], r13d
    je .Lxkb_select_map_found
    inc r12d
    jmp .Lxkb_select_map_loop
.Lxkb_select_map_found:
    mov eax, r15d
    shl eax, 7
    lea rbx, [rip + xkb_type_map_preserves]
    add rbx, rax
    mov edx, r12d
    shl edx, 2
    mov r8d, dword ptr [rbx + rdx]
    mov eax, r15d
    shl eax, 5
    lea rbx, [rip + xkb_type_map_levels]
    add rbx, rax
    movzx eax, byte ptr [rbx + r12]
    test eax, eax
    jz .Lxkb_select_default
    dec eax
    cmp eax, 7
    jbe .Lxkb_select_done
.Lxkb_select_default:
    xor r8d, r8d
    xor eax, eax
.Lxkb_select_done:
    mov edx, r8d
    mov ecx, r9d
    not edx
    and ecx, edx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size .Lxkb_select_level, . - .Lxkb_select_level

# RDI=evdev keycode, ESI=32-bit XKB modifier state, EDX=group.
# Return the consumed-modifier mask for the selected type-map entry.
.global xkb_lookup_consumed_modifiers
.type xkb_lookup_consumed_modifiers, @function
xkb_lookup_consumed_modifiers:
    # Keep SysV call-site alignment before the nested level lookup.
    push rbx
    push r12
    push r13
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_consumed_none
    cmp edi, 247
    ja .Lxkb_consumed_none
    lea r12d, [rdi + 8]
    lea rbx, [rip + xkb_key_names]
    cmp dword ptr [rbx + r12*4], 0
    je .Lxkb_consumed_none
    mov edi, r12d
    cmp edx, 3
    jbe .Lxkb_consumed_group_ok
    xor edx, edx
.Lxkb_consumed_group_ok:
    call .Lxkb_select_level
    mov eax, ecx
    jmp .Lxkb_consumed_exit
.Lxkb_consumed_none:
    xor eax, eax
.Lxkb_consumed_exit:
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_lookup_consumed_modifiers, . - xkb_lookup_consumed_modifiers

# RDI=Linux evdev keycode. EAX=1 if this key is configured to repeat.
# Modifier/group actions remain compositor-owned; this query only reads keymap policy.
.global xkb_key_repeats
.type xkb_key_repeats, @function
xkb_key_repeats:
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_key_repeat_default
    cmp edi, 247
    ja .Lxkb_key_repeat_invalid
    lea eax, [rdi + 8]
    lea rdx, [rip + xkb_key_names]
    cmp dword ptr [rdx + rax*4], 0
    je .Lxkb_key_repeat_invalid
    lea rdx, [rip + xkb_key_repeat_flags]
    movzx eax, byte ptr [rdx + rax]
    ret
.Lxkb_key_repeat_default:
    mov eax, 1
    ret
.Lxkb_key_repeat_invalid:
    xor eax, eax
    ret
.size xkb_key_repeats, . - xkb_key_repeats

# RDI=evdev keycode, ESI=32-bit XKB modifier-index mask, EDX=group.
# Returns an ASCII byte or zero. Wayland keycodes need the XKB +8 offset.
.global xkb_lookup_ascii
.type xkb_lookup_ascii, @function
xkb_lookup_ascii:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_lookup_none
    cmp edi, 247
    ja .Lxkb_lookup_none
    lea r12d, [rdi + 8]
    mov r13d, esi
    mov r14d, edx
    cmp r14d, 3
    jbe .Lxkb_lookup_group_ok
    xor r14d, r14d
.Lxkb_lookup_group_ok:
    mov edi, r12d
    mov esi, r13d
    mov edx, r14d
    call .Lxkb_select_level
    mov r15d, eax
    mov eax, r12d
    shl eax, 5
    lea eax, [rax + r14*8]
    add eax, r15d
    lea rdx, [rip + xkb_ascii_levels]
    movzx eax, byte ptr [rdx + rax]
    test eax, eax
    jnz .Lxkb_lookup_done
    test r14d, r14d
    jz .Lxkb_lookup_done
    mov edi, r12d
    mov esi, r13d
    xor edx, edx
    call .Lxkb_select_level
    mov r15d, eax
    mov eax, r12d
    shl eax, 5
    add eax, r15d
    lea rdx, [rip + xkb_ascii_levels]
    movzx eax, byte ptr [rdx + rax]
    jmp .Lxkb_lookup_done
.Lxkb_lookup_none:
    xor eax, eax
.Lxkb_lookup_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_lookup_ascii, . - xkb_lookup_ascii

# RDI=evdev keycode, ESI=32-bit XKB modifier-index mask, EDX=group.
# Returns an XKB Unicode keysym scalar or zero.
.global xkb_lookup_unicode
.type xkb_lookup_unicode, @function
xkb_lookup_unicode:
    push rbx
    push r12
    push r13
    push r14
    push r15
    cmp dword ptr [rip + xkb_keymap_ready], 1
    jne .Lxkb_unicode_lookup_none
    cmp edi, 247
    ja .Lxkb_unicode_lookup_none
    lea r12d, [rdi + 8]
    mov r13d, esi
    mov r14d, edx
    cmp r14d, 3
    jbe .Lxkb_unicode_group_ok
    xor r14d, r14d
.Lxkb_unicode_group_ok:
    mov edi, r12d
    mov esi, r13d
    mov edx, r14d
    call .Lxkb_select_level
    mov r15d, eax
    mov eax, r12d
    shl eax, 5
    lea eax, [rax + r14*8]
    add eax, r15d
    lea rdx, [rip + xkb_unicode_levels]
    mov eax, dword ptr [rdx + rax*4]
    test eax, eax
    jnz .Lxkb_unicode_lookup_done
    test r14d, r14d
    jz .Lxkb_unicode_lookup_done
    mov edi, r12d
    mov esi, r13d
    xor edx, edx
    call .Lxkb_select_level
    mov r15d, eax
    mov eax, r12d
    shl eax, 5
    add eax, r15d
    lea rdx, [rip + xkb_unicode_levels]
    mov eax, dword ptr [rdx + rax*4]
    jmp .Lxkb_unicode_lookup_done
.Lxkb_unicode_lookup_none:
    xor eax, eax
.Lxkb_unicode_lookup_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size xkb_lookup_unicode, . - xkb_lookup_unicode

.section .note.GNU-stack,"",@progbits
