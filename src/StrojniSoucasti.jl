## Balíček Julia v1.12
###############################################################
## Popis balíčku
# Balíček StrojniSoucasti obsahuje funkce pro výpočet namáhání 
# strojních součástí v tahu, tlaku, krutu, střihu, ohybu, 
# kombinovaně a na otlačení.
# ver: 2026-01-25
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
include("dovoleneNapeti.jl") # dovolená napětí
include("mezUnavy.jl") # mez únavy
## --- profily ---
include("profily/profilTR4HR.jl") # profily TR4HR
include("profily/profilyCSN.jl") # tvary profilů
include("profily/profilyvlcn.jl") # tvary profilů
include("profily/profily.jl") # tvary profilů
include("tvarvlcn.jl") #
include("tvarprofilu.jl") # tvary profilů
#include("hrana.jl") #
## --- namáhání ---
include("namahanitah.jl") # namáhání tahem
include("namahanitahtext.jl")
include("namahanitlak.jl") # namáhání tlakem
include("namahanitlaktext.jl")
include("namahanikrut.jl") # namáhání krutem
include("namahanikruttext.jl")
include("namahanistrih.jl") # namáhání střihem
include("namahanistrihtext.jl")
include("namahaniohyb.jl") # namáhání ohybem
include("namahaniohybtext.jl") #
include("namahanikombinovane.jl") # namáhání kombinovaně
include("namahanikombinovanetext.jl") #
include("tvarCSN.jl") #
include("ulozvypis.jl") #
include("zavity/zavity.jl") # závity
include("namahaniotl.jl") # namáhání otlačením
include("torsion_J_TR4HR_numeric.jl") #
include("profil_text_lines.jl") #

# Export funkcí
export dovoleneNapeti, mezUnavy, tvarprofilu, materialy, profily
namahanitah, namahanitlak, namahanikrut, namahanistrih, 
namahanikombinovane, namahaniohyb, ulozvypis, zavity, namahaniotl

# Zpřístupníme submodul Zavity pod jménem StrojniSoucasti.Zavity 
#using .Zavity

end # module StrojniSoucasti
