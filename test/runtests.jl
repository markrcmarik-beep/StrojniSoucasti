using Test, Unitful, Unitful.DefaultSymbols, StrojniSoucasti

@testset "StrojniSoucasti smoke tests" begin
    # tvar: rozměry
    dims = tvar("PLO 20x10")
    @test haskey(dims, :a) && haskey(dims, :b)
    @test dims[:a] == 20u"mm"
    @test dims[:b] == 10u"mm"

    # tvar + vlastnost S
    dims2 = tvar("PLO 20x10", "S")
    @test haskey(dims2, :S) # vlastnost S je přítomna
    @test typeof(dims2[:S]) <: Unitful.AbstractQuantity # S je s jednotkou

    # namahanitah: základní volání (bez textového výstupu)
    VV = namahanitah(F=1000u"N", S=200u"mm^2", sigmaDt=250u"MPa", return_text=false)
    @test isa(VV, Dict)
    @test haskey(VV, :sigma)
end
