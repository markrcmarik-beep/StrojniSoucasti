## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Numerický výpočet torzní konstanty J silnostěnného obdélníkového 
# uzavřeného profilu (TR4HR / jekl) pomocí Saint-Venantovy teorie krutu (FDM).
# ver: 2026-03-02
## Funkce: torsion_J_TR4HR_numeric()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# balicek/src/profily/torsion_J_TR4HR_numeric.jl
#
## Vzor:
## vystupni_promenne = torsion_J_TR4HR_numeric(vstupni_promenne)
## Vstupní proměnné:
# a, b - vnější rozměry profilu [mm]
# t    - tloušťka stěny [mm]
# nx, ny - počet uzlů sítě (volitelné, výchozí 120)
# tol    - konvergenční tolerance (volitelné, výchozí 1e-6)
# maxiter - max. počet iterací (volitelné, výchozí 50_000)
## Výstupní proměnné:
# J - torzní konstanta [mm^4]
## Použité balíčky:
#
## Použité uživatelské funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
function torsion_J_TR4HR_numeric(a, b, t;
        nx=300, ny=300, tol=1e-6, maxiter=100000, ω=1.8)

    @assert a > 0 && b > 0 && t > 0 "Rozměry musí být kladné."
    @assert a > 2t && b > 2t "Neplatná geometrie profilu."
    @assert nx >= 3 && ny >= 3 "Počet uzlů nx a ny musí být >= 3."

    a_in = a - 2t
    b_in = b - 2t

    # Numerická aproximace J pro dutý obdélník jako rozdíl dvou
    # soustředných plných obdélníků (vnější - vnitřní).
    J_outer = _torsion_J_rect_solid_numeric(a, b; nx=nx, ny=ny, tol=tol, maxiter=maxiter, ω=ω)

    nx_in = max(3, round(Int, (a_in / a) * (nx - 1)) + 1)
    ny_in = max(3, round(Int, (b_in / b) * (ny - 1)) + 1)
    J_inner = _torsion_J_rect_solid_numeric(a_in, b_in; nx=nx_in, ny=ny_in, tol=tol, maxiter=maxiter, ω=ω)

    return max(0.0, J_outer - J_inner)
end

function _torsion_J_rect_solid_numeric(a, b;
        nx=300, ny=300, tol=1e-6, maxiter=100000, ω=1.8)

    @assert a > 0 && b > 0 "Rozměry musí být kladné."
    @assert nx >= 3 && ny >= 3 "Počet uzlů nx a ny musí být >= 3."

    dx = a / (nx - 1)
    dy = b / (ny - 1)
    φ = zeros(Float64, nx, ny)
    c = 2.0 * (1.0 / dx^2 + 1.0 / dy^2)

    for iter in 1:maxiter
        err = 0.0
        for i in 2:nx-1, j in 2:ny-1
            φ_new = ((φ[i+1, j] + φ[i-1, j]) / dx^2 +
                     (φ[i, j+1] + φ[i, j-1]) / dy^2 + 2.0) / c
            Δ = φ_new - φ[i, j]
            φ[i, j] += ω * Δ
            err = max(err, abs(Δ))
        end

        if err < tol
            break
        end
        if iter == maxiter
            @warn "Numerika nedokonvergovala"
        end
    end

    return 2.0 * sum(φ) * dx * dy
end
