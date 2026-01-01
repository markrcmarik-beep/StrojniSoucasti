# ver: 2025-11-13
using StrojniSoucasti, Unitful, Unitful.DefaultSymbols

A = mezUnavy(250u"MPa", 450u"MPa", "tah", "rázový")
println(A)
B = mezUnavy(260MPa, 440MPa, "tah", "rázový")
println(B)