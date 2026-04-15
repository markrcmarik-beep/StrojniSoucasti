# ver: 2026-04-15
using Test
using StrojniSoucasti

@testset "polygon_metrics" begin
    body = [(0,0), (4,0), (4,3), (0,3)]
    S, cx, cy, Ix, Iy, Jp = StrojniSoucasti.polygon_metrics(body)
# S=12.0, cx=2.0, cy=1.5, Ix=44.0, Iy=27.0, Jp=71.0
    @test S == 12.0
    @test cx == 2.0
    @test cy == 1.5
    @test Ix == 9
    @test Iy == 16
    @test Jp == 25
end
