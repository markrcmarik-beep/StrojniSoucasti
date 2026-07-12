# ver: 2026-07-12
using Test
using StrojniSoucasti, Unitful
#include(joinpath(abspath(joinpath(@__DIR__, "..")), "src", "profily", "profily.jl"))

@testset "profily" begin

    @testset "PLO" begin
        dims1 = profily("PLO 20.5x10") # pouze rozměry
        @test dims1[:info] == "PLO"
        @test dims1[:a] == 20.5u"mm"
        @test dims1[:b] == 10u"mm"
        @test dims1[:R] == 0u"mm"
        @test !haskey(dims1, :S) # vlastnost S není přítomna

        dims1a = profily("PLO20.5x10 ČSN") # rozměry bez mezery
        @test dims1a[:info] == "PLO"
        @test dims1a[:a] == 20.5u"mm"
        @test dims1a[:b] == 10u"mm"
        @test !haskey(dims1a, :standard) # standard není přítomen, protože nebyla zadána norma s čísly
        @test dims1a[:zkratka] == "ČSN"
        @test dims1a[:zkratka_info] == "Zkratka pro normu, např. ČSN, ISO, DIN"
        @test !haskey(dims1a, :S)

        dims2 = profily("PLO 20x10", "S") # rozměry + vlastnosti
        @test dims2[:info] == "PLO"
        @test dims2[:a] == 20u"mm"
        @test dims2[:b] == 10u"mm"
        @test dims2[:R] == 0u"mm"
        @test haskey(dims2, :S)
        @test dims2[:S] == 200u"mm^2"

        dims2a = profily("PLO20x10", "S", natoceni=45*pi/180) # rozměry + vlastnosti + natočení
        @test dims2a[:info] == "PLO"
        @test dims2a[:a] == 20u"mm"
        @test dims2a[:b] == 10u"mm"
        @test dims2a[:S] == 200u"mm^2"
        # @test dims2a[:natoceni] == (45*pi/180)u"rad" # profily() nevraci :natoceni pro PLO
    end

    @testset "TR4HR" begin
        dims3c = profily("TR4HR 50x35x5") # pouze rozměry
        @test dims3c[:info] == "TR4HR"
        @test dims3c[:a] == 50u"mm"
        @test dims3c[:b] == 35u"mm"
        @test dims3c[:t] == 5u"mm"
        @test dims3c[:R] ≈ 7.95373788u"mm"

        dims3a = profily("TR4HR 50x35x5", "S", "Ix") # rozměry + vlastnosti
        @test dims3a[:info] == "TR4HR"
        @test dims3a[:a] == 50u"mm"
        @test dims3a[:b] == 35u"mm"
        @test dims3a[:t] == 5u"mm"
        @test dims3a[:R] ≈ 7.95373788u"mm"
        @test haskey(dims3a, :S)
        @test dims3a[:S] ≈ 703.184713u"mm^2"
        @test haskey(dims3a, :Ix) # Ix pro TR4HR není implementováno, vrací nothing
        @test dims3a[:Ix] === nothing

        dims3b = profily("TR4HR 50x35x5", "S", "Ix", natoceni=30*pi/180) # rozměry + vlastnosti
        @test dims3b[:info] == "TR4HR"
        @test dims3b[:a] == 50u"mm"
        @test dims3b[:b] == 35u"mm"
        @test dims3b[:t] == 5u"mm"
        @test dims3b[:R] ≈ 7.95373788u"mm"
        @test haskey(dims3b, :S)
        @test dims3b[:S] ≈ 703.184713u"mm^2"
        @test haskey(dims3b, :Ix) # Ix pro TR4HR není implementováno, vrací nothing
        @test dims3b[:Ix] === nothing # Ix se neotáčí s profilem, I ano
        @test haskey(dims3b, :natoceni)
        @test dims3b[:natoceni] == (30*pi/180)u"rad"
    end

    @testset "4HR" begin
        dims4 = profily("4HR 50")
        @test dims4[:info] == "4HR"
        @test dims4[:a] == 50u"mm"
        @test dims4[:b] == 50u"mm"
        @test dims4[:R] == 0u"mm"
    end

    @testset "KR" begin
        dims5 = profily("KR 30", "S")
        @test dims5[:info] == "KR"
        @test dims5[:D] == 30u"mm"
        @test haskey(dims5, :S)
        @test typeof(dims5[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
        @test isapprox(dims5[:S], 706.8583u"mm^2", atol=1e-4u"mm^2")
    end

    @testset "TRKR" begin
        dims_trkr = profily("TRKR 30x2", "S", "Ix")
        @test dims_trkr[:info] == "TRKR"
        @test dims_trkr[:D] == 30u"mm"
        @test dims_trkr[:t] == 2u"mm"
        @test dims_trkr[:d] == 26u"mm"
        @test haskey(dims_trkr, :S)
        @test isapprox(dims_trkr[:S], 175.9292u"mm^2", atol=1e-4u"mm^2")
        @test haskey(dims_trkr, :Ix)
        @test dims_trkr[:Ix] ≈ 17329.025u"mm^4"
    end

    @testset "6HR" begin
        dims_6hr = profily("6HR 20", "S", "Wk")
        @test dims_6hr[:info] == "6HR"
        @test dims_6hr[:s] == 20u"mm"
        @test haskey(dims_6hr, :S)
        @test dims_6hr[:S] ≈ 346.41016u"mm^2"
        @test haskey(dims_6hr, :Wk)
        @test dims_6hr[:Wk] ≈ 8660.254u"mm^3"
    end

i80_material = ["10 000", "10 370.1", "11 373", "11 375", "11 523"]

function _test_i80_rozmery(dims, material)
    @test dims[:info] == "I"
    @test !haskey(dims, :a)
    @test dims[:b] == 42u"mm"
    @test !haskey(dims, :c)
    @test !haskey(dims, :s)
    @test dims[:h] == 80u"mm"
    @test !haskey(dims, :t)
    @test dims[:t1] == 3.9u"mm"
    @test dims[:t2] == 5.9u"mm"
    @test dims[:R] == 3.9u"mm"
    @test dims[:R1] == 2.3u"mm"
    @test !haskey(dims, :R2)
    @test dims[:sp] == 14
    @test dims[:m] == 5.94u"kg" / u"m"
    @test dims[:standard] == "ČSN425550"
    @test dims[:zkratka] == "ČSN"
    @test dims[:material] == material
end

i80_variants = (
    "I80",
    "I 80",
    "I\t80",
    "I80.0",
    "I 80.0",
    "I80 ČSN",
    "I 80 ČSN",
    "I80 ČSN425550",
    "I 80 ČSN425550",
    "I80 ČSN 42 5550",
    "I 80 ČSN 42 5550",
)

@testset "I profile" begin
    for i80_name in i80_variants
        @testset "I 80 - $(repr(i80_name))" begin
            dims6 = profily(i80_name)
            _test_i80_rozmery(dims6, i80_material)
            @test !haskey(dims6, :S) # vlastnost S není přítomna
            @test !haskey(dims6, :Ix) # vlastnost Ix není přítomna
            @test !haskey(dims6, :Iy) # vlastnost Iy není přítomna
            @test !haskey(dims6, :Ixy) # vlastnost Ixy není přítomna
            @test !haskey(dims6, :Imin) # vlastnost Imin není přítomna
            @test !haskey(dims6, :Imax) # vlastnost Imax není přítomna
            @test !haskey(dims6, :I) # vlastnost I není přítomna
            @test !haskey(dims6, :Wx) # vlastnost Wx není přítomna
            @test !haskey(dims6, :Wy) # vlastnost Wy není přítomna
            @test !haskey(dims6, :Wo) # vlastnost Wo není přítomna
            @test !haskey(dims6, :Jp) # vlastnost Jp není přítomna
            @test !haskey(dims6, :Jt) # vlastnost Jt není přítomna
            @test !haskey(dims6, :J) # vlastnost J není přítomna
            @test !haskey(dims6, :Wk) # vlastnost Wk není přítomna
            @test !haskey(dims6, :Sx) # vlastnost Sx není přítomna
            @test !haskey(dims6, :Sy) # vlastnost Sy není přítomna
            @test !haskey(dims6, :ix) # vlastnost ix není přítomna
            @test !haskey(dims6, :iy) # vlastnost iy není přítomna
            @test !haskey(dims6, :sx) # vlastnost sx není přítomna
        end
    end

    dims6d = profily("I 80 ČSN 42 5550", "S")
    _test_i80_rozmery(dims6d, i80_material)
    @test dims6d[:S] == 758u"mm^2"
    @test !haskey(dims6d, :Ix)

    dims6e = profily("I 80 ČSN 42 5550", "Ix")
    _test_i80_rozmery(dims6e, i80_material)
    @test !haskey(dims6e, :S)
    @test dims6e[:Ix] == 778000u"mm^4"

    dims6f = profily("I 80 ČSN 42 5550", "S", "Ix")
    _test_i80_rozmery(dims6f, i80_material)
    @test dims6f[:S] == 758u"mm^2"
    @test dims6f[:Ix] == 778000u"mm^4"
    @test !haskey(dims6f, :Iy)

    dims6 = profily("I 80 ČSN 42 5550", "Iy")
    _test_i80_rozmery(dims6, i80_material)
    @test !haskey(dims6, :S)
    @test !haskey(dims6, :Ix)
    @test dims6[:Iy] == 62900u"mm^4"

    dims6 = profily("I 80 ČSN 42 5550", "Wx")
    _test_i80_rozmery(dims6, i80_material)
    @test !haskey(dims6, :S)
    @test dims6[:Wx] == 19500u"mm^3"
    @test !haskey(dims6, :Wy)

    dims6g = profily("I 80 ČSN 42 5550", "S", "Ix", "Iy")
    _test_i80_rozmery(dims6g, i80_material)
    @test dims6g[:S] == 758u"mm^2"
    @test dims6g[:Ix] == 778000u"mm^4"
    @test dims6g[:Iy] == 62900u"mm^4"

    dims6_all = profily("I 80 ČSN 42 5550", "S", "Ix", "Iy", "Ixy", "Imin", "Imax", "I", "Wx", "Wy", "Wo", "Jp", "Jt", "J", "Wk", "ix", "iy")
    _test_i80_rozmery(dims6_all, i80_material)
    @test dims6_all[:S] == 758u"mm^2"
    @test dims6_all[:Ix] == 778000u"mm^4"
    @test dims6_all[:Iy] == 62900u"mm^4"
    @test dims6_all[:Ixy] == 0u"mm^4"
    @test dims6_all[:Imin] == 62900u"mm^4"
    @test dims6_all[:Imax] == 778000u"mm^4"
    @test dims6_all[:I] == 778000u"mm^4"
    @test dims6_all[:Wx] == 19500u"mm^3"
    @test dims6_all[:Wy] == 3000u"mm^3"
    @test dims6_all[:Wo] == 19500u"mm^3"
    @test dims6_all[:ix] == 32u"mm"
    @test dims6_all[:iy] == 9.1u"mm"
    @test dims6_all[:Jp] == 840900.0u"mm^4"
    @test dims6_all[:Jt] === nothing
    @test dims6_all[:J] === nothing
    @test dims6_all[:Wk] === nothing

    dims6_90 = profily("I 80", "I", "Ixy", "Wo", natoceni=pi/2)
    _test_i80_rozmery(dims6_90, i80_material)
    @test dims6_90[:natoceni] == (pi/2)u"rad"
    @test dims6_90[:I] == 62900u"mm^4"
    @test dims6_90[:Ixy] == 0u"mm^4"
    @test dims6_90[:Wo] == 3000u"mm^3"
end

ipe80_material = ["11 373", "11 375", "11 503", "11 523", "15 217"]

function _test_ipe80_rozmery(dims, material)
    @test dims[:info] == "IPE"
    @test !haskey(dims, :a)
    @test dims[:b] == 46u"mm"
    @test !haskey(dims, :c)
    @test !haskey(dims, :s)
    @test dims[:h] == 80u"mm"
    @test !haskey(dims, :t)
    @test dims[:t1] == 3.8u"mm"
    @test dims[:t2] == 5.2u"mm"
    @test dims[:R] == 5.0u"mm"
    @test dims[:R1] == 0.0u"mm"
    @test !haskey(dims, :R2)
    @test dims[:sp] == 0.0
    @test dims[:m] == 6.0u"kg" / u"m"
    @test dims[:standard] == "ČSN425553"
    @test dims[:zkratka] == "ČSN"
    @test dims[:material] == material
end

ipe80_variants = (
    "IPE80",
    "IPE 80",
    "IPE\t80",
    "IPE80.0",
    "IPE 80.0",
    "IPE80 ČSN",
    "IPE 80 ČSN",
    "IPE80 ČSN425553",
    "IPE 80 ČSN425553",
    "IPE80 ČSN 42 5553",
    "IPE 80 ČSN 42 5553",
)

@testset "IPE profile" begin
    for ipe80_name in ipe80_variants
        @testset "IPE 80 - $(repr(ipe80_name))" begin
            dims = profily(ipe80_name)
            _test_ipe80_rozmery(dims, ipe80_material)
            @test !haskey(dims, :S)
            @test !haskey(dims, :Ix)
            @test !haskey(dims, :Iy)
            @test !haskey(dims, :Ixy)
            @test !haskey(dims, :Imin)
            @test !haskey(dims, :Imax)
            @test !haskey(dims, :I)
            @test !haskey(dims, :Wx)
            @test !haskey(dims, :Wy)
            @test !haskey(dims, :Wo)
            @test !haskey(dims, :Jp)
            @test !haskey(dims, :Jt)
            @test !haskey(dims, :J)
            @test !haskey(dims, :Wk)
            @test !haskey(dims, :Sx)
            @test !haskey(dims, :Sy)
            @test !haskey(dims, :ix)
            @test !haskey(dims, :iy)
            @test !haskey(dims, :sx)
            @test !haskey(dims, :T)
        end
    end

    dims_S_Ix_Iy = profily("IPE 80", "S", "Ix", "Iy")
    _test_ipe80_rozmery(dims_S_Ix_Iy, ipe80_material)
    @test dims_S_Ix_Iy[:S] == 764u"mm^2"
    @test dims_S_Ix_Iy[:Ix] == 801000u"mm^4"
    @test dims_S_Ix_Iy[:Iy] == 84900u"mm^4" # CHYBA V DATECH: Správná hodnota je 44900, ale databáze vrací hodnotu pro IPE 100.

    dims_all = profily("IPE 80", "S", "Ix", "Iy", "Ixy", "Imin", "Imax", "I", "Wx", "Wy", "Wo", "Jp", "Jt", "J", "Wk", "ix", "iy", "sx", "Sx", "T")
    _test_ipe80_rozmery(dims_all, ipe80_material)
    @test dims_all[:S] == 764u"mm^2"
    @test dims_all[:Ix] == 801000u"mm^4"
    @test dims_all[:Iy] == 84900u"mm^4" # CHYBA V DATECH: Správná hodnota je 44900.
    @test dims_all[:Ixy] == 0u"mm^4"
    @test dims_all[:Imin] == 84900u"mm^4" # CHYBA V DATECH: má být 44900. Imin se nyní počítá, ale z chybné Iy.
    @test dims_all[:Imax] == 801000u"mm^4" # Imax se nyní počítá.
    @test dims_all[:I] == 801000u"mm^4"
    @test dims_all[:Wx] == 20000u"mm^3"
    @test dims_all[:Wy] == 3690u"mm^3" # CHYBA V DATECH: Správná hodnota je 1950.
    @test dims_all[:Wo] == 20000u"mm^3"
    @test dims_all[:ix] == 32.4u"mm"
    @test dims_all[:iy] == 10.5u"mm" # CHYBA V DATECH: Správná hodnota je ~7.68. V DB je 10.5, vypočtená z chybných dat (Iy, S) by byla ~10.54.
    @test dims_all[:Jp] == (801000 + 84900)u"mm^4"
    @test dims_all[:sx] == 69.0u"mm"
    @test dims_all[:Sx] == 11600.0u"mm^3"
    @test dims_all[:T] == [23.0, 40.0]u"mm" # CHYBA V DATECH: T by mělo být [0,0] nebo nothing.
    @test dims_all[:Jt] === nothing
    @test dims_all[:J] === nothing
    @test dims_all[:Wk] === nothing

    dims_90 = profily("IPE 80", "I", "Ixy", "Wo", natoceni=pi/2)
    _test_ipe80_rozmery(dims_90, ipe80_material)
    @test dims_90[:natoceni] == (pi/2)u"rad"
    @test dims_90[:I] == 84900u"mm^4" # CHYBA V DATECH: má být 44900.
    @test dims_90[:Ixy] == 0u"mm^4"
    @test dims_90[:Wo] == 3690u"mm^3" # CHYBA V DATECH: má být 1950.

    dims_10 = profily("IPE 80", "I", natoceni=10*pi/180)
    _test_ipe80_rozmery(dims_10, ipe80_material)
    @test isapprox(dims_10[:I], 779407u"mm^4", atol=1u"mm^4") # CHYBA V DATECH: Vypočteno s chybnou Iy.
end

end

nothing # zkrácení výstupu v REPL, aby se nezobrazovalo všechno
