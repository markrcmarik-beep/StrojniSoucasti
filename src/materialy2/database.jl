
module Material2Database

using ..Material2Types
export MATERIAL_DB

const MATERIAL_DB = Dict{String,Material2}(
    "S235JR+N" => Material2(
        "S235JR+N", "EN 10025-2",
        235.0, 360.0, 510.0,
        26.0, 27.0, 20.0,
        true, 200.0
    ),

    "S235J2+N" => Material2(
        "S235J2+N", "EN 10025-2",
        235.0, 360.0, 510.0,
        26.0, 27.0, -20.0,
        true, 200.0
    )
)
end
