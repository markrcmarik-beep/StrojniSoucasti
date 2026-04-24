#!/usr/bin/env julia
# ver: 2026-04-24

include(joinpath(@__DIR__, "_zobraz_body_common.jl"))
include(joinpath(_ZOBRAZ_BODY_PROFILY_DIR, "body_IPE_CSN425553.jl"))

const _SCRIPT_REL = replace(relpath(@__FILE__, _ZOBRAZ_BODY_ROOT), '\\' => '/')

spust_zobrazeni_body(
    script_name=_SCRIPT_REL,
    priklad="julia $_SCRIPT_REL \"IPE 200\" stred ipe200_body.png",
    default_profile="IPE 100",
    default_png="body_IPE_CSN425553.png",
    nacti_profil=StrojniSoucasti.profil_IPE_CSN425553,
    body_funkce=body_IPE_CSN425553,
    tabulka="IPE",
)
