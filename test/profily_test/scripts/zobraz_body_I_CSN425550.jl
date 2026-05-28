#!/usr/bin/env julia
# ver: 2026-05-17

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
#include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_I_CSN425550.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')
const _DEFAULT_NATOCENI_RAD = 15*pi / 180
const _DEFAULT_UCHYCENI = "ld"

function _body_funkce_i_z_textu(prof, uchyceni::String="ld"; natoceni=0)
    return StrojniSoucasti.body_I_CSN425550(prof.name, uchyceni; natoceni=natoceni)
end

const _ARGS = if isempty(ARGS)
    ["I 100", _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_I_CSN425550.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 1
    [ARGS[1], _DEFAULT_UCHYCENI, joinpath(@__DIR__, "zobraz_I_CSN425550.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 2
    [ARGS[1], ARGS[2], joinpath(@__DIR__, "zobraz_I_CSN425550.png"), string(_DEFAULT_NATOCENI_RAD)]
elseif length(ARGS) == 3
    [ARGS[1], ARGS[2], ARGS[3], string(_DEFAULT_NATOCENI_RAD)]
else
    ARGS
end

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"I 100\" ld i100_body.png 0.2617993878",
    default_profile="I 100",
    default_png="zobraz_I_CSN425550.png",
    nacti_profil=StrojniSoucasti.profil_I_CSN425550,
    body_funkce=_body_funkce_i_z_textu,
    tabulka="I",
    povol_natoceni=true,
    args=_ARGS,
)
