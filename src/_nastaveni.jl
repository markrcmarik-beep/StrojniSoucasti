# ver: 2026-09-22

if isdir(joinpath(homedir(), "StrojniSoucasti"))
    const cesta_balicek = joinpath(homedir(), "StrojniSoucasti") # cesta k souboru s nastavením
    for slozka in ["body", "matematika", "materialy", "namahani", "profily", "spojovacimaterial", "tolerance"]
        !isdir(joinpath(cesta_balicek, slozka)) ? mkdir(joinpath(cesta_balicek, slozka)) : nothing
    end
    const cesta_body = joinpath(cesta_balicek, "body") # cesta k souborům s materiály
    const cesta_matematika = joinpath(cesta_balicek, "matematika") # cesta k souborům s matematika
    const cesta_materialy = joinpath(cesta_balicek, "materialy") # cesta k souborům s materiály
    for soubor in ["gammam.toml", "materialy.db", "materialy.toml", 
        "materialyCSNkovy.toml", "materialyCSNlitina.toml", "materialyCSNocel.toml",
        "materialydatabaseKovyCSN.toml", "materialydatabaseLitinaCSN.toml", "materialydatabaseOcelCSN.toml",
        "materialydatabaseOcelEN10025_2.toml", "materialydatabasePryz.toml",
        "materialyvychozi.toml"]
        if !isfile(joinpath(cesta_materialy, soubor))
            cp(joinpath(@__DIR__, "materialy", soubor), joinpath(cesta_materialy, soubor))
        end
    end
    const cesta_namahani = joinpath(cesta_balicek, "namahani") # cesta k souborům s namahani
    const cesta_profily = joinpath(cesta_balicek, "profily") # cesta k souborům s profily
    for soubor in ["profil_I_CSN425550.toml", "profil_IPE_CSN425553.toml", "profil_TR4HR_CSN425720.toml"]
        if !isfile(joinpath(cesta_profily, soubor))
            cp(joinpath(@__DIR__, "profily", soubor), joinpath(cesta_profily, soubor))
        end
    end
    const cesta_spojovacimaterial = joinpath(cesta_balicek, "spojovacimaterial") # cesta k souborům s spojovacimaterial
    for soubor in ["zavity.db"]
        if !isfile(joinpath(cesta_spojovacimaterial, soubor))
            cp(joinpath(@__DIR__, "spojovacimaterial", soubor), joinpath(cesta_spojovacimaterial, soubor))
        end
    end
    const cesta_tolerance = joinpath(cesta_balicek, "tolerance") # cesta k souborům s tolerance
    for soubor in ["toleranceISOulozIT.toml", "toleranceISOulozPOLE.toml"]
        if !isfile(joinpath(cesta_tolerance, soubor))
            cp(joinpath(@__DIR__, "tolerance", soubor), joinpath(cesta_tolerance, soubor))
        end
    end
else
    const cesta_balicek = @__DIR__ # cesta k souboru s nastavením
    const cesta_body = joinpath(cesta_balicek, "body") # cesta k souborům s materiály
    const cesta_matematika = joinpath(cesta_balicek, "matematika") # cesta k souborům s matematika
    const cesta_materialy = joinpath(cesta_balicek, "materialy") # cesta k souborům s materiály
    const cesta_namahani = joinpath(cesta_balicek, "namahani") # cesta k souborům s namahani
    const cesta_profily = joinpath(cesta_balicek, "profily") # cesta k souborům s profily
    const cesta_spojovacimaterial = joinpath(cesta_balicek, "spojovacimaterial") # cesta k souborům s spojovacimaterial
    const cesta_tolerance = joinpath(cesta_balicek, "tolerance") # cesta k souborům s tolerance
end
