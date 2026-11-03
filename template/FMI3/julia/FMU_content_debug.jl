#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIBase.FMICore
using FMIBase.FMICore:
    fmi3Instance,
    fmi3InstanceEnvironment,
    fmi3FMUState,
    fmi3ValueReference,
    fmi3DependencyKind
using FMIBase.FMICore:
    fmi3Float32,
    fmi3Float64,
    fmi3Int8,
    fmi3UInt8,
    fmi3Int16,
    fmi3UInt16,
    fmi3Int32,
    fmi3UInt32,
    fmi3Int64,
    fmi3UInt64,
    fmi3Boolean,
    fmi3String,
    fmi3Binary,
    fmi3Byte,
    fmi3True,
    fmi3False,
    fmi3StatusOK,
    fmi3StatusWarning,
    fmi3StatusError,
    fmi3StatusFatal
using FMIBase.FMICore: fmi3Status
import FMIBase: logInfo, logWarning, logError, FMU3Instance, statusToString

##############

global FMIBUILD_FMU = nothing
global FMIBUILD_CONSTRUCTOR = nothing
global FMIBUILD_LOGGING = true
global FMIBUILD_INSTANCES = []

const FMIBUILD_FMI3_VERSION = "3.0"

##############

function dereferenceInstance(address::fmi3Instance)
    global FMIBUILD_FMU
    for instance in FMIBUILD_FMU.instances
        if instance.addr == address
            return instance
        end
    end

    @warn "Unknown instance at $(address)."
    return nothing
end

function logInfo(_instance::fmi3Instance, message, status::fmi3Status = fmi3StatusOK)
    instance = dereferenceInstance(_instance)
    logInfo(instance, message, status)
end

function logWarning(
    _instance::fmi3Instance,
    message,
    status::fmi3Status = fmi3StatusWarning,
)
    instance = dereferenceInstance(_instance)
    logWarning(instance, message, status)
end

function logError(_instance::fmi3Instance, message, status::fmi3Status = fmi3StatusError)
    instance = dereferenceInstance(_instance)
    logError(instance, message, status)
end

# FMI functions, whose function pointers are not set in the FMU, return `fmi3Error`
function functionNotProvided(_instance::fmi3Instance, name::String)
    logError(_instance, "$(name)(...): Function is not provided by this FMU.")
    return fmi3StatusError
end

# logs an exception (with stack) thrown in an FMI function through the FMI logger
function logException(_instance::fmi3Instance, signature::String, e)
    logError(
        _instance,
        "Exception thrown:	In function: $(signature)
Message: $(e)
Stack:",
    )
    for s in stacktrace(catch_backtrace())
        logError(_instance, "$(s)")
    end
    return nothing
end

# calls `f`, logs the call and the returned status, exceptions are logged and `fmi3Error` is returned
function debugCall(f::Function, _instance::fmi3Instance, signature::String)
    status = fmi3StatusError
    try
        if FMIBUILD_LOGGING
            logInfo(_instance, signature)
        end
        status = f()
        if FMIBUILD_LOGGING
            logInfo(_instance, "	-> $(status) [$(statusToString(status))]")
        end
    catch e
        logException(_instance, signature, e)
    end
    return status
end

debugString(str::fmi3String) = (str == C_NULL ? "NULL" : "\"$(unsafe_string(str))\"")

##############

Base.@ccallable function jl_init_FMU(_dllLoc::Ptr{Cchar})::Cvoid
    dllLoc = unsafe_string(_dllLoc)
    comps = splitpath(dllLoc)
    resLoc = joinpath(comps[1:(end-3)]..., "resources")

    @info "init_FMU(...)\nDLL location: $(dllLoc)\nResources location: $(resLoc)"

    global FMIBUILD_FMU, FMIBUILD_CONSTRUCTOR
    FMIBUILD_FMU = FMIBUILD_CONSTRUCTOR(resLoc)

    if isnothing(FMIBUILD_FMU)
        @error "init_FMU(...): FMU construction failed!"
    else
        @info "init_FMU(...): FMU constructed successfully."
    end

    nothing
end

# inquire version numbers and set debug logging
Base.@ccallable function jl_fmi3GetVersion()::fmi3String
    FMIBUILD_FMU.cGetVersion == C_NULL && return pointer(FMIBUILD_FMI3_VERSION)
    return FMICore.fmi3GetVersion(FMIBUILD_FMU.cGetVersion)
