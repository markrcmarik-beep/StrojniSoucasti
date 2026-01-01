## Funkce Julia
###############################################################
## Popis funkce:
# Načte informace o závitu podle jeho označení ze standardizované tabulky závitů.
# Podporovány jsou metrické (M) a trapézové (Tr) závity.
# ver: 2025-12-21
## Funkce: zav, text = zavity(s::AbstractString)
## Vzor:
# zav, text = zavity("M10x1.5")
## Vstupní proměnné:
# s - Řetězec označení závitu (např. "M10x1.5" nebo "Tr20x4").
## Výstupní proměnné:
# zav  - Slovník s informacemi o závitu (typ, norma, rozměry).
#   :typ - Typ závitu (např. "metrický" nebo "trapézový").
#   :norma - Použitá norma závitu.
#   :zavit - Normalizované označení závitu.
#   :D - Jmenovitý průměr závitu (s jednotkou mm).
#   :d - Malý průměr závitu (s jednotkou mm).
#   :p - Stoupání závitu (s jednotkou mm).
# text - Textový výpis informací o závitu.
## Použité balíčky:
# Unitful
## Použité uživatelské funkce:
# sprdsheet2velkst(), sprsheetRef(), sprsheet2tabl()
## Příklad:
# zav, text = zavity("M10x1.5")
#   vrátí slovník s informacemi o metrickém závitu M10x1.5 a textový výpis
# => zav = Dict(:typ=>"metrický", :norma=>"ISO 68-1 / ISO 724", :zavit=>"M10x1.5", :D=>10mm, :d=>8.160mm, :p=>1.5mm, ...),
# => text = "Závit: metrický ISO\nOznačení: M10x1.5\n..."
################################################################
## Použité proměnné vnitřní:
#
using SpravaSouboru, Unitful

