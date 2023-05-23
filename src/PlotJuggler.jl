module PlotJuggler

export pjplot

using DelimitedFiles
using SciMLBase: AbstractODESolution

include("xml_templates.jl")

# Write your package code here.

pjpath = try
        strip(read(`which plotjuggler`, String))
    catch
        defaultpath = "/Users/patrick/bin/plotjuggler" # TODO: make customizable
        println("Warning: using default path of $(defaultpath)")
        defaultpath
    end

defaultcolors = ["#1f77b4", "#d62728", "#1ac938", "#ff7f0e", "#f14cc1", "#9467bd", "#17becf", "#bcbd22", "#1f77b4", "#000000"]

"""
    pjplot(t, curves)

Start a PlotJuggler session with `t` as the time variable and `curves` the data to plot against time. Each curve will be given a distinct color (up to 10, then the colors repeat) solid line.

# Examples
For convenience the `curves` argument can take several forms. The most common would be to pass a [`NamedTuple`](@ref) which will allow the names of the variables in the calling scope to be picked up as the curve names automatically:

```
t = 0:0.1:5
freq = 2.0
a = cos.(2*pi/freq*t)
b = sin.(2*pi/freq*t)

pjplot(t, (; a, b))
```

If a simple `Vector` (or compatible type) is passed in for the second argument then it will be plotted against time and named `data1` in the plot:
```
pjplot(t, 2*t)
```

If a Vector of Vectors is passed in for the second argument then each one will be named as `data1`, `data2`, etc.:
```
pjplot(t, [t, 2*t, 4*t])
```

If the optional argument `xy` is set, then its value should be a NamedTuple. This will add a plot pane where the data vectors identified by the keys of this argument are plotted against one another. 
```
pjplot(t, (; a, b); xy=(; a, b))

# or equivalently
coords = (; a, b)
pjplot(t, coords; xy=coords)
``` 
"""
function pjplot(t, curves::AbstractVector{T}; kwargs...) where {T <: AbstractVector}
    curvenames = "data" .* string.(1:length(curves))
    data = (; collect(zip(Symbol.(curvenames), curves))...)
    pjplot(t, data; kwargs...)
end

function pjplot(t, data::AbstractVector{T}; kwargs...) where {T <: Number}
    pjplot(t, [data]; kwargs...)
end

function pjplot(data::AbstractVector{T}; kwargs...) where {T <: Number}
    pjplot(1:length(data), [data]; kwargs...)
end

function pjplot(t, curves::T; xy=nothing, detach=false, wait=false, title="...", kwargs...) where {T <: NamedTuple}
    # TODO: warn if an unsupported kwarg is passed? (is there a Julian way to do this?)
    
    # Generate CSV file
    path = tempname(cleanup=false) * ".csv"
    curvenames = string.(keys(curves))
    open(path, "w") do io
        write(io, join(["t", curvenames...], ","))
        write(io, "\n")
        writedlm(io, [t values(curves)...], ',')
    end

    # Generate layout file
    layoutpath = writelayoutfile(path, curvenames, title; xy=xy)

    pjcmd = `$(pjpath) --nosplash -d $(path) -l $(layoutpath)`
    run(Cmd(pjcmd; detach=detach); wait=wait)
end

function pjplot(t::AbstractVector{T}, curves::Dict{S,V}; kwargs...) where {T <: Number, S <: AbstractString, V <: AbstractVector}
  curves_nt = NamedTuple(Symbol(k) => v for (k, v) in curves)
  pjplot(t, curves_nt; kwargs...)
end

function pjplot(t::AbstractVector{T}, curves::Dict{Symbol,V}; kwargs...) where {T <: Number, V <: AbstractVector}
  curves_nt = NamedTuple(curves)
  pjplot(t, curves_nt; kwargs...)
end

function pjplot(sol::T; kwargs...) where {T <: AbstractODESolution}
  size_u, size_t = size(sol)
  curves = Dict("u$(i)" => u for (i, u) in enumerate(eachrow(sol)))
  pjplot(sol.t, curves; kwargs...)
end

function writelayoutfile(datapath, curvenames, plottitle; xy=nothing, xytitle=nothing)
    path = tempname(cleanup=false) * ".xml"
    @info "layout file: $(path)"
    do_xyplot = !isnothing(xy)
    open(path, "w") do io
        xmlout = xml_templates.header(do_xyplot ? 2 : 1)
        
        xmlout *= xml_templates.dockarea("TimeSeries", plottitle)
        for i = eachindex(curvenames)
            xmlout *= xml_templates.curve(curvenames[i], defaultcolors[mod1(i, length(defaultcolors))])
        end
        xmlout *= xml_templates.plot_foot
        xmlout *= xml_templates.dockarea_foot
        
        if do_xyplot
          xname = string(keys(xy)[1])
          yname = string(keys(xy)[2])
          xmlout *= xml_templates.dockarea("XYPlot", isnothing(xytitle) ? "$(xname), $(yname) vs. t" : xytitle)
          xmlout *= xml_templates.xycurve(xname, yname, defaultcolors[1])
          xmlout *= xml_templates.plot_foot
          xmlout *= xml_templates.dockarea_foot
        end

        xmlout *= xml_templates.footer
        write(io, xmlout)
    end
    return path
end

end