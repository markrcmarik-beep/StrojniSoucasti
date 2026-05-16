# ver: 2026-05-16

using StrojniSoucasti

println("--- I80 ---", "S")
A1 = profily("I80")
println("S = ", A1[:S])
println("Ix = ", A1[:Ix])
println("Iy = ", A1[:Iy])
println("Wx = ", A1[:Wx])
println("Wy = ", A1[:Wy])

body_A1 = StrojniSoucasti.body_I_CSN425550("I80")
A1c = StrojniSoucasti.polygon2plocha(body_A1)
println("S = ", A1c, "mm^2")
I1 = StrojniSoucasti.polygon2kvadratickymoment(body_A1)
println("Ix = ", I1.Ix, "mm^4")
println("Iy = ", I1.Iy, "mm^4")
Jp1 = StrojniSoucasti.polygon2polarnimoment(body_A1)
println("Jp = ", Jp1, "mm^4")
Wk1 = StrojniSoucasti.polygon2prurezovymodulkrut(body_A1)
println("Jp = ", Wk1, "mm^3")

println("--- IPE80 ---")
A2 = profily("IPE80", "S")
println("S = ", A2[:S])
println("Ix = ", A2[:Ix])
println("Iy = ", A2[:Iy])

body_A2 = StrojniSoucasti.body_IPE_CSN425553("IPE80")
A2c = StrojniSoucasti.polygon2plocha(body_A2)
println("S = ", A2c, "mm^2")
I2 = StrojniSoucasti.polygon2kvadratickymoment(body_A2)
println("Ix = ", I2.Ix, "mm^4")
println("Iy = ", I2.Iy, "mm^4")

println("--- TR4HR40x4 ---")
#A3 = profily("TR4HR40x4", "S")
#println("S = ", A3[:S])

body_A3 = StrojniSoucasti.body_TR4HR_CSN425720("TR4HR40x4")
A3c = StrojniSoucasti.polygon2plocha(body_A3)
println("S = ", A3c, "mm^2")
I3 = StrojniSoucasti.polygon2kvadratickymoment(body_A3)
println("Ix = ", I3.Ix, "mm^4")
println("Iy = ", I3.Iy, "mm^4")
