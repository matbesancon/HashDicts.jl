using Documenter, HashDicts

makedocs(sitename="HashDicts documentation")

deploydocs(
    repo = "github.com/matbesancon/HashDicts.jl.git",
    versions = ["stable" => "v^", "v#.#", "dev" => "master"]
)
