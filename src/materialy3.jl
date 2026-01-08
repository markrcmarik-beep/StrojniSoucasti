## Funkce Julia
###############################################################
## Popis funkce:
# Vrátí vlastnosti hledaného materiálu dle tabulky
# ver: 2026-01-07
## Funkce: materialy3()
#
## Vzor:
## B, C = materialy3(A)
## Vstupní proměnné:
# A – řetězec s označením materiálu dle ČSN, ISO, DIN, EN nebo 
# značky materiálu (např. "11 500", "11373", "S235JR", "bronz" apod.)
## Výstupní proměnné:
# B – slovník (Dict) s vlastnostmi materiálu (modul pružnosti, 
# mez kluzu, hustota apod.) s jednotkami (Unitful)
#   :CSN, :ISO, :DIN, :EN, :znacka – identifikace materiálu
#   :E – modul pružnosti [GPa]
#   :G – modul smyku [GPa]
#   :Re – mez kluzu [MPa]
#   :Rm – mez pevnosti [MPa]
#   :rho – hustota [kg/m³]
#   :alfa – součinitel teplotní roztažnosti [1/K]
#   :popis – textový popis materiálu
#   :stav – stav materiálu (např. "tvářený za studena" apod.)
#   + další odvozené vlastnosti, pokud jsou dostupné
# C – textový řetězec se shrnutím materiálu (pro identifikaci)
## Použité balíčky
# SpravaSouboru, Unitful
## Použité uživatelské funkce:
# sprdsheet2velkst(), sprsheetRef(), sprsheet2tabl()
## Příklad:
# B, C = materialy3("11 373")
#   vrátí vlastnosti materiálu "11 373" a textové shrnutí materiálu
#  => B = Dict(:CSN=>"11 373", :E=>210 GPa, :Re=>235 MPa, ...), 
#  => C = "Materiál: 11 373"
# materialy3("bronz")
#   vrátí vlastnosti materiálu "bronz" a vytiskne je na obrazovku
#  => B = Dict(:znacka=>"bronz", :E=>100 GPa, :Re=>200 MPa, ...), 
#  => C = "Materiál: bronz"
# materialy3("unknown")
#   vyvolá chybu, protože materiál neexistuje v tabulce
#  => Error: Zadaný materiál 'unknown' nebyl nalezen.

###############################################################
## Použité proměnné vnitřní:
#
using SpravaSouboru, Unitful

function materialy3(A::AbstractString)
    cesta01 = dirname(@__FILE__)
    podslozka = "materialy3"
    soubor1 = "materialy3.ods"
    souborDat = "materialy3.jld2"
    listname = "material"
    STRTradk = 3
    rozsah = sprdsheet2velkst(joinpath(cesta01, podslozka, soubor1), listname) # Celkový rozsah tabulky. např: A1:W90
    koncova_adresa = last(split(rozsah, ':')) # Koncová adresa. např: W90
    W1 = sprsheetRef(koncova_adresa) # Souřadnice poslední buňky [Y, X]. např: [90, 23]
    W1_nova = sprsheetRef([STRTradk, W1[2]]) # Poslední buňka nadpisu vlevo. např: W3
    rozsahNadpis = "A$(STRTradk):$W1_nova" # Rozsah nadpisu. např: A3:W3
    rozsahTabulka = "A5:$koncova_adresa" # Rozsah tabulky. např: A5:W90
    hdr_mat, _, raw_tbl = sprsheet2tabl(
        joinpath(cesta01, podslozka),
        [soubor1, souborDat], listname,
        [rozsahNadpis, rozsahNadpis, rozsahTabulka]
    ) # hdr_mat: Matice "Any". např: Any["CSN" "ISO" "DIN" "EN" "AISI" "znacka" "E" "G" "Re" "Re_max" "Rm" "Rm_max" "ny" "rho" "alfa" "popis" "stav" "vlastnosti a použití" "svaritelnost" "použití" "kalitelnost" nothing nothing]
