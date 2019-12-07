
"""
    HashDict{K, V}

Dict-like behavior, stores key-value pairs by key hash.
"""
struct HashDict{K, V}
    buckets::Vector{Bucket{K, V}}
    base_size::Int
end

function HashDict{K, V}(; base_size::Int = 1024) where {K, V}
    buckets = [Bucket{K, V}([]) for _ in 1:base_size]
    return HashDict{K, V}(buckets, base_size)
end

function HashDict(items::Vector{Tuple{K, V}}; base_size = 1024) where {K, V}
    d = HashDict{K, V}(base_size = base_size)
    for (k, v) in items
        d[k] = v
    end
    return d
end

function HashDict(items::Vararg{Tuple{K, V}}; base_size = 1024) where {K, V}
    return HashDict(collect(items), base_size = base_size)
end

function HashDict(items::Vector{Pair{K, V}}; base_size = 1024) where {K, V}
    d = HashDict{K, V}(base_size = base_size)
    for (k, v) in items
        d[k] = v
    end
    return d
end

function HashDict(items::Vararg{Pair{K, V}}; base_size = 1024) where {K, V}
    return HashDict(collect(items), base_size = base_size)
end

function Base.setindex!(d::HashDict{K, V}, value::V, key::K) where {K, V}
    key_hash = hash(key)
    idx = key_hash % d.base_size
    bucket = d.buckets[idx]
    return bucket[key] = value
end
