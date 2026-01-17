# ver: 2026-01-17
# Modul pro práci s profily TR4HR - umožňuje ukládat více hodnot pro parametry

using TOML

"""
    struct ProfileData
        name::String                    # označení profilu
        standard::String                # norma
        a::Float64                      # rozměr [mm]
        b::Float64                      # rozměr [mm]
        t::Vector{Float64}              # tloušťky [mm] - více hodnot
        R::Vector{Float64}              # poloměry [mm] - více hodnot
        material::Vector{String}        # materiály - více textových hodnot
end

Struktura pro uchovávání dat profilu TR4HR s podporou více hodnot.
"""
struct ProfileData
    name::String                    # označení profilu
    standard::String                # norma
    a::Float64                      # rozměr [mm]
    b::Float64                      # rozměr [mm]
    t::Vector{Float64}              # tloušťky [mm] - více hodnot
    R::Vector{Float64}              # poloměry [mm] - více hodnot
    material::Vector{String}        # materiály - více textových hodnot
end

"""
    load_profiles(filepath::String)::Dict{String, ProfileData}

Načte profily z TOML souboru a vrátí je jako slovník ProfileData struktur.
Automaticky konvertuje hodnoty oddělené čárkami na vektory.
"""
function load_profiles(filepath::String)::Dict{String, ProfileData}
    data = TOML.parsefile(filepath)
    profiles = Dict{String, ProfileData}()
    
    for (key, profile_data) in data
        if key == "schema_version"
            continue
        end
        
        # Konverze čárkami oddělených hodnot na vektory
        t_values = parse_float_array(profile_data["t"])
        R_values = parse_float_array(profile_data["R"])
        material_values = parse_string_array(profile_data["material"])
        
        profile = ProfileData(
            profile_data["name"],
            profile_data["standard"],
            profile_data["a"],
            profile_data["b"],
            t_values,
            R_values,
            material_values
        )
        
        profiles[key] = profile
    end
    
    return profiles
end

"""
    parse_float_array(value)::Vector{Float64}

Konvertuje čárkami oddělený string nebo jednotlivou hodnotu na vektor Float64.
Příklad: "3, 3.5, 4, 4.5, 5" → [3.0, 3.5, 4.0, 4.5, 5.0]
"""
function parse_float_array(value)::Vector{Float64}
    if value isa Vector
        return Float64.(value)
    elseif value isa String
        return parse.(Float64, strip.(split(value, ",")))
    else
        return [Float64(value)]
    end
end

"""
    parse_string_array(value)::Vector{String}

Konvertuje čárkami oddělený string nebo jednotlivou hodnotu na vektor String.
Příklad: "11 353", "11 453", "11 523" → ["11 353", "11 453", "11 523"]
"""
function parse_string_array(value)::Vector{String}
    if value isa Vector
        return String.(value)
    elseif value isa String
        return strip.(split(value, ","))
    else
        return [String(value)]
    end
end

"""
    get_profile(profiles::Dict, profile_name::String)::ProfileData

Vrátí konkrétní profil ze slovníku.
"""
function get_profile(profiles::Dict, profile_name::String)::ProfileData
    if haskey(profiles, profile_name)
        return profiles[profile_name]
    else
        error("Profil '$profile_name' nebyl nalezen. Dostupné profily: $(keys(profiles))")
    end
end

"""
    display_profile(profile::ProfileData)

Vytiskne detailní informace o profilu v čitelném formátu.
"""
function display_profile(profile::ProfileData)
    println("\n╔════════════════════════════════════╗")
    println("║  Profil: $(profile.name)")
    println("╠════════════════════════════════════╣")
    println("║  Standard: $(profile.standard)")
    println("║  Rozměr A: $(profile.a) mm")
    println("║  Rozměr B: $(profile.b) mm")
    println("├────────────────────────────────────┤")
    #println("║  Tloušťky (t): $(join(profile.t, \", \")) mm")
    #println("║  Poloměry (R): $(join(profile.R, \", \")) mm")
    #println("║  Materiály: $(join(profile.material, \", \"))")
    println("╚════════════════════════════════════╝\n")
end

"""
    get_combinations(profile::ProfileData)::Vector{NamedTuple}

Vrátí všechny kombinace hodnot t, R a material pro daný profil.
"""
function get_combinations(profile::ProfileData)::Vector{NamedTuple}
    combinations = []
    
    for (i, (t, R)) in enumerate(zip(profile.t, profile.R))
        for material in profile.material
            push!(combinations, (
                name = profile.name,
                a = profile.a,
                b = profile.b,
                t = t,
                R = R,
                material = material
            ))
        end
    end
    
    return combinations
end

"""
    list_all_profiles(profiles::Dict)

Vypíše seznam všech dostupných profilů.
"""
function list_all_profiles(profiles::Dict)
    println("\n═══ Dostupné profily ═══")
    for (key, profile) in profiles
        println("\n  • $key: $(profile.name)")
        println("    Standard: $(profile.standard)")
        println("    Rozměry: $(profile.a)×$(profile.b) mm")
        #println("    Tloušťky: $(join(profile.t, \", \")) mm")
        println("    Materiály: $(length(profile.material)) variant")
    end
    println()
end

export ProfileData, load_profiles, get_profile, display_profile, get_combinations, list_all_profiles
