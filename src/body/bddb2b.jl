## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Z bodu A vede úsečku o délce a. Z bodu B vede úsečku o délce b. 
# Obě úsečky se protínají v bodě C. Vypočítá souřadnice bodu C.
# Úhel mezi úsečkami není zadán, ale je určen implicitně polohou 
# bodů A, B a délkami a, b. Pokud existují dvě řešení, vrací obě.
# Pokud řešení neexistuje, vrací prázdný vektor.
## Pracuje v rovině (x, y).
#
# ver: 2026-04-30
## Funkce: bddb2b()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/body/bddb2b.jl
#
## Vzor:
## C = bddb2b(A, a, b, B)
## Vstupní proměnné:
# A - souřadnice bodu A (tuple s dvěma prvky)
# a - délka úsečky AC (kladné číslo)
# b - délka úsečky BC (kladné číslo)
# B - souřadnice bodu B (tuple s dvěma prvky)
## Výstupní proměnné:
# C - souřadnice bodu C. Může být jeden nebo dva body, v závislosti 
# na konfiguraci (tuple s dvěma prvky nebo pole s dvěma tuple). V případě
# neexistence řešení se vrací prázdný vektor.
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
