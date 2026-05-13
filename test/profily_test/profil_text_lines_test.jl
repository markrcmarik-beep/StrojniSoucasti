# ver: 2026-05-13
using Test
using StrojniSoucasti, Unitful

@testset "profil_text_lines" begin
    @testset "prazdny profil" begin
        VV = Dict{Symbol,Any}(
            :profil => "",
        )
        lines = StrojniSoucasti.profil_text_lines(VV)
        @test lines == ["profil:"]
    end

    @testset "profil s rozmery a jednotkami" begin
        VV = Dict{Symbol,Any}(
            :profil => "TRKR 76x5",
            :profil_info => Dict{Symbol,Any}(
                :R => 2.5u"cm",
                :D => 76u"mm",
                :d => 66u"mm",
                :t => 5u"mm",
                :a => 20.0,
                :n => 3,
                :S => 999u"mm^2",
            ),
        )

        lines = StrojniSoucasti.profil_text_lines(VV)

        @test lines == [
            "profil: TRKR 76x5",
            "  a = 20.0",
            "  D = 76 mm",
            "  d = 66 mm",
            "  t = 5 mm",
            "  R = 25.0 mm",
            "  n = 3",
        ]
        @test !any(occursin("S =", line) for line in lines)
    end
end
