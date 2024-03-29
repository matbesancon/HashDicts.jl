
struct Bucket{K, V}
    items::Vector{Pair{K, V}}
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

"""
    Base.setindex!(b::Bucket{K, V}, value::V, key::K) where {K, V}

Set `value` for `key`, returns a tuple `(value, replaced::Boolean)`.
"""
function Base.setindex!(b::Bucket{K, V}, value::V, key::K) where {K, V}
    for i in eachindex(b.items)
        (k, v) = b.items[i]
        if k == key
            b.items[i] = key => value
            return (value, true)
        end
    end
    push!(b.items, key => value)
    return (value, false)
end

function Base.getindex(b::Bucket{K, V}, key::K) where {K, V}
    for (k, v) in b.items
        if k == key
            return v
        end
    end
    throw(KeyError("Key $key not in collection."))
end

function Base.get(b::Bucket{K, V}, key::K, default::V) where {K, V}
    for (k, v) in b.items
        if k == key
            return v
        end
    end
    return default
end

function Base.haskey(b::Bucket{K, V}, key::K) where {K, V}
    for (k, v) in b.items
        if k == key
            return true
        end
    end
    return false
end

function Base.delete!(b::Bucket{K, V}, key::K) where {K, V}
    for (i, pair) in enumerate(b.items)
        (k, v) = pair
        if k == key
            deleteat!(b.items, i)
            return true
        end
    end
    return false
end

function Base.empty!(b::Bucket)
    empty!(b.items)
    return nothing
end
