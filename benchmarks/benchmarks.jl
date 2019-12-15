using HashDicts: HashDict

using BenchmarkTools: @benchmark
import Random

function iterated_entry_insert(d::AbstractDict{K, V}, key_iter, value_iter) where {K, V}
    for (k, v) in zip(key_iter, value_iter)
        d[k] = v
    end
    return nothing
end

function safe_get_functions(d::AbstractDict{K, V}, key_iter, default::V) where {K, V}
    default_counter = 0
    for key in key_iter
        v = get(d, key, default)
        if v == default
            default_counter += 1
        end
    end
    return default_counter
end

function unsafe_getindex(d::AbstractDict, key_iter)
    found = 0
    for key in key_iter
        if haskey(d, key)
            v = d[key]
            found += 1
        end
    end
    return found
end

function basic_benchmark(number_items = 1000, rng::Random.AbstractRNG = Random.GLOBAL_RNG)
    @info "Benchmarking with $number_items items"
    key_iter = rand(rng, Int, number_items)
    value_iter = string.(key_iter)
    for d in (Dict{Int,String}(), HashDict{Int,String}())
        @info "benchmarking $(typeof(d))"
        display(@benchmark iterated_entry_insert($d, $key_iter, $value_iter))
        @info "Benchmarking on existing keys"
        display(@benchmark safe_get_functions($d, $key_iter, ""))
        display(@benchmark unsafe_getindex($d, $key_iter))
        new_keys = rand(rng, Int, number_items)
        @info "Benchmarking on new keys"
        display(@benchmark safe_get_functions($d, $new_keys, ""))
        display(@benchmark unsafe_getindex($d, $new_keys))
    end
end

Random.seed!(42)
basic_benchmark(1000)
basic_benchmark(5000)
