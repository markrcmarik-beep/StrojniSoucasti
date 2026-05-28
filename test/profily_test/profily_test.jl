# ver: 2026-05-27
using Test
using StrojniSoucasti, Unitful
#include(joinpath(abspath(joinpath(@__DIR__, "..")), "src", "profily", "profily.jl"))

@testset "profily" begin

dims = profily("PLO 20.5x10") # pouze rozměry
@test haskey(dims, :a)
@test haskey(dims, :b)
@test haskey(dims, :info)
@test haskey(dims, :R)
@test dims[:info] == "PLO"
@test dims[:a] == 20.5u"mm"
@test dims[:b] == 10u"mm"
#@test dims[:R] == 0u"mm"

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
dims3b = profily("TR4HR 50x30x5", "S", "Ix", natoceni=30) # rozměry + vlastnosti
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
#@test haskey(dims6, :info)
#@test haskey(dims6, :b)

dims7 = profily("IPE 80")
@test dims7[:info] == "IPE"
@test dims7[:b] == 46u"mm"
@test dims7[:h] == 80u"mm"
@test dims7[:S] == 764u"mm^2"
@test dims7[:Ix] == 801000u"mm^4"

dims7a = profily("IPE 80", "S")
@test dims7a[:info] == "IPE"
@test dims7a[:b] == 46u"mm"
@test dims7a[:h] == 80u"mm"
@test dims7a[:S] == 764u"mm^2"
@test dims7a[:Ix] == 801000u"mm^4"

end
