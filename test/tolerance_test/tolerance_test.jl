# ver: 2026-08-07
using Test
using StrojniSoucasti

@testset "tolerance" begin
    t1 = tolerance("40H8")
    @test t1[:nominal] == 40.0
    @test isa(t1[:nominal_info], String)
    @test t1[:zone] == "H"
    @test isa(t1[:zone_info], String)
    @test t1[:grade] == 8
    @test isa(t1[:grade_info], String)
    @test t1[:type] == :hole
    @test isa(t1[:type_info], String)
    @test isapprox(t1[:ei], 0.0; atol=1e-12)
    @test isa(t1[:ei_info], String)
    @test isapprox(t1[:es], 0.039; atol=1e-12)
    @test isa(t1[:es_info], String)
    @test isapprox(t1[:min], 40.0; atol=1e-12)
    @test isa(t1[:min_info], String)
    @test isapprox(t1[:max], 40.039; atol=1e-12)
    @test isa(t1[:max_info], String)
    @test isapprox(t1[:tol], 0.039; atol=1e-12)
    @test isa(t1[:tol_info], String)
    @test t1[:unit] == "mm"
    @test isa(t1[:unit_info], String)

    t2 = tolerance("40f7")
    @test t2[:nominal] == 40.0
    @test isa(t2[:nominal_info], String)
    @test t2[:zone] == "f"
    @test isa(t2[:zone_info], String)
    @test t2[:grade] == 7
    @test isa(t2[:grade_info], String)
    @test t2[:type] == :shaft
    @test isa(t2[:type_info], String)
    @test isapprox(t2[:es], -0.020; atol=1e-12)
    @test isa(t2[:es_info], String)
    @test isapprox(t2[:ei], -0.041; atol=1e-12)
    @test isa(t2[:ei_info], String)
    @test isapprox(t2[:min], 39.959; atol=1e-12)
    @test isa(t2[:min_info], String)
    @test isapprox(t2[:max], 39.98; atol=1e-12)
    @test isa(t2[:max_info], String)
    @test isapprox(t2[:tol], 0.021; atol=1e-12)
    @test isa(t2[:tol_info], String)
    @test t2[:unit] == "mm"
    @test isa(t2[:unit_info], String)

    @test_throws ErrorException tolerance("ABC")
    @test_throws ErrorException tolerance("1000H7")
end

nothing
