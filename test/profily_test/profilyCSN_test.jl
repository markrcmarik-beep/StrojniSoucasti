# ver: 2026-02-09
using StrojniSoucasti, Unitful, Test

@testset "profilyCSN" begin
    dims = StrojniSoucasti.profilyCSN("OBD20.5x15R3")
    @test dims[:info] == "OBD"
    @test dims[:a] == 20.5u"mm"
    @test dims[:b] == 15u"mm"
    @test dims[:R] == 3u"mm"

    dims2 = StrojniSoucasti.profilyCSN("OBD 20 x 15 R 3")
    @test dims2[:info] == "OBD"
    @test dims2[:a] == 20u"mm"
    @test dims2[:b] == 15u"mm"
    @test dims2[:R] == 3u"mm"

    dims3 = StrojniSoucasti.profilyCSN("KR 40.5")
    @test dims3[:info] == "KR"
    @test dims3[:D] == 40.5u"mm"

    dims4 = StrojniSoucasti.profilyCSN("TRKR 60.5x4")
    @test dims4[:info] == "TRKR"
    @test dims4[:D] == 60.5u"mm"
    @test dims4[:t] == 4u"mm"
    @test dims4[:d] == 52.5u"mm"

    dims5 = StrojniSoucasti.profilyCSN("TR4HR20x20x2R4") # existuje v DB, R se bere z DB
    @test dims5[:info] == "TR4HR"
    @test dims5[:a] == 20u"mm"
    @test dims5[:b] == 20u"mm"
    @test dims5[:t] == 2u"mm"
    #@test isapprox(dims5[:R], (8 / 3)u"mm"; atol = 1e-6u"mm")

    dims6 = StrojniSoucasti.profilyCSN("TR4HR 20.5 x 20 x 2 R 4.5") # mimo DB
    @test dims6[:info] == "TR4HR"
    @test dims6[:a] == 20.5u"mm"
    @test dims6[:b] == 20u"mm"
    @test dims6[:t] == 2u"mm"
    @test dims6[:R] == 4.5u"mm"

    dims7 = StrojniSoucasti.profilyCSN("TR4HR20x3") # mimo DB
    @test dims7[:info] == "TR4HR"
    @test dims7[:a] == 20u"mm"
    @test dims7[:b] == 20u"mm"
    @test dims7[:t] == 3u"mm"
    @test dims7[:R] == 0u"mm"

    dims8 = StrojniSoucasti.profilyCSN("4HR25.8R2")
    @test dims8[:info] == "4HR"
    @test dims8[:a] == 25.8u"mm"
    @test dims8[:b] == 25.8u"mm"
    @test dims8[:R] == 2u"mm"

    dims8b = StrojniSoucasti.profilyCSN("4HR25.8")
    @test dims8b[:info] == "4HR"
    @test dims8b[:a] == 25.8u"mm"
    @test dims8b[:b] == 25.8u"mm"
    @test dims8b[:R] == 0u"mm"

    dims9 = StrojniSoucasti.profilyCSN("PLO30x10")
    @test dims9[:info] == "PLO"
    @test dims9[:a] == 30u"mm"
    @test dims9[:b] == 10u"mm"
    @test dims9[:R] == 0u"mm"

    dims10 = StrojniSoucasti.profilyCSN("6HR30")
    @test dims10[:info] == "6HR"
    @test dims10[:s] == 30u"mm"
    @test dims10[:a] == 30u"mm"
    @test dims10[:R] == 0u"mm"

    @test StrojniSoucasti.profilyCSN("NEEXISTUJICI 10x10") === nothing
    @test StrojniSoucasti.profilyCSN("PLO 10x10R10") === nothing
    @test StrojniSoucasti.profilyCSN("TRKR 20x10") === nothing
end
