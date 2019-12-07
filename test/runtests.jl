using HashDicts: HashDict
using Test

import HashDicts

@testset "HashDict construction" begin
    d = HashDict([("A", 1), ("B", 2)])
    d2 = HashDict("A" => 1, "B" => 2)
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
