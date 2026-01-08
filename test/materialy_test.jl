
using StrojniSoucasti

a = materialy("S235JR+N")
println(a.name)
println(a.Re)

a = materialy("16 440")
println(a.name)
println(a.Re)

#req = MaterialRequest(
#    210.0,   # Re_req
#    -10.0,   # Tmin
#    true,    # svařování
#    25.0     # tloušťka
#)
#mat = select_material(req)
#println(mat.name)
