using PlotJuggler
using Test


using ModelingToolkit
using DifferentialEquations: solve

t = 0:0.01:5
freq = 2.0
a = cos.(2 * pi / freq * t)
b = sin.(2 * pi / freq * t)
c = a .* exp.(-t)
d = b .* exp.(-t)

@testset "XY plots" begin
  # return # uncomment to disable these tests
  coords = (; a, b)
  pjplot(t, coords; xy=coords)

  exp_t = exp.(-t)
  pjplot(t, (; c, d, exp_t); xy=(; c, d))
end

@testset "ODE solution" begin
  # Adapted from https://mtk.sciml.ai/stable/tutorials/ode_modeling/
  @variables t x(t) y(t)   # independent and dependent variables
  @parameters τ       # parameters 
  @constants h = 1    # constants have an assigned value
  D = Differential(t) # define an operator for the differentiation w.r.t. time
  @named fol = ODESystem([D(x) ~ y + (h - x) / τ, D(y) ~ -x])
  prob = ODEProblem(fol, [x => 0.0, y => 1.0], (0.0, 20.0), [τ => 3.0])
  sol = solve(prob)
  pjplot(sol; title="ODE Solution")
end

@testset "Basic Usage" begin
  # return # uncomment to disable these tests
  pjplot(2:2:20; title="Simple range")
  curves2 = (; a, b, ab=a .* b, exp_t=exp.(-t))
  pjplot(t, curves2; title="NamedTuple")
  pjplot([0, 1, 2], [1, 2, 4]; title="Vector (ints)")
  pjplot(t, a; title="Vector (anonymous)")
  pjplot(t, (; a); title="Vector (named)")
  curves = [a, b, 2 * a, 2 * b, 3 * a, 3 * b, 4 * a, 4 * b, 5 * a, 5 * b] # <: Vector
  pjplot(t, curves; title="Vector of Vectors")
  curves_dict = Dict("a" => a)
  pjplot(t, curves_dict; title="Dict")
  curves_dict = Dict(:a => a)
  pjplot(t, curves_dict; title="Dict (symbol)")
end


