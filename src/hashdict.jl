
"""
    HashDict{K, V}

Dict-like behavior, stores key-value pairs by key hash.
"""
mutable struct HashDict{K, V}
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
