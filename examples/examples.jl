using HashDicts: HashDict

d = HashDict([("A", 1), ("B", 2)])
d2 = HashDict("A"=>1, "B"=>2)

for (k, v) in [("hi", 2), ("", 0)]
    global d
    d[k] = v
    @assert d[k] == v
end
 