# ver: 2026-01-14
using StrojniSoucasti

Z = StrojniSoucasti.Zavity.Zavity()

#z1 = Z("M8")
#z1.name        # "M8x1.25"
#z1.pitch       # 1.25

#z2 = Z("M10x1")
#z2.pitch       # 1.0

z3 = Z("TR20x4")
println(z3.name)
println(z3.d)            # 20.0
print(z3.pitch )       # 4
