StrojniSoucasti

Balíček v jazyce Julia pro technické výpočty a práci s databázemi strojních součástí.
Knihovna obsahuje pomocné funkce pro práci s tabulkovými daty, materiálovými databázemi a výpočty geometrických a mechanických vlastností.

Projekt je určen především pro:

konstrukční výpočty

technické databáze

automatizaci výpočtů ve strojírenství

práci s daty z tabulek (.xlsx, .ods)

Instalace

Balíček lze instalovat pomocí správce balíčků Julia.

using Pkg
Pkg.add(url="https://github.com/markrcmarik-beep/StrojniSoucasti")

Poté je možné balíček načíst:

using StrojniSoucasti
Hlavní funkce

Balíček obsahuje utility pro práci s tabulkovými daty a pomocné výpočtové funkce.

Příklady funkcí:

převod mezi adresou buňky a indexy tabulky

načítání dat z Excel / ODS souborů

ukládání tabulkových dat do cache souborů

pomocné funkce pro práci s technickými databázemi

Příklad použití

Převod adresy buňky tabulky:

sprsheetRef([3,28])

výstup:

"AB3"

a opačně:

sprsheetRef("AB3")

výstup:

[3,28]
Práce s tabulkami

Balíček obsahuje funkce pro načítání dat z tabulkových souborů:

Excel (.xlsx)

OpenDocument Spreadsheet (.ods)

Načtená data mohou být automaticky ukládána do souborů .jld2, aby bylo opakované načítání výrazně rychlejší.

Databáze technických hodnot

Součástí balíčku mohou být databáze technických údajů používaných při výpočtech strojních součástí (např. materiálové vlastnosti, geometrické parametry apod.).

Tyto hodnoty mohou být sestaveny z různých zdrojů, například:

technické normy

strojírenské tabulky

odborná literatura

veřejně dostupné technické zdroje na internetu

Uvedené hodnoty jsou určeny pouze pro výpočtové a orientační účely.
Balíček neposkytuje oficiální znění technických norem ani jejich úplné tabulky.

Při konstrukčním návrhu nebo výrobě je vždy nutné ověřit hodnoty v aktuálním znění příslušné normy nebo technické dokumentace.

Struktura projektu
StrojniSoucasti
│
├─ src
│   ├─ StrojniSoucasti.jl
│   └─ další moduly
│
├─ test
│
└─ Project.toml
Stav projektu

Projekt je ve vývoji.
Nové funkce a úpravy jsou průběžně přidávány.

Spolupráce na vývoji

Pokud chcete přispět k vývoji:

vytvořte vlastní branch

proveďte změny

odešlete Pull Request

Diskuse o vývoji probíhá pomocí nástrojů platformy GitHub.

License

This project is licensed under the MIT License.
