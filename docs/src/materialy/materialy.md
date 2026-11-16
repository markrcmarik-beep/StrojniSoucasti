## funkce `materialy` 
## soubor `materialy.jl`
###############################################################
## Popis funkce:
Vrátí datovou strukturu s vlastnostmi materiálu z databáze.
Vyhledá materiál podle označení v databázi. Postupně zkouší označení
ČSN, EN, DIN, ISO a obecné označení. Podoba označení, kterou lze použít, závisí
na příslušné normě a záznamu v databázi.

Pokud materiál není nalezen nebo jeho druh funkce nepodporuje, vrací `nothing`.
Číselné vlastnosti mohou mít hodnotu `missing` a dostupná pole se liší podle
typu materiálu. Před čtením vlastností specifických pro daný materiál proto
ověřte typ výsledku.

Funkce vrací jeden z typů:

- `StrojniSoucasti.MaterialOcel`
- `StrojniSoucasti.MaterialNezelezneKovy`
- `StrojniSoucasti.MaterialLitina`
- `StrojniSoucasti.MaterialPryz`
- `StrojniSoucasti.MaterialPlast`

Všechny uvedené typy mají mimo jiné pole `name`, `standard`, `druh`, `E`,
`E_unit`, `G`, `G_unit`, `ny`, `ny_unit`, `rho` a `rho_unit`. Mezi vlastnosti
specifické pro typ patří například `Re` u oceli, `Rp0_2` u neželezných kovů,
`Rm_tah` u litiny a `hardness` u pryže a plastů. Jednotky veličin jsou uvedeny
v odpovídajících polích s příponou `_unit`.

Databáze materiálů je uložena v souboru `materialy.db`.
## Vzor:
```julia
mat = materialy(name)
```
## Vstupní proměnné:
- `name::AbstractString` – označení materiálu, například `"S235"`, `"11373"` nebo `"S235JR+N"`. Funkce předává označení jednotlivým vyhledávacím funkcím; automatické oříznutí okrajů, odstranění mezer ani převod na velká písmena není zaručen.
## Výstupní proměnné:
- Pokud materiál nebyl nalezen nebo jeho druh není podporován, vrací `nothing`. Jinak vrací jednu z datových struktur `MaterialOcel`, `MaterialNezelezneKovy`, `MaterialLitina`, `MaterialPryz` nebo `MaterialPlast`.
- Všechny uvedené typy mají mimo jiné pole `name`, `standard`, `druh`, `E`, `E_unit`, `G`, `G_unit`, `ny`, `ny_unit`, `rho` a `rho_unit`. Další pole se liší podle typu: například `Re` u oceli, `Rp0_2` u neželezných kovů, `Rm_tah` u litiny a `hardness` u pryže a plastů. Jednotky veličin jsou uvedeny v odpovídajících polích s příponou `_unit`.
- Číselné vlastnosti mají typ `Union{Missing, Float64}`; jejich hodnota proto může být `missing`.

