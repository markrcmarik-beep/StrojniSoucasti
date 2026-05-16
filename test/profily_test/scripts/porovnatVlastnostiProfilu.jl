# ver: 2026-05-16

using StrojniSoucasti

println("--- I80 ---")
A1 = profily("I80","S")
println("S = ", A1[:S])

body_A1 = StrojniSoucasti.body_I_CSN425550("I80")
A1c = StrojniSoucasti.polygon2plocha(body_A1)
println("S = ", A1c, "mm^2")

println("--- IPE80 ---")
A2 = profily("IPE80","S")
println("S = ", A2[:S])

body_A2 = StrojniSoucasti.body_IPE_CSN425553("IPE80")
A2c = StrojniSoucasti.polygon2plocha(body_A2)
println("S = ", A2c, "mm^2")

println("--- TR4HR40x4 ---")
#A3 = profily("TR4HR40x4")
#println("S = ", A3[:S])

body_A3 = StrojniSoucasti.body_TR4HR_CSN425720("TR4HR40x4")
A3c = StrojniSoucasti.polygon2plocha(body_A3)
println("S = ", A3c, "mm^2")
