# ver: 2025-12-14
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

VV, txt = namahanistrih(F=6000, S=400, tauDs=240)  # F v N, S v mm^2, sigmaDt v MPa
println(VV[:info]) # výpis výsledků
println("vystup01") # výpis výsledků
println(VV) # výpis výsledků
println("výstup02") # výpis výsledků
println(txt) # výpis výsledků

VV, txt = namahanistrih(F=6000N, S=400mm^2, tauDs=240MPa) # s jednotkami
println(VV)   # napětí v MPa (Unitful.Quantity)

VV, txt = namahanistrih(F=6000N, S=400mm^2, Re=240MPa,
zatizeni="pulzní") # s jednotkami
println(VV) # výpis výsledků
println(txt) # výpis výsledků

# předpokládáme, že materialy("S235") vrátí Dict(:Re => 235MPa, :E => 210GPa)
VV, txt = namahanistrih(F=6000N, S=400mm^2, mat="11373") # mat jako řetězec s názvem materiálu
println(txt) # výpis výsledků

VV, txt = namahanistrih(F=6000N, profil="TRKR 52x5", mat="11373", 
zatizeni="dynamický", k=5) # mat jako řetězec s názvem materiálu
println(VV) # výpis výsledků
println(txt) # výpis výsledků