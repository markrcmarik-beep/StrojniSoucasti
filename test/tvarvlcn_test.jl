# ver: 2025-12-30
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

# Plochá tyč 20x10 mm
plocha = Dict(
    :info => "PLO",
    :a => 20u"mm",
    :b => 10u"mm"
)

S, Stext = StrojniSoucasti.tvarvlcn(plocha, :S) # Výpočet plochy
println("Plocha: $S ($Stext)")

Ix, Ixtext = StrojniSoucasti.tvarvlcn(plocha, :Ix, natoceni=pi) # Výpočet Kvadratický moment v ohybu
println("Kvadratický moment v ohybu: $Ix ($Ixtext)")

Wo, Wotext = StrojniSoucasti.tvarvlcn(plocha, :Wo) # Výpočet průřezového modulu v ohybu
println("Průřezový modul v ohybu: $Wo ($Wotext)")

# Trubka kruhová
plocha1 = Dict(
    :info => "TRKR",
    :D => 20u"mm",
    :d => 10u"mm"
)

Wk, Wktext = StrojniSoucasti.tvarvlcn(plocha1, :Wk) # Výpočet průřezového modulu v krutu
println("Průřezový modul v krutu: $Wk ($Wktext)")

# Další plocha – opakovaný test
Prf2 = Dict(
    :info => "PLO",
    :a => 20u"mm",
    :b => 10u"mm",
    :R => 2u"mm"
)
S2, Stext2 = StrojniSoucasti.tvarvlcn(Prf2, :Ip) # Výpočet plochy
println("Plocha: $S2 ($Stext2)")

Prf3 = Dict(
    :info => "TR4HR",
    :a => 20u"mm",
    :b => 10u"mm",
    :t => 4u"mm"
)
S3, Stext3 = StrojniSoucasti.tvarvlcn(Prf3, :Ip) # Výpočet plochy
println("Polární moment k neutrální ose: $S3 ($Stext3)")