# raw_tbl: Matice "Any". např: Any["-" 5511 "-" "-" "-" "-" 210 81 500 "-" 700 "-" 0.3 7850 1.1e-5 "konstrukční ocel" "-" "-" "-" "-" nothing nothing nothing; "-" "8.8" "-" "-" "-" "-" 210 81 640
    headers = vec(hdr_mat) # Převede na vektor. např: Any["CSN", "ISO", "DIN", "EN", "AISI", "znacka", "E", "G", "Re", "Re_max", "Rm", "Rm_max", "ny", "rho", "alfa", "popis",
    # sanitizace hlaviček
    function sanitize_header(s)
        s2 = replace(string(s), r"\s+" => "_")
        s2 = replace(s2, r"[^A-Za-z0-9_]" => "_")
        if isempty(s2)
            s2 = "col"
        end
        if occursin(r"^[0-9]", s2)
            s2 = "_" * s2
        end
        return Symbol(s2)
    end
    col_syms = [sanitize_header(h) for h in headers]
    if ndims(raw_tbl) == 1
        raw_tbl = reshape(raw_tbl, :, 1)
    end
    nrows, ncols = size(raw_tbl)
    cols = [raw_tbl[:, j] for j in 1:ncols]
    TBL = (; Pair.(col_syms, cols)...)
    # hledání řádku podle materiálu
    function find_row_by_value(vec, val)
        for (i, x) in enumerate(vec)
            xs = lowercase(replace(string(x), " " => ""))
            if xs == lowercase(replace(val, " " => ""))
                return i
            end
        end
        return nothing
    end
    row = nothing
    for key in (:CSN, :ISO, :DIN, :EN, :znacka)
        if haskey(TBL, key)
            r = find_row_by_value(TBL[key], A)
            if r !== nothing
                row = r
                break
            end
        end
    end
    row === nothing && error("Zadaný materiál '$A' nebyl nalezen.")
    # výstupní slovník jako Symbol → Any
    DATA = Dict{Symbol, Any}()
    function set_if_present(sym)
        if haskey(TBL, sym)
            val = TBL[sym][row]
            if !(ismissing(val) || isempty(string(val)))
                DATA[sym] = val
            end
        end
    end
    for s in (:CSN, :ISO, :DIN, :EN, :znacka,
              :E, :G, :Re, :Re_max, :Rm, :Rm_max, :ny, :rho, :alfa, 
              :popis, :stav, :vlastnosti, :svaritelnost, :pouziti, 
              :kalitelnost, :Re_zu1, :Re_zu1_max, :A5)
        set_if_present(s)
    end
    # převod na čísla
    function try_number(x)
        try
            return parse(Float64, string(x))
        catch
            return x
        end
    end
    # jednotky
    for (key, unit) in [
        (:E, u"GPa"),
        (:G, u"GPa"),
        (:Re, u"MPa"),
        (:Re_max, u"MPa"),
        (:Rm, u"MPa"),
        (:Rm_max, u"MPa"),
        (:rho, u"kg/m^3"),
        (:alfa, u"1/K"),
        (:Re_zu1, u"MPa"),
        (:Re_zu1_max, u"MPa")
    ]
        if haskey(DATA, key) && try_number(DATA[key]) isa Real
            DATA[key] = try_number(DATA[key]) * unit
        end
    end
    # Definice popisných informací k vybraným vlastnostem
    info_map = [
        (:E_info,       "Modul pružnosti v tahu (Youngův modul)"),
        (:G_info,       "Modul pružnosti v krutu"),
        (:Re_info,      "Mez kluzu"),
        (:Rm_info,      "Mez pevnosti"),
        (:ny_info,      "Poissonův poměr"),
        (:rho_info,     "hustota"),
        (:alfa_info,    "Koeficient tepelné roztažnosti")
    ]
    # Uložení informací do slovníku DATA, pokud je hlavní vlastnost přítomna
    for (infokey, text) in info_map
        # Získáme název základní vlastnosti odstraněním "_info" (např. :E_info -> :E)
        basekey = Symbol(replace(string(infokey), "_info" => ""))
        # Informaci uložíme pouze v případě, že materiál danou vlastnost skutečně má
        if haskey(DATA, basekey)
            DATA[infokey] = text
        end
    end

    return DATA, StrojniSoucasti.materialy3text(DATA)
end