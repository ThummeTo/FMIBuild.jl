#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] One statement per line (parsed line by line by PackageCompiler), `FMIBUILD_MODULE` is replaced
#        by the FMU module name during the build and types are qualified, because PackageCompiler only
#        resolves (loaded) modules when executing the statements.
# FMI 2 common entry points shared by ME and CS FMUs.
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetTypesPlatform)})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetVersion)})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2Instantiate), FMICore.fmi2String, FMICore.fmi2Type, FMICore.fmi2String, FMICore.fmi2String, Ptr{FMICore.fmi2CallbackFunctions}, FMICore.fmi2Boolean, FMICore.fmi2Boolean})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2FreeInstance), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetDebugLogging), FMICore.fmi2Component, FMICore.fmi2Boolean, Csize_t, Ptr{FMICore.fmi2String}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetupExperiment), FMICore.fmi2Component, FMICore.fmi2Boolean, FMICore.fmi2Real, FMICore.fmi2Real, FMICore.fmi2Boolean, FMICore.fmi2Real})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2EnterInitializationMode), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2ExitInitializationMode), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2Terminate), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2Reset), FMICore.fmi2Component})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetReal), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Real}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetInteger), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Integer}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetBoolean), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Boolean}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2GetString), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2String}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetReal), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Real}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetInteger), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Integer}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetBoolean), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2Boolean}})
precompile(Tuple{typeof(FMIBUILD_MODULE.jl_fmi2SetString), FMICore.fmi2Component, Ptr{FMICore.fmi2ValueReference}, Csize_t, Ptr{FMICore.fmi2String}})
