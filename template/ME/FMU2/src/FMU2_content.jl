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

using FMICore: fmi2CallbackFunctions, fmi2Component, fmi2EventInfo, fmi2ValueReference
using FMICore: fmi2Real, fmi2Integer, fmi2Boolean, fmi2String
using FMICore: fmi2Status, fmi2Type

##############

global FMIBUILD_FMU = nothing
global FMIBUILD_CONSTRUCTOR = nothing

Base.@ccallable function init_FMU()::Cvoid
    global FMIBUILD_FMU, FMIBUILD_CONSTRUCTOR
    FMIBUILD_FMU = FMIBUILD_CONSTRUCTOR()
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
Base.@ccallable function fmi2Instantiate(instanceName::fmi2String,
                                         fmuType::fmi2Type,
                                         fmuGUID::fmi2String,
                                         fmuResourceLocation::fmi2String,
                                         functions::Ptr{fmi2CallbackFunctions},
                                         visible::fmi2Boolean,
                                         loggingOn::fmi2Boolean)::fmi2Component
    return FMICore.fmi2Instantiate(FMIBUILD_FMU.cInstantiate, instanceName, fmuType, fmuGUID, fmuResourceLocation, functions, visible, loggingOn)
end

Base.@ccallable function fmi2FreeInstance(_component::fmi2Component)::Cvoid
    FMICore.fmi2FreeInstance!(FMIBUILD_FMU.cFreeInstance, _component)
    nothing
end

Base.@ccallable function fmi2SetDebugLogging(_component::fmi2Component, loggingOn::fmi2Boolean, nCategories::Csize_t, categories::Ptr{fmi2String})::fmi2Status 
    return FMICore.fmi2SetDebugLogging(FMIBUILD_FMU.cSetDebugLogging, _component, loggingOn, nCategories, categories)
end

Base.@ccallable function fmi2SetupExperiment(_component::fmi2Component, toleranceDefined::fmi2Boolean, tolerance::fmi2Real, startTime::fmi2Real, stopTimeDefined::fmi2Boolean, stopTime::fmi2Real)::fmi2Status 
    return FMICore.fmi2SetupExperiment(FMIBUILD_FMU.cSetupExperiment, _component, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end

Base.@ccallable function fmi2EnterInitializationMode(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2EnterInitializationMode(FMIBUILD_FMU.cEnterInitializationMode, _component)
end

Base.@ccallable function fmi2ExitInitializationMode(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2ExitInitializationMode(FMIBUILD_FMU.cExitInitializationMode, _component)
end

Base.@ccallable function fmi2Terminate(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2Terminate(FMIBUILD_FMU.cTerminate, _component)
end

Base.@ccallable function fmi2Reset(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2Reset(FMIBUILD_FMU.cReset, _component)
end

Base.@ccallable function fmi2GetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})::fmi2Status 
    return FMICore.fmi2GetReal!(FMIBUILD_FMU.cGetReal, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2GetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})::fmi2Status
    return FMICore.fmi2GetInteger!(FMIBUILD_FMU.cGetInteger, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2GetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})::fmi2Status
    return FMICore.fmi2GetBoolean!(FMIBUILD_FMU.cGetBoolean, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2GetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})::fmi2Status
    return FMICore.fmi2GetString!(FMIBUILD_FMU.cGetString, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2SetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})::fmi2Status 
    return FMICore.fmi2SetReal(FMIBUILD_FMU.cSetReal, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2SetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})::fmi2Status
    return FMICore.fmi2SetInteger(FMIBUILD_FMU.cSetInteger, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2SetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})::fmi2Status
    return FMICore.fmi2SetBoolean(FMIBUILD_FMU.cSetBoolean, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2SetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})::fmi2Status
    return FMICore.fmi2SetString(FMIBUILD_FMU.cSetString, _component, _vr, nvr, _value)
end

Base.@ccallable function fmi2SetTime(_component::fmi2Component, time::fmi2Real)::fmi2Status 
    return FMICore.fmi2SetTime(FMIBUILD_FMU.cSetTime, _component, time)
end

Base.@ccallable function fmi2SetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    return FMICore.fmi2SetContinuousStates(FMIBUILD_FMU.cSetContinuousStates, _component, _x, nx)
end

Base.@ccallable function fmi2EnterEventMode(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2EnterEventMode(FMIBUILD_FMU.cEnterEventMode, _component)
end

Base.@ccallable function fmi2NewDiscreteStates(_component::fmi2Component, _fmi2eventInfo::Ptr{fmi2EventInfo})::fmi2Status 
    return FMICore.fmi2NewDiscreteStates!(FMIBUILD_FMU.cNewDiscreteStates, _component, _fmi2eventInfo)
end

Base.@ccallable function fmi2EnterContinuousTimeMode(_component::fmi2Component)::fmi2Status 
    return FMICore.fmi2EnterContinuousTimeMode(FMIBUILD_FMU.cEnterContinuousTimeMode, _component)
end

Base.@ccallable function fmi2CompletedIntegratorStep(_component::fmi2Component, noSetFMUStatePriorToCurrentPoint::fmi2Boolean, enterEventMode::Ptr{fmi2Boolean}, terminateSimulation::Ptr{fmi2Boolean})::fmi2Status 
    return FMICore.fmi2CompletedIntegratorStep!(FMIBUILD_FMU.cCompletedIntegratorStep, _component, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
end

Base.@ccallable function fmi2GetDerivatives(_component::fmi2Component, _derivatives::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    return FMICore.fmi2GetDerivatives!(FMIBUILD_FMU.cGetDerivatives, _component, _derivatives, nx)
end

Base.@ccallable function fmi2GetEventIndicators(_component::fmi2Component, _eventIndicators::Ptr{fmi2Real}, ni::Csize_t)::fmi2Status 
    return FMICore.fmi2GetEventIndicators!(FMIBUILD_FMU.cGetEventIndicators, _component, _eventIndicators, ni)
end

Base.@ccallable function fmi2GetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    return FMICore.fmi2GetContinuousStates!(FMIBUILD_FMU.cGetContinuousStates, _component, _x, nx)
end

Base.@ccallable function fmi2GetNominalsOfContinuousStates(_component::fmi2Component, _x_nominal::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status 
    return FMICore.fmi2GetNominalsOfContinuousStates!(FMIBUILD_FMU.cGetNominalsOfContinuousStates, _component, _x_nominal, nx)
end
