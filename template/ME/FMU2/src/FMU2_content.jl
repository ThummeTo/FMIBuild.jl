#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import FMICore

# import FMICore: fmi2Instantiate, fmi2FreeInstance!, fmi2GetTypesPlatform, fmi2GetVersion
# import FMICore: fmi2SetDebugLogging, fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
# import FMICore: fmi2GetReal!, fmi2SetReal, fmi2GetInteger!, fmi2SetInteger, fmi2GetBoolean!, fmi2SetBoolean, fmi2GetString!, fmi2SetString
# import FMICore: fmi2GetFMUstate!, fmi2SetFMUstate, fmi2FreeFMUstate!, fmi2SerializedFMUstateSize!, fmi2SerializeFMUstate!, fmi2DeSerializeFMUstate!
# import FMICore: fmi2GetDirectionalDerivative!, fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives
# import FMICore: fmi2DoStep, fmi2CancelStep, fmi2GetStatus!, fmi2GetRealStatus!, fmi2GetIntegerStatus!, fmi2GetBooleanStatus!, fmi2GetStringStatus!
# import FMICore: fmi2SetTime, fmi2SetContinuousStates, fmi2EnterEventMode, fmi2NewDiscreteStates, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep!
# import FMICore: fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates

using FMICore: fmi2CallbackFunctions, fmi2Component, fmi2ComponentEnvironment, fmi2EventInfo, fmi2ValueReference
using FMICore: fmi2Real, fmi2Integer, fmi2Boolean, fmi2String, fmi2True, fmi2False, fmi2StatusError, fmi2StatusFatal
using FMICore: fmi2Status, fmi2Type, fmi2StatusToString
using FMICore: FMU2Component

##############

global FMIBUILD_FMU = nothing
global FMIBUILD_CONSTRUCTOR = nothing
global FMIBUILD_LOGGING = false
global FMIBUILD_INSTANCES = []

# a more light weight version of the FMICore.FMU2Component
struct FMU2ComponentSimple
    address::fmi2Component
    instanceName::String
    fmuType::fmi2Type
    fmuGUID::String
    fmuResourceLocation::String
    functions::fmi2CallbackFunctions
    visible::fmi2Boolean
    loggingOn::fmi2Boolean
end

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

# 2.1.4
Base.@ccallable function fmi2GetTypesPlatform()::fmi2String
    return FMICore.fmi2GetTypesPlatform(FMIBUILD_FMU.cGetTypesPlatform)
end

Base.@ccallable function fmi2GetVersion()::fmi2String
    return FMICore.fmi2GetVersion(FMIBUILD_FMU.cGetVersion)
end

# 2.1.5
Base.@ccallable function fmi2Instantiate(_instanceName::fmi2String,
                                         fmuType::fmi2Type,
                                         _fmuGUID::fmi2String,
                                         _fmuResourceLocation::fmi2String,
                                         _functions::Ptr{fmi2CallbackFunctions},
                                         visible::fmi2Boolean,
                                         loggingOn::fmi2Boolean)::fmi2Component
    
    _component = FMICore.fmi2Instantiate(FMIBUILD_FMU.cInstantiate, _instanceName, fmuType, _fmuGUID, _fmuResourceLocation, _functions, visible, loggingOn)

    if FMIBUILD_LOGGING
        logInfo(_component, "fmi2Instantiate($(_instanceName), $(fmuType), $(_fmuGUID), $(_fmuResourceLocation), $(_functions), $(visible), $(loggingOn))\n\t-> $(_component)")
    end

    return _component
end

