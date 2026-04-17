# ver: 2026-04-17
using Test

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
    include("profily_test/profilyCSN_test.jl")
    include("profily_test/profil_TR4HR_CSN425720_test.jl")
    include("profily_test/profil_I_CSN425550_test.jl")
    include("profily_test/profil_IPE_CSN425553_test.jl")
    include("profily_test/profilyvlcn_test.jl")
    include("profily_test/profilyvlcnS_test.jl")
    include("profily_test/profilyvlcnIp_test.jl")
    include("profily_test/torsion_J_TR4HR_numeric_test.jl")
    include("profily_test/profilyvlcnWk_test.jl")
    include("profily_test/profilyvlcnIx_test.jl")
    include("profily_test/profilyvlcnWo_test.jl")
    include("profily_test/profilyvlcnIminlmax_test.jl")
    include("profily_test/hrana_test.jl")
    include("profily_test/obloukBodu_test.jl")
    include("profily_test/plochaBodu_test.jl")
    include("profily_test/polarniMomentBodu_test.jl")
    include("profily_test/polygon_metrics_test.jl")
    include("profily_test/prurezovyModulKrutBodu_test.jl")
    # zavity
    include("zavity_test/zavity_test.jl")
    # strojni soucasti
    include("hridel_test.jl")
    include("ulozvypis_test.jl")
    # tolerance
    include("tolerance_test.jl")
