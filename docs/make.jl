using PlotJuggler
using Documenter

DocMeta.setdocmeta!(PlotJuggler, :DocTestSetup, :(using PlotJuggler); recursive=true)

makedocs(;
    modules=[PlotJuggler],
    authors="Patrick Bouffard <airpmb@fastmail.com> and contributors",
    repo="https://github.com/pbouffard/PlotJuggler.jl/blob/{commit}{path}#{line}",
    sitename="PlotJuggler.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://pbouffard.github.io/PlotJuggler.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pbouffard/PlotJuggler.jl",
    devbranch="main",
)
