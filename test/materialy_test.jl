# ver: 2025-12-06
using StrojniSoucasti, Test

    # zajistí, že máme dostupnou implementaci
    # include(joinpath(dirname(@__FILE__), "materialy.jl"))

    println("Test 1: '11 500'")
    B, C = materialy("11 500")
    println(B)
    println(C)

    println("\nTest 2: '11 448'")
    B, C = materialy("11 448")
    println("Summary: ", C)
    display(B)

    println("\nTest 3: '1.0553'")
    B, C = materialy("1.0553")
    println("Summary: ", C)
    display(B)

    println("\nTest 4: '42CrMo4+Qt'")
    B, C = materialy("42CrMo4+Qt")
    println("Summary: ", C)
    display(B)

    println("\nTest 5: 16 440 kaleno a popousteno")
    B, C = materialy("16 440.4 zuslechteno")
    println(B)
    println(C)

if abspath(PROGRAM_FILE) == @__FILE__
    materialy_test()
end