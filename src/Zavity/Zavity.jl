
#module Zavity
using TOML

include("types.jl")
#include("load_db.jl")
include("lookup_toml.jl")

#export zavity, DbRecord
const ZAVITY_DB = TOML.parsefile(joinpath(@__DIR__, "zavityM.toml"))
#println("Loaded ZAVITY_DB keys: ", keys(ZAVITY_DB))

function zavity(oznaceni::AbstractString)
    oznaceni = replace(oznaceni, "," => ".")
    RX_METRIC = r"^M(\d+)(?:[xX](\d+(?:\.\d+)?))?$"
    RX_TRAPEZ = r"^(?:TR|Tr|tr)(\d+)(?:[xX](\d+(?:\.\d+)?))?$"
    return lookup_toml(ZAVITY_DB, oznaceni)
end

#end # module Zavity