Base.@ccallable function fmi2FreeInstance(_component::fmi2Component)::Cvoid
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2FreeInstance($(_component))")
        end
        FMICore.fmi2FreeInstance!(FMIBUILD_FMU.cFreeInstance, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> [NOTHING]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: fmi2FreeInstance($(_component))\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end

    return nothing
end

Base.@ccallable function fmi2SetDebugLogging(_component::fmi2Component, loggingOn::fmi2Boolean, nCategories::Csize_t, categories::Ptr{fmi2String})::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetDebugLogging($(_component), $(loggingOn), $(nCategories), $(categories))")
        end
        status = FMICore.fmi2SetDebugLogging(FMIBUILD_FMU.cSetDebugLogging, _component, loggingOn, nCategories, categories)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetupExperiment(_component::fmi2Component, toleranceDefined::fmi2Boolean, tolerance::fmi2Real, startTime::fmi2Real, stopTimeDefined::fmi2Boolean, stopTime::fmi2Real)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetupExperiment($(_component), $(toleranceDefined), $(tolerance), $(startTime), $(stopTimeDefined), $(stopTime))")
        end
        status = FMICore.fmi2SetupExperiment(FMIBUILD_FMU.cSetupExperiment, _component, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2EnterInitializationMode(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2EnterInitializationMode($(_component))")
        end
        status = FMICore.fmi2EnterInitializationMode(FMIBUILD_FMU.cEnterInitializationMode, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2ExitInitializationMode(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2ExitInitializationMode($(_component))")
        end
        status = FMICore.fmi2ExitInitializationMode(FMIBUILD_FMU.cExitInitializationMode, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2Terminate(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2Terminate($(_component))")
        end
        status = FMICore.fmi2Terminate(FMIBUILD_FMU.cTerminate, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2Reset(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2Reset($(_component))")
        end
        status = FMICore.fmi2Reset(FMIBUILD_FMU.cReset, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e 
        logError(_component, "Exception thrown:\tIn function: fmi2Reset($(_component))\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    return status
end

Base.@ccallable function fmi2GetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})::fmi2Status 
    status = fmi2StatusError
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetReal($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2GetReal!(FMIBUILD_FMU.cGetReal, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e 
        logError(_component, "Exception thrown:\tIn function: fmi2GetReal($(_component), $(_vr), $(nvr), $(_value))\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    return status
end

Base.@ccallable function fmi2GetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetInteger($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2GetInteger!(FMIBUILD_FMU.cGetInteger, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetBoolean($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2GetBoolean!(FMIBUILD_FMU.cGetBoolean, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetString($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2GetString!(FMIBUILD_FMU.cGetString, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetReal($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2SetReal(FMIBUILD_FMU.cSetReal, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetInteger($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2SetInteger(FMIBUILD_FMU.cSetInteger, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetBoolean($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2SetBoolean(FMIBUILD_FMU.cSetBoolean, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})::fmi2Status
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetString($(_component), $(_vr), $(nvr), $(_value))")
        end
        status = FMICore.fmi2SetString(FMIBUILD_FMU.cSetString, _component, _vr, nvr, _value)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetTime(_component::fmi2Component, time::fmi2Real)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetTime($(_component), $(time))")
        end
        status = FMICore.fmi2SetTime(FMIBUILD_FMU.cSetTime, _component, time)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2SetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2SetContinuousStates($(_component), $(_x), $(nx))")
        end
        status = FMICore.fmi2SetContinuousStates(FMIBUILD_FMU.cSetContinuousStates, _component, _x, nx)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2EnterEventMode(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2EnterEventMode($(_component))")
        end
        status = FMICore.fmi2EnterEventMode(FMIBUILD_FMU.cEnterEventMode, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2NewDiscreteStates(_component::fmi2Component, _fmi2eventInfo::Ptr{fmi2EventInfo})::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2NewDiscreteStates($(_component), $(_fmi2eventInfo))")
        end
        status = FMICore.fmi2NewDiscreteStates!(FMIBUILD_FMU.cNewDiscreteStates, _component, _fmi2eventInfo)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2EnterContinuousTimeMode(_component::fmi2Component)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2EnterContinuousTimeMode($(_component))")
        end
        status = FMICore.fmi2EnterContinuousTimeMode(FMIBUILD_FMU.cEnterContinuousTimeMode, _component)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2CompletedIntegratorStep(_component::fmi2Component, noSetFMUStatePriorToCurrentPoint::fmi2Boolean, enterEventMode::Ptr{fmi2Boolean}, terminateSimulation::Ptr{fmi2Boolean})::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2CompletedIntegratorStep($(_component), $(noSetFMUStatePriorToCurrentPoint), $(enterEventMode), $(terminateSimulation))")
        end
        status = FMICore.fmi2CompletedIntegratorStep!(FMIBUILD_FMU.cCompletedIntegratorStep, _component, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetDerivatives(_component::fmi2Component, _derivatives::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    status = fmi2StatusError
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetDerivatives($(_component), $(_derivatives), $(nx))")
        end
        status = FMICore.fmi2GetDerivatives!(FMIBUILD_FMU.cGetDerivatives, _component, _derivatives, nx)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: fmi2GetDerivatives($(_component), $(_derivatives), $(nx))\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetEventIndicators(_component::fmi2Component, _eventIndicators::Ptr{fmi2Real}, ni::Csize_t)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetEventIndicators($(_component), $(_eventIndicators), $(ni))")
        end
        status = FMICore.fmi2GetEventIndicators!(FMIBUILD_FMU.cGetEventIndicators, _component, _eventIndicators, ni)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetContinuousStates($(_component), $(_x), $(nx))")
        end
        status = FMICore.fmi2GetContinuousStates!(FMIBUILD_FMU.cGetContinuousStates, _component, _x, nx)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end

Base.@ccallable function fmi2GetNominalsOfContinuousStates(_component::fmi2Component, _x_nominal::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    status = fmi2StatusError 
    try
        if FMIBUILD_LOGGING
            logInfo(_component, "fmi2GetNominalsOfContinuousStates($(_component), $(_x_nominal), $(nx))")
        end
        status = FMICore.fmi2GetNominalsOfContinuousStates!(FMIBUILD_FMU.cGetNominalsOfContinuousStates, _component, _x_nominal, nx)
        if FMIBUILD_LOGGING
            logInfo(_component, "\t-> $(status) [$(fmi2StatusToString(status))]")
        end
    catch e
        logError(_component, "Exception thrown:\tIn function: ...\n\tMessage: $(e)\n\tStack:")
        for s in stacktrace()
            logError(_component, "$(s)")
        end
    end
    
    return status
end
