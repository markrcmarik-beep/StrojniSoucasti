#!/usr/bin/env julia
# ver: 2026-05-01

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_TR4HR_CSN425720.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"TR4HR 60x40x6\" stred tr4hr_body.png",
    default_profile="TR4HR20x20x2",
    default_png="zobraz_TR4HR_CSN425720.png",
    nacti_profil=StrojniSoucasti.profil_TR4HR_CSN425720,
    body_funkce=body_TR4HR_CSN,
    tabulka="TR4HR",
)
