
module MaterialReductionTables

export ThicknessBand, REDUCTION_TABLES

struct ThicknessBand
    t_min::Float64
    t_max::Float64
    Re::Float64
    Rm_min::Float64
    Rm_max::Float64
    A::Float64
end

const REDUCTION_TABLES = Dict{Float64,Vector{ThicknessBand}}(

    235.0 => [
        ThicknessBand(0,16,235,360,510,26),
        ThicknessBand(16,40,225,360,510,25),
        ThicknessBand(40,63,215,360,510,24),
        ThicknessBand(63,80,215,360,510,23),
        ThicknessBand(80,100,205,360,510,22),
        ThicknessBand(100,150,195,360,510,21),
        ThicknessBand(150,200,185,360,510,20)
    ],

    355.0 => [
        ThicknessBand(0,16,355,470,630,22),
        ThicknessBand(16,40,345,470,630,22),
        ThicknessBand(40,63,335,470,630,21),
        ThicknessBand(63,80,325,470,630,21),
        ThicknessBand(80,100,315,470,630,20),
        ThicknessBand(100,150,295,470,630,19),
        ThicknessBand(150,200,285,470,630,18)
    ]
)

end
