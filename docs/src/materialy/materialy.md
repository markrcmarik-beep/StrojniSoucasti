## funkce `materialy` 
## soubor `materialy.jl`
## Funkce Julia v1.13
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
## Vzor:
`mat = materialy(name)`
## Vstupní proměnné:
- `name::AbstractString` – označení materiálu, například `"S235"`, `"11373"` nebo `"S235JR+N"`. Funkce předává označení jednotlivým vyhledávacím funkcím; automatické oříznutí okrajů, odstranění mezer ani převod na velká písmena není zaručen.
## Výstupní proměnné:
- Pokud materiál nebyl nalezen nebo jeho druh není podporován, vrací `nothing`. Jinak vrací jednu z datových struktur `MaterialOcel`, `MaterialNezelezneKovy`, `MaterialLitina`, `MaterialPryz` nebo `MaterialPlast`.
- Všechny uvedené typy mají mimo jiné pole `name`, `standard`, `druh`, `E`, `E_unit`, `G`, `G_unit`, `ny`, `ny_unit`, `rho` a `rho_unit`. Další pole se liší podle typu: například `Re` u oceli, `Rp0_2` u neželezných kovů, `Rm_tah` u litiny a `hardness` u pryže a plastů. Jednotky veličin jsou uvedeny v odpovídajících polích s příponou `_unit`.
- Číselné vlastnosti mají typ `Union{Missing, Float64}`; jejich hodnota proto může být `missing`.
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

## Funkce `materialy`

```@docs
materialy
```


## Příklad

```julia
using StrojniSoucasti

mat = materialy("11 373")
if mat isa StrojniSoucasti.MaterialOcel
    println("Mez kluzu: ", mat.Re, " ", mat.Re_unit)
end
```

Databáze materiálů je uložena v souboru `materialy.db`.
