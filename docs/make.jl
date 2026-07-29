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
        "Dovolene napeti" => "materialy/dovoleneNapeti.md",
        "Materialy" => "materialy/materialy.md",
        # namahani
        # profily
        "Profily" => "profily/profily.md",
        "Profiltvary" => "profily/profiltvary.md",
        # tolerance
        # zavity
        "Pouziti balicku" => "pouziti.md",
        "API" => "api.md"
    ],
)
