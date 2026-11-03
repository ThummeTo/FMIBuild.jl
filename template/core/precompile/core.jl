#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# Shared Julia runtime initialization entry point.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_init_FMU), Ptr{Cchar}})
