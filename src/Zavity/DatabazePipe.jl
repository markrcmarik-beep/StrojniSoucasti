module DatabazePipe

using ..Zavity: ThreadSpec

export PIPE_DB

const PIPE_DB = Dict(
    "TR20x4.0" => ThreadSpec("TR20x4.0", :pipe, 20.0, 4.0),
    "TR16x3.0" => ThreadSpec("TR16x3.0", :pipe, 16.0, 3.0),
)

end # module
