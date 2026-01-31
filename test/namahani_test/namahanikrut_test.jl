# ver: 2025-12-13
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

println("--01-- Test funkce namahanikrut")
println("_______________________________")
VV, txt = namahanikrut(Mk=6000, Wk=400, tauDk=240)  # F v N, S v mm^2, sigmaDt v MPa
println(VV) # výpis výsledků
println(txt) # výpis výsledků
println("--02-- Test funkce namahanitlak")
println("_______________________________")
VV, txt = namahanikrut(Mk=200N*m, Wk=400mm^3, Re=240MPa) # s jednotkami
println(txt) # výpis výsledků
println("--03-- Test funkce namahanitlak")
println("_______________________________")
VV, txt = namahanikrut(Mk=120N*m, Wk=2200mm^3, Ip=25000mm^4, 
mat="11373") # mat jako řetězec s názvem materiálu
println(VV) # výpis výsledků
println(txt) # výpis výsledků
println("--04-- Test funkce namahanitlak")
println("_______________________________")
VV, txt = namahanikrut(Mk=300N*m, profil="TRKR 40x5", 
mat="16440", L0=90mm, zatizeni="rázový", k=5) # mat jako Dict s vlastnostmi materiálu
println(VV) # výpis výsledků
println(txt) # výpis výsledků