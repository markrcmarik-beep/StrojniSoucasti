# ver: 2026-01-14
using StrojniSoucasti

Z = StrojniSoucasti.zavity.zavity()
z = Z("M8")

z.name       # "M8x1.25"
z.stoupani   # 1.25
z.d          # 8.0
z.typ        # :metric
