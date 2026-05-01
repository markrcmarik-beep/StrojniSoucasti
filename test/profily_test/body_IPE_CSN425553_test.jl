# ver: 2026-05-01
using Test
using StrojniSoucasti

include(joinpath(@__DIR__, "..", "..", "src", "profily", "body_IPE_CSN425553.jl"))

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

@testset "body_IPE_CSN425553 - zakladni tvar" begin
    prof = StrojniSoucasti.profil_IPE_CSN425553("IPE 100")
    @test prof !== nothing

    body = body_IPE_CSN425553(prof, "ld")
    @test body isa NamedTuple
    @test haskey(body, :obrys)
    @test haskey(body, :otvory)
    @test length(body.obrys) > 100
    @test isempty(body.otvory)

    xmin, xmax, ymin, ymax = _bbox(body.obrys)
    @test isapprox(xmin, 0.0; atol=1e-9)
    @test isapprox(xmax, prof.b; atol=1e-9)
    @test isapprox(ymin, 0.0; atol=1e-9)
    @test isapprox(ymax, prof.h; atol=1e-9)
end

@testset "body_IPE_CSN425553 - uchyceni posunuje stejne body" begin
    prof = StrojniSoucasti.profil_IPE_CSN425553("IPE 100")
    base = body_IPE_CSN425553(prof, "ld").obrys

    by_anchor = Dict(
        "stred" => (-prof.b / 2, -prof.h / 2),
        "lu" => (0.0, -prof.h),
        "rd" => (-prof.b, 0.0),
        "ru" => (-prof.b, -prof.h),
    )

    for (uchyceni, (dx, dy)) in by_anchor
        shifted = body_IPE_CSN425553(prof, uchyceni).obrys
        _assert_shifted_shape(base, shifted, dx, dy)
    end
end

@testset "body_IPE_CSN425553 - neplatne uchyceni" begin
    prof = StrojniSoucasti.profil_IPE_CSN425553("IPE 100")
    @test_throws ArgumentError body_IPE_CSN425553(prof, "xyz")
end
