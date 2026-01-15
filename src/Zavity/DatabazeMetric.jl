module DatabazeMetric

using ..Zavity: ThreadSpec

export METRIC_DB

const METRIC_DB = Dict(
    "M6x1.0"   => ThreadSpec("M6x1.0", :metric, 6.0, 1.0),
    "M8x1.25"  => ThreadSpec("M8x1.25", :metric, 8.0, 1.25),
    "M10x1.5"  => ThreadSpec("M10x1.5", :metric, 10.0, 1.5),
)

end # module