end

Base.@ccallable function jl_fmi3SetDebugLogging(
    _instance::fmi3Instance,
    loggingOn::fmi3Boolean,
    nCategories::Csize_t,
    _categories::Ptr{fmi3String},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetDebugLogging($(_instance), $(loggingOn), $(nCategories), $(_categories))",
    ) do
        FMIBUILD_FMU.cSetDebugLogging == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetDebugLogging")
        return FMICore.fmi3SetDebugLogging(
            FMIBUILD_FMU.cSetDebugLogging,
            _instance,
            loggingOn,
            nCategories,
            _categories,
        )
    end
end

# creation and destruction of FMU instances
Base.@ccallable function jl_fmi3InstantiateModelExchange(
    _instanceName::fmi3String,
    _instantiationToken::fmi3String,
    _resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
)::fmi3Instance
    _instance = C_NULL
    signature = "fmi3InstantiateModelExchange($(debugString(_instanceName)), $(debugString(_instantiationToken)), $(debugString(_resourcePath)), $(visible), $(loggingOn), $(instanceEnvironment), $(logMessage))"
    try
        if FMIBUILD_FMU.cInstantiateModelExchange == C_NULL
            @error "fmi3InstantiateModelExchange(...): Model Exchange is not provided by this FMU."
            return C_NULL
        end

        _instance = FMICore.fmi3InstantiateModelExchange(
            FMIBUILD_FMU.cInstantiateModelExchange,
            _instanceName,
            _instantiationToken,
            _resourcePath,
            visible,
            loggingOn,
            instanceEnvironment,
            logMessage,
        )

        if FMIBUILD_LOGGING
            logInfo(
                _instance,
                "$(signature)
-> $(_instance)",
            )
        end
    catch e
        logException(_instance, signature, e)
    end

    return _instance
end

Base.@ccallable function jl_fmi3InstantiateCoSimulation(
    _instanceName::fmi3String,
    _instantiationToken::fmi3String,
    _resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    eventModeUsed::fmi3Boolean,
    earlyReturnAllowed::fmi3Boolean,
    _requiredIntermediateVariables::Ptr{fmi3ValueReference},
    nRequiredIntermediateVariables::Csize_t,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    intermediateUpdate::Ptr{Cvoid},
)::fmi3Instance
    _instance = C_NULL
    signature = "fmi3InstantiateCoSimulation($(debugString(_instanceName)), $(debugString(_instantiationToken)), $(debugString(_resourcePath)), $(visible), $(loggingOn), $(eventModeUsed), $(earlyReturnAllowed), $(_requiredIntermediateVariables), $(nRequiredIntermediateVariables), $(instanceEnvironment), $(logMessage), $(intermediateUpdate))"
    try
        if FMIBUILD_FMU.cInstantiateCoSimulation == C_NULL
            @error "fmi3InstantiateCoSimulation(...): Co-Simulation is not provided by this FMU."
            return C_NULL
        end

        _instance = FMICore.fmi3InstantiateCoSimulation(
            FMIBUILD_FMU.cInstantiateCoSimulation,
            _instanceName,
            _instantiationToken,
            _resourcePath,
            visible,
            loggingOn,
            eventModeUsed,
            earlyReturnAllowed,
            _requiredIntermediateVariables,
            nRequiredIntermediateVariables,
            instanceEnvironment,
            logMessage,
            intermediateUpdate,
        )

        if FMIBUILD_LOGGING
            logInfo(
                _instance,
                "$(signature)
-> $(_instance)",
            )
        end
    catch e
        logException(_instance, signature, e)
    end

    return _instance
end

Base.@ccallable function jl_fmi3FreeInstance(_instance::fmi3Instance)::Cvoid
    signature = "fmi3FreeInstance($(_instance))"
    try
        if FMIBUILD_LOGGING
            logInfo(_instance, signature)
        end

        if FMIBUILD_FMU.cFreeInstance == C_NULL
            functionNotProvided(_instance, "fmi3FreeInstance")
        else
            FMICore.fmi3FreeInstance(FMIBUILD_FMU.cFreeInstance, _instance)
        end
    catch e
        logException(_instance, signature, e)
    end

    return nothing
