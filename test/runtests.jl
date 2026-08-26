# ver: 2026-08-26
using Test
    # body
    include("body_test/bdu2b_test.jl")
    include("body_test/burub2body_test.jl")
    include("body_test/bux2b_test.jl")
    include("body_test/buub2b_test.jl")
    include("body_test/ubru2bb_test.jl")
    include("body_test/uu2u_test.jl")
    include("body_test/brsb2body_test.jl")
    include("body_test/posun_body_test.jl")
    include("body_test/rotuj_body_test.jl")
    ## --matematika--
    include("matematika_test/parse_numeric_smart_test.jl")
    include("matematika_test/vyhodnot_vyraz_test.jl")
    # materialy
    include("materialy_test/materialy_test.jl")
    include("materialy_test/dovoleneNapeti_test.jl")
    include("materialy_test/mezUnavy_test.jl")
    # namahani
    include("namahani_test/namahanitah_test.jl")
    include("namahani_test/namahanitlak_test.jl")
    include("namahani_test/namahanikrut_test.jl")
    include("namahani_test/namahanistrih_test.jl")
    include("namahani_test/namahaniohyb_test.jl")
    include("namahani_test/namahaniotl_test.jl")
    include("namahani_test/namahanikombinovane_test.jl")
    # profily
    include("profily_test/profily_test.jl")
    include("profily_test/profil_text_lines_test.jl")
    include("profily_test/profiltvary_test.jl")
    include("profily_test/profil_TR4HR_CSN425720_test.jl")
    include("profily_test/profil_I_CSN425550_test.jl")
    include("profily_test/profil_IPE_CSN425553_test.jl")
    include("profily_test/body_I_CSN425550_test.jl")
    include("profily_test/body_IPE_CSN425553_test.jl")
    include("profily_test/body_TR4HR_CSN425720_test.jl")
    include("profily_test/profilyvlcn_test.jl")
    include("profily_test/profilyvlcnS_test.jl")
    include("profily_test/profilyvlcnJ_test.jl")
    include("profily_test/torsion_J_TR4HR_numeric_test.jl")
    include("profily_test/profilyvlcnWk_test.jl")
    include("profily_test/profilyIminmax_test.jl")
    include("profily_test/profilyvlcnI_test.jl")
    include("profily_test/profilyvlcnWo_test.jl")
    include("profily_test/profilyvlcneo_test.jl")
    include("profily_test/profilyvlcnrmax_test.jl")
    include("profily_test/profilyvlcnixy_test.jl")
    include("profily_test/hrana_test.jl")
    include("profily_test/polygon2plocha_test.jl")
    include("profily_test/polygon2kvadratickymoment_test.jl")
    include("profily_test/polygon2polarnimoment_test.jl")
    include("profily_test/polygon_metrics_test.jl")
    include("profily_test/polygon2eonatoceni_test.jl")
    include("profily_test/polygon2prurezovymodulkrut_test.jl")
    # tolerance
    include("tolerance_test/tolerance_test.jl")
    include("tolerance_test/toleranceISOlicovani_test.jl")
    include("tolerance_test/toleranceISOulozeni_test.jl")
    # zavity
    include("zavity_test/zavity_test.jl")

    # strojni soucasti
    include("hridel_test.jl")
    include("ulozvypis_test.jl")

    nothing
