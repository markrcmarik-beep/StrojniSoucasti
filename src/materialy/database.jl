# ver: 2026-01-08
module MaterialDatabase

using ..MaterialTypes
export MATERIAL_DB

const MATERIAL_DB = Dict{String,Material}(
    "S235JR+N" => Material(
        "S235JR+N", "EN 10025-2",
        235.0, 360.0, 510.0,
        26.0, 27.0, 20.0,
        true, 200.0
    ),

    "S235J2+N" => Material(
        "S235J2+N", "EN 10025-2",
        235.0, 360.0, 510.0,
        26.0, 27.0, -20.0,
        true, 200.0
    ),
    "16440" => Material(
        "16 440", "",
        340, 400, 460,
        26, 27, -20,
        true, 200
    )
)
end
