# ver: 2026-04-24
import Pkg
using Printf

function _najdi_koren_projektu(start_dir::AbstractString)
    dir = abspath(start_dir)
    while true
        ma_project = isfile(joinpath(dir, "Project.toml"))
        ma_modul = isfile(joinpath(dir, "src", "StrojniSoucasti.jl"))
        if ma_project && ma_modul
            return dir
        end
        parent = dirname(dir)
        if parent == dir
            error(
                "Nepodarilo se najit koren projektu StrojniSoucasti od '$start_dir'. " *
                "Ocekavam soubory Project.toml a src/StrojniSoucasti.jl."
            )
        end
        dir = parent
    end
end

const _ZOBRAZ_BODY_ROOT = _najdi_koren_projektu(@__DIR__)
const _ZOBRAZ_BODY_PROFILY_DIR = joinpath(_ZOBRAZ_BODY_ROOT, "src", "profily")
Pkg.activate(_ZOBRAZ_BODY_ROOT; io=devnull)

using StrojniSoucasti

const _PLOTS_AVAILABLE = Base.find_package("Plots") !== nothing
if _PLOTS_AVAILABLE
    @eval import Plots
end

function _usage(script_name::AbstractString, priklad::AbstractString)
    println("Pouziti:")
    println("  julia $script_name [profil] [uchyceni] [vystup_png]")
    println("")
    println("Priklad:")
    println("  $priklad")
end

const _VYPIS_PREVIEW_HEAD = 20
const _VYPIS_PREVIEW_TAIL = 20

function _vypis_body(nadpis::AbstractString, body::AbstractVector)
    println("")
    println(nadpis)
    println(rpad("i", 5), rpad("x [mm]", 14), "y [mm]")

    n = length(body)
    max_bez_zkraceni = _VYPIS_PREVIEW_HEAD + _VYPIS_PREVIEW_TAIL + 1
    vypis_vse = n <= max_bez_zkraceni

    if vypis_vse
        println("Vypis vsech bodu: $n")
    else
        println(
            "Zkraceny vypis: prvnich $(_VYPIS_PREVIEW_HEAD) a poslednich " *
            "$(_VYPIS_PREVIEW_TAIL) z celkem $n bodu."
        )
    end

    first_last_i = 0
    for (i, (x, y)) in enumerate(body)
        if !vypis_vse && i > _VYPIS_PREVIEW_HEAD
            break
        end
        @printf("%-5d%-14.3f%.3f\n", i, x, y)
        first_last_i = i
    end

    if !vypis_vse
        println("...  ...           ...")
        start_tail = max(n - _VYPIS_PREVIEW_TAIL + 1, first_last_i + 1)
        for i in start_tail:n
            x, y = body[i]
            @printf("%-5d%-14.3f%.3f\n", i, x, y)
        end
    end
end

function _uzavri_ring(ring::AbstractVector)
    xs = [p[1] for p in ring]
    ys = [p[2] for p in ring]
    push!(xs, first(xs))
    push!(ys, first(ys))
    return xs, ys
end

function _normalizuj_otvory(otvory_raw)
    if otvory_raw isa AbstractMatrix
        return (otvory_raw,)
    end

    if !(otvory_raw isa Tuple || otvory_raw isa AbstractVector)
        return ()
    end

    isempty(otvory_raw) && return ()

    first_item = first(otvory_raw)
    if first_item isa Tuple && length(first_item) == 2
        return (otvory_raw,)
    end

    return Tuple(otvory_raw)
end

function spust_zobrazeni_body(;
    script_name::String,
    priklad::String,
    default_profile::String,
    default_png::String,
    nacti_profil::Function,
    body_funkce::Function,
    tabulka::String,
    args::Vector{String}=ARGS
)
    if any(arg -> arg in ("-h", "--help"), args)
        _usage(script_name, priklad)
        return nothing
    end

    profil_name = length(args) >= 1 ? args[1] : default_profile
    uchyceni = length(args) >= 2 ? args[2] : "ld"
    vystup_png = length(args) >= 3 ? args[3] : joinpath(@__DIR__, default_png)

    prof = nacti_profil(profil_name)
    prof === nothing && error("Profil '$profil_name' nebyl nalezen v tabulce $tabulka.")

    body = body_funkce(prof, uchyceni)
    obrys = body.obrys
    otvory_raw = hasproperty(body, :otvory) ? body.otvory : ()
    otvory = _normalizuj_otvory(otvory_raw)

    println("Profil: ", prof.name)
    println("Uchyceni: ", uchyceni)
    println("Pocet bodu obrysu: ", length(obrys))
    println("Pocet otvoru: ", length(otvory))
    for (i, otvor) in enumerate(otvory)
        println("  Otvor $i: ", length(otvor), " bodu")
    end

    _vypis_body("Body obrysu", obrys)
    for (i, otvor) in enumerate(otvory)
        _vypis_body("Body otvoru $i", otvor)
    end

    if !_PLOTS_AVAILABLE
        println("")
        println("Balicek Plots neni nainstalovany. Body jsou vypsane v konzoli.")
        println("Pro graf nainstaluj Plots (v tomto projektu) prikazem:")
        println("  julia --project=. -e \"using Pkg; Pkg.add(\\\"Plots\\\")\"")
        return nothing
    end

    try
        plots_mod = Plots

        xs, ys = _uzavri_ring(obrys)
        if isempty(otvory)
            plt = plots_mod.plot(
                xs, ys;
                seriestype=:path,
                marker=:circle,
                ms=2.2,
                lw=2,
                legend=false,
                aspect_ratio=:equal,
                xlabel="x [mm]",
                ylabel="y [mm]",
                title="Body obrysu $(prof.name) ($(uchyceni))",
                grid=true,
                size=(960, 640),
            )
        else
            plt = plots_mod.plot(
                xs, ys;
                seriestype=:path,
                marker=:circle,
                ms=2.2,
                lw=2,
                label="obrys",
                legend=true,
                aspect_ratio=:equal,
                xlabel="x [mm]",
                ylabel="y [mm]",
                title="Body obrysu $(prof.name) ($(uchyceni))",
                grid=true,
                size=(960, 640),
            )
            for (i, otvor) in enumerate(otvory)
                xh, yh = _uzavri_ring(otvor)
                plots_mod.plot!(
                    plt,
                    xh,
                    yh;
                    seriestype=:path,
                    marker=:circle,
                    ms=2.2,
                    lw=2,
                    label="otvor $i",
                )
            end
        end

        plots_mod.savefig(plt, vystup_png)
        display(plt)
        println("")
        println("Graf ulozen do: ", vystup_png)
    catch err
        println("")
        println("Vykresleni pres Plots selhalo, body jsou ale vypsane v konzoli.")
        println("Chyba: ", sprint(showerror, err))
    end

    return nothing
end
