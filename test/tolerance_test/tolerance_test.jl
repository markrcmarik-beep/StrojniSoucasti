# ver: 2026-08-21
using Test
using StrojniSoucasti

@testset "tolerance" begin
    t1 = tolerance("40H8")
    @test t1[:nominal] == 40.0
    @test t1[:druh] == "díra"
    @test t1[:zone] == "H"
    @test t1[:stupen] == "8"
    @test t1[:IT] == 0.039
    @test t1[:ES] == 0.039
    @test t1[:EI] == 0.0
    @test t1[:min] ≈ 40.0
    @test t1[:max] ≈ 40.039
    @test t1[:es] === nothing
    @test t1[:ei] === nothing

    t2 = tolerance("40f7")
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

    @test_throws ErrorException tolerance("ABC")
    @test_throws ErrorException tolerance("-1000H7")
end

nothing
