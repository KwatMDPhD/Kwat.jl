using Colors: RGB

using Test: @test

using Omics

# ---- #

for (co, re) in ((RGB(1.0, 0.0, 0.0), "#ff0000ff"),)

    @test Omics.Color.hexify(co) === re

end

# ---- #

for st in ("red", "#f00", "#ff0000")

    @test Omics.Color.hexify(st) === "#ff0000ff"

    for (al, re) in ((0.0, "#ff000000"), (0.5, "#ff000080"))

        @test Omics.Color.hexify(st, al) === re

    end

end
