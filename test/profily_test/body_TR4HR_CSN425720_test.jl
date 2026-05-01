# ver: 2026-05-01
using Test
using StrojniSoucasti

include(joinpath(@__DIR__, "..", "..", "src", "profily", "body_TR4HR_CSN425720.jl"))

function _bbox(body)
    xs = first.(body)
    ys = last.(body)
    return (minimum(xs), maximum(xs), minimum(ys), maximum(ys))
end

function _assert_shifted_shape(base, shifted, dx, dy; atol=1e-10)
    @test length(base) == length(shifted)
    for i in eachindex(base)
        @test shifted[i][1] ≈ base[i][1] + dx atol=atol
        @test shifted[i][2] ≈ base[i][2] + dy atol=atol
    end
end

@testset "body_TR4HR_CSN425720 - zakladni tvar" begin
    prof = StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20x20x2")
    @test prof !== nothing

    body = body_TR4HR_CSN(prof, "ld")
    @test body isa NamedTuple
    @test haskey(body, :obrys)
    @test haskey(body, :otvory)
    @test length(body.obrys) > 100
    @test length(body.otvory) == 1
    @test length(body.otvory[1]) > 100

    xmin, xmax, ymin, ymax = _bbox(body.obrys)
    @test isapprox(xmin, 0.0; atol=1e-9)
    @test isapprox(xmax, prof.a; atol=1e-9)
    @test isapprox(ymin, 0.0; atol=1e-9)
    @test isapprox(ymax, prof.b; atol=1e-9)

    xmini, xmaxi, yini, yaxi = _bbox(body.otvory[1])
    @test isapprox(xmini, prof.t; atol=1e-9)
    @test isapprox(xmaxi, prof.a - prof.t; atol=1e-9)
    @test isapprox(yini, prof.t; atol=1e-9)
    @test isapprox(yaxi, prof.b - prof.t; atol=1e-9)
end

@testset "body_TR4HR_CSN425720 - uchyceni posunuje stejne body" begin
    prof = StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20x20x2")
    base = body_TR4HR_CSN(prof, "ld")
    base_obrys = base.obrys
    base_otvor = base.otvory[1]

    by_anchor = Dict(
        "stred" => (-prof.a / 2, -prof.b / 2),
        "lu" => (0.0, -prof.b),
        "rd" => (-prof.a, 0.0),
        "ru" => (-prof.a, -prof.b),
    )

    for (uchyceni, (dx, dy)) in by_anchor
        shifted = body_TR4HR_CSN(prof, uchyceni)
        @test length(shifted.otvory) == 1
        _assert_shifted_shape(base_obrys, shifted.obrys, dx, dy)
        _assert_shifted_shape(base_otvor, shifted.otvory[1], dx, dy)
    end
end

@testset "body_TR4HR_CSN425720 - neplatne uchyceni" begin
    prof = StrojniSoucasti.profil_TR4HR_CSN425720("TR4HR20x20x2")
    @test_throws ArgumentError body_TR4HR_CSN(prof, "xyz")
end
