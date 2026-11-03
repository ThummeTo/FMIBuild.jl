//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 common functions.

// inquire version numbers and set debug logging
const char* fmi3GetVersion(void);
fmi3Status fmi3SetDebugLogging(fmi3Instance, fmi3Boolean, size_t, const fmi3String[]);

// creation and destruction of FMU instances
fmi3Instance fmi3InstantiateModelExchange(fmi3String, fmi3String, fmi3String, fmi3Boolean, fmi3Boolean, fmi3InstanceEnvironment, fmi3LogMessageCallback);
fmi3Instance fmi3InstantiateCoSimulation(fmi3String, fmi3String, fmi3String, fmi3Boolean, fmi3Boolean, fmi3Boolean, fmi3Boolean, const fmi3ValueReference[], size_t, fmi3InstanceEnvironment, fmi3LogMessageCallback, fmi3IntermediateUpdateCallback);
fmi3Instance fmi3InstantiateScheduledExecution(fmi3String, fmi3String, fmi3String, fmi3Boolean, fmi3Boolean, fmi3InstanceEnvironment, fmi3LogMessageCallback, fmi3ClockUpdateCallback, fmi3LockPreemptionCallback, fmi3UnlockPreemptionCallback);
void fmi3FreeInstance(fmi3Instance);

// enter and exit initialization mode, enter event mode, terminate and reset
fmi3Status fmi3EnterInitializationMode(fmi3Instance, fmi3Boolean, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Float64);
fmi3Status fmi3ExitInitializationMode(fmi3Instance);
fmi3Status fmi3EnterEventMode(fmi3Instance);
fmi3Status fmi3Terminate(fmi3Instance);
fmi3Status fmi3Reset(fmi3Instance);

// getting and setting variable values
fmi3Status fmi3GetFloat32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float32[], size_t);
fmi3Status fmi3GetFloat64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float64[], size_t);
fmi3Status fmi3GetInt8(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int8[], size_t);
fmi3Status fmi3GetUInt8(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt8[], size_t);
fmi3Status fmi3GetInt16(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int16[], size_t);
fmi3Status fmi3GetUInt16(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt16[], size_t);
fmi3Status fmi3GetInt32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int32[], size_t);
fmi3Status fmi3GetUInt32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt32[], size_t);
fmi3Status fmi3GetInt64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int64[], size_t);
fmi3Status fmi3GetUInt64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt64[], size_t);
fmi3Status fmi3GetBoolean(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Boolean[], size_t);
fmi3Status fmi3GetString(fmi3Instance, const fmi3ValueReference[], size_t, fmi3String[], size_t);
fmi3Status fmi3GetBinary(fmi3Instance, const fmi3ValueReference[], size_t, size_t[], fmi3Binary[], size_t);
fmi3Status fmi3GetClock(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Clock[]);

fmi3Status fmi3SetFloat32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float32[], size_t);
fmi3Status fmi3SetFloat64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t);
fmi3Status fmi3SetInt8(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int8[], size_t);
fmi3Status fmi3SetUInt8(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt8[], size_t);
fmi3Status fmi3SetInt16(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int16[], size_t);
fmi3Status fmi3SetUInt16(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt16[], size_t);
fmi3Status fmi3SetInt32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int32[], size_t);
fmi3Status fmi3SetUInt32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt32[], size_t);
fmi3Status fmi3SetInt64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int64[], size_t);
fmi3Status fmi3SetUInt64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt64[], size_t);
fmi3Status fmi3SetBoolean(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Boolean[], size_t);
fmi3Status fmi3SetString(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3String[], size_t);
fmi3Status fmi3SetBinary(fmi3Instance, const fmi3ValueReference[], size_t, const size_t[], const fmi3Binary[], size_t);
fmi3Status fmi3SetClock(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Clock[]);

// getting variable dependency information
fmi3Status fmi3GetNumberOfVariableDependencies(fmi3Instance, fmi3ValueReference, size_t*);
fmi3Status fmi3GetVariableDependencies(fmi3Instance, fmi3ValueReference, size_t[], fmi3ValueReference[], size_t[], fmi3DependencyKind[], size_t);

// getting and setting the internal FMU state
fmi3Status fmi3GetFMUState(fmi3Instance, fmi3FMUState*);
fmi3Status fmi3SetFMUState(fmi3Instance, fmi3FMUState);
fmi3Status fmi3FreeFMUState(fmi3Instance, fmi3FMUState*);
fmi3Status fmi3SerializedFMUStateSize(fmi3Instance, fmi3FMUState, size_t*);
fmi3Status fmi3SerializeFMUState(fmi3Instance, fmi3FMUState, fmi3Byte[], size_t);
fmi3Status fmi3DeserializeFMUState(fmi3Instance, const fmi3Byte[], size_t, fmi3FMUState*);

// getting partial derivatives
fmi3Status fmi3GetDirectionalDerivative(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t, fmi3Float64[], size_t);
fmi3Status fmi3GetAdjointDerivative(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t, fmi3Float64[], size_t);

// entering and exiting the configuration or reconfiguration mode
fmi3Status fmi3EnterConfigurationMode(fmi3Instance);
fmi3Status fmi3ExitConfigurationMode(fmi3Instance);

// clock related functions
fmi3Status fmi3GetIntervalDecimal(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float64[], fmi3IntervalQualifier[]);
fmi3Status fmi3GetIntervalFraction(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt64[], fmi3UInt64[], fmi3IntervalQualifier[]);
fmi3Status fmi3GetShiftDecimal(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float64[]);
fmi3Status fmi3GetShiftFraction(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt64[], fmi3UInt64[]);
fmi3Status fmi3SetIntervalDecimal(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float64[]);
fmi3Status fmi3SetIntervalFraction(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt64[], const fmi3UInt64[]);
fmi3Status fmi3SetShiftDecimal(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float64[]);
fmi3Status fmi3SetShiftFraction(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt64[], const fmi3UInt64[]);
fmi3Status fmi3EvaluateDiscreteStates(fmi3Instance);
fmi3Status fmi3UpdateDiscreteStates(fmi3Instance, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Float64*);

// scheduled execution is not supported, but importers (e.g. FMPy) require the symbol
fmi3Status fmi3ActivateModelPartition(fmi3Instance, fmi3ValueReference, fmi3Float64);
