module Nodes

import Base: show

abstract type Node end

function get_values() end

function set_index!(no, id)

    if !(0 <= id <= lastindex(get_values(no)))

        throw(DomainError(id))

    end

    return no.index = id

end

macro node(no, va_)

    quote

        mutable struct $no <: Node

            index::UInt16

            function $no()

                return new(0)

            end

            function $no(id)

                no = new()

                set_index!(no, id)

                return no

            end

        end

        function $(esc(:(PGMs.Nodes.get_values)))(::$(esc(no)))

            return $(esc(va_))

        end

    end

end

function show(io::IO, no::Node)

    ty = rsplit(string(typeof(no)), '.'; limit = 2)[end]

    va_ = get_values(no)

    id = no.index

    return print(io, iszero(id) ? "$ty = $va_" : "$ty = $va_[$id] = $(va_[id])")

end

end

module Factors

using MacroTools: combinedef, splitdef

function p!() end

macro factor(fu)

    sp = splitdef(fu)

    if sp[:name] != :p!

        error("the function name is not `p!`.")

    end

    if !issorted(sp[:args][2:end]; by = ar -> ar.args[2])

        error("the second to last arguments are not sorted by their types.")

    end

    sp[:name] = :(PGMs.Factors.p!)

    quote

        $(esc(combinedef(sp)))

    end

end

end

module Graphs

using Graphs: AbstractGraph, SimpleDiGraph, add_edge!, add_vertex!, nv

using ..PGMs

struct Graph

    gr::AbstractGraph

    no_::Vector{DataType}

    no_id::Dict{DataType, UInt16}

    function Graph()

        return new(SimpleDiGraph(), DataType[], Dict{DataType, UInt16}())

    end

end

function add_node!(gr, no)

    if haskey(gr.no_id, no)

        error("$no exists.")

    end

    add_vertex!(gr.gr)

    push!(gr.no_, no)

    return gr.no_id[no] = nv(gr.gr)

end

function graph(mo)

    gr = Graph()

    for na in names(mo; all = true)

        fi = getfield(mo, na)

        if fi isa DataType && fi <: PGMs.Nodes.Node

            add_node!(gr, fi)

        end

    end

    for me in methods(PGMs.Factors.p!)

        pa_ = me.sig.parameters

        if isone(lastindex(pa_))

            continue

        end

        pa_ = pa_[2:end]

        if any(pa -> !haskey(gr.no_id, pa), pa_)

            continue

        end

        ic = gr.no_id[pa_[1]]

        for pa in pa_[2:end]

            add_edge!(gr.gr, gr.no_id[pa] => ic)

        end

    end

    return gr

end

end
