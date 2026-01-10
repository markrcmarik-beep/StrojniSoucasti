# ver: 2026-01-08
module StrojniSoucasti

# Import implementací
# Nejdřív materialy aby byly dostupné typy a databáze
include("materialy/materialy.jl")
include("materialy/request.jl")
include("materialy/reduction_table.jl")
include("materialy/reduction.jl")
include("materialy/select.jl")

include("materialy3.jl") # materiály - stará funkce
include("materialy3text.jl") #
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

# Export funkcí
export materialy3, dovoleneNapeti, mezUnavy,
tvarprofilu, namahanitah, namahanitlak, namahanikrut,
namahanistrih, namahanikombinovane, namahaniohyb, ulozvypis,
zavity, namahaniotl,
    materialy,
    MaterialRequest,
    Material,
    select_material,
    reduced_properties,
    Re_eff,
    Rm_eff,
    A_eff,
    MATERIAL_DB,
    REDUCTION_TABLES,
    ThicknessBand,
    thickness_band

end # module StrojniSoucasti
