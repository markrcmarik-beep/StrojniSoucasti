# ver: 2026-07-17
using Test
using StrojniSoucasti

@testset "polygon_metrics" begin
    
    body = [(0,0), (4,0), (4,3), (0,3)]
    S, cx, cy, Jp = StrojniSoucasti.polygon_metrics(body)
    @test S == 12.0
    @test cx == 2.0
    @test cy == 1.5
    @test Jp == 25.0

    @testset "Rectangle (Vector of Tuples, CCW)" begin
        body = [(0,0), (4,0), (4,3), (0,3)]
        metrics = StrojniSoucasti.polygon_metrics(body)
        @test metrics.S ≈ 12.0
        @test metrics.cx ≈ 2.0
        @test metrics.cy ≈ 1.5
        @test metrics.Jp ≈ 25.0
    end

    @testset "Input Formats and Winding Order" begin
        # Matrix input
        body_matrix = [0 0; 4 0; 4 3; 0 3]
        metrics_matrix = StrojniSoucasti.polygon_metrics(body_matrix)
        @test metrics_matrix.S ≈ 12.0
        @test metrics_matrix.cx ≈ 2.0
        @test metrics_matrix.cy ≈ 1.5
        @test metrics_matrix.Jp ≈ 25.0

        # Vector of Vectors input
        body_vec_vec = [[0,0], [4,0], [4,3], [0,3]]
        metrics_vec_vec = StrojniSoucasti.polygon_metrics(body_vec_vec)
        @test metrics_vec_vec.S ≈ 12.0
        @test metrics_vec_vec.cx ≈ 2.0
        @test metrics_vec_vec.cy ≈ 1.5
        @test metrics_vec_vec.Jp ≈ 25.0

        # Clockwise winding order
        body_cw = [(0,0), (0,3), (4,3), (4,0)]
        metrics_cw = StrojniSoucasti.polygon_metrics(body_cw)
        @test metrics_cw.S ≈ 12.0
        @test metrics_cw.cx ≈ 2.0
        @test metrics_cw.cy ≈ 1.5
        @test metrics_cw.Jp ≈ 25.0
    end

    @testset "Triangle" begin
        body = [(0,0), (6,0), (3,4)]
        metrics = StrojniSoucasti.polygon_metrics(body)
        @test metrics.S ≈ 12.0
        @test metrics.cx ≈ 3.0
        @test metrics.cy ≈ 4/3
        @test metrics.Jp ≈ 86/3
    end

    @testset "Error Handling" begin
        @test_throws ArgumentError("Degenerovany polygon: plocha vychazi nulova.") StrojniSoucasti.polygon_metrics([(0,0), (1,1), (2,2)])
        @test_throws ArgumentError("Pro vypocet zadejte alespon 3 body.") StrojniSoucasti.polygon_metrics([(0,0), (1,1)])
        @test_throws ArgumentError("Pro vypocet zadejte alespon 3 body.") StrojniSoucasti.polygon_metrics([0 0; 1 1])
        @test_throws ArgumentError("Matice bodu musi mit presne 2 sloupce (x, y).") StrojniSoucasti.polygon_metrics([0 0 0; 4 0 0; 4 3 0])
        @test_throws ArgumentError("Kazdy bod musi mit presne 2 souradnice (x, y).") StrojniSoucasti.polygon_metrics([(0,0), (1,1,1), (2,2)])
    end

    @testset "_max_radius_from_centroid" begin
        body = [(0,0), (4,0), (4,3), (0,3)]
        metrics = StrojniSoucasti.polygon_metrics(body)
        r_max = StrojniSoucasti._max_radius_from_centroid(body, metrics.cx, metrics.cy)
        @test r_max ≈ 2.5
    end

    @testset "Nothing input" begin
        @test StrojniSoucasti.polygon_metrics(nothing) === nothing
    end
end

nothing
