#!/usr/bin/env julia

using StrojniSoucasti

println("Testing select_material...")

# Test 1: Re_req = 210.0
req = MaterialRequest(210.0, -10.0, true, 25.0)
mat = select_material(req)
println("Test 1: $(mat.name)")
@assert mat.name == "S235J2+N" "Expected S235J2+N, got $(mat.name)"

# Test 2: Re_req = 300.0
req = MaterialRequest(300.0, -20.0, true, 30.0)
mat = select_material(req)
println("Test 2: $(mat.name)")
@assert mat.name == "S355J2+N" "Expected S355J2+N, got $(mat.name)"

println("All tests passed!")
