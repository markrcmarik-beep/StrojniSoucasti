#!/usr/bin/env julia
# ver: 2026-05-08

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_drazka4pero.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')

function _nacti_profil_drazka4pero(name::AbstractString)
    s = lowercase(strip(name))
    s = replace(s, r"\s+" => "")
    s == "pero" || return nothing

    return (
        name = "pero",
        D = 100.0, # prumer
        t = 6.0, # hloubka drazky
        b = 8.0, # sirka drazky
        R1 = 3.0, # polomer zaobleni drazky
        #natoceni = pi / 2,
        #n = 1,
    )
end

const _ARGS = if isempty(ARGS)
    ["pero", "stred"]
elseif length(ARGS) == 1
    [ARGS[1], "stred"]
else
    ARGS
end

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"pero\" stred drazka4pero_body.png",
    default_profile="pero",
    default_png="zobraz_drazka4pero.png",
    nacti_profil=_nacti_profil_drazka4pero,
    body_funkce=body_drazka4pero,
    tabulka="pero",
    args=_ARGS,
)
