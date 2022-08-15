using PlotJuggler
using Test

t = 0:0.01:5
freq = 2.0
a = cos.(2*pi/freq*t)
b = sin.(2*pi/freq*t)
c = a .* exp.(-t)
d = b .* exp.(-t)

@testset "XY plots" begin
    coords = (; a, b)
    pjplot(t, coords; xy=coords)

    exp_t=exp.(-t)
    pjplot(t, (; c, d, exp_t); xy=(; c, d))
end

@testset "Basic Usage" begin
    # Write your tests here.
    
    println("Implicit t = 1, 2, 3, ..., N")
    
    pjplot(2:2:20)
    println("NamedTuple")
    curves2 = (;a, b, ab=a.*b, exp_t=exp.(-t))  # <: NamedTuple
    pjplot(t, curves2)

    # return # skip for now
    
    println("Vector (ints)")
    pjplot([0, 1, 2], [1, 2, 4])
    
    println("Vector (anonymous)")
    pjplot(t, a)
    
    println("Vector (named)")
    pjplot(t, (; a))
    

    println("Vector of Vectors")
    curves = [a, b, 2*a, 2*b, 3*a, 3*b, 4*a, 4*b, 5*a, 5*b] # <: Vector
    pjplot(t, curves)

end


