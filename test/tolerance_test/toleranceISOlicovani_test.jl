# ver: 2026-08-26
using Test
using StrojniSoucasti

@testset "toleranceISOlicovani" begin
    T1 = StrojniSoucasti.toleranceISOlicovani("40H8")
    @test T1[:nominal] == 40.0
    @test T1[:druh] == "díra"
    @test T1[:zone] == "H"
    @test T1[:stupen] == "8"
    @test T1[:IT] == 0.039
    @test T1[:ES] == 0.039
    @test T1[:EI] == 0.0
    @test T1[:min] ≈ 40.0
    @test T1[:max] ≈ 40.039
    @test T1[:es] === nothing
    @test T1[:ei] === nothing

    t2 = StrojniSoucasti.toleranceISOlicovani("40f7")
    @test t2[:nominal] == 40.0
    @test t2[:druh] == "hřídel"
    @test t2[:zone] == "f"
    @test t2[:stupen] == "7"
    @test t2[:IT] == 0.025
    @test t2[:es] ≈ -0.025
    @test t2[:ei] ≈ -0.05
    @test t2[:min] ≈ 39.95
    @test t2[:max] ≈ 39.975
    @test t2[:ES] === nothing
    @test t2[:EI] === nothing

    Tt1 = StrojniSoucasti.toleranceISOlicovani("40H8/40f7")

    @test_throws ErrorException StrojniSoucasti.toleranceISOlicovani("ABC")
    @test_throws ErrorException StrojniSoucasti.toleranceISOlicovani("-1000H7")
end

nothing
