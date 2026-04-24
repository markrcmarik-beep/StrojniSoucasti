## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet plochy obecneho tvaru (polygonu)
# pomoci bodu na obrysu. Umoznuje i vstup ve tvaru
# vnejsi obrys + jeden nebo vice vnitrnich otvoru.
# Sdilene helpery v tomto souboru
# pouzivaji i dalsi funkce v samostatnych souborech.
# ver: 2026-04-24
## Funkce: polygon2plocha()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/polygon2plocha.jl
#
## Vzor:
## vystupni_promenne = polygon2plocha(body)
## Vstupní proměnné:
# body - Body na obrysu polygonu, zadane jako vektor bodu (x, y) nebo jako matice N x 2.
## Výstupní proměnné:
# vystupni_promenne - Plocha polygonu (absolutni hodnota, bez ohledu na smer bodu).
## Použité balíčky
#
## Použité uživatelské funkce:
# _polygon_metrics, _max_radius_from_centroid, _polygon_point_count, _polygon_point, _point_xy
## Příklad:
# S = polygon2plocha([(0, 0), (4, 0), (4, 3), (0, 3)]) # => 12.0
# Neplatne vstupy:
# polygon2plocha([(0, 0), (1, 0)]) # => ArgumentError: Pro vypocet zadejte alespon 3 body.
# polygon2plocha([0 0 0; 1 1 1; 2 2 2]) # => ArgumentError: Matice bodu musi mit presne 2 sloupce (x, y).
# polygon2plocha([(0, 0, 0), (1, 0, 0), (1, 1, 0)]) # => ArgumentError: Kazdy bod musi mit presne 2 souradnice (x, y).
###############################################################

function polygon2plocha(body::Union{AbstractVector,AbstractMatrix})
    return polygon_metrics(body).S
end

function polygon2plocha(body::NamedTuple{(:obrys, :otvory)})
    S = polygon_metrics(body.obrys).S
    for otvor in _plochaBodu_normalizuj_otvory(body.otvory)
        S -= polygon_metrics(otvor).S
    end
    return S
end

function _plochaBodu_normalizuj_otvory(otvory::AbstractMatrix)
    return (otvory,)
end

function _plochaBodu_normalizuj_otvory(otvory::Union{AbstractVector,Tuple})
    if isempty(otvory)
        return ()
    end
    first_item = first(otvory)
    if _plochaBodu_je_bod(first_item)
        return (otvory,)
    end
    for otvor in otvory
        if !(otvor isa AbstractVector || otvor isa AbstractMatrix || otvor isa Tuple)
            throw(ArgumentError("Kazdy otvor musi byt polygon (vektor bodu nebo matice Nx2)."))
        end
    end
    return otvory
end

function _plochaBodu_normalizuj_otvory(otvory)
    throw(ArgumentError("`otvory` musi byt polygon nebo kolekce polygonu."))
end

_plochaBodu_je_bod(p::NTuple{2,Any}) = true
_plochaBodu_je_bod(p::Tuple) = length(p) == 2
_plochaBodu_je_bod(p::AbstractVector) = length(p) == 2
_plochaBodu_je_bod(::Any) = false
