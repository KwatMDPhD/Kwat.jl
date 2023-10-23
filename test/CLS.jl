using Test: @test

using Nucleus

# ---- #

const DA = joinpath(Nucleus._DA, "CLS")

# ---- #

@test Nucleus.Path.read(DA) == ["CCLE_mRNA_20Q2_no_haem_phen.cls", "GSE76137.cls", "LPS_phen.cls"]

# ---- #

for n in (10, 100, 1000)

    st_ = string.(1:n)

    # 172.545 ns (1 allocation: 144 bytes)
    # 1.346 μs (1 allocation: 896 bytes)
    # 13.334 μs (1 allocation: 7.94 KiB)
    #@btime Nucleus.CLS._make_matrix(st -> parse(Float64, st), $st_)

end

# ---- #

for (cl, ta, re) in (
    (
        "CCLE_mRNA_20Q2_no_haem_phen.cls",
        "HER2",
        [1.087973, -1.358492, -1.178614, -0.77898, 0.157222, 1.168224, -0.360195, 0.608629],
    ),
    ("GSE76137.cls", "Proliferating_Arrested", [1, 2, 1, 2, 1, 2]),
    ("LPS_phen.cls", "CNTRL_LPS", [1, 1, 1, 2, 2, 2]),
)

    cl = joinpath(DA, cl)

    nar, ro_, co_, ta_x_sa_x_nu = Nucleus.DataFrame.separate(Nucleus.CLS.read(cl))

    @test nar === "Target"

    @test ro_ == [ta]

    @test all(startswith("Sample "), co_)

    @test eltype(ta_x_sa_x_nu) === eltype(re)

    @test view(ta_x_sa_x_nu, 1, eachindex(re)) == re

    # 387.667 μs (6234 allocations: 530.46 KiB)
    # 9.875 μs (98 allocations: 7.70 KiB)
    # 9.666 μs (98 allocations: 7.64 KiB)
    #@btime Nucleus.CLS.read($cl)

end
