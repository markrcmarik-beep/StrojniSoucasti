## Funkce Julia v1.12
###############################################################
## Popis funkce:
# Výpočet po sobě jdoucich bodů na kruhovém oblouku.
# ver: 2026-04-15
## Funkce: obloukBodu()
## Autor: Martin + Codex
#
## Cesta uvnitř balíčku:
# StrojniSoucasti/src/profily/obloukBodu.jl
#
## Vzor:
# body = obloukBodu((x1, y1), (x2, y2), R, "+", 0.5)
#
## Vstupní proměnné:
# prvni_bod   - Prvni bod oblouku (x, y).
# posledni_bod - Posledni bod oblouku (x, y).
# polomer     - Polomer kruznice.
# smer        - "+" = proti smeru hodin (CCW), "-" = po smeru hodin (CW).
# presnost    - Maximalni delka jednoho dilku po oblouku.
#
## Výstupní proměnné:
# body - Vektor bodu [(x, y), ...] vcetne prvniho i posledniho bodu.
## Použité balíčky:
#
## Použite uživatelské funkce:
# _oblouk_point_xy - Pomocna funkce pro ziskani x, y ze zadaneho formatu bodu.
## Příklad:
# body = obloukBodu((0, 0), (1, 1), 1.0, "+", 0.5)
# => body = [(0.0, 0.0), (0.2928932188134524, 0.7071067811865475), (1.0, 1.0)]
###############################################################

function obloukBodu(prvni_bod, posledni_bod, polomer::Real, smer::String="+", presnost::Real=1.0)
    polomer > 0 || throw(ArgumentError("Polomer musi byt kladny."))
    presnost > 0 || throw(ArgumentError("Presnost musi byt kladna."))
    (smer == "+" || smer == "-") || throw(ArgumentError("Smer musi byt '+' (proti smeru hodin) nebo '-' (po smeru hodin)."))

    x1_raw, y1_raw = _oblouk_point_xy(prvni_bod)
    x2_raw, y2_raw = _oblouk_point_xy(posledni_bod)

    x1 = Float64(x1_raw)
    y1 = Float64(y1_raw)
    x2 = Float64(x2_raw)
    y2 = Float64(y2_raw)
    r = Float64(polomer)
    s = Float64(presnost)

    dx = x2 - x1
    dy = y2 - y1
    chord = hypot(dx, dy)
    chord > 0 || throw(ArgumentError("Prvni a posledni bod se nesmi shodovat."))

    half_chord = chord / 2
    r >= half_chord || throw(ArgumentError("Polomer je prilis maly pro zadane body (musi platit polomer >= vzdalenost_bodu/2)."))

    mx = (x1 + x2) / 2
    my = (y1 + y2) / 2

    h2 = r^2 - half_chord^2
    h = sqrt(max(h2, 0.0))

    ux = -dy / chord
    uy = dx / chord

    centers = Tuple{Float64,Float64}[(mx + h * ux, my + h * uy)]
    if h > 0
        push!(centers, (mx - h * ux, my - h * uy))
    end

    best_center = centers[1]
    best_theta1 = 0.0
    best_delta = Inf
    for center in centers
        cx, cy = center
        theta1 = atan(y1 - cy, x1 - cx)
        theta2 = atan(y2 - cy, x2 - cx)
        delta = smer == "+" ? mod2pi(theta2 - theta1) : mod2pi(theta1 - theta2)

        if delta < best_delta
            best_delta = delta
            best_theta1 = theta1
            best_center = center
        end
    end

    arc_length = r * best_delta
    n_segments = max(1, ceil(Int, arc_length / s))

    cx, cy = best_center
    sign = smer == "+" ? 1.0 : -1.0
    angle_step = best_delta / n_segments

    body = Vector{Tuple{Float64,Float64}}(undef, n_segments + 1)
    for i in 0:n_segments
        angle = best_theta1 + sign * angle_step * i
        body[i + 1] = (cx + r * cos(angle), cy + r * sin(angle))
    end

    body[1] = (x1, y1)
    body[end] = (x2, y2)
    return body
end

function _oblouk_point_xy(p::NTuple{2,Any})
    x, y = p
    x isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    y isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    return x, y
end

function _oblouk_point_xy(p::Tuple)
    length(p) == 2 || throw(ArgumentError("Kazdy bod musi mit presne 2 souradnice (x, y)."))
    x, y = p[1], p[2]
    x isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    y isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    return x, y
end

function _oblouk_point_xy(p::AbstractVector)
    length(p) == 2 || throw(ArgumentError("Kazdy bod musi mit presne 2 souradnice (x, y)."))
    x, y = p[1], p[2]
    x isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    y isa Real || throw(ArgumentError("Souradnice bodu musi byt cisla."))
    return x, y
end

function _oblouk_point_xy(p)
    throw(ArgumentError("Nepodporovany format bodu: $(typeof(p)). Pouzijte (x, y) nebo [x, y]."))
end
