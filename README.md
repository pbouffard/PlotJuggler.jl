# PlotJuggler

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pbouffard.github.io/PlotJuggler.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pbouffard.github.io/PlotJuggler.jl/dev/)
[![Build Status](https://github.com/pbouffard/PlotJuggler.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pbouffard/PlotJuggler.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/pbouffard/PlotJuggler.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/pbouffard/PlotJuggler.jl)

A very basic package for getting timeseries plots out of your Julia session and into [PlotJuggler](https://github.com/facontidavide/PlotJuggler) *fast*.

## Usage
```
t = 0:0.1:100
a = cos.(2*pi*t)
b = sin.(2*pi*t)

pjplot(t, [a, b])
```