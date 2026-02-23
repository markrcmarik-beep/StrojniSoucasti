# ver: 2025-12-30
"""
    torsion_J_TR4HR_numeric(a, b, t; nx=120, ny=120, tol=1e-6, maxiter=50_000)

Numerický výpočet torzní konstanty J silnostěnného
obdélníkového uzavřeného profilu (TRKR / jekl)
pomocí Saint-Venantovy teorie krutu (FDM).

Vstupy:
- a, b : vnější rozměry profilu [mm]
- t    : tloušťka stěny [mm]

Volitelné:
- nx, ny : počet uzlů sítě
- tol    : konvergenční tolerance
- maxiter: max. počet iterací

Výstup:
- J : torzní konstanta [mm^4]
"""
function torsion_J_TR4HR_numeric(a, b, t;
        nx=500, ny=500, tol=1e-6, maxiter=100000, ω=1.8)

    @assert a > 2t && b > 2t "Neplatná geometrie profilu"

    dx = a / (nx-1)
    dy = b / (ny-1)

    φ = zeros(nx, ny)

    # hranice dutiny
    x_in_min = t
    x_in_max = a - t
    y_in_min = t
    y_in_max = b - t

    inside_void(i,j) = begin
        x = (i-1)*dx
        y = (j-1)*dy
        x > x_in_min && x < x_in_max &&
        y > y_in_min && y < y_in_max
    end

    c = 2*(1/dx^2 + 1/dy^2)

    for iter = 1:maxiter
        err = 0.0

        for i in 2:nx-1, j in 2:ny-1
            inside_void(i,j) && continue

            # sousedé – pokud je dutina, φ = 0
            φe = inside_void(i+1,j) ? 0.0 : φ[i+1,j]
            φw = inside_void(i-1,j) ? 0.0 : φ[i-1,j]
            φn = inside_void(i,j+1) ? 0.0 : φ[i,j+1]
            φs = inside_void(i,j-1) ? 0.0 : φ[i,j-1]

            φ_new =
                ((φe + φw) / dx^2 +
                 (φn + φs) / dy^2 +
                 2.0) / c

            Δ = φ_new - φ[i,j]
            φ[i,j] += ω * Δ
            err = max(err, abs(Δ))
        end

        err < tol && break
        iter == maxiter && @warn "Numerika nedokonvergovala"
    end

    # integrace
    J = 0.0
    for i in 1:nx, j in 1:ny
        inside_void(i,j) && continue
        J += φ[i,j]
    end

    return 2 * J * dx * dy
end