function zavity(s::AbstractString)
    s = replace(strip(s), "," => ".")
    text = IOBuffer()
    cesta01 = dirname(@__FILE__) # Získá cestu k adresáři aktuálního souboru
    podslozka = "zavity" # Podadresář s testovacími soubory
    cesta = joinpath(cesta01, podslozka) # Úplná cesta k souboru
    soubor1 = "zavity.ods" # Název testovacího souboru .ods
    
    # Zpracování zadaného označení závitu
    # =========================================================================

    # ================= METRICKÝ ZÁVIT =========================
    if (m = match(r"^M(\d+)(x([\d\.]+))?$", s)) !== nothing
        
        if m.captures[3] === nothing
            # Pokud není stoupání zadáno, použije se standardní hodnota
            s = "M" * m.captures[1]
        else
            s = "M" * m.captures[1] * "x" * m.captures[3]
        end
        
        list_nazev1 = "M" # Místo list{listCi}
        souborDat1 = "zavity_M.jld2" # Změna na standardní Julia kešovací formát
        zavitydata = nacti_zavity_data(cesta, soubor1, souborDat1, list_nazev1, s)

        zav = Dict{Symbol,Any}()
        zav[:typ] = "metrický"
        zav[:typ_info] = "Typ závitu"
        zav[:norma] = "ISO 68-1 / ISO 724"
        zav[:norma_info] = "Použitá norma závitu"
        zav[:zavit] = zavitydata[1]
        zav[:zavit_info] = "Normalizované označení závitu"
        zav[:D] = zavitydata[3]
        zav[:D_info] = "Jmenovitý průměr závitu"
        zav[:d] = zavitydata[6]
        zav[:d_info] = "Malý (jádrový) průměr závitu"
        zav[:d2] = zavitydata[4]
        zav[:d2_info] = "Střední průměr závitu"
        zav[:d1] = zavitydata[5]
        zav[:d1_info] = "Velký průměr závitu"
        zav[:P] = zavitydata[2]
        zav[:P_info] = "Stoupání závitu"

        println(text, zav[:typ], "   ", zav[:typ_info])
        println(text, zav[:norma], "   ", zav[:norma_info])
        println(text, zav[:zavit],"   ", zav[:zavit_info])
        println(text, "D = ", zav[:D], "   ", zav[:D_info])
        println(text, "d1 = ", zav[:d1], "   ", zav[:d1_info])
        println(text, "d2 = ", zav[:d2], "   ", zav[:d2_info])
        println(text, "d = ", zav[:d], "   ", zav[:d_info])
        println(text, "P = ", zav[:P], "   ", zav[:P_info])

        return zav, String(take!(text))

    # ================= TRAPÉZOVÝ ZÁVIT ========================
    elseif (m = match(r"^Tr(\d+)(x([\d\.]+))?$", s)) !== nothing
        println(m[1]," ", m[2], " ", m[3])
        #display(m.captures)
        
        if m.captures[3] === nothing
            # Pokud není stoupání zadáno, použije se standardní hodnota
            s = "Tr" * m.captures[1]
        else
            s = "Tr" * m.captures[1] * "x" * m.captures[3]
        end
        println(s)
        list_nazev1 = "Tr" # Místo list{listCi}
        souborDat1 = "zavity_Tr.jld2" # Změna na standardní Julia kešovací formát
        zavitydata = nacti_zavity_data(cesta, soubor1, souborDat1, list_nazev1, s)

        zav = Dict{Symbol,Any}()
        zav[:typ] = "trapézový"
        zav[:typ_info] = "Typ závitu"
        zav[:norma] = "ISO 2901 / ISO 2902"
        zav[:norma_info] = "Použitá norma závitu"
        zav[:zavit] = zavitydata[1]
        zav[:zavit_info] = "Normalizované označení závitu"
        zav[:D] = zavitydata[3]
        zav[:D_info] = "Jmenovitý průměr závitu"
        zav[:d] = zavitydata[6]
        zav[:d_info] = "Malý (jádrový) průměr závitu"
        zav[:d2] = zavitydata[4]
        zav[:d2_info] = "Střední průměr závitu"
        zav[:d1] = zavitydata[5]
        zav[:d1_info] = "Velký průměr závitu"
        zav[:P] = zavitydata[2]
        zav[:P_info] = "Stoupání závitu"

        println(text, zav[:typ], "   ", zav[:typ_info])
        println(text, zav[:norma], "   ", zav[:norma_info])
        println(text, zav[:zavit],"   ", zav[:zavit_info])
        println(text, "D = ", zav[:D], "   ", zav[:D_info])
        println(text, "d1 = ", zav[:d1], "   ", zav[:d1_info])
        println(text, "d2 = ", zav[:d2], "   ", zav[:d2_info])
        println(text, "d = ", zav[:d], "   ", zav[:d_info])
        println(text, "P = ", zav[:P], "   ", zav[:P_info])

        return zav, String(take!(text))
    else
        error("Neznámé nebo nepodporované označení závitu: $s")
    end
end

function nacti_zavity_data(
    cesta::AbstractString,
    soubor1::AbstractString,
    souborDat1::AbstractString,
    list_nazev1::AbstractString,
    oznaceni::AbstractString
)
    koncova_adresa1 = sprdsheet2velkst(
        joinpath(cesta, soubor1),
        list_nazev1,
        druh="poslední"
    )
    STRTradk = 3
    rozsahTabulka = "A$(STRTradk):$koncova_adresa1"

    _, _, TBL1 = sprsheet2tabl(
        cesta,
        [soubor1, souborDat1],
        list_nazev1,
        ["A2", "D2", rozsahTabulka]
    )
    for row in eachrow(TBL1)
        row_oznaceni = replace(string(row[1]), "," => ".")
        #display(row_oznaceni)
        if row_oznaceni == oznaceni
            return row
        end
    end
    error("Závit $oznaceni nebyl nalezen v tabulce listu $list_nazev1")
end