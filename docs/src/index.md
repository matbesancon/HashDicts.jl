# HashDicts

Like `Base.Dict`, but slower. This package defines a single `AbstractDict` type which
relies on key hashnig and equality comparison.

```@docs
HashDict
```

# Resizing and managing capacity

```@docs
Base.resize!(d::HashDict{K, V}) where {K, V}
Base.resize!(d::HashDict{K, V}, capacity::Integer) where {K, V}
```

```@docs
HashDicts.LOAD_FACTOR
```