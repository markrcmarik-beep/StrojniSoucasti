# ver: 2026-01-17
# Modul pro práci s profily TR4HR - umožňuje ukládat více hodnot pro parametry

using TOML

include("profilTR4HRtypes.jl")

const TR4HR_DB = TOML.parsefile(joinpath(@__DIR__, "profilTR4HR.toml"))

function profilTR4HR(name::AbstractString)::Union{Profil, Nothing}
    
    #name = uppercase(strip(name)) # velká písmena
    name = replace(name, r"\s+" => "")   # odstranění všech mezer
    parsers = [
        (
        r"^TR4HR(\d+)X(\d+)X(\d+)$",
        function (m)
                a = parse(Int, m.captures[1])
                b = parse(Int, m.captures[2])
                t = parse(Int, m.captures[3])
        end
        )]
        nadp = string($a,"x",$b)
    haskey(TR4HR_DB, nadp) || return nothing
    
    row = TR4HR_DB[nadp]
    
    return Profil(
        get(row, "name", "")::String,
        get(row, "standard", "")::String,
        Float64(get(row, "a", 0.0)),
        Float64(get(row, "b", 0.0)),
        Float64(get(row, "t", 0.0)),
        Float64(get(row, "R", 0.0)),
        get(row, "material", "")::String
    )
end
