## Balíček Julia v1.12
###############################################################
## Popis balíčku
# Balíček StrojniSoucasti obsahuje funkce pro výpočet namáhání 
# strojních součástí v tahu, tlaku, krutu, střihu, ohybu, 
# kombinovaně a na otlačení.
# ver: 2026-02-01
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
include("profily/profilyvlcnS.jl")
include("profily/profilyvlcnIp.jl")
include("profily/profilyvlcnWk.jl")
include("tvarprofilu.jl") # tvary profilů
include("profily/hrana.jl") # hrany
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
include("tvarCSN.jl") #
include("ulozvypis.jl") #
include("zavity/zavity.jl") # závity
include("torsion_J_TR4HR_numeric.jl") #
include("profil_text_lines.jl") #

# Export funkcí
export dovoleneNapeti, mezUnavy, tvarprofilu, materialy, profily,
namahanitah, namahanitlak, namahanikrut, namahanistrih, 
namahanikombinovane, namahaniohyb, ulozvypis, zavity, namahaniotl

# Zpřístupníme submodul Zavity pod jménem StrojniSoucasti.Zavity 
#using .Zavity

end # module StrojniSoucasti
