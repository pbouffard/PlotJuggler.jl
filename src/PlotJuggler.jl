module PlotJuggler

using DelimitedFiles

include("xml_templates.jl")

# Write your package code here.

pjpath = "/Users/patrick/dev/PlotJuggler/install/bin/plotjuggler" # TODO: make customizable

defaultcolors = ["#1f77b4", "#d62728", "#1ac938", "#ff7f0e", "#f14cc1", "#9467bd", "#17becf", "#bcbd22", "#1f77b4"]

function pjplot(t, curves)
    # Generate CSV file
    path = tempname(cleanup=false) * ".csv"
    @show path
    curvenames = "data" .* string.(1:length(curves))
    open(path, "w") do io
        write(io, join(["t"; curvenames], ","))
        write(io, "\n")
        writedlm(io, [t curves...], ',')
    end

    # Generate layout file
    layoutpath = writelayoutfile(path, curvenames)

    pjcmd = `$(pjpath) --nosplash -d $(path) -l $(layoutpath)`
    # pjcmd = `$(pjcmdstr)`
    @show pjcmd
    # start PJ (TODO - surely there's a better way to spawn PJ and return immediately..?)
    pjbashcmd = `/bin/bash -c "$(pjcmd)"\&`
    run(Cmd(pjcmd; detach=true))
end

function writelayoutfile(datapath, curvenames)
    path = tempname(cleanup=false) * ".xml"
    open(path, "w") do io
        xmlout = xml_templates.header
        for i = eachindex(curvenames)
            xmlout *= xml_templates.curve(curvenames[i], defaultcolors[mod1(i, length(defaultcolors))])
        end
        xmlout *= xml_templates.footer
        write(io, xmlout)
    end
    return path
end

end