# ver: 2026-11-21
# skript pro sestavení dokumentace balíčku pomocí Documenter.jl
using Documenter
using StrojniSoucasti

makedocs(
    sitename = "StrojniSoucasti",
    modules = [StrojniSoucasti],
    pages = [
        "Uvod" => "index.md",
        # body
        # materialy
        "Dovolene napeti" => "materialy/dovoleneNapeti.md",
        "Bezpecnostni faktor gammaM" => "materialy/gammaM.md",
        "Materialy" => "materialy/materialy.md",
        # namahani
        # profily
        "Profily" => "profily/profily.md",
        "Profiltvary" => "profily/profiltvary.md",
        # tolerance
        "Tolerance" => "tolerance/tolerance.md",
        # zavity
        "Zavity" => "spojovacimaterial/zavity.md",
        "Pouziti balicku" => "pouziti.md",
        "API" => "api.md"
    ],
)
