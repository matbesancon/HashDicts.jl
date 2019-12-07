
# iterate(iter [, state]) -> Union{Nothing, Tuple{Any, Any}}

struct Bucket{K, V}
    items::Vector{Tuple{K, V}}
end

function Base.iterate(b::Bucket)
    if isempty(b.items)
        return nothing
    end
    return (b.items[1], 2)
end

function Base.iterate(b::Bucket, state::Int)
    if length(b.items) < state
        return nothing
    end
    return (b.items[state], state + 1)
end

function Base.setindex!(b::Bucket{K, V}, value::V, key::K) where {K, V}
    for i in eachindex(b.items)
        (k, v) = b.items[i]
        if k == key
            b.items[i] = (key, value)
            return value
        end
    end
    push!(b.items, (key, value))
    return value
end

function Base.getindex(b::Bucket{K, V}, key::K) where {K, V}
    for (k, v) in b.items
        if k == key
            return v
        end
    end
    throw(KeyError("Key $key not in collection."))
end
