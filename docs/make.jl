# ver: 2026-07-29
using Documenter
using StrojniSoucasti

makedocs(
    sitename = "StrojniSoucasti",
    modules = [StrojniSoucasti],
    pages = [
        "Uvod" => "index.md",
        # body
        # materialy
        "Dovolene napeti" => "dovoleneNapeti.md",
        "Materialy" => "materialy.md",
        # namahani
        # profily
        "Profily" => "profily.md",
        "Profiltvary" => "profiltvary.md",
        # tolerance
        # zavity
        "Pouziti balicku" => "pouziti.md",
        "API" => "api.md"
    ],
)
