## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet namáhání na otlačení pro strojní součásti. Generování 
# textového výpisu výpočtu.
# ver: 2026-02-21
## Funkce: namahaniotltext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/namahaniotltext.jl
#
## Vzor:
## vystupni_promenne = namahaniotltext(vstupni_promenne)
## Vstupní proměnné:
# VV::Dict{Symbol,Any} - slovník vstupních a výstupních proměnných
## Výstupní proměnné:
# lines - textový výstup s popisem výpočtu
## Použité balíčky
# Printf: @sprintf
## Použité uživatelské funkce:
# profil_text_lines(),
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
using Printf: @sprintf

function namahaniotltext(VV::Dict{Symbol,Any})
    lines = String[]
    info = get(VV, :info, "namáhání na otlačení")
    mat = get(VV, :mat, nothing)
    zatizeni = get(VV, :zatizeni, "")
    profil = get(VV, :profil, "")
    profil_info = get(VV, :profil_info, Dict{Symbol,Any}())
    if !(profil_info isa Dict{Symbol,Any})
        profil_info = Dict{Symbol,Any}()
    end
    push!(lines, "Výpočet $info")
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "materiál: $(mat === nothing ? "" : string(mat))")
    append!(lines, profil_text_lines(Dict(:profil => profil, :profil_info => profil_info)))
    push!(lines, "zatížení: $zatizeni")
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "zadání:")
    if get(VV, :F, nothing) !== nothing # zatěžující síla
        push!(lines, @sprintf("F = %g   %s", VV[:F], get(VV, :F_info, "")))
    end
    if get(VV, :k, nothing) !== nothing
        push!(lines, @sprintf("k = %g   %s", VV[:k], get(VV, :k_info, "")))
    end
    if get(VV, :S, nothing) !== nothing # plocha průřezu
        S_text = get(VV, :S_text, get(VV, :S_str, ""))
        if S_text != ""
            push!(lines, @sprintf("S = %s = %g   %s", S_text, VV[:S], get(VV, :S_info, "")))
        else
            push!(lines, @sprintf("S = %g   %s", VV[:S], get(VV, :S_info, "")))
        end
    end
    sigmaD = get(VV, :sigmaDotl, get(VV, :sigmaDt, nothing))
    sigmaD_info = haskey(VV, :sigmaDotl_info) ? VV[:sigmaDotl_info] : get(VV, :sigmaDt_info, "")
    if sigmaD !== nothing # dovolené napětí
        push!(lines, @sprintf("sigmaDotl = %g   %s", sigmaD, sigmaD_info))
    end
    if get(VV, :Re, nothing) !== nothing # mez kluzu
        push!(lines, @sprintf("Re = %g   %s", VV[:Re], get(VV, :Re_info, "")))
    end
    push!(lines, "--------------------------------------------------------------")
    push!(lines, "výpočet:")
    push!(lines, @sprintf("sigma = %s = %g   %s", get(VV, :sigma_str, "F / S"),
        get(VV, :sigma, 0), get(VV, :sigma_info, "")))
    k = get(VV, :bezpecnost, 0) # součinitel bezpečnosti
    kval = try
        ustrip(k)
    catch
        k
    end
    push!(lines, @sprintf("k = %s = %g   %s\n%s:  %s", get(VV, :bezpecnost_str, "sigmaDotl / sigma"),
        kval, get(VV, :bezpecnost_info, ""), get(VV, :verdict_info, "Výsledek"),
        get(VV, :verdict, "")))

    return join(lines, "\n")
end