### MaterialOcel::struct
    tabulka::String             # název tabulky
    name::String                # název
    nameObecne::String          # název obecný
    nameISO::String             # název ISO (nepovinné)
    nameCSN::String             # název ČSN (nepovinné)
    nameDIN::String             # název DIN (nepovinné)
    nameENcislo::String         # název EN číslo (nepovinné)
    nameENznacka::String        # název EN značka (nepovinné)
    standard::String            # norma (nepovinné)
    druh::String                # druh oceli (např. "konstrukční", "nástrojová", "nerezová")
    Re::Union{Missing, Float64} # nominální mez kluzu [MPa]
    Re_unit::String             # jednotka meze kluzu
    Rm_min::Union{Missing, Float64} # mez pevnosti [MPa]
    Rm_min_unit::String         # jednotka meze pevnosti
    Rm_max::Union{Missing, Float64} # mez pevnosti max. [MPa]
    Rm_max_unit::String         # jednotka meze pevnosti max
    A::Union{Missing, Float64}  # tažnost [%]
    A_unit::String              # jednotka tažnosti
    KV::Union{Missing, Float64} # rázová práce [J]
    KV_unit::String             # jednotka rázové práce
    T_KV::Union{Missing, Float64} # teplota zkoušky [°C]
    T_KV_unit::String           # jednotka teploty zkoušky
    svaritelnost::String        # svařitelnost ("výpborná", "omezená", "špatná")
    weldable::Bool              # svařitelnost
    thickness_max::Union{Missing, Float64} # maximální tloušťka [mm]
    thickness_max_unit::String  # jednotka maximální tloušťky
    E::Union{Missing, Float64}  # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String              # jednotka modulu pružnosti
    G::Union{Missing, Float64}  # Modul smyku [GPa]
    G_unit::String              # jednotka modulu smyku
    ny::Union{Missing, Float64} # Poissonovo číslo
    ny_unit::String             # jednotka Poissonova čísla
    rho::Union{Missing, Float64} # hustota [kg/m^3]
    rho_unit::String            # jednotka hustoty

### MaterialNezelezneKovy::struct
    tabulka::String             # název tabulky
    name::String                # název
    nameObecne::String          # název obecný
    nameISO::String             # název ISO (nepovinné)
    nameCSN::String             # název ČSN (nepovinné)
    nameDIN::String             # název DIN (nepovinné)
    nameENcislo::String         # název EN číslo (nepovinné)
    nameENznacka::String    # název EN značka (nepovinné)
    standard::String        # norma (nepovinné)
    druh::String            # druh kovu (např. "hliník", "měď", "titan")
    Rp0_2::Union{Missing, Float64} # nominální mez kluzu [MPa]
    Rp0_2_unit::String      # jednotka meze kluzu
    Rm_min::Union{Missing, Float64} # mez pevnosti [MPa]
    Rm_min_unit::String     # jednotka meze pevnosti
    Rm_max::Union{Missing, Float64} # mez pevnosti max. [MPa]
    Rm_max_unit::String     # jednotka meze pevnosti max
    A::Union{Missing, Float64} # tažnost [%]
    A_unit::String          # jednotka tažnosti
    E::Union{Missing, Float64} # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String          # jednotka modulu pružnosti
    G::Union{Missing, Float64} # Modul smyku [GPa]
    G_unit::String          # jednotka modulu smyku
    ny::Union{Missing, Float64} # Poissonovo číslo
    ny_unit::String         # jednotka Poissonova čísla
    rho::Union{Missing, Float64} # hustota [kg/m^3]
    rho_unit::String        # jednotka hustoty
    #extra::Dict{Symbol, Any}

### MaterialLitina::struct
    tabulka::String         # název tabulky
    name::String            # název
    nameObecne::String      # název obecný
    nameISO::String         # název ISO (nepovinné)
    nameCSN::String         # název ČSN (nepovinné)
    nameDIN::String         # název DIN (nepovinné)
    nameENcislo::String     # název EN číslo (nepovinné)
    nameENznacka::String    # název EN značka (nepovinné)
    standard::String        # norma (nepovinné)
    druh::String            # typ litiny (např. "šedá", "tvárná", "spheroidalní")
    Rm_tah::Union{Missing, Float64} # mez pevnosti v tahu [MPa]
    Rm_tah_unit::String     # jednotka meze pevnosti v tahu
    Rm_tlak::Union{Missing, Float64} # mez pevnosti v tlaku [MPa]
    Rm_tlak_unit::String    # jednotka meze pevnosti v tlaku
    tau_lim::Union{Missing, Float64} # mez smykové pevnosti [MPa]
    tau_lim_unit::String    # jednotka meze smykové pevnosti
    A::Union{Missing, Float64} # tažnost [%]
    A_unit::String          # jednotka tažnosti
    HB_min::Union{Missing, Float64} # minimální tvrdost Brinell [HB]
    HB_min_unit::String     # jednotka tvrdosti Brinell min
    HB_max::Union{Missing, Float64} # maximální tvrdost Brinell [HB]
    HB_max_unit::String     # jednotka tvrdosti Brinell max
    E::Union{Missing, Float64} # Modul pružnosti (Youngův modul) [GPa]
    E_unit::String          # jednotka modulu pružnosti
    G::Union{Missing, Float64} # Modul smyku [GPa]
    G_unit::String          # jednotka modulu smyku
    ny::Union{Missing, Float64} # Poissonovo číslo
    ny_unit::String         # jednotka Poissonova čísla
    rho::Union{Missing, Float64} # hustota [kg/m^3]
    rho_unit::String        # jednotka hustoty

