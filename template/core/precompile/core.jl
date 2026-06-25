#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# Shared Julia runtime initialization entry point.
precompile(Tuple{typeof(.jl_init_FMU), Ptr{Cchar}})
