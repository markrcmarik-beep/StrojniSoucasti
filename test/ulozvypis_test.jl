# ver: 2025-12-13
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

println("--01-- Test funkce namahanikrut")
println("_______________________________")
VV1, _ = namahanikrut(Mk=6000, profil="KR 30", mat="16440")  # F v N, S v mm^2, sigmaDt v MPa
VV2, _ = namahaniohyb(Mo=600, profil="KR 30", mat="16440")  # F v N, S v mm^2, sigmaDt v MPa
_, txt = namahanikombinovane(vysledky=[VV1, VV2])
ulozvypis(txt,@__DIR__,"ulozvypistest")