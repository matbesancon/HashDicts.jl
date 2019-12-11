
"""
    HashDict{K, V} <: AbstractDict{K, V}

Dict-like behavior, stores key-value pairs by key hash.
"""
mutable struct HashDict{K, V} <: AbstractDict{K, V}
    buckets::Vector{Bucket{K, V}}
    number_entries::Int
end

function HashDict{K, V}(; base_size::Int = 1024) where {K, V}
    buckets = [Bucket{K, V}([]) for _ in 1:base_size]
    return HashDict{K, V}(buckets, 0)
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
    bucket = find_bucket(d, key)
    (v, replaced) = setindex!(bucket, value, key)
    if !replaced
        d.number_entries += 1
        if d.number_entries > LOAD_FACTOR * length(d.buckets)
            resize!(d)
        end
    end
    return v
end

function Base.getindex(d::HashDict{K, V}, key::K) where {K, V}
    bucket = find_bucket(d, key)
    return bucket[key]
end

function Base.delete!(d::HashDict{K, V}, key::K) where {K, V}
    bucket = find_bucket(d, key)
    found = delete!(bucket, key)
    if found
        d.number_entries -= 1
    end
    return d
end

"""
    replace_for_delete!(d::HashDict{K, V}, key::K, value::V, former_size::Int)

Delete a (key, value) pair from its former location and re-add it to the `HashDict`.
"""
function replace_for_delete!(d::HashDict{K, V}, key::K, value::V, former_size::Int) where {K, V}
    key_hash = hash(key)
    new_idx = 1 + key_hash % length(d.buckets)
    new_bucket = d.buckets[new_idx]
    old_idx = 1 + key_hash % former_size
    old_bucket = d.buckets[old_idx]
    found = delete!(old_bucket, key)
    if found
        new_bucket[key] = value
    end
    return d
end

function Base.empty!(d::HashDict)
    for bucket in d.buckets
        empty!(bucket)
    end
    d.number_entries = 0
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

function Base.get(d::HashDict{K, V}, key::K, default::V) where {K, V}
    bucket = find_bucket(d, key)
    return get(bucket, key, default)    
end

function Base.haskey(d::HashDict{K, V}, key::K) where {K, V}
    bucket = find_bucket(d, key)
    return haskey(bucket, key)
end

"""
Maximum average number of items per bucket.
Resizing is performed when this average is reached.
"""
const LOAD_FACTOR = 3

"""
    Base.resize!(d::HashDict)

Double the size of the data underlying the hash dict.
Called when inserting an item goes above `LOAD_FACTOR`.
"""
function Base.resize!(d::HashDict{K, V}) where {K, V}
    l = length(d.buckets)
    resize!(d.buckets, 2l)
    for idx in l+1:2l
        d.buckets[idx] = Bucket{K, V}([])
    end
    for (k, v) in d
        replace_for_delete!(d, k, v, l)
    end
    return d
end

"""
    Base.resize!(d::HashDict{K, V}, capacity::Integer)

Resize a `HashDict` by adding a given capacity.
Becomes a no-op if `capacity <= 0`.    
"""
function Base.resize!(d::HashDict{K, V}, capacity::Integer) where {K, V}
    if capacity <= 0
        return d
    end
    l = length(d.buckets)
    new_size = l + capacity
    resize!(d.buckets, new_size)
    for idx in l+1:new_size
        d.buckets[idx] = Bucket{K, V}([])
    end
    for (k, v) in d
        replace_for_delete!(d, k, v, l)
    end
    return d
end

function find_bucket(d::HashDict{K}, key::K) where {K}
    key_hash = hash(key)
    idx = 1 + key_hash % length(d.buckets)
    return d.buckets[idx]
end
