# ver: 2026-01-04
using Test, Unitful, StrojniSoucasti

@testset "StrojniSoucasti smoke tests" begin

    include("tvarprofilu_test.jl")

    

    # namahanitah: základní volání (bez textového výstupu)
    VV = namahanitah(F=1000u"N", S=200u"mm^2", sigmaDt=250u"MPa", return_text=false)
    @test isa(VV, Dict)
    @test haskey(VV, :sigma)

end

include("materialy_test.jl")
