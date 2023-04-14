#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import FMICore

using FMICore: fmi2CallbackFunctions, fmi2Component, fmi2ComponentEnvironment, fmi2EventInfo, fmi2ValueReference
using FMICore: fmi2Real, fmi2Integer, fmi2Boolean, fmi2String, fmi2True, fmi2False, fmi2StatusError, fmi2StatusFatal
using FMICore: fmi2Status, fmi2Type, fmi2StatusToString
using FMICore: FMU2Component

##############

global FMIBUILD_FMU = nothing
global FMIBUILD_CONSTRUCTOR = nothing
global FMIBUILD_LOGGING = true
global FMIBUILD_INSTANCES = []

Base.@ccallable function init_FMU(_dllLoc::Ptr{Cchar})::Cvoid
    dllLoc = unsafe_string(_dllLoc)
    comps = splitpath(dllLoc)
    resLoc = joinpath(comps[1:end-3]..., "resources")

    @info "init_FMU(...)\nDLL location: $(dllLoc)\nRessouces location: $(resLoc)"

    global FMIBUILD_FMU, FMIBUILD_CONSTRUCTOR
    FMIBUILD_FMU = FMIBUILD_CONSTRUCTOR(resLoc)

    if !isnothing(FMIBUILD_FMU)
        @info "init_FMU(...): FMU constructed successfully."
    else
        @error "init_FMU(...): FMU construction failed!"
    end

    nothing
end