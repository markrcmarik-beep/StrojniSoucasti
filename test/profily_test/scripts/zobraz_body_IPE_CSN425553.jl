#!/usr/bin/env julia
# ver: 2026-05-17

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
#include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_IPE_CSN425553.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')
const _DEFAULT_NATOCENI_RAD = 15*pi / 180
const _DEFAULT_UCHYCENI = "ld"

function _body_funkce_ipe_z_textu(prof, uchyceni::String="ld"; natoceni=0)
    return StrojniSoucasti.body_IPE_CSN425553(prof.name, uchyceni; natoceni=natoceni)
end

const _ARGS = if isempty(ARGS)
    ["IPE 100", _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_IPE_CSN425553.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 1
    [ARGS[1], _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_IPE_CSN425553.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 2
    [ARGS[1], ARGS[2], joinpath(@__DIR__, "zobraz_IPE_CSN425553.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 3
    [ARGS[1], ARGS[2], ARGS[3], string(_DEFAULT_NATOCENI_RAD)]
else
    ARGS
end

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"IPE 100\" ld ipe100_body.png 0.2617993878",
    default_profile="IPE 100",
    default_png="zobraz_IPE_CSN425553.png",
    nacti_profil=StrojniSoucasti.profil_IPE_CSN425553,
    body_funkce=_body_funkce_ipe_z_textu,
    tabulka="IPE",
    povol_natoceni=true,
    args=_ARGS,
)
