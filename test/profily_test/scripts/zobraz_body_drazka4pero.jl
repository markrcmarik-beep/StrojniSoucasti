#!/usr/bin/env julia
# ver: 2026-05-17

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
#include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_drazka4pero.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')
const _DEFAULT_NATOCENI_RAD = 15*pi / 180
const _DEFAULT_UCHYCENI = "stred"

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
        n = 1,
    )
end

function _body_funkce_drazka4pero_s_natocenim(prof, uchyceni::String="stred"; natoceni=0)
    prof1 = merge(prof, (natoceni = Float64(natoceni),))
    return StrojniSoucasti.body_drazka4pero(prof1, uchyceni)
end

const _ARGS = if isempty(ARGS)
    ["pero", _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_drazka4pero.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 1
    [ARGS[1], _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_drazka4pero.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 2
    [ARGS[1], ARGS[2], joinpath(@__DIR__, "zobraz_drazka4pero.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 3
    [ARGS[1], ARGS[2], ARGS[3], string(_DEFAULT_NATOCENI_RAD)]
else
    ARGS
end

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"pero\" stred drazka4pero_body.png 0.2617993878",
    default_profile="pero",
    default_png="zobraz_drazka4pero.png",
    nacti_profil=_nacti_profil_drazka4pero,
    body_funkce=_body_funkce_drazka4pero_s_natocenim,
    tabulka="pero",
    povol_natoceni=true,
    args=_ARGS,
)
