## Funkce Julia
###############################################################
## Popis funkce:
# Vrátí vlastnosti hledaného materiálu dle tabulky
# ver: 2025-12-12
## Funkce: materialy()
#
## Vzor:
## B, C = materialy(A)
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
# B, C = materialy("11 373")
#   vrátí vlastnosti materiálu "11 373" a textové shrnutí materiálu
#  => B = Dict(:CSN=>"11 373", :E=>210 GPa, :Re=>235 MPa, ...), 
#  => C = "Materiál: 11 373"
# materialy("bronz"; tisk=true)
#   vrátí vlastnosti materiálu "bronz" a vytiskne je na obrazovku
#  => B = Dict(:znacka=>"bronz", :E=>100 GPa, :Re=>200 MPa, ...), 
#  => C = "Materiál: bronz"
# materialy("unknown")
#   vyvolá chybu, protože materiál neexistuje v tabulce
#  => Error: Zadaný materiál 'unknown' nebyl nalezen.

###############################################################
## Použité proměnné vnitřní:
#
using SpravaSouboru, Unitful

function materialy(A::AbstractString; tisk::Bool=false)
    cesta01 = dirname(@__FILE__)
    podslozka = "materialy"
    soubor1 = "materialy.ods"
    souborDat = "materialy.jld2"
    listname = "material"
    STRTradk = 3

    rozsah = sprdsheet2velkst(joinpath(cesta01, podslozka, soubor1), listname)
    koncova_adresa = last(split(rozsah, ':'))
    W1 = sprsheetRef(koncova_adresa)
    W1_nova = sprsheetRef([STRTradk, W1[2]])
    rozsahNadpis = "A$(STRTradk):$W1_nova"
    rozsahTabulka = "A5:$koncova_adresa"

    hdr_mat, _, raw_tbl = sprsheet2tabl(
        joinpath(cesta01, podslozka),
        [soubor1, souborDat],
        listname,
        [rozsahNadpis, rozsahNadpis, rozsahTabulka]
    )

    headers = vec(hdr_mat)

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

    for s in (:CSN, :ISO, :DIN, :EN, :znacka, :ny,
              :E, :G, :Re, :Rm, :rho, :alfa, :popis, :stav)
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
        (:Rm, u"MPa"),
        (:rho, u"kg/m^3"),
        (:alfa, u"1/K")
    ]
        if haskey(DATA, key) && try_number(DATA[key]) isa Real
            DATA[key] = try_number(DATA[key]) * unit
        end
    end

    # popis
    C = "Materiál: " * (get(DATA, :CSN, get(DATA, :znacka, A)))

    if tisk
        println("─── Materiál ───")
        for (k, v) in sort(collect(DATA))
            println(rpad(string(k), 12), " = ", v)
        end
    end

    return DATA, C
end