end

# enter and exit initialization mode, enter event mode, terminate and reset
Base.@ccallable function jl_fmi3EnterInitializationMode(
    _instance::fmi3Instance,
    toleranceDefined::fmi3Boolean,
    tolerance::fmi3Float64,
    startTime::fmi3Float64,
    stopTimeDefined::fmi3Boolean,
    stopTime::fmi3Float64,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3EnterInitializationMode($(_instance), $(toleranceDefined), $(tolerance), $(startTime), $(stopTimeDefined), $(stopTime))",
    ) do
        FMIBUILD_FMU.cEnterInitializationMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3EnterInitializationMode")
        return FMICore.fmi3EnterInitializationMode(
            FMIBUILD_FMU.cEnterInitializationMode,
            _instance,
            toleranceDefined,
            tolerance,
            startTime,
            stopTimeDefined,
            stopTime,
        )
    end
end

Base.@ccallable function jl_fmi3ExitInitializationMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3ExitInitializationMode($(_instance))") do
        FMIBUILD_FMU.cExitInitializationMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3ExitInitializationMode")
        return FMICore.fmi3ExitInitializationMode(
            FMIBUILD_FMU.cExitInitializationMode,
            _instance,
        )
    end
end

Base.@ccallable function jl_fmi3EnterEventMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3EnterEventMode($(_instance))") do
        FMIBUILD_FMU.cEnterEventMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3EnterEventMode")
        return FMICore.fmi3EnterEventMode(FMIBUILD_FMU.cEnterEventMode, _instance)
    end
end

