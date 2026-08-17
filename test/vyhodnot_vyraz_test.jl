# ver: 2026-08-17
# Test script for vyhodnot_vyraz.jl
using StrojniSoucasti, Test

@testset "vyhodnot_vyraz" begin
    # Test basic arithmetic operations
    @testset "Arithmetic operations" begin
        data = Dict(:a => 10, :b => 5, :c => 2.0)
        @test StrojniSoucasti.vyhodnot_vyraz("a + b", data) == 15
        @test StrojniSoucasti.vyhodnot_vyraz("a - b", data) == 5
        @test StrojniSoucasti.vyhodnot_vyraz("a * b", data) == 50
        @test StrojniSoucasti.vyhodnot_vyraz("a / b", data) == 2.0
        @test StrojniSoucasti.vyhodnot_vyraz("b ^ c", data) == 25.0
        @test StrojniSoucasti.vyhodnot_vyraz("a + b * c", data) == 20.0 # Order of operations
        @test StrojniSoucasti.vyhodnot_vyraz("(a + b) * c", data) == 30.0
    end

    # Test unary operations
    @testset "Unary operations" begin
        data = Dict(:x => 5)
        @test StrojniSoucasti.vyhodnot_vyraz("+x", data) == 5
        @test StrojniSoucasti.vyhodnot_vyraz("-x", data) == -5
        @test StrojniSoucasti.vyhodnot_vyraz("- (x + 2)", data) == -7
    end

    # Test mathematical functions
    @testset "Mathematical functions" begin
        data = Dict(:val => 4.0, :angle => pi/2, :pi => Base.pi)
        @test StrojniSoucasti.vyhodnot_vyraz("sqrt(val)", data) == 2.0
        @test StrojniSoucasti.vyhodnot_vyraz("sin(angle)", data) ≈ 1.0
        @test StrojniSoucasti.vyhodnot_vyraz("cos(angle)", data) ≈ 0.0 atol=1e-9
        
        data_tan = Dict(:angle => pi/4, :pi => Base.pi)
        @test StrojniSoucasti.vyhodnot_vyraz("tan(angle)", data_tan) ≈ 1.0
        @test StrojniSoucasti.vyhodnot_vyraz("abs(-val)", data) == 4.0
        @test StrojniSoucasti.vyhodnot_vyraz("log(exp(val))", data) ≈ 4.0
        @test StrojniSoucasti.vyhodnot_vyraz("exp(log(val))", data) ≈ 4.0
    end

    # Test with no variables (only numbers)
    @testset "Literal numbers" begin
        data = Dict()
        @test StrojniSoucasti.vyhodnot_vyraz("123", data) == 123
        @test StrojniSoucasti.vyhodnot_vyraz("12.34", data) == 12.34
        @test StrojniSoucasti.vyhodnot_vyraz("1 + 2 * 3", data) == 7
    end

    # Test error handling
    @testset "Error handling" begin
        data = Dict(:a => 10)
        # Invalid variable
        @test_throws ArgumentError StrojniSoucasti.vyhodnot_vyraz("a + b", data)
        # Unsupported operator/function
        @test_throws ArgumentError StrojniSoucasti.vyhodnot_vyraz("a % 2", data)
        @test_throws ArgumentError StrojniSoucasti.vyhodnot_vyraz("my_func(a)", data)
        # Malformed expression (Meta.parse handles some, but eval_expr might catch others)
        #@test_throws Meta.ParseError StrojniSoucasti.vyhodnot_vyraz("1 +", data)
    end

    # Test unsupported expression types (e.g., control flow)
    @testset "Unsupported expression types" begin
        data = Dict()
        @test_throws ArgumentError StrojniSoucasti.vyhodnot_vyraz("begin 1 end", data)
        @test_throws ArgumentError StrojniSoucasti.vyhodnot_vyraz("if true 1 else 0 end", data)
    end

    # Test complex expressions
    @testset "Complex expressions" begin
        data = Dict(:x => 3.0, :y => 4.0, :z => 5.0, :pi => Base.pi)
        expr = "sqrt(x^2 + y^2) / z"
        @test StrojniSoucasti.vyhodnot_vyraz(expr, data) == 1.0 # sqrt(9+16)/5 = sqrt(25)/5 = 5/5 = 1
        expr2 = "sin(pi/2) + cos(0) - abs(-10)"
        @test StrojniSoucasti.vyhodnot_vyraz(expr2, data) ≈ (1.0 + 1.0 - 10.0)
    end
end

nothing
