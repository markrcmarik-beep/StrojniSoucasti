using Test
using StrojniSoucasti

@testset "Materiály – základní vlastnosti z databáze" begin
    mat = materialy("S235")
    
    @test mat.name == "S235"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235.0
    @test mat.Rm_min == 360.0
    @test mat.Rm_max == 510.0
    @test mat.A == 26.0
    @test mat.KV == 27.0
    @test mat.T_KV == 20.0
    @test mat.weldable == true
    @test mat.thickness_max == 200.0
    @test mat.E == 210.0
    @test mat.G == 81.0
    @test mat.ny == 0.3
    @test mat.rho == 7850.0
end

@testset "Materiály – S235JR+N z databáze" begin
    mat = materialy("S235JR+N")
    
    @test mat.name == "S235JR+N"
    @test mat.standard == "EN 10025-2"
    @test mat.Re == 235.0
    @test mat.weldable == true
    @test mat.thickness_max == 200.0
    @test mat.E == 210.0
    @test mat.rho == 7850.0
end
