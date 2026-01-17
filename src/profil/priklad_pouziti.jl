# Příklad použití profilTR4HR.jl
# Ukázka jak pracovat s profily, které obsahují více hodnot

using Revise
include("profilTR4HR.jl")

# 1. Načtení profilů z TOML souboru
println("Načítám profily...")
profiles = load_profiles("profilTR4HR.toml")

# 2. Výpis všech dostupných profilů
list_all_profiles(profiles)

# 3. Výběr konkrétního profilu
profile = get_profile(profiles, "40x40")
display_profile(profile)

# 4. Získání všech kombinací hodnot
println("Všechny kombinace pro profil 40x40:")
combinations = get_combinations(profile)
for (i, combo) in enumerate(combinations)
    println("$i. t=$(combo.t)mm, R=$(combo.R)mm, materiál=$(combo.material)")
end

# 5. Přímý přístup k jednotlivým hodnotám
println("\n═══ Přímý přístup ═══")
println("Tloušťky (t): $(profile.t)")
println("Poloměry (R): $(profile.R)")
println("Materiály: $(profile.material)")
println("Počet variant tloušťky: $(length(profile.t))")
println("Počet materiálů: $(length(profile.material))")
