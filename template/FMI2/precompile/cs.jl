#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# FMI 2 Co-Simulation entry points, included only for CS-capable FMUs.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetRealInputDerivatives), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Integer}, Ptr{FMICore.fmi2Real}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetRealOutputDerivatives), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Integer}, Ptr{FMICore.fmi2Real}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2DoStep), FMICore.fmi2Component, FMICore.fmi2Real, FMICore.fmi2Real, FMICore.fmi2Boolean})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2CancelStep), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetStatus), FMICore.fmi2Component, FMICore.fmi2StatusKind, Ptr{FMICore.fmi2Status}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetRealStatus), FMICore.fmi2Component, FMICore.fmi2StatusKind, Ptr{FMICore.fmi2Real}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetIntegerStatus), FMICore.fmi2Component, FMICore.fmi2StatusKind, Ptr{FMICore.fmi2Integer}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetBooleanStatus), FMICore.fmi2Component, FMICore.fmi2StatusKind, Ptr{FMICore.fmi2Boolean}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetStringStatus), FMICore.fmi2Component, FMICore.fmi2StatusKind, Ptr{FMICore.fmi2String}})
