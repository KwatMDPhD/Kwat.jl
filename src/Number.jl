module Number

using Printf: @sprintf

using ..Nucleus

function format2(nu)

    @sprintf "%.2g" nu

end

function format4(nu)

    @sprintf "%.4g" nu

end

function categorize(nu, nu_, ca_)

    i1 = findfirst(>(nu), nu_)

    ca_[isnothing(i1) ? end : i1]

end

function try_parse(st)

    try

        return convert(Int, parse(Float64, st))

    catch

    end

    try

        return parse(Float64, st)

    catch

    end

    st

end

function integize(an_)

    an_i1 = Nucleus.Collection._map_index(sort!(unique(an_)))

    [an_i1[an] for an in an_]

end

end
