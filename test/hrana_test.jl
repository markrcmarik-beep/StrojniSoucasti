# ver: 2026-01-27
using Test
using StrojniSoucasti

@testset "hrana" begin

B = StrojniSoucasti.hrana("R5", pi/2, "out")
@test B[:info] === "R"
@test B[:rozmer] == "R5"
@test B[:R] == 5

B = StrojniSoucasti.hrana("R4.25", pi/2, "out")
@test B[:info] === "R"
@test B[:rozmer] == "R4.25"
@test B[:R] == 4.25

end

B = StrojniSoucasti.hrana("2x2", pi/2, "out")
println(B)

B = StrojniSoucasti.hrana("2x45deg", pi/2, "out")
println(B)

B = StrojniSoucasti.hrana("2x2", 30*pi/180, "out")
println(B)

B = StrojniSoucasti.hrana("2x45deg", 30*pi/180, "out")
println(B)
