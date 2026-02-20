# Test Suite

# Here we can write tests for our Julia code.

using Test

# Example test
function test_example()
    @test 1 + 1 == 2
end

test_example()