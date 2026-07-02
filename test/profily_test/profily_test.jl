# ver: 2026-07-02
using Test
using StrojniSoucasti, Unitful
#include(joinpath(abspath(joinpath(@__DIR__, "..")), "src", "profily", "profily.jl"))

@testset "profily" begin

dims1 = profily("PLO 20.5x10") # pouze rozměry
@test haskey(dims1, :a)
@test haskey(dims1, :b)
@test haskey(dims1, :info)
@test haskey(dims1, :R)
@test dims1[:info] == "PLO"
@test dims1[:a] == 20.5u"mm"
@test dims1[:b] == 10u"mm"
#@test dims[:R] == 0u"mm"
@test !haskey(dims1, :S) # vlastnost S není přítomna

dims1a = profily("PLO20.5x10 ČSN") # rozměry bez mezery
@test haskey(dims1a, :a)
@test haskey(dims1a, :b)
@test haskey(dims1a, :info)
@test dims1a[:info] == "PLO"
@test dims1a[:a] == 20.5u"mm"
@test dims1a[:b] == 10u"mm"
@test !haskey(dims1a, :standard) # standard není přítomen, protože nebyla zadána norma s čísly
@test dims1a[:zkratka] == "ČSN"
@test dims1a[:zkratka_info] == "Zkratka pro normu, např. ČSN"
@test !haskey(dims1a, :S) # vlastnost S není přítomna

dims2 = profily("PLO 20x10", "S") # rozměry + vlastnosti
@test haskey(dims2, :a)
@test haskey(dims2, :b)
@test haskey(dims2, :info)
@test haskey(dims2, :R)
@test haskey(dims2, :S)
@test dims2[:info] == "PLO"
@test dims2[:a] == 20u"mm"
@test dims2[:b] == 10u"mm"
#@test dims2[:R] == 0u"mm"
dims2a = profily("PLO20x10", "S", natoceni=45*pi/180) # rozměry + vlastnosti + natočení
@test dims2a[:a] == 20u"mm"
@test dims2a[:b] == 10u"mm"
@test dims2a[:info] == "PLO"
@test dims2a[:S] == 200u"mm^2"
#@test dims2a[:natoceni] == 45*pi/180

dims33 = profily("TR4HR 50x35x5", "Ix") # rozměry + vlastnosti
dims3a = profily("TR4HR 50x35x5", "S", "Ix") # rozměry + vlastnosti
@test haskey(dims3a, :a)
@test haskey(dims3a, :b)
@test haskey(dims3a, :t)
@test haskey(dims3a, :info)
@test haskey(dims3a, :R)
@test haskey(dims3a, :S) # vlastnost S je přítomna
@test dims3a[:S] === nothing
@test haskey(dims3a, :Ix)
@test dims3a[:Ix] === nothing
@test dims3a[:info] == "TR4HR"
@test dims3a[:a] == 50u"mm"
@test dims3a[:b] == 35u"mm"
@test dims3a[:t] == 5u"mm"
@test dims3a[:R] == 7.953737880970119u"mm"
dims3b = profily("TR4HR 50x35x5", "S", "Ix", natoceni=30*pi/180) # rozměry + vlastnosti
@test haskey(dims3b, :a)
@test haskey(dims3b, :b)
@test haskey(dims3b, :t)
@test haskey(dims3b, :info)
@test haskey(dims3b, :R)
@test haskey(dims3b, :S) # vlastnost S je přítomna
@test dims3b[:S] === nothing
@test haskey(dims3b, :Ix)
@test dims3b[:Ix] === nothing
@test haskey(dims3b, :natoceni)
@test dims3b[:info] == "TR4HR"
@test dims3b[:a] == 50u"mm"
@test dims3b[:b] == 35u"mm"
@test dims3b[:t] == 5u"mm"
@test dims3b[:R] == 7.953737880970119u"mm"

dims3c = profily("TR4HR 50x35x5") # pouze rozměry
@test dims3c[:info] == "TR4HR"
@test dims3c[:a] == 50u"mm"
@test dims3c[:b] == 35u"mm"
@test dims3c[:t] == 5u"mm"
@test dims3c[:R] == 7.953737880970119u"mm"

dims4 = profily("4HR 50")
@test haskey(dims4, :a)
@test haskey(dims4, :b)
@test haskey(dims4, :info)
@test haskey(dims4, :R)
@test dims4[:info] == "4HR"
@test dims4[:a] == 50u"mm"
@test dims4[:b] == 50u"mm"
#@test dims4[:R] == 0u"mm"

