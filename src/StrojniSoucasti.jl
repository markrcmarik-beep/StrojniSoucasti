# ver: 2026-01-03
module StrojniSoucasti

# Import implementací
include("materialy3.jl") # materiály
include("materialy3text.jl") #
include("materialy2/types.jl") #
include("materialy2/database.jl") #
include("materialy2.jl") #
include("dovoleneNapeti.jl") # dovolená napětí
include("mezUnavy.jl") # mez únavy
include("tvarvlcn.jl") #
include("tvarprofilu.jl") # tvary profilů
#include("hrana.jl") #
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
include("zavity.jl") # závity
include("namahaniotl.jl") # namáhání otlačením
include("torsion_J_TR4HR_numeric.jl") #
include("profil_text_lines.jl") #

using .Materialy2
# Export funkcí
export materialy3, materialy2, dovoleneNapeti, mezUnavy,
tvarprofilu, namahanitah, namahanitlak, namahanikrut,
namahanistrih, namahanikombinovane, namahaniohyb, ulozvypis, 
zavity, namahaniotl

end # module StrojniSoucasti
