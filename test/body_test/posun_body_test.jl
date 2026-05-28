# ver: 2026-05-08
# Test script for posun_body.jl

using StrojniSoucasti, Test

@testset "posun_body" begin

    body = [(0, 0), (10, -5), (2.5, 3.5)]
    smer = (2, -1)
    posunute = StrojniSoucasti.posun_body(body, smer)

    @test isa(posunute, Vector{Tuple{Float64, Float64}})
    @test length(posunute) == 3
    @test posunute[1] == (2.0, -1.0)
    @test posunute[2] == (12.0, -6.0)
    @test posunute[3] == (4.5, 2.5)

    jeden_bod_ve_vektoru = [(3, 4)]
    posunuty = StrojniSoucasti.posun_body(jeden_bod_ve_vektoru, (-3, 1))
    @test posunuty == [(0.0, 5.0)]

    @test_throws MethodError StrojniSoucasti.posun_body((3, 4), (1, 2))

end