### MaterialPryz::struct
    tabulka::String         # název tabulky
    name::String            # název
    nameObecne::String      # název obecný
    nameISO::String         # název ISO (nepovinné)
    nameCSN::String         # název ČSN (nepovinné)
    nameDIN::String         # název DIN (nepovinné)
    nameENcislo::String     # název EN číslo (nepovinné)
    nameENznacka::String    # název EN značka (nepovinné)
    standard::String        # norma (nepovinné)
    druh::String            # druh pryže (např. "NBR", "EPDM")
    hardness::Union{Missing, Float64} # tvrdost [ShA]
    hardness_unit::String   # jednotka tvrdosti
    E::Union{Missing, Float64} # Modul pružnosti (Youngův modul) [MPa]
    E_unit::String          # jednotka modulu pružnosti
    G::Union{Missing, Float64} # Modul smyku [MPa]
    G_unit::String          # jednotka modulu smyku
    ny::Union{Missing, Float64} # Poissonovo číslo
    ny_unit::String         # jednotka Poissonova čísla
    rho::Union{Missing, Float64} # hustota [kg/m^3]
    rho_unit::String        # jednotka hustoty

### MaterialPlast::struct
    tabulka::String         # název tabulky
    name::String            # název
    nameObecne::String      # název obecný
    nameISO::String         # název ISO (nepovinné)
    nameCSN::String         # název ČSN (nepovinné)
    nameDIN::String         # název DIN (nepovinné)
    nameENcislo::String     # název EN číslo (nepovinné)
    nameENznacka::String    # název EN značka (nepovinné)
    standard::String        # norma (nepovinné)
    druh::String            # druh plastu (např. "PE", "PP", "PVC")
    hardness::Union{Missing, Float64} # tvrdost [ShD]
    hardness_unit::String   # jednotka tvrdosti
    E::Union{Missing, Float64} # Modul pružnosti (Youngův modul) [MPa]
    E_unit::String          # jednotka modulu pružnosti
    G::Union{Missing, Float64} # Modul smyku [MPa]
    G_unit::String          # jednotka modulu smyku
    ny::Union{Missing, Float64} # Poissonovo číslo
    ny_unit::String         # jednotka Poissonova čísla
    rho::Union{Missing, Float64} # hustota [kg/m^3]
    rho_unit::String        # jednotka hustoty

## Příklad:
```julia
using StrojniSoucasti
mat = materialy("11373")
StrojniSoucasti.MaterialOcel("ocel", "11373", "", "", "11373", "", "1.0036", "S235JRG1", "ČSN 41 1373", "konstrukční ocel", 250.0, "MPa", 340.0, "MPa", 440.0, "MPa", 7.0, "%", 27.0, "J", 20.0, "°C", "zaručená", false, 0.0, "mm", 210.0, "GPa", 81.0, "GPa", 0.3, "-", 7850.0, "kg/m^3")
mat = materialy("11 373")
if mat isa StrojniSoucasti.MaterialOcel
    println("Mez kluzu: ", mat.Re, " ", mat.Re_unit)
end
```
