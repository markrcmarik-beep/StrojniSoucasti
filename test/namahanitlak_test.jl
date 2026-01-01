# ver: 2025-12-11
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

println("--01-- Test funkce namahanitlak")
VV, txt = namahanitlak(F=6000, S=400, sigmaDt=240)  # F v N, S v mm^2, sigmaDt v MPa
println(VV[:info]) # výpis výsledků
println(VV) # výpis výsledků
println(txt) # výpis výsledků
println("--02-- Test funkce namahanitlak")
VV, txt = namahanitlak(F=6000N, S=400mm^2, Re=240MPa) # s jednotkami
println(txt) # výpis výsledků
println("--03-- Test funkce namahanitlak")
# předpokládáme, že materialy("S235") vrátí Dict(:Re => 235MPa, :E => 210GPa)
VV, txt = namahanitlak(F=6000N, S=400mm^2, mat="11373") # mat jako řetězec s názvem materiálu
println(txt) # výpis výsledků
println("--04-- Test funkce namahanitlak")
VV, txt = namahanitlak(F=6000N, profil="PLO 20x20", 
mat="S235",L0=90mm, k=5) # mat jako Dict s vlastnostmi materiálu
println(txt) # výpis výsledků