## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Vyřeší mechanické veličiny pro různé tvary dle zkratky označení.
# ver: 2026-06-09
## Funkce: profilyvlcn()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/profilyvlcn.jl
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
#       J - Polární (torzní) moment setrvačnosti pro krut [mm^4] - zatím není implementováno
#       Jp - Polární moment [mm⁴]
#       Jt - Torzní moment [mm³] (pro kruhové průřezy) - zatím není implementováno
#       Wk - Průřezový modul v krutu [mm³]
#       Wt - Torzní průřezový modul [mm³] (pro kruhové průřezy) - zatím není implementováno
#       Ix - Kvadratický moment [mm⁴]
#       Iy - Kvadratický moment [mm⁴] - zatím není implementováno
#       Imin - Kvadratický moment minimální [mm⁴]
#       Imax - Kvadratický moment maximální [mm⁴] - zatím není implementováno
#       Ixy - Kvadratický moment součinitele [mm⁴] - zatím není implementováno
#       Wo - Průřezový modul v ohybu [mm³]
#       Wx - Průřezový modul v ohybu pro osu x [mm³] - zatím není implementováno
#       Wy - Průřezový modul v ohybu pro osu y [mm³] - zatím není implementováno
# natoceni – úhel natočení [rad], volitelný (parametr pro Ix a Wo) (výchozí hodnota 0) [rad]
## Výstupní proměnné:
# rozmer – hodnota veličiny s jednotkami (Unitful) nebo bez jednotek (číslo), pokud není k dispozici
# text – vzorec použitý pro výpočet (string) nebo prázdný string, pokud není k dispozici
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
        else
            S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1)
            S_hod = dopln_jednotku(S_hod, u"mm^2")
        end
        S_info = "plocha průřezu [mm²]"
        return S_hod, S_str, S_info # Vrátí hodnotu, vzorec a informaci pro plochu
    # -----------------------------------------------------------
    # J - Polární (torzní) moment setrvačnosti pro krut [mm^4]
    # -----------------------------------------------------------
    elseif velicina == :J  # Polární (torzní) moment setrvačnosti pro krut [mm^4]
        J_hod, J_str = StrojniSoucasti.profilyvlcnJ(tvar1, :Jt) # Zatím není implementováno, ale připraveno pro budoucí rozšíření
        J_hod = dopln_jednotku(J_hod, u"mm^4")
        J_info = "polární moment setrvačnosti pro krut [mm⁴]"
        return J_hod, J_str, J_info # Vrátí hodnotu, vzorec a informaci pro polární moment setrvačnosti pro krut
    # -----------------------------------------------------------
    # Jp - Polární moment [mm⁴]
    # -----------------------------------------------------------
    elseif velicina == :Jp  # Polární moment [mm⁴]
        Jp_hod, Jp_str = StrojniSoucasti.profilyvlcnJ(tvar1, :Jp)
        Jp_hod = dopln_jednotku(Jp_hod, u"mm^4")
        Jp_info = "polární moment [mm⁴]"
        return Jp_hod, Jp_str, Jp_info # Vrátí hodnotu, vzorec a informaci pro polární moment
    # -----------------------------------------------------------
    # Jt - Torzní moment [mm³] (pro kruhové průřezy)
    # -----------------------------------------------------------
    elseif velicina == :Jt  # Torzní moment [mm³] (pro kruhové průřezy)
        Jt_hod, Jt_str = StrojniSoucasti.profilyvlcnJt(tvar1, :Jt)
        Jt_hod = dopln_jednotku(Jt_hod, u"mm^3")
        Jt_info = "torzní moment [mm³]"
        return Jt_hod, Jt_str, Jt_info # Vrátí hodnotu, vzorec a informaci pro torzní moment
    # -----------------------------------------------------------
    # rmax - Maximální poloměr setrvačnosti [mm]
    # -----------------------------------------------------------
    elseif velicina == :rmax  # Maximální poloměr setrvačnosti [mm]
        rmax_hod, rmax_str = StrojniSoucasti.profilyvlcnrmax(tvar1)
        rmax_hod = dopln_jednotku(rmax_hod, u"mm")
        rmax_info = "maximální poloměr setrvačnosti [mm]"
        return rmax_hod, rmax_str, rmax_info # Vrátí hodnotu, vzorec a informaci pro maximální poloměr setrvačnosti
    # -----------------------------------------------------------
    # Wk - Modul v krutu [mm³]
    # -----------------------------------------------------------
    elseif velicina == :Wk  # Modul v krutu [mm³]
        Wk_hod, Wk_str = StrojniSoucasti.profilyvlcnWk(tvar1, velicina)
        Wk_hod = dopln_jednotku(Wk_hod, u"mm^3")
        Wk_info = "modul v krutu [mm³]"
        return Wk_hod, Wk_str, Wk_info # Vrátí hodnotu, vzorec a informaci pro modul v krutu
    # ------------------------------------------------------------
    # Wt - Torzní průřezový modul [mm³] (pro kruhové průřezy)
    # ------------------------------------------------------------
    elseif velicina == :Wt  # Torzní průřezový modul [mm³] (pro kruhové průřezy)
        Wt_hod, Wt_str = StrojniSoucasti.profilyvlcnWt(tvar1)
        Wt_hod = dopln_jednotku(Wt_hod, u"mm^3")
        Wt_info = "torzní průřezový modul [mm³]"
        return Wt_hod, Wt_str, Wt_info # Vrátí hodnotu, vzorec a informaci pro torzní průřezový modul
    # ------------------------------------------------------------
    # Ix - Kvadratický moment průřezu pro osu x [mm⁴]
    # ------------------------------------------------------------
    elseif velicina == :Ix  # Kvadratický moment [mm⁴]
        Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnI(tvar1, velicina)
        Ix_hod = dopln_jednotku(Ix_hod, u"mm^4")
        Ix_info = "kvadratický moment průřezu pro osu x [mm⁴]"
        return Ix_hod, Ix_str, Ix_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment Ix
    # ------------------------------------------------------------
    # Iy - Kvadratický moment průřezu pro osu y [mm⁴]
    # ------------------------------------------------------------
    elseif velicina == :Iy  # Kvadratický moment [mm⁴]
        Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnI(tvar1, :Iy)
        Iy_hod = dopln_jednotku(Iy_hod, u"mm^4")
        Iy_info = "kvadratický moment průřezu pro osu y [mm⁴]"
        return Iy_hod, Iy_str, Iy_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment Iy
    # ------------------------------------------------------------
    # I - Kvadratický moment průřezu [mm⁴]
    # ------------------------------------------------------------
    elseif velicina == :I  # Kvadratický moment [mm⁴]
        I_hod, I_str = StrojniSoucasti.profilyvlcnI(tvar1, :I, natoceni)
        I_hod = dopln_jednotku(I_hod, u"mm^4")
        I_info = "kvadratický moment průřezu [mm⁴]"
        return I_hod, I_str, I_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment I
    # ------------------------------------------------------------
    # Ixy - Kvadratický moment průřezu součinitele [mm⁴]
    # ------------------------------------------------------------
    elseif velicina == :Ixy  # Kvadratický moment [mm⁴]
        if hasproperty(tvar1, :Ixy)
            Ixy_hod = getv(:Ixy)
            Ixy_hod = dopln_jednotku(Ixy_hod, u"mm^4")
            Ixy_str = hasproperty(tvar1, :Ixy_str) ? tvar1[:Ixy_str] : ""
        else
            Ixy_hod, Ixy_str = StrojniSoucasti.profilyvlcnI(tvar1, :Ixy, natoceni)
            Ixy_hod = dopln_jednotku(Ixy_hod, u"mm^4")
        end
        Ixy_info = "kvadratický moment průřezu součinitele [mm⁴]"
        return Ixy_hod, Ixy_str, Ixy_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment Ixy
    # ------------------------------------------------------------
    # Imin - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 - √( ((Ix - Iy)/2)² + Ixy² )")
    # ------------------------------------------------------------
    elseif velicina == :Imin  # Kvadratický moment mimimální [mm⁴]
        Imin_hod, Imin_str = StrojniSoucasti.profilyvlcnI(tvar1, :Imin, natoceni)
        Imin_hod = dopln_jednotku(Imin_hod, u"mm^4")
        Imin_info = "kvadratický moment průřezu minimální [mm⁴]"
        return Imin_hod, Imin_str, Imin_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment Imin
    # --------------------------------------------------------
    # Imax - Kvadratický moment minimální [mm⁴] ("Imin = (Ix + Iy)/2 + √( ((Ix - Iy)/2)² + Ixy² )")
    # ------------------------------------------------------------
    elseif velicina == :Imax  # Kvadratický moment mimimální [mm⁴]
        Imax_hod, Imax_str = StrojniSoucasti.profilyvlcnI(tvar1, :Imax, natoceni)
        Imax_hod = dopln_jednotku(Imax_hod, u"mm^4")
        Imax_info = "kvadratický moment průřezu maximální [mm⁴]"
        return Imax_hod, Imax_str, Imax_info # Vrátí hodnotu, vzorec a informaci pro kvadratický moment Imax
    # ------------------------------------------------------------
    # ex - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) x [mm] (pro výpočet Wx)
    # ------------------------------------------------------------
    elseif velicina == :ex  # Vzdálenost nejvzdálenějšího vlákna od neutrální osy x [mm] (pro výpočet Wx)
        ex_hod, ex_str = StrojniSoucasti.profilyvlcnI(tvar1, :ex, natoceni)
        ex_hod = dopln_jednotku(ex_hod, u"mm")
        ex_info = "vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) x [mm]"
        return ex_hod, ex_str, ex_info # Vrátí hodnotu, vzorec a informaci pro vzdálenost nejvzdálenějšího vlákna od neutrální osy x
    # ------------------------------------------------------------
    # ey - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) y [mm] (pro výpočet Wy)
    # ------------------------------------------------------------
    elseif velicina == :ey  # Vzdálenost nejvzdálenějšího vlákna od neutrální osy y [mm] (pro výpočet Wy)
        ey_hod, ey_str = StrojniSoucasti.profilyvlcnI(tvar1, :ey, natoceni)
        ey_hod = dopln_jednotku(ey_hod, u"mm")
        ey_info = "vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) y [mm]"
        return ey_hod, ey_str, ey_info # Vrátí hodnotu, vzorec a informaci pro vzdálenost nejvzdálenějšího vlákna od neutrální osy y
    # ------------------------------------------------------------
    # eo - Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) [mm] dle natočení (pro výpočet Wo)
    # ------------------------------------------------------------
    elseif velicina == :eo  # Vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) [mm] dle natočení (pro výpočet Wo)
        eo_hod, eo_str = StrojniSoucasti.profilyvlcnI(tvar1, :eo, natoceni)
        eo_hod = dopln_jednotku(eo_hod, u"mm")
        eo_info = "vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště) [mm]"
        return eo_hod, eo_str, eo_info # Vrátí hodnotu, vzorec a informaci pro vzdálenost nejvzdálenějšího vlákna od neutrální osy (těžiště)
    # ------------------------------------------------------------
    # Wx - Průřezový modul v ohybu pro osu x [mm³]
    # ------------------------------------------------------------
    elseif velicina == :Wx  # Průřezový modul v ohybu pro osu x [mm³]
        Wx_hod, Wx_str = StrojniSoucasti.profilyvlcnWo(tvar1, :Wo, natoceni)
        Wx_hod = dopln_jednotku(Wx_hod, u"mm^3")
        Wx_info = "průřezový modul v ohybu pro osu x [mm³]"
        return Wx_hod, Wx_str, Wx_info # Vrátí hodnotu, vzorec a informaci pro průřezový modul v ohybu pro osu x
    # ------------------------------------------------------------
    # Wy - Průřezový modul v ohybu pro osu y [mm³]
    # ------------------------------------------------------------
    elseif velicina == :Wy  # Průřezový modul v ohybu pro osu y [mm³]
        Wy_hod, Wy_str = StrojniSoucasti.profilyvlcnWo(tvar1, :Wo, natoceni)
        Wy_hod = dopln_jednotku(Wy_hod, u"mm^3")
        Wy_info = "průřezový modul v ohybu pro osu y [mm³]"
        return Wy_hod, Wy_str, Wy_info # Vrátí hodnotu, vzorec a informaci pro průřezový modul v ohybu pro osu y
    # ------------------------------------------------------------
    # Wo - Průřezový modul v ohybu [mm³]
    # ------------------------------------------------------------
    elseif velicina == :Wo  # Modul v ohybu [mm³]
        Wo_hod, Wo_str = StrojniSoucasti.profilyvlcnWo(tvar1, :Wo, natoceni)
        Wo_hod = dopln_jednotku(Wo_hod, u"mm^3")
        Wo_info = "průřezový modul v ohybu [mm³]"
        return Wo_hod, Wo_str, Wo_info # Vrátí hodnotu, vzorec a informaci pro modul v ohybu Wo (natočený o natoceni)
    # ------------------------------------------------------------
    # ix - Poloměr setrvačnosti pro osu x [mm]
    # ------------------------------------------------------------
    elseif velicina == :ix  # Poloměr setrvačnosti pro osu x [mm]
        Ix_hod, Ix_str = StrojniSoucasti.profilyvlcnI(tvar1, :Ix, natoceni)
        S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1)
        ix_hod = sqrt(Ix_hod / S_hod)
        ix_str = "√(Ix/S)"
        ix_info = "poloměr setrvačnosti pro osu x [mm]"
        return ix_hod, ix_str, ix_info # Vrátí hodnotu, vzorec a informaci pro poloměr setrvačnosti pro osu x
    # ------------------------------------------------------------
    # iy - Poloměr setrvačnosti pro osu y [mm]
    # ------------------------------------------------------------
    elseif velicina == :iy  # Poloměr setrvačnosti pro osu y [mm]
        Iy_hod, Iy_str = StrojniSoucasti.profilyvlcnI(tvar1, :Iy, natoceni)
        S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1)
        iy_hod = sqrt(Iy_hod / S_hod)
        iy_str = "√(Iy/S)"
        iy_info = "poloměr setrvačnosti pro osu y [mm]"
        return iy_hod, iy_str, iy_info # Vrátí hodnotu, vzorec a informaci pro poloměr setrvačnosti pro osu y
    # ------------------------------------------------------------
    # i - Poloměr setrvačnosti [mm]
    # ------------------------------------------------------------
    elseif velicina == :i  # Poloměr setrvačnosti [mm]
        I_hod, I_str = StrojniSoucasti.profilyvlcnI(tvar1, :I, natoceni)
        S_hod, S_str = StrojniSoucasti.profilyvlcnS(tvar1)
        i_hod = sqrt(I_hod / S_hod)
        i_str = "√(I/S)"
        i_info = "poloměr setrvačnosti [mm]"
        return i_hod, i_str, i_info # Vrátí hodnotu, vzorec a informaci pro poloměr setrvačnosti
    # ------------------------------------------------------------
    # Neznámá veličina
    # ------------------------------------------------------------
    else
        error("Neznámá veličina: $velicina")
    end
    return nothing, nothing
end
