# ver: 2026-08-19
## Funkce: tolerance()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/tolerance/toleranceHODN.jl
## Použité balíčky:
# TOML
## Použité uživatelské funkce:
#
###############################################################
## Použité proměnné vnitřní:
#
using TOML

#const TOL_IT = TOML.parsefile(joinpath(@__DIR__, "toleranceIT.toml"))
#const TOL_POLE = TOML.parsefile(joinpath(@__DIR__, "tolerancePOLE1.toml"))

function toleranceHODN(nominal::Real, zone::AbstractString, grade::AbstractString)

#---------------------------------------------------------------------
# pomocné funkce

#---------------------------------------------------------------------
# pomocné funkce konec
    nominal = Float64(nominal) # převod jmenovitého rozměru na Float64
    zone = strip(zone) # odstranění mezer ze zóny
    grade_str = strip(grade) # odstraneni mezer z grade stringu
    gradeIT = replace(grade_str, "01" => "-1") # stupeň přesnosti -1 - 18
    gradeIT = parse(Int, gradeIT) # převod stupně na Int
    TOL_IT = TOML.parsefile(joinpath(@__DIR__, "toleranceIT.toml"))
dira = false
hridel = false
    if all(isuppercase, zone)
        druh = "díra"
        dira = true
    elseif all(islowercase, zone)
        druh = "hřídel"
        hridel = true
    else
        error("Zóna musí být velká (díra) nebo malá (hřídel).")
    end
#---------------------------------------------------------------------
# IT
    # Vyhledání klíče rozsahu (size_key) pro jmenovitý rozměr
    size_keyIT = ""
    found_size_keyIT = false
    for keyIT in TOL_IT["sizesIT"]
        parts = split(keyIT, "-")
        a = parse(Float64, parts[1])
        b = parse(Float64, parts[2])
        if nominal > a && nominal <= b
            size_keyIT = keyIT
            found_size_keyIT = true
            break
        end
    end
    !found_size_keyIT && error("Rozměr $(nominal) mm je mimo rozsah tabulky IT.")
    # Získání hodnoty IT na základě sizeIT_key a grade
    table = TOL_IT[size_keyIT]
    grade_str = string(grade_str)
    haskey(table, grade_str) || error("IT$(grade_str) není v tabulce pro rozsah $(size_key).")
    it_value = table[grade_str] # Získání hodnoty IT z tabulky
