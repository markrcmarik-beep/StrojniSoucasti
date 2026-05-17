# ver: 2026-05-17
using Test
using StrojniSoucasti
using TOML

const _TR4HR_DB = TOML.parsefile(
    joinpath(@__DIR__, "..", "..", "src", "profily", "profil_TR4HR_CSN425720.toml")
)
const _RHO_OCEL_KG_NA_M_NA_MM2 = 0.00785
const _KOEF_ROHU_TR4HR = 4 - pi

function _num_to_string(x::Real)::String
    x_f = Float64(x)
    if x_f == floor(x_f)
        return string(Int(x_f))
    else
        return string(x_f)
    end
end

function _m_z_radku(row::Dict, idx::Int, t::Real)
    if haskey(row, "m")
        m_raw = row["m"]
        if m_raw isa AbstractVector && idx <= length(m_raw)
            return Float64(m_raw[idx])
        end
    end

    if haskey(row, "m_by_t")
        m_by_t = row["m_by_t"]
        if m_by_t isa AbstractDict
            for key in (
                string(Float64(t)),
                _num_to_string(t),
                string(round(Float64(t), digits=1)),
                string(round(Float64(t), digits=2))
            )
                if haskey(m_by_t, key)
                    return Float64(m_by_t[key])
                end
            end
        end
    end

    return nothing
end

function _expected_R(a::Real, b::Real, t::Real)
    a_f = Float64(a)
    b_f = Float64(b)
    t_f = Float64(t)
    db_key = if a_f == b_f
        _num_to_string(a_f)
    else
        string(_num_to_string(a_f), "x", _num_to_string(b_f))
    end
    row = _TR4HR_DB[db_key]
    t_vec = Float64.(row["t"])
    idx = findfirst(==(t_f), t_vec)
    idx === nothing && error("V testu chybi t=$t_f pro key=$db_key.")

    R_raw = get(row, "R", nothing)
    if R_raw isa AbstractVector && idx <= length(R_raw)
        return Float64(R_raw[idx])
    end

    m_tab = _m_z_radku(row, idx, t_f)
    if m_tab !== nothing
        A_cil = m_tab / _RHO_OCEL_KG_NA_M_NA_MM2
        A0 = a_f*b_f - (a_f - 2t_f)*(b_f - 2t_f)
        if A_cil >= A0
            return 0.0
        end
        delta = A0 - A_cil
        delta_v_t = _KOEF_ROHU_TR4HR * t_f^2
        R = if delta <= delta_v_t
            sqrt(delta / _KOEF_ROHU_TR4HR)
        else
            (delta / _KOEF_ROHU_TR4HR + t_f^2) / (2t_f)
        end
        return clamp(R, 0.0, min(a_f, b_f)/2)
    end

    return min(t_f + t_f/3, 8.0)
end

profil_TR4HR_CSN425720_tests = [
    ("TR4HR20x20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 20x2"),
    ("TR4HR20x2", 20, 20, 2, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 20x2"),
    ("TR4HR30x20x3", 30, 20, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 30x20x3"),
    #("TR4HR30x3", 30, 30, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 30x3"),
    ("TR4HR25x3", 25, 25, 3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 25x3"),
    ("TR4HR40x40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 40x5"),
    ("TR4HR40x5", 40, 40, 5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 40x5"),
    ("TR4HR15x10x1.5", 15, 10, 1.5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 15x10x1.5"),
    #("TR4HR15x1.5", 15, 15, 1.5, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 15x1.5"),
    ("TR4HR10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 10x1"),
    ("tr4hr10x10x1", 10, 10, 1, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 10x1"),
    ("TR4HR60x40x6", 60, 40, 6, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x40x6"),
    ("TR4HR60x6.3", 60, 60, 6.3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x6.3"),
    ("tr4hr60x6.3", 60, 60, 6.3, "ČSN 42 5720", ["11 353", "11 453", "11 523"], "TR4HR 60x6.3"),
]

@testset "profil_TR4HR_CSN425720" begin
    for (name1, exp_a, exp_b, exp_t, exp_standard, exp_material, nazev1) in profil_TR4HR_CSN425720_tests
        prof = StrojniSoucasti.profil_TR4HR_CSN425720(name1)
        @test prof !== nothing
        @test prof isa StrojniSoucasti.TR4HR_CSN425720
        @test prof.name == nazev1
        @test prof.series == "TR4HR"
        @test prof.a == exp_a
        @test prof.b == exp_b
        @test prof.t == exp_t
        @test isapprox(prof.R, _expected_R(exp_a, exp_b, exp_t); atol=1e-4)
        @test prof.standard == exp_standard
        @test prof.material == exp_material
    end

    # Test neexistující profil
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR999x999x9") === nothing
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20x20x3") === nothing # tloušťka 3 mm není v databázi pro 20x20
    @test StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20.5x30x2") === nothing
end
