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
