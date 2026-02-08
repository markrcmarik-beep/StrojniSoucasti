using Documenter
using StrojniSoucasti

makedocs(
    sitename = "StrojniSoucasti",
    modules = [StrojniSoucasti],
    pages = [
        "Uvod" => "index.md",
        "Materialy" => "materialy.md",
        "Dovolene napeti" => "dovolene_napeti.md",
    ],
)
