## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vrátí TR4HR_CSN425720 struct s vlastnostmi profilu TR4HR z databáze.
# ver: 2026-05-17
## Funkce: profilTR4HR()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profil/profilTR4HR.jl
#
## Vzor:
## vystupni_promenne = profilTR4HR(vstupni_promenne)
## Vstupní proměnné:
# - name::AbstractString: Označení profilu (např. "TR4HR 20x20x2", "TR4HR20x2")
## Výstupní proměnné:
# - TR4HR_CSN425720 struct s vlastnostmi profilu nebo nothing, pokud profil neexistuje.
#   Vlastnosti TR4HR_CSN425720 struct:
#   - name::String: Název profilu
#   - standard::String: Norma (nepovinné)
#   - a::Float64: Rozměr a
#   - b::Float64: Rozměr b
#   - t::Float64: Tloušťka
#   - R::Float64: Poloměr (buď z databáze, nebo vypočítaný jako min(t + t/3, 8.0))
#   - material::Vector{String}: Seznam materiálů (nepovinné)
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
# profil_TR4HR_CSN425720.toml, num_to_string()
## Příklad:
# prof = profilTR4HR("TR4HR 20x20x2")
# println(prof.a)  # 20.0
# println(prof.b)  # 20.0
# println(prof.t)  # 2.0
# println(prof.R)  # 2.666...
###############################################################
## Použité proměnné vnitřní:
#

using TOML

struct TR4HR_CSN425720
    name::String
    series::String
    standard::String
    standard_info::String
    a::Float64
    a_unit::String
    a_info::String
    b::Float64
    b_unit::String
    b_info::String
    t::Float64
    t_unit::String
    t_info::String
    R::Float64
    R_unit::String
    R_info::String
    material::Vector{String}
    Ixy::Float64 # kvadratický moment setrvacnosti Ixy [mm^4] (neni v tabulce, nastaveno na 0)
    Ixy_unit::String # jednotka pro kvadratický moment setrvacnosti Ixy
    Ixy_info::String # popis kvadratického momentu setrvacnosti Ixy
end

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profil_TR4HR_CSN425720.toml"))
const _RHO_OCEL_KG_NA_M_NA_MM2 = 0.00785
const _KOEF_ROHU_TR4HR = 4 - pi

function _hmotnost_z_radku(row::Dict, idx::Int, t::Real)::Union{Nothing, Float64}
    t_val = Float64(t)

    if haskey(row, "m")
        m_raw = row["m"]
        if m_raw isa AbstractVector && idx <= length(m_raw)
            return Float64(m_raw[idx])
        end
    end

    if haskey(row, "m_by_t")
        m_by_t = row["m_by_t"]
        if m_by_t isa AbstractDict
            for key in (
                string(t_val),
                num_to_string(t_val),
                string(round(t_val, digits=1)),
                string(round(t_val, digits=2))
            )
                if haskey(m_by_t, key)
                    return Float64(m_by_t[key])
                end
            end
        end
    end

    return nothing
end

function _odhadni_R_z_hmotnosti(a::Real, b::Real, t::Real, m::Real)::Float64
    a_val = Float64(a)
    b_val = Float64(b)
    t_val = Float64(t)
    m_val = Float64(m)
    t_val <= 0 && return 0.0

    # Cilova plocha z tabulkove hmotnosti [kg/m] pro ocel ~7850 kg/m^3.
    A_cil = m_val / _RHO_OCEL_KG_NA_M_NA_MM2 # [mm^2]
    A0 = a_val*b_val - (a_val - 2t_val)*(b_val - 2t_val) # plocha TR4HR bez zaobleni rohu
    A_cil >= A0 && return 0.0

    delta = A0 - A_cil
    delta_v_t = _KOEF_ROHU_TR4HR * t_val^2
    R = if delta <= delta_v_t
        sqrt(delta / _KOEF_ROHU_TR4HR)
    else
        (delta / _KOEF_ROHU_TR4HR + t_val^2) / (2t_val)
    end

    return clamp(R, 0.0, min(a_val, b_val)/2)
end

function profil_TR4HR_CSN425720(name::AbstractString)::Union{TR4HR_CSN425720, Nothing}

    name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    nadpDB = nothing
    oznaceni = nothing
    # Zkusit rozebrat formát TR4HR_a_x_b_x_t
    m = match(r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$", name)
    if m !== nothing
        a = parse(Float64, m.captures[1]) # rozměr
        b = parse(Float64, m.captures[2]) # rozměr
        t = parse(Float64, m.captures[3]) # tloušťka
        if a < b # zajistit a >= b
            #a, b = b, a  # zajistit a >= b
            nadpDB = num_to_string(a) * "x" * num_to_string(b) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * num_to_string(t) # označení
        elseif a > b
            nadpDB = num_to_string(a) * "x" * num_to_string(b) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * num_to_string(t) # označení
        elseif a == b
            nadpDB = num_to_string(a) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * num_to_string(t) # označení
        end
    else
        # Zkusit rozebrat formát TR4HR_a_x_t
        m = match(r"^TR4HR(\d+(?:\.\d+)?)X(\d+(?:\.\d+)?)$", name)
        if m !== nothing
            a = parse(Float64, m.captures[1]) # rozměr
            b = a
            t = parse(Float64, m.captures[2]) # tloušťka
            nadpDB = num_to_string(a) # nadpis v DB
            oznaceni = "TR4HR " * nadpDB * "x" * num_to_string(t) # označení
        end
    end
    nadpDB === nothing && return nothing
    haskey(TR4HR_DB, nadpDB) || return nothing
    row = TR4HR_DB[nadpDB] # načíst řádek z DB
    t_vec = get(row, "t", Float64[]) # dostupné tloušťky
    if !(t in t_vec)
        return nothing
    end
    idx = findfirst(==(t), t_vec) # najít index tloušťky
    t = t_vec[idx] # vybraná tloušťka
    R_vec = get(row, "R", nothing)
    m_tab = _hmotnost_z_radku(row, idx, t)
    R_val = if R_vec isa AbstractVector && idx <= length(R_vec)
        Float64(R_vec[idx]) # poloměr z databáze (pokud je uveden)
    else
        min(t + t/3, 8.0) # výchozí poloměr
    end

    ma_R_v_tabulce = R_vec isa AbstractVector && idx <= length(R_vec)
    if !ma_R_v_tabulce && m_tab !== nothing
        R_val = _odhadni_R_z_hmotnosti(a, b, t, m_tab)
    end

    return TR4HR_CSN425720(
        string(oznaceni), # name
        "TR4HR", # serie
        "\u010CSN 42 5720", # standard
        "norma - textova hodnota", # info o normě
        a, # rozměr a
        "mm", # jednotka a
        "rozměr a", # info a
        b, # rozměr b
        "mm", # jednotka b
        "rozměr b", # info b
        t, # tloušťka
        "mm", # jednotka t
        "tloušťka", # info t
        R_val, # poloměr
        "mm", # jednotka R
        "poloměr", # info R
        get(row, "material", String[])::Vector{String},
        0, # Ixy - kvadratický moment setrvacnosti Ixy [mm^4] (neni v tabulce, nastaveno na 0)
        "mm^4", # jednotka pro kvadratický moment setrvacnosti Ixy
        "kvadratický moment setrvacnosti Ixy [mm^4]" # popis kvadratického momentu setrvacnosti Ixy
    )
end

# Pomocná funkce pro konverzi čísla na string bez zbytečných nul
function num_to_string(x::Float64)::String
    if x == floor(x)
        return string(Int(x))  # celočíslo bez tečky
    else
        return string(x)  # desetinné číslo
    end
end
