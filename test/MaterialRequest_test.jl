
using StrojniSoucasti

req = MaterialRequest(
    210.0,   # Re_req
    -10.0,   # Tmin
    true,    # svařování
    25.0     # tloušťka
)

mat = select_material(req)

println(mat.name)
