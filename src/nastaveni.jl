# ver: 2026-09-22
using SpravaSouboru

function nastaveni()
    println("cesta k datům balíčku:")
    println(cesta_balicek)
    a01, _ = menutext("nastaveni", ["změna cesty", "konec"])
    #println("Vybral jsi možnost $a01: $a02")
    if a01 == 1
        println("cesta k datům balíčku:")
        println(cesta_balicek)
        pathnew = joinpath(homedir(), "StrojniSoucasti")
        if !isdir(pathnew)
            a02, _ = menutext("změna cesty", ["nastavit: $pathnew", "konec"])
            #println("Vybral jsi možnost $a02: $b02")
            if a02 == 1
                mkdir(pathnew)
                println("cesta k datům balíčku byla nastavena na:")
                println(pathnew)
                println("!!nutno restartovat Julia!!")
            end
        else
            println("již existuje složka: $pathnew")
        end
    end

end