Base.@ccallable function jl_fmi3Terminate(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3Terminate($(_instance))") do
        FMIBUILD_FMU.cTerminate == C_NULL &&
            return functionNotProvided(_instance, "fmi3Terminate")
        return FMICore.fmi3Terminate(FMIBUILD_FMU.cTerminate, _instance)
    end
end

Base.@ccallable function jl_fmi3Reset(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3Reset($(_instance))") do
        FMIBUILD_FMU.cReset == C_NULL && return functionNotProvided(_instance, "fmi3Reset")
        return FMICore.fmi3Reset(FMIBUILD_FMU.cReset, _instance)
    end
end

# getting and setting variable values
Base.@ccallable function jl_fmi3GetFloat32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Float32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetFloat32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetFloat32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetFloat32")
        return FMICore.fmi3GetFloat32!(
            FMIBUILD_FMU.cGetFloat32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetFloat64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Float64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetFloat64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetFloat64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetFloat64")
        return FMICore.fmi3GetFloat64!(
            FMIBUILD_FMU.cGetFloat64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetInt8(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int8},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetInt8($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetInt8 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetInt8")
        return FMICore.fmi3GetInt8!(
            FMIBUILD_FMU.cGetInt8,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetUInt8(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt8},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetUInt8($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetUInt8 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetUInt8")
        return FMICore.fmi3GetUInt8!(
            FMIBUILD_FMU.cGetUInt8,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetInt16(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int16},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetInt16($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetInt16 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetInt16")
        return FMICore.fmi3GetInt16!(
            FMIBUILD_FMU.cGetInt16,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetUInt16(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt16},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetUInt16($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetUInt16 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetUInt16")
        return FMICore.fmi3GetUInt16!(
            FMIBUILD_FMU.cGetUInt16,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetInt32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetInt32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetInt32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetInt32")
        return FMICore.fmi3GetInt32!(
            FMIBUILD_FMU.cGetInt32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetUInt32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetUInt32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetUInt32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetUInt32")
        return FMICore.fmi3GetUInt32!(
            FMIBUILD_FMU.cGetUInt32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetInt64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetInt64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetInt64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetInt64")
        return FMICore.fmi3GetInt64!(
            FMIBUILD_FMU.cGetInt64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetUInt64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetUInt64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetUInt64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetUInt64")
        return FMICore.fmi3GetUInt64!(
            FMIBUILD_FMU.cGetUInt64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetBoolean(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Boolean},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetBoolean($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetBoolean == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetBoolean")
        return FMICore.fmi3GetBoolean!(
            FMIBUILD_FMU.cGetBoolean,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetString(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3String},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetString($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetString == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetString")
        return FMICore.fmi3GetString!(
            FMIBUILD_FMU.cGetString,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetFloat32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Float32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetFloat32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetFloat32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetFloat32")
        return FMICore.fmi3SetFloat32(
            FMIBUILD_FMU.cSetFloat32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetFloat64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Float64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetFloat64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetFloat64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetFloat64")
        return FMICore.fmi3SetFloat64(
            FMIBUILD_FMU.cSetFloat64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetInt8(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int8},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetInt8($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetInt8 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetInt8")
        return FMICore.fmi3SetInt8(
            FMIBUILD_FMU.cSetInt8,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetUInt8(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt8},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetUInt8($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetUInt8 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetUInt8")
        return FMICore.fmi3SetUInt8(
            FMIBUILD_FMU.cSetUInt8,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetInt16(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int16},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetInt16($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetInt16 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetInt16")
        return FMICore.fmi3SetInt16(
            FMIBUILD_FMU.cSetInt16,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetUInt16(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt16},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetUInt16($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetUInt16 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetUInt16")
        return FMICore.fmi3SetUInt16(
            FMIBUILD_FMU.cSetUInt16,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetInt32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetInt32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetInt32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetInt32")
        return FMICore.fmi3SetInt32(
            FMIBUILD_FMU.cSetInt32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetUInt32(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt32},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetUInt32($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetUInt32 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetUInt32")
        return FMICore.fmi3SetUInt32(
            FMIBUILD_FMU.cSetUInt32,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetInt64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Int64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetInt64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetInt64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetInt64")
        return FMICore.fmi3SetInt64(
            FMIBUILD_FMU.cSetInt64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetUInt64(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3UInt64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetUInt64($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetUInt64 == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetUInt64")
        return FMICore.fmi3SetUInt64(
            FMIBUILD_FMU.cSetUInt64,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetBoolean(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3Boolean},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetBoolean($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetBoolean == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetBoolean")
        return FMICore.fmi3SetBoolean(
            FMIBUILD_FMU.cSetBoolean,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetString(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _values::Ptr{fmi3String},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetString($(_instance), $(_vr), $(nvr), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetString == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetString")
        return FMICore.fmi3SetString(
            FMIBUILD_FMU.cSetString,
            _instance,
            _vr,
            nvr,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3GetBinary(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _valueSizes::Ptr{Csize_t},
    _values::Ptr{fmi3Binary},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetBinary($(_instance), $(_vr), $(nvr), $(_valueSizes), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetBinary == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetBinary")
        return FMICore.fmi3GetBinary!(
            FMIBUILD_FMU.cGetBinary,
            _instance,
            _vr,
            nvr,
            _valueSizes,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3SetBinary(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _valueSizes::Ptr{Csize_t},
    _values::Ptr{fmi3Binary},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SetBinary($(_instance), $(_vr), $(nvr), $(_valueSizes), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cSetBinary == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetBinary")
        return FMICore.fmi3SetBinary(
            FMIBUILD_FMU.cSetBinary,
            _instance,
            _vr,
            nvr,
            _valueSizes,
            _values,
            nValues,
        )
    end
end

# getting variable dependency information
Base.@ccallable function jl_fmi3GetNumberOfVariableDependencies(
    _instance::fmi3Instance,
    vr::fmi3ValueReference,
    _nDependencies::Ptr{Csize_t},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetNumberOfVariableDependencies($(_instance), $(vr), $(_nDependencies))",
    ) do
        FMIBUILD_FMU.cGetNumberOfVariableDependencies == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetNumberOfVariableDependencies")
        return FMICore.fmi3GetNumberOfVariableDependencies!(
            FMIBUILD_FMU.cGetNumberOfVariableDependencies,
            _instance,
            vr,
            _nDependencies,
        )
    end
end

Base.@ccallable function jl_fmi3GetVariableDependencies(
    _instance::fmi3Instance,
    dependent::fmi3ValueReference,
    _elementIndicesOfDependent::Ptr{Csize_t},
    _independents::Ptr{fmi3ValueReference},
    _elementIndicesOfIndependents::Ptr{Csize_t},
    _dependencyKinds::Ptr{fmi3DependencyKind},
    nDependencies::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetVariableDependencies($(_instance), $(dependent), $(_elementIndicesOfDependent), $(_independents), $(_elementIndicesOfIndependents), $(_dependencyKinds), $(nDependencies))",
    ) do
        FMIBUILD_FMU.cGetVariableDependencies == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetVariableDependencies")
        return FMICore.fmi3GetVariableDependencies!(
            FMIBUILD_FMU.cGetVariableDependencies,
            _instance,
            dependent,
            _elementIndicesOfDependent,
            _independents,
            _elementIndicesOfIndependents,
            _dependencyKinds,
            nDependencies,
        )
    end
end

# getting and setting the internal FMU state
Base.@ccallable function jl_fmi3GetFMUState(
    _instance::fmi3Instance,
    _FMUState::Ptr{fmi3FMUState},
)::fmi3Status
    return debugCall(_instance, "fmi3GetFMUState($(_instance), $(_FMUState))") do
        FMIBUILD_FMU.cGetFMUState == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetFMUState")
        return FMICore.fmi3GetFMUState!(FMIBUILD_FMU.cGetFMUState, _instance, _FMUState)
    end
end

Base.@ccallable function jl_fmi3SetFMUState(
    _instance::fmi3Instance,
    FMUState::fmi3FMUState,
)::fmi3Status
    return debugCall(_instance, "fmi3SetFMUState($(_instance), $(FMUState))") do
        FMIBUILD_FMU.cSetFMUState == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetFMUState")
        return FMICore.fmi3SetFMUState(FMIBUILD_FMU.cSetFMUState, _instance, FMUState)
    end
end

Base.@ccallable function jl_fmi3FreeFMUState(
    _instance::fmi3Instance,
    _FMUState::Ptr{fmi3FMUState},
)::fmi3Status
    return debugCall(_instance, "fmi3FreeFMUState($(_instance), $(_FMUState))") do
        FMIBUILD_FMU.cFreeFMUState == C_NULL &&
            return functionNotProvided(_instance, "fmi3FreeFMUState")
        return FMICore.fmi3FreeFMUState(FMIBUILD_FMU.cFreeFMUState, _instance, _FMUState)
    end
end

Base.@ccallable function jl_fmi3SerializedFMUStateSize(
    _instance::fmi3Instance,
    FMUState::fmi3FMUState,
    _size::Ptr{Csize_t},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SerializedFMUStateSize($(_instance), $(FMUState), $(_size))",
    ) do
        FMIBUILD_FMU.cSerializedFMUStateSize == C_NULL &&
            return functionNotProvided(_instance, "fmi3SerializedFMUStateSize")
        return FMICore.fmi3SerializedFMUStateSize!(
            FMIBUILD_FMU.cSerializedFMUStateSize,
            _instance,
            FMUState,
            _size,
        )
    end
end

Base.@ccallable function jl_fmi3SerializeFMUState(
    _instance::fmi3Instance,
    FMUState::fmi3FMUState,
    _serializedState::Ptr{fmi3Byte},
    size::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3SerializeFMUState($(_instance), $(FMUState), $(_serializedState), $(size))",
    ) do
        FMIBUILD_FMU.cSerializeFMUState == C_NULL &&
            return functionNotProvided(_instance, "fmi3SerializeFMUState")
        return FMICore.fmi3SerializeFMUState!(
            FMIBUILD_FMU.cSerializeFMUState,
            _instance,
            FMUState,
            _serializedState,
            size,
        )
    end
end

Base.@ccallable function jl_fmi3DeserializeFMUState(
    _instance::fmi3Instance,
    _serializedState::Ptr{fmi3Byte},
    size::Csize_t,
    _FMUState::Ptr{fmi3FMUState},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3DeserializeFMUState($(_instance), $(_serializedState), $(size), $(_FMUState))",
    ) do
        FMIBUILD_FMU.cDeSerializeFMUState == C_NULL &&
            return functionNotProvided(_instance, "fmi3DeserializeFMUState")
        return FMICore.fmi3DeSerializeFMUState!(
            FMIBUILD_FMU.cDeSerializeFMUState,
            _instance,
            _serializedState,
            size,
            _FMUState,
        )
    end
end

# getting partial derivatives
Base.@ccallable function jl_fmi3GetDirectionalDerivative(
    _instance::fmi3Instance,
    _unknowns::Ptr{fmi3ValueReference},
    nUnknowns::Csize_t,
    _knowns::Ptr{fmi3ValueReference},
    nKnowns::Csize_t,
    _seed::Ptr{fmi3Float64},
    nSeed::Csize_t,
    _sensitivity::Ptr{fmi3Float64},
    nSensitivity::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetDirectionalDerivative($(_instance), $(_unknowns), $(nUnknowns), $(_knowns), $(nKnowns), $(_seed), $(nSeed), $(_sensitivity), $(nSensitivity))",
    ) do
        FMIBUILD_FMU.cGetDirectionalDerivative == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetDirectionalDerivative")
        return FMICore.fmi3GetDirectionalDerivative!(
            FMIBUILD_FMU.cGetDirectionalDerivative,
            _instance,
            _unknowns,
            nUnknowns,
            _knowns,
            nKnowns,
            _seed,
            nSeed,
            _sensitivity,
            nSensitivity,
        )
    end
end

Base.@ccallable function jl_fmi3GetAdjointDerivative(
    _instance::fmi3Instance,
    _unknowns::Ptr{fmi3ValueReference},
    nUnknowns::Csize_t,
    _knowns::Ptr{fmi3ValueReference},
    nKnowns::Csize_t,
    _seed::Ptr{fmi3Float64},
    nSeed::Csize_t,
    _sensitivity::Ptr{fmi3Float64},
    nSensitivity::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetAdjointDerivative($(_instance), $(_unknowns), $(nUnknowns), $(_knowns), $(nKnowns), $(_seed), $(nSeed), $(_sensitivity), $(nSensitivity))",
    ) do
        FMIBUILD_FMU.cGetAdjointDerivative == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetAdjointDerivative")
        return FMICore.fmi3GetAdjointDerivative!(
            FMIBUILD_FMU.cGetAdjointDerivative,
            _instance,
            _unknowns,
            nUnknowns,
            _knowns,
            nKnowns,
            _seed,
            nSeed,
            _sensitivity,
            nSensitivity,
        )
    end
end

# entering and exiting the configuration or reconfiguration mode
Base.@ccallable function jl_fmi3EnterConfigurationMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3EnterConfigurationMode($(_instance))") do
        FMIBUILD_FMU.cEnterConfigurationMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3EnterConfigurationMode")
        return FMICore.fmi3EnterConfigurationMode(
            FMIBUILD_FMU.cEnterConfigurationMode,
            _instance,
        )
    end
end

Base.@ccallable function jl_fmi3ExitConfigurationMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3ExitConfigurationMode($(_instance))") do
        FMIBUILD_FMU.cExitConfigurationMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3ExitConfigurationMode")
        return FMICore.fmi3ExitConfigurationMode(
            FMIBUILD_FMU.cExitConfigurationMode,
            _instance,
        )
    end
end

# discrete states
Base.@ccallable function jl_fmi3EvaluateDiscreteStates(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3EvaluateDiscreteStates($(_instance))") do
        FMIBUILD_FMU.cEvaluateDiscreteStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3EvaluateDiscreteStates")
        return FMICore.fmi3EvaluateDiscreteStates(
            FMIBUILD_FMU.cEvaluateDiscreteStates,
            _instance,
        )
    end
end

Base.@ccallable function jl_fmi3UpdateDiscreteStates(
    _instance::fmi3Instance,
    _discreteStatesNeedUpdate::Ptr{fmi3Boolean},
    _terminateSimulation::Ptr{fmi3Boolean},
    _nominalsOfContinuousStatesChanged::Ptr{fmi3Boolean},
    _valuesOfContinuousStatesChanged::Ptr{fmi3Boolean},
    _nextEventTimeDefined::Ptr{fmi3Boolean},
    _nextEventTime::Ptr{fmi3Float64},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3UpdateDiscreteStates($(_instance), $(_discreteStatesNeedUpdate), $(_terminateSimulation), $(_nominalsOfContinuousStatesChanged), $(_valuesOfContinuousStatesChanged), $(_nextEventTimeDefined), $(_nextEventTime))",
    ) do
        FMIBUILD_FMU.cUpdateDiscreteStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3UpdateDiscreteStates")
        return FMICore.fmi3UpdateDiscreteStates(
            FMIBUILD_FMU.cUpdateDiscreteStates,
            _instance,
            _discreteStatesNeedUpdate,
            _terminateSimulation,
            _nominalsOfContinuousStatesChanged,
            _valuesOfContinuousStatesChanged,
            _nextEventTimeDefined,
            _nextEventTime,
        )
    end
end

# Model Exchange
Base.@ccallable function jl_fmi3EnterContinuousTimeMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3EnterContinuousTimeMode($(_instance))") do
        FMIBUILD_FMU.cEnterContinuousTimeMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3EnterContinuousTimeMode")
        return FMICore.fmi3EnterContinuousTimeMode(
            FMIBUILD_FMU.cEnterContinuousTimeMode,
            _instance,
        )
    end
end

Base.@ccallable function jl_fmi3CompletedIntegratorStep(
    _instance::fmi3Instance,
    noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
    _enterEventMode::Ptr{fmi3Boolean},
    _terminateSimulation::Ptr{fmi3Boolean},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3CompletedIntegratorStep($(_instance), $(noSetFMUStatePriorToCurrentPoint), $(_enterEventMode), $(_terminateSimulation))",
    ) do
        FMIBUILD_FMU.cCompletedIntegratorStep == C_NULL &&
            return functionNotProvided(_instance, "fmi3CompletedIntegratorStep")
        return FMICore.fmi3CompletedIntegratorStep!(
            FMIBUILD_FMU.cCompletedIntegratorStep,
            _instance,
            noSetFMUStatePriorToCurrentPoint,
            _enterEventMode,
            _terminateSimulation,
        )
    end
end

Base.@ccallable function jl_fmi3SetTime(
    _instance::fmi3Instance,
    time::fmi3Float64,
)::fmi3Status
    return debugCall(_instance, "fmi3SetTime($(_instance), $(time))") do
        FMIBUILD_FMU.cSetTime == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetTime")
        return FMICore.fmi3SetTime(FMIBUILD_FMU.cSetTime, _instance, time)
    end
end

Base.@ccallable function jl_fmi3SetContinuousStates(
    _instance::fmi3Instance,
    _x::Ptr{fmi3Float64},
    nx::Csize_t,
)::fmi3Status
    return debugCall(_instance, "fmi3SetContinuousStates($(_instance), $(_x), $(nx))") do
        FMIBUILD_FMU.cSetContinuousStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3SetContinuousStates")
        return FMICore.fmi3SetContinuousStates(
            FMIBUILD_FMU.cSetContinuousStates,
            _instance,
            _x,
            nx,
        )
    end
end

Base.@ccallable function jl_fmi3GetContinuousStateDerivatives(
    _instance::fmi3Instance,
    _derivatives::Ptr{fmi3Float64},
    nx::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetContinuousStateDerivatives($(_instance), $(_derivatives), $(nx))",
    ) do
        FMIBUILD_FMU.cGetContinuousStateDerivatives == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetContinuousStateDerivatives")
        return FMICore.fmi3GetContinuousStateDerivatives!(
            FMIBUILD_FMU.cGetContinuousStateDerivatives,
            _instance,
            _derivatives,
            nx,
        )
    end
end

Base.@ccallable function jl_fmi3GetEventIndicators(
    _instance::fmi3Instance,
    _eventIndicators::Ptr{fmi3Float64},
    ni::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetEventIndicators($(_instance), $(_eventIndicators), $(ni))",
    ) do
        FMIBUILD_FMU.cGetEventIndicators == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetEventIndicators")
        return FMICore.fmi3GetEventIndicators!(
            FMIBUILD_FMU.cGetEventIndicators,
            _instance,
            _eventIndicators,
            ni,
        )
    end
end

Base.@ccallable function jl_fmi3GetContinuousStates(
    _instance::fmi3Instance,
    _x::Ptr{fmi3Float64},
    nx::Csize_t,
)::fmi3Status
    return debugCall(_instance, "fmi3GetContinuousStates($(_instance), $(_x), $(nx))") do
        FMIBUILD_FMU.cGetContinuousStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetContinuousStates")
        return FMICore.fmi3GetContinuousStates!(
            FMIBUILD_FMU.cGetContinuousStates,
            _instance,
            _x,
            nx,
        )
    end
end

Base.@ccallable function jl_fmi3GetNominalsOfContinuousStates(
    _instance::fmi3Instance,
    _x_nominal::Ptr{fmi3Float64},
    nx::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetNominalsOfContinuousStates($(_instance), $(_x_nominal), $(nx))",
    ) do
        FMIBUILD_FMU.cGetNominalsOfContinuousStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetNominalsOfContinuousStates")
        return FMICore.fmi3GetNominalsOfContinuousStates!(
            FMIBUILD_FMU.cGetNominalsOfContinuousStates,
            _instance,
            _x_nominal,
            nx,
        )
    end
end

Base.@ccallable function jl_fmi3GetNumberOfEventIndicators(
    _instance::fmi3Instance,
    _nEventIndicators::Ptr{Csize_t},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetNumberOfEventIndicators($(_instance), $(_nEventIndicators))",
    ) do
        FMIBUILD_FMU.cGetNumberOfEventIndicators == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetNumberOfEventIndicators")
        return FMICore.fmi3GetNumberOfEventIndicators!(
            FMIBUILD_FMU.cGetNumberOfEventIndicators,
            _instance,
            _nEventIndicators,
        )
    end
end

Base.@ccallable function jl_fmi3GetNumberOfContinuousStates(
    _instance::fmi3Instance,
    _nContinuousStates::Ptr{Csize_t},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetNumberOfContinuousStates($(_instance), $(_nContinuousStates))",
    ) do
        FMIBUILD_FMU.cGetNumberOfContinuousStates == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetNumberOfContinuousStates")
        return FMICore.fmi3GetNumberOfContinuousStates!(
            FMIBUILD_FMU.cGetNumberOfContinuousStates,
            _instance,
            _nContinuousStates,
        )
    end
end

# Co-Simulation
Base.@ccallable function jl_fmi3EnterStepMode(_instance::fmi3Instance)::fmi3Status
    return debugCall(_instance, "fmi3EnterStepMode($(_instance))") do
        FMIBUILD_FMU.cEnterStepMode == C_NULL &&
            return functionNotProvided(_instance, "fmi3EnterStepMode")
        return FMICore.fmi3EnterStepMode(FMIBUILD_FMU.cEnterStepMode, _instance)
    end
end

Base.@ccallable function jl_fmi3GetOutputDerivatives(
    _instance::fmi3Instance,
    _vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    _orders::Ptr{fmi3Int32},
    _values::Ptr{fmi3Float64},
    nValues::Csize_t,
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3GetOutputDerivatives($(_instance), $(_vr), $(nvr), $(_orders), $(_values), $(nValues))",
    ) do
        FMIBUILD_FMU.cGetOutputDerivatives == C_NULL &&
            return functionNotProvided(_instance, "fmi3GetOutputDerivatives")
        return FMICore.fmi3GetOutputDerivatives!(
            FMIBUILD_FMU.cGetOutputDerivatives,
            _instance,
            _vr,
            nvr,
            _orders,
            _values,
            nValues,
        )
    end
end

Base.@ccallable function jl_fmi3DoStep(
    _instance::fmi3Instance,
    currentCommunicationPoint::fmi3Float64,
    communicationStepSize::fmi3Float64,
    noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
    _eventHandlingNeeded::Ptr{fmi3Boolean},
    _terminateSimulation::Ptr{fmi3Boolean},
    _earlyReturn::Ptr{fmi3Boolean},
    _lastSuccessfulTime::Ptr{fmi3Float64},
)::fmi3Status
    return debugCall(
        _instance,
        "fmi3DoStep($(_instance), $(currentCommunicationPoint), $(communicationStepSize), $(noSetFMUStatePriorToCurrentPoint), $(_eventHandlingNeeded), $(_terminateSimulation), $(_earlyReturn), $(_lastSuccessfulTime))",
    ) do
        FMIBUILD_FMU.cDoStep == C_NULL &&
            return functionNotProvided(_instance, "fmi3DoStep")
        return FMICore.fmi3DoStep!(
            FMIBUILD_FMU.cDoStep,
            _instance,
            currentCommunicationPoint,
            communicationStepSize,
            noSetFMUStatePriorToCurrentPoint,
            _eventHandlingNeeded,
            _terminateSimulation,
            _earlyReturn,
            _lastSuccessfulTime,
        )
    end
end
