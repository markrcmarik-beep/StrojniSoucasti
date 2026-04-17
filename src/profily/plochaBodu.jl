## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vypocet plochy obecneho tvaru (jednoducheho polygonu)
# pomoci bodu na obrysu. Sdilene helpery v tomto souboru
# pouzivaji i dalsi funkce v samostatnych souborech.
# ver: 2026-04-17
## Funkce: plochaBodu()
## Autor: Martin
#
## Cesta uvnitr balicku:
# StrojniSoucasti/src/profily/plochaBodu.jl
#
## Vzor:
## vystupni_promenne = plochaBodu(body)
## Vstupní proměnné:
# body - Body na obrysu polygonu, zadane jako vektor bodu (x, y) nebo jako matice N x 2.
## Výstupní proměnné:
# vystupni_promenne - Plocha polygonu (absolutni hodnota, bez ohledu na smer bodu).
## Použité balíčky
#
## Použité uživatelské funkce:
# _polygon_metrics, _max_radius_from_centroid, _polygon_point_count, _polygon_point, _point_xy
## Příklad:
# S = plochaBodu([(0, 0), (4, 0), (4, 3), (0, 3)]) # => 12.0
# Neplatne vstupy:
# plochaBodu([(0, 0), (1, 0)]) # => ArgumentError: Pro vypocet zadejte alespon 3 body.
# plochaBodu([0 0 0; 1 1 1; 2 2 2]) # => ArgumentError: Matice bodu musi mit presne 2 sloupce (x, y).
# plochaBodu([(0, 0, 0), (1, 0, 0), (1, 1, 0)]) # => ArgumentError: Kazdy bod musi mit presne 2 souradnice (x, y).
###############################################################

function plochaBodu(body::Union{AbstractVector,AbstractMatrix})
    return polygon_metrics(body).S
end
