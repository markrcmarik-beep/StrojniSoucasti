# ver: 2026-01-27
using Test
using StrojniSoucasti

@testset "hrana" begin

#A1 = hrana("2x2", π/2, "out")
#A1 = println(A1)

#A2 = hrana("2x45deg", π/2, "out")
#A2 = println(A2)

B = StrojniSoucasti.hrana("R5", pi/2, "out")
B = println(B[:info])
@test B[:info] === "R"
#@test B[:rozmer] == "R5"
#@test B[:R] == 5

end
