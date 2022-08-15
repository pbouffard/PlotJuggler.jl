module PlotJuggler

export pjplot

using DelimitedFiles

include("xml_templates.jl")

# Write your package code here.

pjpath = try
        strip(read(`which plotjuggler`, String))
    catch
        defaultpath = "/Users/patrick/dev/PlotJuggler/install/bin/plotjuggler" # TODO: make customizable
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
function pjplot(t, curves::AbstractVector{T}) where {T <: AbstractVector}
    curvenames = "data" .* string.(1:length(curves))
    data = (; collect(zip(Symbol.(curvenames), curves))...)
    pjplot(t, data)
end

function pjplot(t, data::AbstractVector{T}) where {T <: Number}
    pjplot(t, [data])
end

function pjplot(data::AbstractVector{T}) where {T <: Number}
    pjplot(1:length(data), [data])
end

function pjplot(t, curves::T; xy=nothing) where {T <: NamedTuple}
    # Generate CSV file
    path = tempname(cleanup=false) * ".csv"
    curvenames = string.(keys(curves))
    open(path, "w") do io
        write(io, join(["t", curvenames...], ","))
        write(io, "\n")
        writedlm(io, [t values(curves)...], ',')
    end

    # Generate layout file
    layoutpath = writelayoutfile(path, curvenames; xy=xy)

    pjcmd = `$(pjpath) --nosplash -d $(path) -l $(layoutpath)`
    # pjcmd = `$(pjcmdstr)`
    # start PJ (TODO - surely there's a better way to spawn PJ and return immediately..?)
    pjbashcmd = `/bin/bash -c "$(pjcmd)"\&`
    run(Cmd(pjcmd; detach=false))
end

function writelayoutfile(datapath, curvenames; xy=nothing)
    path = tempname(cleanup=false) * ".xml"
    @info "layout file: $(path)"
    doxyplot = !isnothing(xy)
    open(path, "w") do io
        xmlout = xml_templates.header(doxyplot ? 2 : 1)
        
        xmlout *= xml_templates.dockarea("TimeSeries")
        for i = eachindex(curvenames)
            xmlout *= xml_templates.curve(curvenames[i], defaultcolors[mod1(i, length(defaultcolors))])
        end
        xmlout *= xml_templates.plot_foot
        xmlout *= xml_templates.dockarea_foot
        
        if doxyplot
            xmlout *= xml_templates.dockarea("XYPlot")
            xmlout *= xml_templates.xycurve(string(keys(xy)[1]), string(keys(xy)[2]), defaultcolors[1])
            xmlout *= xml_templates.plot_foot
            xmlout *= xml_templates.dockarea_foot
        end

        xmlout *= xml_templates.footer
        write(io, xmlout)
    end
    return path
end

end