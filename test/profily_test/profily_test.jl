# ver: 2026-06-20
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

dims33 = profily("TR4HR 50x30x5", "Ix") # rozměry + vlastnosti
dims3a = profily("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti
@test haskey(dims3a, :a)
@test haskey(dims3a, :b)
@test haskey(dims3a, :t)
@test haskey(dims3a, :info)
@test haskey(dims3a, :R)
@test haskey(dims3a, :S) # vlastnost S je přítomna
@test typeof(dims3a[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
@test haskey(dims3a, :Ix)
@test typeof(dims3a[:Ix]) <: Unitful.AbstractQuantity # Ix je s jednotkou
@test dims3a[:info] == "TR4HR"
@test dims3a[:a] == 50u"mm"
@test dims3a[:b] == 30u"mm"
@test dims3a[:t] == 5u"mm"
@test dims3a[:R] == 0u"mm"
dims3b = profily("TR4HR 50x30x5", "S", "Ix", natoceni=30*pi/180) # rozměry + vlastnosti
@test haskey(dims3b, :a)
@test haskey(dims3b, :b)
@test haskey(dims3b, :t)
@test haskey(dims3b, :info)
@test haskey(dims3b, :R)
@test haskey(dims3b, :S) # vlastnost S je přítomna
@test typeof(dims3b[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
@test haskey(dims3b, :Ix)
@test typeof(dims3b[:Ix]) <: Unitful.AbstractQuantity # Ix je s jednotkou
@test dims3b[:info] == "TR4HR"
@test dims3b[:a] == 50u"mm"
@test dims3b[:b] == 30u"mm"
@test dims3b[:t] == 5u"mm"
@test dims3b[:R] == 0u"mm"

dims3c = profily("TR4HR 50x30x5") # pouze rozměry
@test dims3c[:info] == "TR4HR"
@test dims3c[:a] == 50u"mm"
@test dims3c[:b] == 30u"mm"
@test dims3c[:t] == 5u"mm"
@test dims3c[:R] == 0u"mm"

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

dims6 = profily("I 80")
@test haskey(dims6, :info)
@test dims6[:info] == "I"
@test dims6[:b] == 42u"mm"
@test dims6[:h] == 80u"mm"
@test haskey(dims6, :info)
@test haskey(dims6, :b)
dims6a = profily("I80 ČSN425550")
@test haskey(dims6a, :info)
@test dims6a[:info] == "I"
@test dims6a[:b] == 42u"mm"
@test dims6a[:h] == 80u"mm"
@test dims6a[:standard] == "ČSN425550"
@test dims6a[:zkratka] == "\u010CSN"
dims6b = profily("I 80 ČSN425550")
@test haskey(dims6b, :info)
dims6c = profily("I 80 ČSN 42 5550")
@test haskey(dims6c, :info)

dims7 = profily("IPE 80")
@test dims7[:info] == "IPE"
@test dims7[:b] == 46u"mm"
@test dims7[:h] == 80u"mm"
@test !haskey(dims7, :S)
#@test dims7[:S] == 764u"mm^2"
@test dims7[:Ix] == 801000u"mm^4"

dims7a = profily("IPE 80", "S")
@test dims7a[:info] == "IPE"
@test dims7a[:b] == 46u"mm"
@test dims7a[:h] == 80u"mm"
@test dims7a[:S] == 764u"mm^2"
@test dims7a[:Ix] == 801000u"mm^4"

dims7b = profily("IPE 80", "Ix")

dims7c = profily("IPE 80", "Ix", natoceni=10*pi/180)
@test dims7c[:info] == "IPE"
@test dims7c[:b] == 46u"mm"

end
