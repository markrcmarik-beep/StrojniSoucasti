# ver: 2026-11-16
# Testovací skript pro funkci dovoleneNapeti.jl

using StrojniSoucasti, Unitful, Test

@testset "dovoleneNapeti" begin
    @testset "faktory z gammaM.toml" begin
        @test isapprox(
            dovoleneNapeti("tah", "statický"; Re=260u"MPa"),
            200u"MPa";
            rtol=1e-12,
        )
        @test isapprox(
            dovoleneNapeti("tah-střih", "statický-pulzní"; Re=230u"MPa"),
            100u"MPa";
            rtol=1e-12,
        )
    end

    @testset "základní namáhání a zatížení" begin
        namahani = ("tah", "tlak", "střih", "krut", "ohyb", "otlačení")
        zatizeni = ("statický", "pulzní", "dynamický", "rázový")

        for N in namahani, Z in zatizeni
            @testset "$N / $Z" begin
                sigma = dovoleneNapeti(N, Z; Re=250u"MPa")
                @test sigma isa Quantity
                @test unit(sigma) == u"MPa"
                @test ustrip(uconvert(u"MPa", sigma)) > 0
            end
        end
    end

    @testset "výpočet pro statické zatížení" begin
        Re = 250u"MPa"
        ocekavane = (
            ("tah", Re / 1.3),
            ("tlak", Re / 1.3),
            ("ohyb", Re / 1.5),
            ("střih", (Re / sqrt(3)) / 1.5),
            ("krut", (Re / sqrt(3)) / 1.7),
            ("otlačení", Re),
        )
        for (N, sigma_ocek) in ocekavane
            @test isapprox(
                dovoleneNapeti(N, "statický"; Re=Re),
                sigma_ocek;
                rtol=1e-12,
            )
        end
    end

    @testset "kombinace namáhání" begin
        kombinace = (
            ("tah-střih", "statický-statický"),
            ("tlak-střih", "statický-statický"),
            ("tah-střih", "statický-pulzní"),
            ("tah-krut", "statický-statický"),
            ("tlak-krut", "statický-statický"),
            ("tah-ohyb", "statický-statický"),
            ("tlak-ohyb", "statický-statický"),
            ("střih-krut", "statický-statický"),
            ("střih-krut", "pulzní-dynamický"),
            ("střih-ohyb", "statický-statický"),
            ("krut-ohyb", "dynamický-dynamický"),
            ("krut-ohyb", "pulzní-rázový"),
        )

        for (N, Z) in kombinace
            @testset "$N / $Z" begin
                sigma = dovoleneNapeti(N, Z; Re=500u"MPa")
                @test sigma isa Quantity
                @test sigma > 0u"MPa"
            end
        end

        sigma_jednotne = dovoleneNapeti(
            "tah-střih", "statický"; Re=500u"MPa",
        )
        sigma_dvojite = dovoleneNapeti(
            "tah-střih", "statický-statický"; Re=500u"MPa",
        )
        @test sigma_jednotne == sigma_dvojite
    end

    @testset "výchozí zatížení, jednotky a změna Re" begin
        @test dovoleneNapeti("otlačení"; Re=600u"MPa") ==
              dovoleneNapeti("otlačení", "statický"; Re=600u"MPa")

        sigma_s_jednotkou = dovoleneNapeti("tah", "statický"; Re=250u"MPa")
        sigma_bez_jednotky = dovoleneNapeti("tah", "statický"; Re=250)
        @test sigma_bez_jednotky isa Quantity
        @test sigma_bez_jednotky == sigma_s_jednotkou

        sigma_nizke = dovoleneNapeti("tah", "statický"; Re=200u"MPa")
        sigma_vysoke = dovoleneNapeti("tah", "statický"; Re=300u"MPa")
        @test sigma_nizke < sigma_vysoke
    end

    @testset "vyšší zatížení snižuje dovolené napětí" begin
        for N in ("tah", "tlak", "střih", "krut", "ohyb", "otlačení")
            sigma = map(
                Z -> dovoleneNapeti(N, Z; Re=250u"MPa"),
                ("statický", "pulzní", "dynamický", "rázový"),
            )
            @test sigma[1] > sigma[2] > sigma[3] > sigma[4]
        end
    end

    @testset "materiálové vlastnosti" begin
        ocel = materialy("S235JRG1")
        @test ocel isa StrojniSoucasti.MaterialOcel
        @test dovoleneNapeti("tah", "statický"; mat=ocel) ≈
              dovoleneNapeti("tah", "statický"; Re=ocel.Re)

        litina = materialy("422420")
        @test !isnothing(litina)
        @test isapprox(
            dovoleneNapeti("tah", "statický"; mat=litina),
            (200 / 1.3)u"MPa";
            rtol=1e-12,
        )
        @test isapprox(
            dovoleneNapeti("tlak", "statický"; mat=litina),
            (800 / 1.3)u"MPa";
            rtol=1e-12,
        )
        @test isapprox(
            dovoleneNapeti("střih", "statický"; mat=litina),
            ((200 / sqrt(3)) / 1.5)u"MPa";
            rtol=1e-12,
        )

        mat_s_tau = (; Rm_tah=200.0, tau_lim=100.0)
        @test isapprox(
            dovoleneNapeti("střih", "statický"; mat=mat_s_tau),
            (100 / 1.5)u"MPa";
            rtol=1e-12,
        )

        mat_bez_tau = (; Rm_tah=200.0, Rm_tlak=800.0)
        @test isapprox(
            dovoleneNapeti("střih", "statický"; mat=mat_bez_tau),
            ((200 / sqrt(3)) / 1.5)u"MPa";
            rtol=1e-12,
        )

        neznamy_material = materialy("NEEXISTUJICI_MATERIAL")
        @test isnothing(neznamy_material)
        @test_throws ErrorException dovoleneNapeti(
            "tah", "statický"; mat=neznamy_material,
        )
    end

    @testset "neplatné vstupy" begin
        @test_throws ErrorException dovoleneNapeti(
            "zkrutování", "statický"; Re=250u"MPa",
        )
        @test_throws ErrorException dovoleneNapeti(
            "tah", "cyklické"; Re=250u"MPa",
        )
        @test_throws ErrorException dovoleneNapeti(
            "tah", "statický"; Re=250u"MPa", mat=(; Re=250.0),
        )
    end
end

nothing
