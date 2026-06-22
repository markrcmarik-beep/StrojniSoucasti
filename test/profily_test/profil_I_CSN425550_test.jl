# ver: 2026-06-22
using Test
using TOML
using StrojniSoucasti

const PROFIL_I_CSN425550_DB = TOML.parsefile(
    joinpath(@__DIR__, "..", "..", "src", "profily", "profil_I_CSN425550.toml")
)

function _profil_i_csn425550_keys()
    profil_keys = filter(k -> occursin(r"^I\d+(?:\.\d+)?$", k), collect(keys(PROFIL_I_CSN425550_DB)))
    return sort(profil_keys; by=key -> parse(Float64, match(r"^I(\d+(?:\.\d+)?)$", key).captures[1]))
end

function _row_float(row, key::String, default=nothing)
    value = get(row, key, default)
    return value === nothing ? nothing : Float64(value)
end

function _test_float(actual, expected; rtol=1e-12, atol=1e-9)
    if expected === nothing
        @test actual === nothing
    else
        @test actual !== nothing
        if actual !== nothing
            @test isapprox(actual, expected; rtol=rtol, atol=atol)
        end
    end
end

function _inertia_limits(Ix, Iy, Ixy)
    if Ix === nothing || Iy === nothing || Ixy === nothing
        return nothing, nothing
    end
    Imin = (Ix + Iy) / 2 - sqrt(((Ix - Iy) / 2)^2 + Ixy^2)
    Imax = (Ix + Iy) / 2 + sqrt(((Ix - Iy) / 2)^2 + Ixy^2)
    return Imin, Imax
end

function _expected_sx(row)
    sx = _row_float(row, "sx")
    return sx === nothing ? nothing : max(sx, 0.0)
end

function _expected_sx_moment(row, Ix, sx)
    if haskey(row, "Sx")
        return Float64(row["Sx"])
    elseif Ix !== nothing && sx !== nothing
        return sx > 0.0 ? Ix / sx : 0.0
    else
        return nothing
    end
end

function _test_profil_i_csn425550_row(prof, key::String, row)
    @test prof !== nothing
    if prof === nothing
        return
    end

    @test prof isa StrojniSoucasti.I_CSN425550
    @test hasproperty(prof, :serie)
    @test prof.name == string("I ", key[2:end])
    @test prof.serie == "I"
    @test prof.standard == "\u010CSN425550"
    @test prof.standard_info == "norma - textova hodnota"
    @test prof.zkratka == "ČSN"
    @test prof.zkratka_info == "zkratka pro rychlejší hledání v tabulce"

    _test_float(prof.h, _row_float(row, "h"))
    @test prof.h_unit == "mm"
    @test prof.h_info == "vyska profilu [mm]"
    _test_float(prof.b, _row_float(row, "b"))
    @test prof.b_unit == "mm"
    @test prof.b_info == "sirka pasnice [mm]"
    _test_float(prof.t1, _row_float(row, "t1"))
    @test prof.t1_unit == "mm"
    @test prof.t1_info == "tloustka stojiny [mm]"
    _test_float(prof.t2, _row_float(row, "t2"))
    @test prof.t2_unit == "mm"
    @test prof.t2_info == "stredni tloustka pasnice [mm]"
    _test_float(prof.R, _row_float(row, "R"))
    @test prof.R_unit == "mm"
    @test prof.R_info == "polomer zaobleni vyskove spojnice [mm]"
    _test_float(prof.R1, _row_float(row, "R1"))
    @test prof.R1_unit == "mm"
    @test prof.R1_info == "polomer zaobleni vnitrni sirky pasnice [mm]"
    _test_float(prof.sp, _row_float(row, "sp"))
    @test prof.sp_unit == "%"
    @test prof.sp_info == "sklon priruby [%]"
    _test_float(prof.m, _row_float(row, "m"))
    @test prof.m_unit == "kg/m"
    @test prof.m_info == "hmotnost [kg/m]"

    @test prof.material isa Vector{String}
    @test prof.material == get(row, "material", String[])
    @test prof.material_info == "Dostupné materiály pro tento profil"

    Ix = _row_float(row, "Ix")
    Iy = _row_float(row, "Iy")
    Ixy = _row_float(row, "Ixy", 0.0)
    Imin_calc, Imax_calc = _inertia_limits(Ix, Iy, Ixy)
    sx = _expected_sx(row)
    Sx = _expected_sx_moment(row, Ix, sx)

    _test_float(prof.S, _row_float(row, "S"))
    @test prof.S_unit == "mm^2"
    @test prof.S_info == "plocha prurezu [mm^2]"
    _test_float(prof.Ix, Ix)
    @test prof.Ix_unit == "mm^4"
    @test prof.Ix_info == "moment setrvacnosti podle osy x [mm^4]"
    _test_float(prof.Wx, _row_float(row, "Wx"))
    @test prof.Wx_unit == "mm^3"
    @test prof.Wx_info == "prurezovy modul podle osy x [mm^3]"
    _test_float(prof.ix, _row_float(row, "ix"))
    @test prof.ix_unit == "mm"
    @test prof.ix_info == "polomer setrvacnosti podle osy x [mm]"
    _test_float(prof.Iy, Iy)
    @test prof.Iy_unit == "mm^4"
    @test prof.Iy_info == "moment setrvacnosti podle osy y [mm^4]"
    _test_float(prof.Ixy, Ixy)
    @test prof.Ixy_unit == "mm^4"
    @test prof.Ixy_info == "kvadratický moment [mm^4]"
    _test_float(prof.Imin, haskey(row, "Imin") ? _row_float(row, "Imin") : Imin_calc)
    @test prof.Imin_unit == "mm^4"
    @test prof.Imin_info == "minimální moment setrvačnosti [mm^4]"
    _test_float(prof.Imax, haskey(row, "Imax") ? _row_float(row, "Imax") : Imax_calc)
    @test prof.Imax_unit == "mm^4"
    @test prof.Imax_info == "maximální moment setrvačnosti [mm^4]"
    _test_float(prof.Wy, _row_float(row, "Wy"))
    @test prof.Wy_unit == "mm^3"
    @test prof.Wy_info == "prurezovy modul podle osy y [mm^3]"
    _test_float(prof.Jp, _row_float(row, "Jp"))
    @test prof.Jp_unit == "mm^4"
    @test prof.Jp_info == "polární moment setrvačnosti [mm^4]"
    _test_float(prof.Jt, _row_float(row, "Jt"))
    @test prof.Jt_unit == "mm^4"
    @test prof.Jt_info == "Torsní moment setrvačnosti [mm^4]"
    _test_float(prof.J, _row_float(row, "J"))
    @test prof.J_unit == "mm^4"
    @test prof.J_info == "Torsní moment setrvačnosti [mm^4]"
    _test_float(prof.Wk, _row_float(row, "Wk"))
    @test prof.Wk_unit == "mm^3"
    @test prof.Wk_info == "Kroutící průřezový modul [mm^3]"
    _test_float(prof.iy, _row_float(row, "iy"))
    @test prof.iy_unit == "mm"
    @test prof.iy_info == "polomer setrvacnosti podle osy y [mm]"
    _test_float(prof.Sx, Sx)
    @test prof.Sx_unit == "mm^3"
    @test prof.Sx_info == "staticky moment prurezu podle osy x [mm^3]"
    _test_float(prof.sx, sx)
    @test prof.sx_unit == "mm"
    @test prof.sx_info == "staticka hodnota sx [mm]"
