# Shared Julia runtime initialization entry point.
precompile(Tuple{typeof(.jl_init_FMU), Ptr{Cchar}})
