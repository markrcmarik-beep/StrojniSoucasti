# ver: 2025-12-29
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols
prof1 = "KR 25"
mat1 = "16440"
VVtah1, _ = namahanitah(F=20kN, profil=prof1, mat=mat1)
VVtlak1, _ = namahanitlak(F=20kN, profil=prof1, mat=mat1)
VVstrih1, _ = namahanistrih(F=10kN, profil=prof1, mat=mat1)
VVkrut1, _ = namahanikrut(Mk=400N*m, profil=prof1, mat=mat1)
VVohyb1, _ = namahaniohyb(Mo=400N*m, profil=prof1, mat=mat1)
VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtah1, VVstrih1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtlak1, VVstrih1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtah1, VVkrut1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtlak1, VVkrut1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtah1, VVohyb1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVtlak1, VVohyb1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVstrih1, VVkrut1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVstrih1, VVohyb1])
println(VVkomb1)
println(txtkomb1)

VVkomb1, txtkomb1 = namahanikombinovane(vysledky = [VVkrut1, VVohyb1],k=5)
println(VVkomb1)
println(txtkomb1)
