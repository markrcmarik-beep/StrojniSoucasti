# ver: 2025-12-06
using StrojniSoucasti, Test

    # zajistí, že máme dostupnou implementaci
    # include(joinpath(dirname(@__FILE__), "materialy.jl"))

    println("Test 1: '11 500'")
    B, C = materialy("11 500")
    println("Schrnutí: ", C)
    display(B)
    println("E: ", B[:E])
    println(B[:Re])
    println(C)

    println("\nTest 2: '11373'")
    B, C = materialy("11373")
    println("Summary: ", C)
    display(B)

    println("\nTest 3: '1.0553'")
    B, C = materialy("1.0553")
    println("Summary: ", C)
    display(B)

    println("\nTest 4: 'bronz'")
    B, C = materialy("bronz")
    println("Summary: ", C)
    display(B)

    println("\nTest 5: unknown 'bhronz' (should error)")
    B, C = materialy("bhronz")
        println("Unexpected success:")
        display(B)

if abspath(PROGRAM_FILE) == @__FILE__
    materialy_test()
end