end

@testset "profil_I_CSN425550" begin
    @testset "normalizace oznaceni" begin
        valid_inputs = [
            ("I80", "I 80"),
            ("I 80", "I 80"),
            (" i 80 ", "I 80"),
            ("I\t80", "I 80"),
            ("I80.0", "I 80"),
            ("i 100.0", "I 100"),
            ("I 500", "I 500"),
            (SubString("xxI80yy", 3, 5), "I 80"),
        ]

        for (name1, exp_name) in valid_inputs
            prof = StrojniSoucasti.profil_I_CSN425550(name1)
            @test prof !== nothing
            if prof !== nothing
                @test prof.name == exp_name
            end
        end
    end

    @testset "hodnoty z databaze" begin
        for key in _profil_i_csn425550_keys()
            @testset "$key" begin
                row = PROFIL_I_CSN425550_DB[key]
                prof = StrojniSoucasti.profil_I_CSN425550(key)
                _test_profil_i_csn425550_row(prof, key, row)
            end
        end
    end

    @testset "dopoctene hodnoty" begin
        prof80 = StrojniSoucasti.profil_I_CSN425550("I80")
        @test prof80 !== nothing
        if prof80 !== nothing
            @test prof80.Ixy == 0.0
            @test isapprox(prof80.Imin, 62900.0; rtol=1e-12)
            @test isapprox(prof80.Imax, 778000.0; rtol=1e-12)
            @test prof80.Jp === nothing
            @test prof80.Jt === nothing
            @test prof80.J === nothing
            @test prof80.Wk === nothing
            @test prof80.Sx == 11400.0
            @test prof80.sx == 68.4
            @test prof80.sx_unit == "mm"
        end
    end

    @testset "neplatna oznaceni" begin
        invalid_inputs = [
            "",
            "I",
            "80",
            "I999",
            "IPE100",
            "IPN100",
            "XYZ100",
            "I80x",
            "I 80 mm",
            "I80,0",
            "I-80",
        ]

        for name1 in invalid_inputs
            @test StrojniSoucasti.profil_I_CSN425550(name1) === nothing
        end
    end
end
