module MatchPlot

using Distances: CorrDist, Euclidean

using ..Omics

const CO = Omics.Coloring.fractionate(("#0000ff", "#ffffff", "#ff0000"))

const OL = Dict(
    "x" => 0.5,
    "orientation" => "h",
    "len" => 0.56,
    "thickness" => 16,
    "outlinewidth" => 0,
    "title" => Dict("side" => "top"),
)

function trace_target(ns, sa_, nt, vt_, st, ur)

    Omics.Normalization.do_0_clamp!(vt_, st)

    ty = eltype(vt_)

    if ty == Bool

        vt_ = convert(Vector{Int}, vt_)

    end

    mi, ma = ty <: AbstractFloat ? (-st, st) : extrema(vt_)

    bo = 1.0 - inv(ur)

    [
        Dict(
            "type" => "heatmap",
            "y" => (nt,),
            "x" => sa_,
            "z" => (vt_,),
            "zmin" => Omics.Numbe.shorten(mi),
            "zmax" => Omics.Numbe.shorten(ma),
            "colorscale" => CO,
            "colorbar" => merge(
                OL,
                Dict(
                    "y" => -0.344,
                    "tickvals" => map(Omics.Numbe.shorten, Omics.Plot.tick(vt_)),
                ),
            ),
        ),
    ],
    Dict(
        "height" => max(640, ur * 40),
        "width" => 1280,
        "margin" => Dict("r" => 232),
        "yaxis" => Dict("domain" => (bo, 1.0), "tickfont" => Dict("size" => 16)),
        "xaxis" =>
            Dict("side" => "top", "title" => Dict("text" => "$ns ($(lastindex(sa_)))")),
        "annotations" => Dict{String, Any}[],
    ),
    bo

end

function print(n1, n2)

    "$(Omics.Numbe.shorten(n1)) ($(Omics.Numbe.shorten(n2)))"

end

function annotate(to, wi, nf, he, vr)

    an = Dict(
        "yref" => "paper",
        "xref" => "paper",
        "yanchor" => "middle",
        "showarrow" => false,
    )

    yc = to + wi * 0.392

    an_ =
        [merge(an, Dict("y" => yc, "x" => 0.5, "text" => nf, "font" => Dict("size" => 16)))]

    x1 = 1.016

    x2 = 1.128

    if he

        push!(
            an_,
            merge(
                an,
                Dict("y" => yc, "x" => x1, "xanchor" => "left", "text" => "Score (⧱)"),
            ),
        )

        push!(
            an_,
            merge(
                an,
                Dict("y" => yc, "x" => x2, "xanchor" => "left", "text" => "P Value (𝐪)"),
            ),
        )

    end

    yc = to - wi * 0.5

    for (sc, ma, pv, qv) in eachrow(vr)

        push!(
            an_,
            merge(
                an,
                Dict("y" => yc, "x" => x1, "xanchor" => "left", "text" => print(sc, ma)),
            ),
        )

        push!(
            an_,
            merge(
                an,
                Dict("y" => yc, "x" => x2, "xanchor" => "left", "text" => print(pv, qv)),
            ),
        )

        yc -= wi

    end

    an_

end

function trace_feature(sa_, nf, fe_, vf, vr, st, iy, bo, wi)

    foreach(vf_ -> Omics.Normalization.do_0_clamp!(vf_, st), eachrow(vf))

    mi, ma = eltype(vf) <: AbstractFloat ? (-st, st) : extrema(vf)

    he = iy == 2

    to = bo - wi

    bo = to - wi * lastindex(fe_)

    Dict(
        "yaxis" => "y$iy",
        "type" => "heatmap",
        "y" => map(fe -> Omics.Strin.limit(fe, 40), fe_),
        "x" => sa_,
        "z" => collect(eachrow(vf)),
        "zmin" => Omics.Numbe.shorten(mi),
        "zmax" => Omics.Numbe.shorten(ma),
        "colorscale" => CO,
        he ?
        "colorbar" => merge(
            OL,
            Dict(
                "y" => -0.456,
                "tickvals" => map(Omics.Numbe.shorten, Omics.Plot.tick(vf)),
            ),
        ) : "showscale" => false,
    ),
    Dict("yaxis$iy" => Dict("domain" => (bo, to), "autorange" => "reversed")),
    annotate(to, wi, nf, he, vr),
    bo

end

function order(vt_, vf)

    Omics.Clustering.order(isone(size(vf, 1)) ? Euclidean() : CorrDist(), vt_, eachcol(vf))

end

function order(vt_::AbstractVector{<:AbstractFloat}, ::Any)

    eachindex(vt_)

end

function writ(
    di,
    ns,
    sa_,
    nt,
    vt_,
    nf,
    fe_,
    vf,
    vr;
    u1 = 8,
    st = 3.0,
    la = Dict{String, Any}(),
)

    pr = joinpath(di, "result")

    Omics.Table.writ(
        "$pr.tsv",
        Omics.Table.make(
            nf,
            fe_,
            ["Score", "95% Margin of Error", "P-Value", "Q-Value"],
            vr,
        ),
    )

    sc_ = vr[:, 1]

    ig_ = findall(!isnan, sc_)

    ix_ = ig_[reverse!(Omics.Extreme.ge(sc_[ig_], u1))]

    fe_ = fe_[ix_]

    vf = vf[ix_, :]

    vr = vr[ix_, :]

    io_ = order(vt_, vf)

    ur = 2 + lastindex(fe_)

    tr_, la, bo = trace_target(ns, sa_[io_], nt, vt_[io_], st, ur)

    tr, ya, an_, _ = trace_feature(sa_, nf, fe_, vf[:, io_], vr, st, 2, bo, inv(ur))

    push!(tr_, tr)

    merge!(la, ya)

    append!(la["annotations"], an_)

    Omics.Plot.plot("$pr.html", tr_, la)

end

function summarize(ht, ns, sa_, nt, vt_, na___, nf___; st = 3.0, la = Dict{String, Any}())

    io_ = sortperm(vt_)

    ur = 1 + sum(nf_ -> 1 + lastindex(nf_[2]), nf___)

    tr_, la, bo = trace_target(ns, sa_[io_], nt, vt_[io_], st, ur)

    for ih in eachindex(nf___)

        nf, fe_ = nf___[ih]

        na_ = filter(na_ -> na_[1] == nf, na___)[]

        ie_ = indexin(fe_, na_[2])

        tr, ya, an_, bo = trace_feature(
            sa_,
            nf,
            fe_,
            na_[3][ie_, io_],
            na_[4][ie_, :],
            st,
            1 + ih,
            bo,
            inv(ur),
        )

        push!(tr_, tr)

        merge!(la, ya)

        append!(la["annotations"], an_)

    end

    Omics.Plot.plot(ht, tr_, la)

end

end
