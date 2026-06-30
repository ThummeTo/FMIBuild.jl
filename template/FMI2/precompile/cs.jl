#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# FMI 2 Co-Simulation entry points, included only for CS-capable FMUs.
precompile(Tuple{typeof(.jl_fmi2SetRealInputDerivatives), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}})
precompile(Tuple{typeof(.jl_fmi2GetRealOutputDerivatives), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}})
precompile(Tuple{typeof(.jl_fmi2DoStep), fmi2Component, fmi2Real, fmi2Real, fmi2Boolean})
precompile(Tuple{typeof(.jl_fmi2CancelStep), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2GetStatus), fmi2Component, fmi2StatusKind, Ptr{fmi2Status}})
precompile(Tuple{typeof(.jl_fmi2GetRealStatus), fmi2Component, fmi2StatusKind, Ptr{fmi2Real}})
precompile(Tuple{typeof(.jl_fmi2GetIntegerStatus), fmi2Component, fmi2StatusKind, Ptr{fmi2Integer}})
precompile(Tuple{typeof(.jl_fmi2GetBooleanStatus), fmi2Component, fmi2StatusKind, Ptr{fmi2Boolean}})
precompile(Tuple{typeof(.jl_fmi2GetStringStatus), fmi2Component, fmi2StatusKind, Ptr{fmi2String}})
