# ver: 2026-08-06
using Test
using StrojniSoucasti

@testset "tolerance" begin
    t1 = tolerance("40H8")
    @test t1.nominal == 40.0
    @test t1.zone == "H"
    @test t1.grade == 8
    @test t1.type == :hole
    @test isapprox(t1.ei, 0.0; atol=1e-12)
    @test isapprox(t1.es, 0.039; atol=1e-12)
    @test isapprox(t1.min, 40.0; atol=1e-12)
    @test isapprox(t1.max, 40.039; atol=1e-12)
    @test isapprox(t1.tol, 0.039; atol=1e-12)
    @test t1.unit == "mm"

    t2 = tolerance("40f7")
    @test t2.nominal == 40.0
    @test t2.zone == "f"
    @test t2.grade == 7
    @test t2.type == :shaft
    @test isapprox(t2.es, -0.020; atol=1e-12)
    @test isapprox(t2.ei, -0.041; atol=1e-12)
    @test isapprox(t2.min, 39.959; atol=1e-12)
    @test isapprox(t2.max, 39.98; atol=1e-12)
    @test isapprox(t2.tol, 0.021; atol=1e-12)
    @test t2.unit == "mm"

    @test_throws ErrorException tolerance("ABC")
    @test_throws ErrorException tolerance("1000H7")
end

nothing
