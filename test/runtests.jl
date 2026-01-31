# ver: 2026-01-31
using Test

    # materialy
    include("materialy_test/materialy_test.jl")
    # namahani
    #iseror("namahani") do
        include("namahani_test/namahanitah_test.jl")
        include("namahani_test/namahanitlak_test.jl")
        include("namahani_test/namahanikrut_test.jl")
        include("namahani_test/namahanistrih_test.jl")
        include("namahani_test/namahaniohyb_test.jl")
        include("namahani_test/namahanikombinovane_test.jl")
        #include("namahani_test/namahaniotl_test.jl")
    #end
    # profily
    include("profily_test/tvarprofilu_test.jl")
    include("profily_test/profilTR4HR_test.jl")
    include("profily_test/profily_test.jl")
    include("profily_test/profilyvlcn_test.jl")
    include("profily_test/hrana_test.jl")
    # zavity
    include("zavity_test.jl")
    # strojni soucasti
    