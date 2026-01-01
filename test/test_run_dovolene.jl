using Unitful
include("c:/Users/markr/ProjektyTechnika/Julia/funkce/balicky/StrojniSoucasti/src/dovoleneNapeti.jl")
println("tah statický: ", dovoleneNapeti(250u"MPa", "tah", "statický"))
println("tah-střih statický-statický: ", dovoleneNapeti(250u"MPa", "tah-střih", "statický-statický"))
println("otlačení statický: ", dovoleneNapeti(250u"MPa", "otlačení", "statický"))
