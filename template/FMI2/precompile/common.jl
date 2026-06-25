#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# FMI 2 common entry points shared by ME and CS FMUs.
precompile(Tuple{typeof(.jl_fmi2GetTypesPlatform)})
precompile(Tuple{typeof(.jl_fmi2GetVersion)})
precompile(Tuple{typeof(.jl_fmi2Instantiate), fmi2String, fmi2Type, fmi2String, fmi2String, Ptr{fmi2CallbackFunctions}, fmi2Boolean, fmi2Boolean})
precompile(Tuple{typeof(.jl_fmi2FreeInstance), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2SetDebugLogging), fmi2Component, fmi2Boolean, Csize_t, Ptr{fmi2String}})
precompile(Tuple{typeof(.jl_fmi2SetupExperiment), fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real})
precompile(Tuple{typeof(.jl_fmi2EnterInitializationMode), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2ExitInitializationMode), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2Terminate), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2Reset), fmi2Component})
precompile(Tuple{typeof(.jl_fmi2GetReal), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}})
precompile(Tuple{typeof(.jl_fmi2GetInteger), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}})
precompile(Tuple{typeof(.jl_fmi2GetBoolean), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}})
precompile(Tuple{typeof(.jl_fmi2GetString), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}})
precompile(Tuple{typeof(.jl_fmi2SetReal), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}})
precompile(Tuple{typeof(.jl_fmi2SetInteger), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}})
precompile(Tuple{typeof(.jl_fmi2SetBoolean), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}})
precompile(Tuple{typeof(.jl_fmi2SetString), fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}})
