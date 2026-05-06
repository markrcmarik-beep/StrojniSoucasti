## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vyřeší mechanické veličiny pro různé tvary dle zkratky označení.
# ver: 2026-05-06
## Funkce: profilyvlcn()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/profilyvlcn.jl
#
## Vzor:
## (rozmer, text) = profilyvlcn(tvar::Dict, velicina::Symbol; natoceni=0)
## Vstupní proměnné:
# tvar – slovník (Dict) s informacemi o tvaru, např.:
#    Dict("info" => "PLO", "a" => 20u"mm", "b" => 10u"mm")
#    Dict("info" => "KR", "D" => 30u"mm")
#    Dict("info" => "TRKR", "D" => 30u"mm", "d" => 20u"mm")
#    Dict("info" => "4HR", "a" => 20u"mm")
#    Dict("info" => "6HR", "s" => 20u"mm")
#    Dict("info" => "TR4HR", "a" => 20u"mm", "b" => 10u"mm", "t" => 4u"mm")
# velicina – hledaná veličina: 
#       S - Plocha průřezu [mm²]
#       Ip - Polární moment [mm⁴]
#       Wk - Průřezový modul v krutu [mm³]
#       Ix - Kvadratický moment [mm⁴]
#       Imin - Kvadratický moment minimální [mm⁴]
#       Wo - Průřezový modul v ohybu [mm³]
# natoceni – úhel natočení [rad], volitelný (parametr pro Ix a Wo)
## Výstupní proměnné:
# rozmer – hodnota veličiny s jednotkami (Unitful)
# text – vzorec použitý pro výpočet (string)
## Použité balíčky
# Unitful
## Použité uživatelské funkce:
# StrojniSoucasti.profilyvlcnS(), StrojniSoucasti.profilyvlcnIp(), 
# StrojniSoucasti.profilyvlcnWk(), StrojniSoucasti.profilyvlcnIx(), 
# StrojniSoucasti.profilyvlcnIminImax(), StrojniSoucasti.profilyvlcnWo()
## Příklad:
# tvar = Dict("info" => "KR", "D" => 30u"mm") # Definice tvaru kruhové tyče o průměru 30 mm
# S, vzorec = profilyvlcn(tvar, :S) # Plocha kruhové tyče
#   vrátí plochu a použitý vzorec
#   => S = 706.8583470577034 mm², vzorec = "π*(D/2)²"
#
###############################################################
## Použité proměnné vnitřní:
# S_hod, S_str, Ip_hod, Ip_str, Wk_hod, Wk_str, Ix_hod, Ix_str, 
# Iy_hod, Iy_str, Ixy_hod, Ixy_str, Imin_hod, Imin_str, Imax_hod, 
# Imax_str, Wo_hod, Wo_str, natoceni, k, getv, info
using Unitful

function profilyvlcn(tvar1::Dict, velicina::Symbol; natoceni=0)
    #info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing
    dopln_jednotku(hod, cil_jednotka) =
        (!(hod isa Unitful.AbstractQuantity) || unit(hod) == Unitful.NoUnits) ? hod * cil_jednotka : hod
    natoceni = mod(natoceni, 2*pi) # Normalizace úhlu do intervalu <0, 2*pi)
    # -----------------------------------------------------------
    # S - Plocha [mm²]
    # -----------------------------------------------------------
    if velicina == :S  # Plocha [mm²]
        if hasproperty(tvar1, :S)
            S_hod = getv(:S)
            S_hod = dopln_jednotku(S_hod, u"mm^2")
            S_str = hasproperty(tvar1, :S_str) ? tvar1[:S_str] : ""
            return S_hod, S_str # Vrátí hodnotu a vzorec pro plochu
        else
            S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1)
            S_hod = dopln_jednotku(S_hod, u"mm^2")
            return S_hod, S_str # Vrátí hodnotu a vzorec pro plochu
        end
    # -----------------------------------------------------------
    # Ip - Polární moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ip  # Polární moment [mm⁴]
        Ip_hod, Ip_str = StrojniSoucasti.profilyvlcnIp(tvar1)
        Ip_hod = dopln_jednotku(Ip_hod, u"mm^4")
        return Ip_hod, Ip_str # Vrátí hodnotu a vzorec pro polární moment
    # -----------------------------------------------------------
    # Wk - Modul v krutu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wk  # Modul v krutu [mm³]
        Wk_hod, Wk_str = StrojniSoucasti.profilyvlcnWk(tvar1, velicina)
        Wk_hod = dopln_jednotku(Wk_hod, u"mm^3")
        return Wk_hod, Wk_str # Vrátí hodnotu a vzorec pro modul v krutu
    # -----------------------------------------------------------
    # Ix - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ix  # Kvadratický moment [mm⁴]
        Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, velicina, natoceni)
        Ix_hod = dopln_jednotku(Ix_hod, u"mm^4")
        return Ix_hod, Ix_str # Vrátí hodnotu a vzorec pro kvadratický moment Ix (natočený o natoceni)
    # -----------------------------------------------------------
    # Iy - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Iy  # Kvadratický moment [mm⁴]
        Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni+pi/2)
        Iy_hod = dopln_jednotku(Iy_hod, u"mm^4")
        return Iy_hod, Iy_str # Vrátí hodnotu a vzorec pro kvadratický moment Iy (natočený o 90°)
    # -----------------------------------------------------------
    # Ixy - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ixy  # Kvadratický moment [mm⁴]
        Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, velicina)
        Ixy_hod = dopln_jednotku(Ixy_hod, u"mm^4")
        return Ixy_hod, Ixy_str # Vrátí hodnotu a vzorec pro kvadratický moment Ixy (natočený o natoceni)
    # -----------------------------------------------------------
    # Imin - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 - √( ((Ix - Iy)/2)² + Ixy² )")
    # -----------------------------------------------------------
    elseif velicina == :Imin  # Kvadratický moment mimimální [mm⁴]
        Imin_hod, Imin_str = StrojniSoucasti.profilyvlcnIminImax(tvar1, velicina)
        Imin_hod = dopln_jednotku(Imin_hod, u"mm^4")
        return Imin_hod, Imin_str # Vrátí hodnotu a vzorec pro kvadratický moment Imin
        # -----------------------------------------------------------
    # Imax - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 + √( ((Ix - Iy)/2)² + Ixy² )")
    # -----------------------------------------------------------
    elseif velicina == :Imax  # Kvadratický moment mimimální [mm⁴]
        Imax_hod, Imax_str = StrojniSoucasti.profilyvlcnIminImax(tvar1, velicina)
        Imax_hod = dopln_jednotku(Imax_hod, u"mm^4")
        return Imax_hod, Imax_str # Vrátí hodnotu a vzorec pro kvadratický moment Imax
    # -----------------------------------------------------------
    # Wo - Průřezový modul v ohybu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wo  # Modul v ohybu [mm³]
        Wo_hod, Wo_str = StrojniSoucasti.profilyvlcnWo(tvar1, velicina, natoceni)
        Wo_hod = dopln_jednotku(Wo_hod, u"mm^3")
        return Wo_hod, Wo_str # Vrátí hodnotu a vzorec pro modul v ohybu Wo (natočený o natoceni)
    # -----------------------------------------------------------
    # Neznámá veličina
    # -----------------------------------------------------------
    else
        error("Neznámá veličina: $velicina")
    end
    return nothing, nothing
end
