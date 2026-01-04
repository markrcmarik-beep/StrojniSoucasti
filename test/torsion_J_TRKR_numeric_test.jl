# ver: 2025-12-30
using StrojniSoucasti

a,b,t = 20.0, 10.0, 1
J = StrojniSoucasti.torsion_J_TR4HR_numeric(a,b,t)
println(J)

J_BB = 2*(a-t)^2*(b-t)^2*t/((a-t)+(b-t))
println(J_BB)
println( J > J_BB )