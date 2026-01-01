# ver: 2025-12-30
module StrojniSoucasti

# Import implementací
include("materialy.jl") # materiály
include("dovoleneNapeti.jl") # dovolená napětí
include("mezUnavy.jl") # mez únavy
include("tvarvlcn.jl")
include("tvarprofilu.jl") # tvary profilů
include("hrana.jl")
include("namahanitah.jl") # namáhání tahem
include("namahanitahtext.jl")
include("namahanitlak.jl") # namáhání tlakem
include("namahanitlaktext.jl")
include("namahanikrut.jl") # namáhání krutem
include("namahanikruttext.jl")
include("namahanistrih.jl") # namáhání střihem
include("namahanistrihtext.jl")
include("namahaniohyb.jl") # namáhání ohybem
include("namahaniohybtext.jl")
include("namahanikombinovane.jl") # namáhání kombinovaně
include("namahanikombinovanetext.jl")
include("tvarCSN.jl")
include("ulozvypis.jl")
include("zavity.jl") # závity
include("namahaniotl.jl") # namáhání otlačením
include("torsion_J_TR4HR_numeric.jl") #

# Export funkcí
export materialy, dovoleneNapeti, mezUnavy,
tvarprofilu, namahanitah, namahanitlak, namahanikrut,
namahanistrih, namahanikombinovane, namahaniohyb, ulozvypis, 
zavity, namahaniotl

# Pomocná funkce pro výpis profil informací
function profil_text_lines(VV::Dict{Symbol,Any})
    lines = String[] # výpis informací o profilu
    if VV[:profil] != ""
        push!(lines, "profil: $(VV[:profil])") # název profilu
        selected_keys = [:a, :b, :D, :d, :t, :R] # běžné rozměry profilu
        for k in selected_keys # výpis rozměrů profilu
            if haskey(VV[:profil_info], k)
                v = VV[:profil_info][k] 
                if isa(v, Unitful.AbstractQuantity)
                    v2 = try uconvert(u"mm", v) catch v end
                    push!(lines, "  $(k) = $(v2)")
                else
                    push!(lines, "  $(k) = $(v)")
                end
            end
        end
    else
        push!(lines, "profil:") # prázdný profil
    end
    return lines # návrat výpisu
end

end # module StrojniSoucasti
