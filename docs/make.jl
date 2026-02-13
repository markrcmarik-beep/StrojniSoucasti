# ver: 2026-02-08
using Documenter
using StrojniSoucasti

makedocs(
    sitename = "StrojniSoucasti",
    modules = [StrojniSoucasti],
    pages = [
        "Uvod" => "index.md",
        "Materialy" => "materialy.md",
        "Dovolene napeti" => "dovoleneNapeti.md",
    ],
)
