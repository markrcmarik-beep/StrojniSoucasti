#!/usr/bin/env julia
# ver: 2026-05-01

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_I_CSN425550.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"I 100\" stred i100_body.png",
    default_profile="I 100",
    default_png="zobraz_I_CSN425550.png",
    nacti_profil=StrojniSoucasti.profil_I_CSN425550,
    body_funkce=body_I_CSN425550,
    tabulka="I",
)
