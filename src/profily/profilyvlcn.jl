## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vyřeší mechanické veličiny pro různé tvary dle zkratky označení.
# ver: 2026-02-01
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
#
## Příklad:
# tvar = Dict("info" => "KR", "D" => 30u"mm") # Definice tvaru kruhové tyče o průměru 30 mm
# S, vzorec = profilyvlcn(tvar, :S) # Plocha kruhové tyče
#   vrátí plochu a použitý vzorec
#   => S = 706.8583470577034 mm², vzorec = "π*(D/2)²"
#
###############################################################
## Použité proměnné vnitřní:
#

using Unitful

function profilyvlcn(tvar1::Dict, velicina::Symbol; natoceni=0)
    #info = tvar1[:info] # Získání informace o tvaru
    # Pomocné funkce na čtení parametrů
    getv(k) = haskey(tvar1, k) ? tvar1[k] : missing # Vrátí hodnotu nebo missing
    if natoceni > 2*pi
        natoceni = natoceni - 2*pi
    end
    # -----------------------------------------------------------
    # S - Plocha [mm²]
    # -----------------------------------------------------------
    if velicina == :S  # Plocha [mm²]
        S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1, velicina)
        return S_hod, S_str
    # -----------------------------------------------------------
    # Ip - Polární moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ip  # Polární moment [mm⁴]
        Ip_hod, Ip_str = StrojniSoucasti.profilyvlcnIp(tvar1, velicina)
        return Ip_hod, Ip_str
    # -----------------------------------------------------------
    # Wk - Modul v krutu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wk  # Modul v krutu [mm³]
        Wk_hod, Wk_str = StrojniSoucasti.profilyvlcnWk(tvar1, velicina)
        return Wk_hod, Wk_str
    # -----------------------------------------------------------
    # Ix - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ix  # Kvadratický moment [mm⁴]
        Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnIx(tvar1, velicina, natoceni)
        return Ix_hod, Ix_str
    # -----------------------------------------------------------
    # Iy - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Iy  # Kvadratický moment [mm⁴]
        Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnIx(tvar1, :Ix, natoceni+pi/2)
        return Iy_hod, Iy_str
    # -----------------------------------------------------------
    # Ixy - Kvadratický moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Ixy  # Kvadratický moment [mm⁴]
        Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnIx(tvar1, velicina)
        return Ixy_hod, Ixy_str
    # -----------------------------------------------------------
    # Imin - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 - √( ((Ix - Iy)/2)² + Ixy² )")
    # -----------------------------------------------------------
    elseif velicina == :Imin  # Kvadratický moment mimimální [mm⁴]
        Imin_hod, Imin_str = StrojniSoucasti.profilyvlcnIminImax(tvar1, velicina)
        return Imin_hod, Imin_str
        # -----------------------------------------------------------
    # Imax - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 + √( ((Ix - Iy)/2)² + Ixy² )")
    # -----------------------------------------------------------
    elseif velicina == :Imax  # Kvadratický moment mimimální [mm⁴]
        Imax_hod, Imax_str = StrojniSoucasti.profilyvlcnIminImax(tvar1, velicina)
        return Imax_hod, Imax_str
    # -----------------------------------------------------------
    # Wo - Průřezový modul v ohybu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wo  # Modul v ohybu [mm³]
        Wo_hod, Wo_str = StrojniSoucasti.profilyvlcnWo(tvar1, velicina, natoceni)
        return Wo_hod, Wo_str
    # -----------------------------------------------------------
    # Neznámá veličina
    # -----------------------------------------------------------
    else
        error("Neznámá veličina: $velicina")
    end
    return nothing, nothing
end
