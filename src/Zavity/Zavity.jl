
module Zavity

include("types.jl")
include("load_db.jl")
include("lookup.jl")

export zavity, DbRecord

function zavity(oznaceni::AbstractString)
    return lookup_toml(ZAVITY_DB, oznaceni)
end

end # module Zavity
