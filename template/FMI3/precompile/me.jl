#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# FMI 3 Model Exchange entry points, included only for ME-capable FMUs.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3EnterContinuousTimeMode), FMICore.fmi3Instance})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3CompletedIntegratorStep), FMICore.fmi3Instance, FMICore.fmi3Boolean, Ptr{FMICore.fmi3Boolean}, Ptr{FMICore.fmi3Boolean}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3SetTime), FMICore.fmi3Instance, FMICore.fmi3Float64})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3SetContinuousStates), FMICore.fmi3Instance, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetContinuousStateDerivatives), FMICore.fmi3Instance, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetEventIndicators), FMICore.fmi3Instance, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetContinuousStates), FMICore.fmi3Instance, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetNominalsOfContinuousStates), FMICore.fmi3Instance, Ptr{FMICore.fmi3Float64}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetNumberOfEventIndicators), FMICore.fmi3Instance, Ptr{Csize_t}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi3GetNumberOfContinuousStates), FMICore.fmi3Instance, Ptr{Csize_t}})
