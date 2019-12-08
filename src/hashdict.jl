
"""
    HashDict{K, V} <: AbstractDict{K, V}

Dict-like behavior, stores key-value pairs by key hash.
"""
mutable struct HashDict{K, V} <: AbstractDict{K, V}
    buckets::Vector{Bucket{K, V}}
    base_size::Int
    number_entries::Int
end

function HashDict{K, V}(; base_size::Int = 1024) where {K, V}
    buckets = [Bucket{K, V}([]) for _ in 1:base_size]
    return HashDict{K, V}(buckets, base_size, 0)
end

function HashDict(items::Vector{Tuple{K, V}}; base_size = 1024) where {K, V}
    d = HashDict{K, V}(base_size = base_size)
    for (k, v) in items
        d[k] = v
    end
    return d
end

function HashDict(items::Vector{Pair{K, V}}; base_size = 1024) where {K, V}
    d = HashDict{K, V}(base_size = base_size)
    for (k, v) in items
        d[k] = v
    end
    return d
end

function HashDict(items::Vararg{Pair{K, V}}; base_size = 1024) where {K, V}
    d = HashDict{K, V}(base_size = base_size)
    for (k, v) in items
        d[k] = v
    end
    return d
end

function Base.setindex!(d::HashDict{K, V}, value::V, key::K) where {K, V}
    key_hash = hash(key)
    idx = key_hash % d.base_size
    bucket = d.buckets[idx]
    (v, replaced) = setindex!(bucket, value, key)
    if !replaced
        d.number_entries += 1
    end
    return v
end

function Base.getindex(d::HashDict{K, V}, key::K) where {K, V}
    key_hash = hash(key)
    idx = key_hash % d.base_size
    bucket = d.buckets[idx]
    return bucket[key]
end

function Base.delete!(d::HashDict{K, V}, key::K) where {K, V}
    key_hash = hash(key)
    idx = key_hash % d.base_size
    bucket = d.buckets[idx]
    found = delete!(bucket, key)
    if found
        d.number_entries -= 1
    end
    return d
end

function Base.length(d::HashDict)
    return d.number_entries
end

function Base.show(io::IO, d::HashDict{K, V}) where {K, V}
    show(io, typeof(d))
    write(io, " with $(d.number_entries) entries:\n")
    for (k, v) in d
        Base.write(io, "  ")
        Base.show(io, k)
        Base.write(io, " => ")
        Base.show(io, v)       
        Base.write(io, "\n")
    end
    return nothing
end

function Base.iterate(d::HashDict)
    if length(d) == 0
        return nothing
    end
    res = nothing
    bucket_idx = 1
    while res === nothing && bucket_idx <= length(d.buckets)
        res = iterate(d.buckets[bucket_idx])
        if res === nothing
            bucket_idx += 1
            continue
        else
            (value, bucket_state) = res
            return (value, (bucket_idx, bucket_state))
        end
    end
    return nothing
end

function Base.iterate(d::HashDict, state::Tuple{Int, Int})
    (bucket_idx, bucket_state) = state
    current_bucket = d.buckets[bucket_idx]
    res = iterate(d.buckets[bucket_idx], bucket_state)
    while res === nothing
        bucket_idx += 1
        if bucket_idx > length(d.buckets)
            return nothing
        end
        res = iterate(d.buckets[bucket_idx])        
    end
    (value, next_bucket_state) = res
    return (value, (bucket_idx, next_bucket_state))    
end