#-------------------------------------------------------------------
# ES, EI
    TOL_POLE = TOML.parsefile(joinpath(@__DIR__, "tolerancePOLE1.toml"))
    # Vyhledání klíče rozsahu (size_key) pro jmenovitý rozměr
    size_keyPOLE = ""
    found_size_keyPOLE = false
    for keyPOLE in TOL_POLE["sizesPOLE"]
        parts = split(keyPOLE, "-")
        a = parse(Float64, parts[1])
        b = parse(Float64, parts[2])
        if nominal > a && nominal <= b
            size_keyPOLE = keyPOLE
            found_size_keyPOLE = true
            break
        end
    end

    !found_size_keyPOLE && error("Rozměr $(nominal) mm je mimo rozsah tabulky POLE.")
    # Získání hodnoty z tabulky POLE na základě sizePOLE_key a zone
    table_pole = TOL_POLE[size_keyPOLE]
    #println("table_pole: ", table_pole)
    haskey(table_pole, zone) || error("Zóna $(zone) není v tabulce pro rozsah $(size_keyPOLE).")
    zone_value = table_pole[zone] # Získání hodnoty z tabulky POLE z tabulky
    # Výpočet tolerance
    velkost = length(zone_value)
    dataP = Dict{Symbol,Any}()
    if velkost == 2
        if hridel
            esZone = zone_value["es"] # horní mez tolerance
            eiZone = zone_value["ei"] # horní mez tolerance

        elseif dira
            ESZone = zone_value["ES"] # horní mez tolerance
            EIZone = zone_value["EI"] # horní mez tolerance
        end
    elseif velkost == 3
            itZone = zone_value["IT"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es"] # horní mez tolerance
                    eiZone = zone_value["ei"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES"] # horní mez tolerance
                    EIZone = zone_value["EI"] # horní mez tolerance
                end
            else
                error("Hodnota IT $(gradeIT) není v rozsahu $(itZone) pro zónu $(zone).")
            end
    elseif velkost == 6
            itZone = zone_value["IT1"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es1"] # horní mez tolerance
                    eiZone = zone_value["ei1"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES1"] # horní mez tolerance
                    EIZone = zone_value["EI1"] # horní mez tolerance
                end
            end
            itZone = zone_value["IT2"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es2"] # horní mez tolerance
                    eiZone = zone_value["ei2"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES2"] # horní mez tolerance
                    EIZone = zone_value["EI2"] # horní mez tolerance
                end
            end
        elseif velkost == 9
            itZone = zone_value["IT1"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es1"] # horní mez tolerance
                    eiZone = zone_value["ei1"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES1"] # horní mez tolerance
                    EIZone = zone_value["EI1"] # horní mez tolerance
                end
            end
            itZone = zone_value["IT2"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es2"] # horní mez tolerance
                    eiZone = zone_value["ei2"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES2"] # horní mez tolerance
                    EIZone = zone_value["EI2"] # horní mez tolerance
                end
            end
            itZone = zone_value["IT3"] # hodnota dovolené IT
            itZone = replace(itZone, "01" => "-1")
            casti = split(itZone, "-")
            a1 = parse(Int, casti[1])
            a2 = length(casti) == 2 ? parse(Int, casti[2]) : nothing
            if (a2 === nothing && gradeIT == a1) || (a2 !== nothing && gradeIT >= a1 && gradeIT <= a2)
                if hridel
                    esZone = zone_value["es3"] # horní mez tolerance
                    eiZone = zone_value["ei3"] # horní mez tolerance
                elseif dira
                    ESZone = zone_value["ES3"] # horní mez tolerance
                    EIZone = zone_value["EI3"] # horní mez tolerance
                end
            end
    else
        error("Neznámá struktura zóny v tabulce POLE.")
    end
    IT = it_value
    dataP[:IT] = IT
    if hridel
        if !isa(esZone, String)
            es = esZone
            dataP[:es] = es
        end
        if !isa(eiZone, String)
            ei = eiZone
            dataP[:ei] = ei
        end
        if isa(esZone, String)
            es = StrojniSoucasti.vyhodnot_vyraz(esZone, dataP) # převod stringu na číslo
        end
        if isa(eiZone, String)
            ei = StrojniSoucasti.vyhodnot_vyraz(eiZone, dataP) # převod stringu na číslo
        end
        D1 = nominal+ei
        D2 = nominal+es
    elseif dira
        if !isa(ESZone, String)
            ES = ESZone
            dataP[:ES] = ES
        end
        if !isa(EIZone, String)
            EI = EIZone
            dataP[:EI] = EI
        end
        if isa(ESZone, String)
            ES = StrojniSoucasti.vyhodnot_vyraz(ESZone, dataP) # převod stringu na číslo
        elseif !isa(EIZone, String)
            EI = StrojniSoucasti.vyhodnot_vyraz(EIZone, dataP) # převod stringu na číslo
        end
        D1 = nominal+EI
        D2 = nominal+ES
    end
    Dmin = min(D1, D2)
    Dmax = max(D1, D2)
#----------------------------------------------------------------------
# výstupní
    VV = Dict{Symbol,Any}(
        :druh => druh,
        :druh_info => "druh tolerance (díra/hřídel)",
        :rozsahIT => size_keyIT,
        :rozsahIT_info => "rozsah jmenovitého rozměru dle IT",
        :rozsahPOLE => size_keyPOLE,
        :rozsahPOLE_info => "rozsah jmenovitého rozměru dle POLE",
        :stupen => grade_str,
        :stupen_info => "stupeň tolerance",
        :IT => it_value,
        :IT_info => "hodnota IT pro daný rozsah a stupeň",
        :nominal => nominal,
        :nominal_info => "jmenovitý rozměr",
        :zone => zone,
        :zone_info => "zóna tolerance (velká/malá)",
        :min => Dmin,
        :min_info => "průměr min",
        :max => Dmax,
        :max_info => "průměr max"
    )
    if dira
        VV[:ES] = ES
        VV[:EI] = EI
        VV[:es] = nothing
        VV[:ei] = nothing
    elseif hridel
        VV[:es] = es
        VV[:ei] = ei
        VV[:ES] = nothing
        VV[:EI] = nothing
    end

    return VV
end
