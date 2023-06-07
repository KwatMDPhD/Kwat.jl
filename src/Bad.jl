module Bad

# TODO: Consider removing.

function _get_bad(::Any)

    ()

end

function _get_bad(::Type{Float64})

    (-Inf, Inf, NaN)

end

function _get_bad(::Type{<:AbstractString})

    ("",)

end

function error_bad_type(an, ty)

    if !(an isa ty)

        error("There is a bad type; $an is not a $ty.")

    end

    for ba in _get_bad(ty)

        if isequal(an, ba)

            error("There is a bad type; $an is a bad $ty.")

        end

    end

end

end
