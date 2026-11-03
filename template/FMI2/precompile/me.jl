#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# FMI 2 Model Exchange entry points, included only for ME-capable FMUs.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetTime), FMICore.fmi2Component, FMICore.fmi2Real})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetContinuousStates), FMICore.fmi2Component, Ptr{FMICore.fmi2Real}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2EnterEventMode), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2NewDiscreteStates), FMICore.fmi2Component, Ptr{FMICore.fmi2EventInfo}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2EnterContinuousTimeMode), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2CompletedIntegratorStep), FMICore.fmi2Component, FMICore.fmi2Boolean, Ptr{FMICore.fmi2Boolean}, Ptr{FMICore.fmi2Boolean}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetDerivatives), FMICore.fmi2Component, Ptr{FMICore.fmi2Real}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetEventIndicators), FMICore.fmi2Component, Ptr{FMICore.fmi2Real}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetContinuousStates), FMICore.fmi2Component, Ptr{FMICore.fmi2Real}, Csize_t})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetNominalsOfContinuousStates), FMICore.fmi2Component, Ptr{FMICore.fmi2Real}, Csize_t})
