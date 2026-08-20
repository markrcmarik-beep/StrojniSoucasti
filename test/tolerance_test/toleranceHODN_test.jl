# ver: 2026-08-20
using Test
using StrojniSoucasti

@testset "toleranceHODN" begin

    @testset "Valid hole tolerance (díra)" begin
        # Test case for 40 H8 (díra)
        T1 = StrojniSoucasti.toleranceHODN(40, "H", "8")
        @test T1[:nominal] == 40.0
        @test T1[:druh] == "díra"
        @test T1[:zone] == "H"
        @test T1[:stupen] == "8"
        @test T1[:IT] == 0.039
        @test T1[:ES] == 0.039
        @test T1[:EI] == 0.0
        @test T1[:max] ≈ 40.039
        @test T1[:min] ≈ 40.0
        @test T1[:es] === nothing
        @test T1[:ei] === nothing
    end

    @testset "Valid shaft tolerance (hřídel)" begin
        # Test case for 40 f7 (hřídel)
        t1 = StrojniSoucasti.toleranceHODN(40, "f", "7")
        @test t1[:nominal] == 40
        @test t1[:druh] == "hřídel"
        @test t1[:zone] == "f"
        @test t1[:stupen] == "7"
        @test t1[:IT] == 0.025
        @test t1[:es] ≈ -0.025
        @test t1[:ei] ≈ -0.050
        @test t1[:max] ≈ 39.975
        @test t1[:min] ≈ 39.950
        @test t1[:ES] === nothing
        @test t1[:EI] === nothing
        t2 = StrojniSoucasti.toleranceHODN(40, "j", "7")
        @test t2[:nominal] == 40
        @test t2[:druh] == "hřídel"
        @test t2[:zone] == "j"
        @test t2[:stupen] == "7"
        @test t2[:IT] == 0.025
        @test t2[:es] ≈ 0.015
        @test t2[:ei] ≈ -0.01
        @test t2[:max] ≈ 40.015
        @test t2[:min] ≈ 39.99
        @test t2[:ES] === nothing
        @test t2[:EI] === nothing
        t3 = StrojniSoucasti.toleranceHODN(40, "js", "7")
        @test t3[:nominal] == 40
        @test t3[:druh] == "hřídel"
        @test t3[:zone] == "js"
        @test t3[:stupen] == "7"
        @test t3[:IT] == 0.025
        
    end

    @testset "Error handling" begin
        # Test for invalid zone
        @test_throws ErrorException StrojniSoucasti.toleranceHODN(40, "H7", "7")
        # Test for out-of-range nominal dimension
        @test_throws ErrorException StrojniSoucasti.toleranceHODN(-1000, "H", "8")
    end

end

nothing
