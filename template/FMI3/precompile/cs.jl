#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# FMI 3 Co-Simulation entry points, included only for CS-capable FMUs.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3EnterStepMode), FMICore.fmi3Instance})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetOutputDerivatives), FMICore.fmi3Instance, Ptr{FMICore.fmi3ValueReference}, Csize_t, Ptr{FMICore.fmi3Int32}, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3DoStep), FMICore.fmi3Instance, FMICore.fmi3Float64, FMICore.fmi3Float64, FMICore.fmi3Boolean, Ptr{FMICore.fmi3Boolean}, Ptr{FMICore.fmi3Boolean}, Ptr{FMICore.fmi3Boolean}, Ptr{FMICore.fmi3Float64}})
