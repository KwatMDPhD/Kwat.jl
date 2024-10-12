using Omics

using Test: @test

# ----------------------------------------------------------------------------------------------- #

# ---- #

for mo in (
    "Color",
    "Density",
    "Dic",
    "HTM",
    "Normalization",
    "Palette",
    "Path",
    "Plot",
    "Probability",
    "Significance",
    "Strin",
    "Table",
)

    @info mo

    run(`julia --project $mo.jl`)

end
