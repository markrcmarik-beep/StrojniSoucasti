## Balíček Julia v1.12
###############################################################
## Popis balíčku
# Balíček StrojniSoucasti obsahuje funkce pro výpočet namáhání 
# strojních součástí v tahu, tlaku, krutu, střihu, ohybu, 
# kombinovaně a na otlačení.
# ver: 2026-04-25
## Autor: Martin
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/StrojniSoucasti.jl
#
## Použité balíčky:
#
###############################################################
## Použité proměnné vnitřní:
#
module StrojniSoucasti

# Import implementací
## --- materialy ---
include("materialy/materialy.jl")
#include("materialy/request.jl")
#include("materialy/reduction_table.jl")
#include("materialy/reduction.jl")
#include("materialy/select.jl")
include("materialy/dovoleneNapeti.jl") # dovolená napětí
include("materialy/mezUnavy.jl") # mez únavy
## --- body ---
include("body/bdu2b.jl") # souřadnice bodu B z bodu A, vzdálenosti a úhlu (2D)
include("body/bux2b.jl") # souřadnice bodu B z bodu A, vzdálenosti ve směru osy x a úhlu (2D)
include("body/buub2b.jl") # souřadnice bodu C z bodu A, úhlů a bodu B (2D)
include("body/ubru2bb.jl") # souřadnice bodů B a C z bodu A, úhlů a vzdálenosti (2D)
include("body/uu2u.jl") # úhel mezi dvěma úhly (2D)
include("body/oblouk2body.jl") # po sobě jdoucí body na kruhovém oblouku
## --- profily ---
include("profily/profil_TR4HR_CSN425720.jl") # profily TR4HR dle CSN 42 5720
include("profily/profil_I_common.jl") # sdilene helpery pro I/IPE profily
include("profily/profil_I_CSN425550.jl") # profily I dle CSN 42 5550
include("profily/profil_IPE_CSN425553.jl") # profily IPE dle CSN 42 5553
include("profily/profilyCSN.jl") # tvary profilů
include("profily/profilyvlcn.jl") # tvary profilů
include("profily/profily.jl") # tvary profilů
include("profily/profil_text_lines.jl") #
include("profily/profilyvlcnS.jl")
include("profily/profilyvlcnIp.jl")
include("profily/profilyvlcnWk.jl")
include("profily/profilyvlcnIx.jl")
include("profily/profilyvlcnIminImax.jl")
include("profily/profilyvlcnWo.jl")
include("profily/torsion_J_TR4HR_numeric.jl") #
include("profily/hrana.jl") # hrany
include("profily/polygon2plocha.jl") # plocha obecneho tvaru z obrysovych bodu
include("profily/polygon2kvadratickymoment.jl") # kvadraticke momenty z obrysovych bodu
include("profily/polygon2polarnimoment.jl") # polarni moment z obrysovych bodu
include("profily/polygon_metrics.jl") # plocha, teziste, momenty setrvacnosti z obrysovych bodu
include("profily/polygon2prurezovymodulkrut.jl") # modul v krutu z obrysovych bodu
## --- namáhání ---
include("namahani/namahanitah.jl") # namáhání tahem
include("namahani/namahanitahtext.jl")
include("namahani/namahanitlak.jl") # namáhání tlakem
include("namahani/namahanitlaktext.jl")
include("namahani/namahanikrut.jl") # namáhání krutem
include("namahani/namahanikruttext.jl")
include("namahani/namahanistrih.jl") # namáhání střihem
include("namahani/namahanistrihtext.jl")
include("namahani/namahaniohyb.jl") # namáhání ohybem
include("namahani/namahaniohybtext.jl") #
include("namahani/namahanikombinovane.jl") # namáhání kombinovaně
include("namahani/namahanikombinovanetext.jl") #
include("namahani/namahaniotl.jl") # namáhání otlačením
include("namahani/namahaniotltext.jl") # textový výpis namáhání otlačením
include("hridel.jl")
include("hrideltext.jl")
include("ulozvypis.jl") #
include("zavity/zavity.jl") # závity
include("tolerance/tolerance.jl") # tolerance

# Export funkcí
export materialy, dovoleneNapeti, mezUnavy, 
# body
 
# profily
profily,
# namahani
namahanitah, namahanitlak, namahanikrut, namahanistrih, 
namahaniohyb, namahaniotl, namahanikombinovane, 
# strojni soucasti
hridel, ulozvypis, zavity,
# tolerance
tolerance

# Zpřístupníme submodul Zavity pod jménem StrojniSoucasti.Zavity 
#using .Zavity

end # module StrojniSoucasti


