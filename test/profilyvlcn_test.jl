# ver: 2026-01-30
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

# Plochá tyč 20x10 mm
PLO_01 = Dict(
    :info => "PLO",
    :a => 20u"mm",
    :b => 10u"mm"
)
PLO_02 = Dict(
    :info => "PLO",
    :a => 20u"mm",
    :b => 10u"mm",
    :R => 2u"mm"
)
# Trubka kruhová
TRKR_01 = Dict(
    :info => "TRKR",
    :D => 20u"mm",
    :d => 10u"mm"
)

TR4HR_01 = Dict(
    :info => "TR4HR",
    :a => 20u"mm",
    :b => 10u"mm",
    :t => 4u"mm"
)

S, Stext = StrojniSoucasti.profilyvlcn(PLO_01, :S) # Výpočet plochy
println("Plocha: $S ($Stext)")

Ix, Ixtext = StrojniSoucasti.profilyvlcn(PLO_01, :Ix, natoceni=pi) # Výpočet Kvadratický moment v ohybu
println("Kvadratický moment v ohybu: $Ix ($Ixtext)")

Wo, Wotext = StrojniSoucasti.profilyvlcn(PLO_01, :Wo) # Výpočet průřezového modulu v ohybu
println("Průřezový modul v ohybu: $Wo ($Wotext)")



Wk, Wktext = StrojniSoucasti.profilyvlcn(TRKR_01, :Wk) # Výpočet průřezového modulu v krutu
println("Průřezový modul v krutu: $Wk ($Wktext)")

# Další plocha – opakovaný test

S2, Stext2 = StrojniSoucasti.profilyvlcn(PLO_02, :Ip) # Výpočet plochy
println("Plocha: $S2 ($Stext2)")

S3, Stext3 = StrojniSoucasti.profilyvlcn(TR4HR_01, :Ip) # Výpočet plochy
println("Polární moment k neutrální ose: $S3 ($Stext3)")

Imin, Imintext = StrojniSoucasti.profilyvlcn(TRKR_01, :Imin) # Výpočet Kvadratický moment v ohybu
println("Kvadratický moment min: $Imin ($Imintext)")

Imin, Imintext = StrojniSoucasti.profilyvlcn(PLO_01, :Imin) # Výpočet Kvadratický moment v ohybu
println("Kvadratický moment min: $Imin ($Imintext)")
