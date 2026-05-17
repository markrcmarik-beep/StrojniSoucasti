#!/usr/bin/env julia
# ver: 2026-05-17

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
#include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_TR4HR_CSN425720.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')
const _DEFAULT_NATOCENI_RAD = 15*pi / 180
const _DEFAULT_UCHYCENI = "ld"

function _body_funkce_tr4hr_z_textu(prof, uchyceni::String="ld"; natoceni=0)
    return StrojniSoucasti.body_TR4HR_CSN425720(prof.name, uchyceni; natoceni=natoceni)
end

const _ARGS = if isempty(ARGS)
    ["TR4HR20x20x2", _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_TR4HR_CSN425720.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 1
    [ARGS[1], _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_TR4HR_CSN425720.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 2
    [ARGS[1], ARGS[2], joinpath(@__DIR__, "zobraz_TR4HR_CSN425720.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 3
    [ARGS[1], ARGS[2], ARGS[3], string(_DEFAULT_NATOCENI_RAD)]
else
    ARGS
end

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"TR4HR 60x40x6\" ld tr4hr_body.png 0.2617993878",
    default_profile="TR4HR20x20x2",
    default_png="zobraz_TR4HR_CSN425720.png",
    nacti_profil=StrojniSoucasti.profil_TR4HR_CSN425720,
    body_funkce=_body_funkce_tr4hr_z_textu,
    tabulka="TR4HR",
    povol_natoceni=true,
    args=_ARGS,
)
