# ver: 2026-07-03
using Test
using StrojniSoucasti

@testset "polygon_metrics" begin
    body = [(0,0), (4,0), (4,3), (0,3)]
    S, cx, cy, Jp = StrojniSoucasti.polygon_metrics(body)
    @test S == 12.0
    @test cx == 2.0
    @test cy == 1.5
    @test Jp == 25.0

    @test StrojniSoucasti.polygon_metrics(nothing) === nothing
end

nothing
