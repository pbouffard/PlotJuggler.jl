using PlotJuggler
using Test

@testset "PlotJuggler.jl" begin
    # Write your tests here.
    t = 0:0.1:10
    freq = 2.0
    a = cos.(2*pi/freq*t)
    b = sin.(2*pi/freq*t)
    PlotJuggler.pjplot(t, [a, b, 2*a, 2*b, 3*a, 3*b, 4*a, 4*b, 5*a, 5*b])
end
