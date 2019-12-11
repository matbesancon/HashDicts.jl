using HashDicts: HashDict
using Test

import HashDicts

@testset "HashDict construction" begin
    d = HashDict([("A", 1), ("B", 2)])
    d2 = HashDict("A" => 1, "B" => 2)
    @test d["A"] == d2["A"] == 1
    @test d["B"] == d2["B"] == 2
end

@testset "Bucket construction and iteration" begin
    b = HashDicts.Bucket([(1, 2), (2, 8)])
    for (k, v) in b
        @test k == 1 || k == 2
        @test v == 2 || v == 8
    end
    b[8] = 33
    @test b[8] == 33
end

@testset "Number of entries kept up-to-date" begin
    d = HashDict([("A", 1), ("B", 2)])
    @test d.number_entries == 2
    @test length(d) == 2
    d["T"] = 2
    @test d.number_entries == 3    
    @test length(d) == 3
    d["T"] = 1
    @test d.number_entries == 3    
    d2 = delete!(d, "T")
    @test d2 === d
    @test d.number_entries == 2
    @test_throws KeyError d["T"]
end

@testset "Iteration over HashDict" begin
    d = HashDict{Int,Int}()
    for value in d
    end
    d[1] = 42
    for (k, v) in d
        @test k == 1
        @test v == 42
    end
    d[2] = 42
    for (k, v) in d
        @test k < 3
        @test v == 42
    end
    d2 = Dict{Int, UInt8}()
    idxs = rand(Int, 100)
    vals = rand(UInt8, 100)
    for i in eachindex(idxs)
        d2[idxs[i]] = vals[i]
        @test haskey(d2, idxs[i])
    end
    for (k, v) in d2
        idx = findfirst(==(k), idxs)
        @test idx !== nothing
        d2[idxs[idx]] = vals[idx]
    end
    d3 = Dict{Int, Int}()
    idxs = rand(Int, 100)
    vals = abs.(rand(Int, 100))
    for i in eachindex(idxs)
        d3[idxs[i]] = vals[i]
    end
    for (k, v) in d3
        idx = findfirst(==(k), idxs)
        @test idx !== nothing
        d3[idxs[idx]] = vals[idx]
        @test get(d3, idxs[idx], -1) != -1
    end

    # deleting and default
    for key in idxs[1:10]
        delete!(d3, key)
        @test get(d3, key, -1) == -1
    end
end

@testset "Emptying HashDict" begin
    d = HashDict([("A", 1), ("B", 2)])
    @test length(d) == 2
    empty!(d)   
    @test length(d) == 0
    for (k, v) in d
        @test v > 5
    end
end


@testset "Displaying HashDicts" begin
    d = HashDict(2 => "", 3 => "hi")
    io = IOBuffer()
    show(io, d)
    result_str = String(take!(io))
    @test result_str == """
HashDict{Int64,String} with 2 entries:
  2 => ""
  3 => "hi"
"""
end

@testset "Resizing does not affect HashDict" begin
    d = HashDict(2 => "", 3 => "hi")
    initial_size = length(d.buckets)
    @test length(d) == 2
    for (k, v) in d
        @test 2 <= k <= 3
        @test 0 <= length(v) <= 2
    end
    resize!(d)
    @test length(d) == 2
    for (k, v) in d
        @test 2 <= k <= 3
        @test 0 <= length(v) <= 2
    end
    @test length(d.buckets) == 2 * initial_size
end

@testset "Adding elements causes resize" begin
    d = HashDict{Int, String}(base_size = 10)
    @test length(d.buckets) == 10
    for i in 1:10:301
        d[i] = string(i)
    end
    @test length(d.buckets) == 20
    for i in 1:60
        d[i+301] = string(i)
    end
    @test length(d.buckets) == 40
end

@testset "Allocating capacity avoids automatic resize!" begin
    d = HashDict{Int, String}(base_size = 10)
    @test length(d.buckets) == 10
    for i in 1:10:301
        d[i] = string(i)
    end
    @test length(d.buckets) == 20
    resize!(d, 15)
    @test length(d.buckets) == 35
    for i in 1:60
        d[i+301] = string(i)
    end
    @test length(d.buckets) == 35
end
