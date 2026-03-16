# ver: 2026-02-21

struct MaterialOcel
    name::String        # název
    standard::String    # norma (nepovinné)
    druh::String        # druh oceli (např. "konstrukční", "nástrojová", "nerezová")
    Re::Float64         # nominální mez kluzu [MPa]
    Re_unit::String     # jednotka meze kluzu
    Rm_min::Float64     # mez pevnosti [MPa]
    Rm_min_unit::String # jednotka meze pevnosti
    Rm_max::Float64     # mez pevnosti max. [MPa]
    Rm_max_unit::String # jednotka meze pevnosti max
    A::Float64          # tažnost [%]
    A_unit::String      # jednotka tažnosti
    KV::Float64         # rázová práce [J]
    KV_unit::String     # jednotka rázové práce
    T_KV::Float64       # teplota zkoušky [°C]
    T_KV_unit::String   # jednotka teploty zkoušky
    weldable::Bool      # svařitelnost
    thickness_max::Float64 # maximální tloušťka [mm]
    thickness_max_unit::String # jednotka maximální tloušťky
    E::Float64          # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String      # jednotka modulu pružnosti
    G::Float64          # Modul smyku [GPa]
    G_unit::String      # jednotka modulu smyku
    ny::Float64         # Poissonovo číslo
    ny_unit::String     # jednotka Poissonova čísla
    rho::Float64        # hustota [kg/m^3]
    rho_unit::String    # jednotka hustoty
    #extra::Dict{Symbol, Any}
end

struct MaterialKovy
    name::String        # název
    standard::String    # norma (nepovinné)
    druh::String        # druh kovu (např. "hliník", "měď", "titan")
    Re::Float64         # nominální mez kluzu [MPa]
    Re_unit::String     # jednotka meze kluzu
    Rm_min::Float64     # mez pevnosti [MPa]
    Rm_min_unit::String # jednotka meze pevnosti
    Rm_max::Float64     # mez pevnosti max. [MPa]
    Rm_max_unit::String # jednotka meze pevnosti max
    A::Float64          # tažnost [%]
    A_unit::String      # jednotka tažnosti
    E::Float64          # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String      # jednotka modulu pružnosti
    G::Float64          # Modul smyku [GPa]
    G_unit::String      # jednotka modulu smyku
    ny::Float64         # Poissonovo číslo
    ny_unit::String     # jednotka Poissonova čísla
    rho::Float64        # hustota [kg/m^3]
    rho_unit::String    # jednotka hustoty
    #extra::Dict{Symbol, Any}
end

struct MaterialLitina
    name::String        # název
    standard::String    # norma (nepovinné)
    druh::String        # typ litiny (např. "šedá", "tvárná", "spheroidalní")
    Rm_tah::Float64     # mez pevnosti v tahu [MPa]
    Rm_tah_unit::String # jednotka meze pevnosti v tahu
    Rm_tlak::Float64    # mez pevnosti v tlaku [MPa]
    Rm_tlak_unit::String # jednotka meze pevnosti v tlaku
    tau_lim::Float64    # mez smykové pevnosti [MPa]
    tau_lim_unit::String # jednotka meze smykové pevnosti
    A::Float64          # tažnost [%]
    A_unit::String      # jednotka tažnosti
    HB_min::Float64     # minimální tvrdost Brinell [HB]
    HB_min_unit::String # jednotka tvrdosti Brinell min
    HB_max::Float64     # maximální tvrdost Brinell [HB]
    HB_max_unit::String # jednotka tvrdosti Brinell max
    E::Float64          # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String      # jednotka modulu pružnosti
    G::Float64          # Modul smyku [GPa]
    G_unit::String      # jednotka modulu smyku
    ny::Float64         # Poissonovo číslo
    ny_unit::String     # jednotka Poissonova čísla
    rho::Float64        # hustota [kg/m^3]
    rho_unit::String    # jednotka hustoty
end

