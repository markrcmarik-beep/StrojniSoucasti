# ver: 2025-12-16
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

dims = tvarprofilu("PLO 20x10") # pouze rozměry
println("Rozměry profilu: ")
println(dims)

dims2 = tvarprofilu("PLO 20x10", "S") # rozměry + vlastnosti
println("Rozměry a vlastnosti profilu: ")
println(dims2)

dims3 = tvarprofilu("TR4HR 50x30x5", "S", "Ix") # rozměry + vlastnosti
println("Rozměry a vlastnosti U profilu: ")
println(dims3)
println("Plocha U profilu: ", dims3[:S])
println("Moment setrvačnosti Ix U profilu: ", dims3[:Ix])

dims4 = tvarprofilu("4HR 50")
println(dims4)

dims5 = tvarprofilu("KR 30", "S")
println(dims5)
