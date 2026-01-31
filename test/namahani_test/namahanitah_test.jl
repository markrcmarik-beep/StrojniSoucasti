# ver: 2025-12-12
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

VV, txt = namahanitah(F=6000, S=400, sigmaDt=240)  # F v N, S v mm^2, sigmaDt v MPa
println(VV[:info]) # výpis výsledků
println("vystup01") # výpis výsledků
println(VV) # výpis výsledků
println("výstup02") # výpis výsledků
println(txt) # výpis výsledků

VV, txt = namahanitah(F=6000N, S=400mm^2, sigmaDt=240MPa) # s jednotkami
println("sigma = ",VV[:sigma])   # napětí v MPa (Unitful.Quantity)

VV, txt = namahanitah(F=6000N, S=400mm^2, Re=240MPa,
L0=220mm, zatizeni="pulzní") # s jednotkami
println(VV) # výpis výsledků
println(txt) # výpis výsledků

# předpokládáme, že materialy("S235") vrátí Dict(:Re => 235MPa, :E => 210GPa)
VV, txt = namahanitah(F=6000N, S=400mm^2, mat="11373") # mat jako řetězec s názvem materiálu
println(txt) # výpis výsledků

VV, txt = namahanitah(F=6000N, profil="TRKR 76x5", mat="11373", 
zatizeni="dynamický", L0=210mm, k=5) # mat jako řetězec s názvem materiálu
println(VV) # výpis výsledků
println(txt) # výpis výsledků