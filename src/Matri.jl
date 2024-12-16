module Matri

using ..Omics

function collapse(fu, ty, ro_, ma)

    ur, uc = size(ma)

    r2_id_ = Omics.Dic.index2(ro_)

    u2 = length(r2_id_)

    @info "Collapsing using `$fu` and making ($ur -->) $u2 x $uc"

    r2_ = sort(collect(keys(r2_id_)))

    m2 = Matrix{ty}(undef, u2, uc)

    for i2 in eachindex(r2_)

        id_ = r2_id_[r2_[i2]]

        m2[i2, :] =
            isone(lastindex(id_)) ? view(ma, id_[], :) :
            [fu(an_) for an_ in eachcol(ma[id_, :])]

    end

    r2_, m2

end

function joi(fi, r1_, c1_, a1, r2_, c2_, a2)

    rj_ = union(r1_, r2_)

    cj_ = union(c1_, c2_)

    aj = fill(fi, lastindex(rj_), lastindex(cj_))

    rj_id = Omics.Dic.index(rj_)

    cj_id = Omics.Dic.index(cj_)

    for (ro_, co_, an) in ((r1_, c1_, a1), (r2_, c2_, a2))

        for (ic, co) in enumerate(co_), (ir, ro) in enumerate(ro_)

            aj[rj_id[ro], cj_id[co]] = an[ir, ic]

        end

    end

    rj_, cj_, aj

end

end
