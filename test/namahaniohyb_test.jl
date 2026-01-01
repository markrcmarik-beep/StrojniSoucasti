# ver: 2025-12-23
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

VV, txt = namahaniohyb(Mo=600, Wo=400, sigmaDo=240)  # F v N, S v mm^2, sigmaDt v MPa
println(VV[:info]) # výpis výsledků
println("vystup01") # výpis výsledků
println(VV) # výpis výsledků
println("výstup02") # výpis výsledků
println(txt) # výpis výsledků

VV, txt = namahaniohyb(Mo=600N*m, Wo=400mm^3, sigmaDo=240MPa) # s jednotkami
println(VV)   # napětí v MPa (Unitful.Quantity)

VV, txt = namahaniohyb(Mo=600N*m, Wo=400mm^3, Re=240MPa, 
    zatizeni="pulzní") # s jednotkami
println(VV) # výpis výsledků
println(txt) # výpis výsledků

# předpokládáme, že materialy("S235") vrátí Dict(:Re => 235MPa, :E => 210GPa)
VV, txt = namahaniohyb(Mo=600N*m, Wo=400mm^3, Ix=600mm^4, mat="11373") # mat jako řetězec s názvem materiálu
println(txt) # výpis výsledků

VV, txt = namahaniohyb(Mo=600N*m, profil="TRKR 76x5", mat="11373", 
    zatizeni="dynamický",natoceni=0u"rad", Lo=200mm, k=5) # mat jako řetězec s názvem materiálu
println(VV) # výpis výsledků
println(txt) # výpis výsledků