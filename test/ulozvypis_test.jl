# ver: 2026-03-08
# Testovací skript pro funkci ulozvypis.jl

using StrojniSoucasti, Test

@testset "ulozvypis" begin
    @testset "keyword volání" begin
        mktempdir() do dir
            text = "Testovaci vystup"
            fullpath = ulozvypis(text; cesta=dir, soubor="ulozvypistest")

            @test isfile(fullpath)
            @test endswith(fullpath, "ulozvypistest.txt")
            @test read(fullpath, String) == text
        end
    end

    @testset "poziční volání (3 argumenty)" begin
        mktempdir() do dir
            text = "Ahoj"
            fullpath = ulozvypis(text, dir, "vysledek")

            @test isfile(fullpath)
            @test endswith(fullpath, "vysledek.txt")
            @test read(fullpath, String) == text
        end
    end

    @testset "poziční volání (4 argumenty)" begin
        mktempdir() do dir
            text = "Obsah se uklada"
            fullpath = ulozvypis(text, dir, "vystup.txt", ".txt")

            @test isfile(fullpath)
            @test endswith(fullpath, "vystup.txt")
            @test read(fullpath, String) == text
        end
    end

    @testset "nepodporovaná koncovka" begin
        mktempdir() do dir
            @test_throws ErrorException ulozvypis("text"; cesta=dir, soubor="x", koncovka=".csv")
        end
    end
end
