# ver: 2026-01-04
using StrojniSoucasti, Unitful, Test

dims = tvarprofilu("PLO 20x10") # pouze rozměry
@test haskey(dims, :a)
@test haskey(dims, :b)
@test haskey(dims, :info)
@test haskey(dims, :R)
@test dims[:info] == "PLO"
@test dims[:a] == 20u"mm"
@test dims[:b] == 10u"mm"
@test dims[:R] == 0u"mm"

dims2 = tvarprofilu("PLO 20x10", "S") # rozměry + vlastnosti
@test haskey(dims2, :a)
@test haskey(dims2, :b)
@test haskey(dims2, :info)
@test haskey(dims2, :R)
@test haskey(dims2, :S)
@test dims2[:info] == "PLO"
@test dims2[:a] == 20u"mm"
@test dims2[:b] == 10u"mm"
@test dims2[:R] == 0u"mm"

dims3 = tvarprofilu("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti
@test haskey(dims3, :a)
@test haskey(dims3, :b)
@test haskey(dims3, :t)
@test haskey(dims3, :info)
@test haskey(dims3, :R)
@test haskey(dims3, :S) # vlastnost S je přítomna
@test typeof(dims3[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
@test haskey(dims3, :Ix)
@test typeof(dims3[:Ix]) <: Unitful.AbstractQuantity # Ix je s jednotkou
@test dims3[:info] == "TR4HR"
@test dims3[:a] == 50u"mm"
@test dims3[:b] == 30u"mm"
@test dims3[:t] == 5u"mm"
@test dims3[:R] == 0u"mm"

dims4 = tvarprofilu("4HR 50")
@test haskey(dims4, :a)
@test haskey(dims4, :b)
@test haskey(dims4, :info)
@test haskey(dims4, :R)
@test dims4[:info] == "4HR"
@test dims4[:a] == 50u"mm"
@test dims4[:b] == 50u"mm"
@test dims4[:R] == 0u"mm"

dims5 = tvarprofilu("KR 30", "S")
@test haskey(dims5, :D)
@test haskey(dims5, :info)
@test haskey(dims5, :S)
@test typeof(dims5[:S]) <: Unitful.AbstractQuantity # S je s jednotkou
@test dims5[:info] == "KR"
@test dims5[:D] == 30u"mm"
