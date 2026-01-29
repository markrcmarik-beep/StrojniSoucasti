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

B = StrojniSoucasti.hrana("2x2", pi/2, "out")
@test B[:info] === "sražení"
@test B[:rozmer] == "2x2"
@test B[:x1] == 2
@test B[:x2] == 2
@test B[:S] == 2 * 2 / 2

@test_throws ErrorException(
    "Neznámé nebo nepodporované označení profilu: \"k2xk2\"") begin
    StrojniSoucasti.hrana("k2xk2", pi/2, "out")
end

B = StrojniSoucasti.hrana("2x2", pi/2, "out")
@test B[:info] === "sražení"
@test B[:rozmer] == "2x2"
@test B[:x1] == 2
@test B[:x2] == 2
@test B[:S] == 2 * 2 / 2

B = StrojniSoucasti.hrana("2x45deg", pi/2, "out")
@test B[:info] === "sražení"
@test B[:rozmer] == "2x45˚"
@test B[:x1] == 2
println(B[:x2])
#@test B[:x2] == 2
#@test B[:S] == 2 * 2 / 2

B = StrojniSoucasti.hrana("2x2", 30*pi/180, "out")
@test B[:info] === "sražení"
@test B[:rozmer] == "2x2"
@test B[:x1] == 2
@test B[:x2] == 2

B = StrojniSoucasti.hrana("2x45deg", 30*pi/180, "out")
@test B[:info] === "sražení"
@test B[:rozmer] == "2x45˚"
@test B[:x1] == 2

end
