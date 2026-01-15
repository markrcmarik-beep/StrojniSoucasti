module DefaultPitch

export get_default_pitch

const METRIC_DEFAULT_PITCH = Dict(
    1.0  => 0.25,
    1.2  => 0.25,
    1.4  => 0.3,
    1.6  => 0.35,
    1.8  => 0.35,
    2.0  => 0.4,
    2.5  => 0.45,
    3.0  => 0.5,
    4.0  => 0.7,
    5.0  => 0.8,
    6.0  => 1.0,
    8.0  => 1.25,
    10.0 => 1.5,
    12.0 => 1.75,
    14.0 => 2.0,
    16.0 => 2.0,
    18.0 => 2.5,
    20.0 => 2.5,
    22.0 => 2.5,
    24.0 => 3.0,
    27.0 => 3.0,
    30.0 => 3.5,
    33.0 => 3.5,
    36.0 => 4.0,
)

function get_default_pitch(d::Float64)
    return get(METRIC_DEFAULT_PITCH, d,
        error("Pro průměr M$(d) není definováno standardní stoupání"))
end

end # module