dims5 = profily("KR 30", "S")
@test haskey(dims5, :D)
@test haskey(dims5, :info)
@test haskey(dims5, :S)
@test typeof(dims5[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
@test dims5[:info] == "KR"
@test dims5[:D] == 30u"mm"

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
@test !haskey(dims6d, :Ix) # vlastnost Ix není přítomna
@test !haskey(dims6d, :Iy) # vlastnost Iy není přítomna
dims6e = profily("I 80 ČSN 42 5550", "Ix")
_test_i80_rozmery(dims6e, i80_material)
@test !haskey(dims6e, :S) # vlastnost S není přítomna
@test dims6e[:Ix] == 778000u"mm^4"
@test !haskey(dims6e, :Iy) # vlastnost Iy není přítomna
dims6f = profily("I 80 ČSN 42 5550", "S", "Ix")
_test_i80_rozmery(dims6f, i80_material)
@test dims6f[:S] == 758u"mm^2"
@test dims6f[:Ix] == 778000u"mm^4"
@test !haskey(dims6f, :Iy) # vlastnost Iy není přítomna
dims6 = profily("I 80 ČSN 42 5550", "Iy")
_test_i80_rozmery(dims6, i80_material)
@test !haskey(dims6, :S) # vlastnost S není přítomna
@test !haskey(dims6, :Ix) # vlastnost Ix není přítomna
@test dims6[:Iy] == 62900u"mm^4"
dims6 = profily("I 80 ČSN 42 5550", "Wx")
_test_i80_rozmery(dims6, i80_material)
@test !haskey(dims6, :S) # vlastnost S není přítomna
@test !haskey(dims6, :Ix) # vlastnost Ix není přítomna
@test !haskey(dims6, :Iy) # vlastnost Iy není přítomna
@test !haskey(dims6, :Ixy) # vlastnost Ixy není přítomna
@test !haskey(dims6, :Imin)
@test !haskey(dims6, :Imax)
@test !haskey(dims6, :I) # vlastnost I není přítomna
@test dims6[:Wx] == 19500u"mm^3"
@test !haskey(dims6, :Wy) # vlastnost Wy není přítomna
@test !haskey(dims6, :Wo) # vlastnost Wo není přítomna
@test !haskey(dims6, :Jp) # vlastnost Jp není přítomna
@test !haskey(dims6, :Jt) # vlastnost Jt není přítomna
@test !haskey(dims6, :J) # vlastnost J není přítomna
@test !haskey(dims6, :Wk) # vlastnost Wk není přítomna
dims6g = profily("I 80 ČSN 42 5550", "S", "Ix", "Iy")
_test_i80_rozmery(dims6g, i80_material)
@test dims6g[:S] == 758u"mm^2"
@test dims6g[:Ix] == 778000u"mm^4"
@test dims6g[:Iy] == 62900u"mm^4"
dims6 = profily("I 80 ČSN 42 5550", "S", "Ix", "Iy", "Ixy", "Imin", "Imax", "I", "Wx", "Wy", "Wo", "Jp", "Jt", "J", "Wk", "ix", "iy")
_test_i80_rozmery(dims6, i80_material)
@test dims6[:S] == 758u"mm^2"
@test dims6[:Ix] == 778000u"mm^4"
@test dims6[:Iy] == 62900u"mm^4"
@test dims6[:Ixy] == 0u"mm^4"
@test dims6[:Imin] == 62900u"mm^4"
@test dims6[:Imax] == 778000u"mm^4"
@test dims6[:I] == 778000u"mm^4"
@test dims6[:Wx] == 19500u"mm^3"
@test dims6[:Wy] == 3000u"mm^3"
@test dims6[:Wo] == 19500u"mm^3"
@test dims6[:ix] == 32u"mm"
@test dims6[:iy] == 9.1u"mm"
@test dims6[:Jp] === nothing
@test dims6[:Jt] === nothing
@test dims6[:J] === nothing
@test dims6[:Wk] === nothing

dims6_90 = profily("I 80", "I", "Ixy", "Wo", natoceni=pi/2)
_test_i80_rozmery(dims6_90, i80_material)
@test dims6_90[:natoceni] == (pi/2)u"rad"
@test dims6_90[:I] == 62900u"mm^4"
@test dims6_90[:Ixy] == 0u"mm^4"
@test dims6_90[:Wo] == 3000u"mm^3"

dims7 = profily("IPE 80")
@test dims7[:info] == "IPE"
@test dims7[:b] == 46u"mm"
@test dims7[:h] == 80u"mm"
@test !haskey(dims7, :S)
@test !haskey(dims7, :Ix)

dims7a = profily("IPE 80", "S")
@test dims7a[:info] == "IPE"
@test dims7a[:b] == 46u"mm"
@test dims7a[:h] == 80u"mm"
@test dims7a[:S] == 764u"mm^2"
@test !haskey(dims7a, :Ix)

dims7b = profily("IPE 80", "Ix")

dims7c = profily("IPE 80", "Ix", natoceni=10*pi/180)
@test dims7c[:info] == "IPE"
@test dims7c[:b] == 46u"mm"
@test dims7c[:h] == 80u"mm"
@test dims7c[:Ix] == 801000u"mm^4"

end

nothing # zkrácení výstupu v REPL, aby se nezobrazovalo všechno
