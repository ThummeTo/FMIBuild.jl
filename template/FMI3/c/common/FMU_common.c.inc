//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 common Julia entry points and exported C wrappers.

const char* jl_fmi3GetVersion(void);
fmi3Status jl_fmi3SetDebugLogging(fmi3Instance, fmi3Boolean, size_t, const fmi3String[]);
fmi3Instance jl_fmi3InstantiateModelExchange(fmi3String, fmi3String, fmi3String, fmi3Boolean, fmi3Boolean, fmi3InstanceEnvironment, fmi3LogMessageCallback);
fmi3Instance jl_fmi3InstantiateCoSimulation(fmi3String, fmi3String, fmi3String, fmi3Boolean, fmi3Boolean, fmi3Boolean, fmi3Boolean, const fmi3ValueReference[], size_t, fmi3InstanceEnvironment, fmi3LogMessageCallback, fmi3IntermediateUpdateCallback);
void jl_fmi3FreeInstance(fmi3Instance);
fmi3Status jl_fmi3EnterInitializationMode(fmi3Instance, fmi3Boolean, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Float64);
fmi3Status jl_fmi3ExitInitializationMode(fmi3Instance);
fmi3Status jl_fmi3EnterEventMode(fmi3Instance);
fmi3Status jl_fmi3Terminate(fmi3Instance);
fmi3Status jl_fmi3Reset(fmi3Instance);
fmi3Status jl_fmi3GetFloat32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float32[], size_t);
fmi3Status jl_fmi3GetFloat64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetInt8(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int8[], size_t);
fmi3Status jl_fmi3GetUInt8(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt8[], size_t);
fmi3Status jl_fmi3GetInt16(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int16[], size_t);
fmi3Status jl_fmi3GetUInt16(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt16[], size_t);
fmi3Status jl_fmi3GetInt32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int32[], size_t);
fmi3Status jl_fmi3GetUInt32(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt32[], size_t);
fmi3Status jl_fmi3GetInt64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Int64[], size_t);
fmi3Status jl_fmi3GetUInt64(fmi3Instance, const fmi3ValueReference[], size_t, fmi3UInt64[], size_t);
fmi3Status jl_fmi3GetBoolean(fmi3Instance, const fmi3ValueReference[], size_t, fmi3Boolean[], size_t);
fmi3Status jl_fmi3GetString(fmi3Instance, const fmi3ValueReference[], size_t, fmi3String[], size_t);
fmi3Status jl_fmi3GetBinary(fmi3Instance, const fmi3ValueReference[], size_t, size_t[], fmi3Binary[], size_t);
fmi3Status jl_fmi3SetFloat32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float32[], size_t);
fmi3Status jl_fmi3SetFloat64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t);
fmi3Status jl_fmi3SetInt8(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int8[], size_t);
fmi3Status jl_fmi3SetUInt8(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt8[], size_t);
fmi3Status jl_fmi3SetInt16(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int16[], size_t);
fmi3Status jl_fmi3SetUInt16(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt16[], size_t);
fmi3Status jl_fmi3SetInt32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int32[], size_t);
fmi3Status jl_fmi3SetUInt32(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt32[], size_t);
fmi3Status jl_fmi3SetInt64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int64[], size_t);
fmi3Status jl_fmi3SetUInt64(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3UInt64[], size_t);
fmi3Status jl_fmi3SetBoolean(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Boolean[], size_t);
fmi3Status jl_fmi3SetString(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3String[], size_t);
fmi3Status jl_fmi3SetBinary(fmi3Instance, const fmi3ValueReference[], size_t, const size_t[], const fmi3Binary[], size_t);
fmi3Status jl_fmi3GetNumberOfVariableDependencies(fmi3Instance, fmi3ValueReference, size_t*);
fmi3Status jl_fmi3GetVariableDependencies(fmi3Instance, fmi3ValueReference, size_t[], fmi3ValueReference[], size_t[], fmi3DependencyKind[], size_t);
fmi3Status jl_fmi3GetFMUState(fmi3Instance, fmi3FMUState*);
fmi3Status jl_fmi3SetFMUState(fmi3Instance, fmi3FMUState);
fmi3Status jl_fmi3FreeFMUState(fmi3Instance, fmi3FMUState*);
fmi3Status jl_fmi3SerializedFMUStateSize(fmi3Instance, fmi3FMUState, size_t*);
fmi3Status jl_fmi3SerializeFMUState(fmi3Instance, fmi3FMUState, fmi3Byte[], size_t);
fmi3Status jl_fmi3DeserializeFMUState(fmi3Instance, const fmi3Byte[], size_t, fmi3FMUState*);
fmi3Status jl_fmi3GetDirectionalDerivative(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetAdjointDerivative(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3ValueReference[], size_t, const fmi3Float64[], size_t, fmi3Float64[], size_t);
fmi3Status jl_fmi3EnterConfigurationMode(fmi3Instance);
fmi3Status jl_fmi3ExitConfigurationMode(fmi3Instance);
fmi3Status jl_fmi3EvaluateDiscreteStates(fmi3Instance);
fmi3Status jl_fmi3UpdateDiscreteStates(fmi3Instance, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Float64*);

FMU_EXPORT const char* fmi3GetVersion(void) { ensure_constructor(); return jl_fmi3GetVersion(); }
FMU_EXPORT fmi3Status fmi3SetDebugLogging(fmi3Instance a, fmi3Boolean b, size_t c, const fmi3String d[]) { ensure_constructor(); return jl_fmi3SetDebugLogging(a, b, c, d); }
FMU_EXPORT fmi3Instance fmi3InstantiateModelExchange(fmi3String a, fmi3String b, fmi3String c, fmi3Boolean d, fmi3Boolean e, fmi3InstanceEnvironment f, fmi3LogMessageCallback g) { ensure_constructor(); return jl_fmi3InstantiateModelExchange(a, b, c, d, e, f, g); }
FMU_EXPORT fmi3Instance fmi3InstantiateCoSimulation(fmi3String a, fmi3String b, fmi3String c, fmi3Boolean d, fmi3Boolean e, fmi3Boolean f, fmi3Boolean g, const fmi3ValueReference h[], size_t i, fmi3InstanceEnvironment j, fmi3LogMessageCallback k, fmi3IntermediateUpdateCallback l) { ensure_constructor(); return jl_fmi3InstantiateCoSimulation(a, b, c, d, e, f, g, h, i, j, k, l); }
FMU_EXPORT fmi3Instance fmi3InstantiateScheduledExecution(fmi3String a, fmi3String b, fmi3String c, fmi3Boolean d, fmi3Boolean e, fmi3InstanceEnvironment f, fmi3LogMessageCallback g, fmi3ClockUpdateCallback h, fmi3LockPreemptionCallback i, fmi3UnlockPreemptionCallback j) { ensure_constructor(); return NULL; }
FMU_EXPORT void fmi3FreeInstance(fmi3Instance a) { ensure_constructor(); jl_fmi3FreeInstance(a); }
FMU_EXPORT fmi3Status fmi3EnterInitializationMode(fmi3Instance a, fmi3Boolean b, fmi3Float64 c, fmi3Float64 d, fmi3Boolean e, fmi3Float64 f) { ensure_constructor(); return jl_fmi3EnterInitializationMode(a, b, c, d, e, f); }
FMU_EXPORT fmi3Status fmi3ExitInitializationMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3ExitInitializationMode(a); }
FMU_EXPORT fmi3Status fmi3EnterEventMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3EnterEventMode(a); }
FMU_EXPORT fmi3Status fmi3Terminate(fmi3Instance a) { ensure_constructor(); return jl_fmi3Terminate(a); }
FMU_EXPORT fmi3Status fmi3Reset(fmi3Instance a) { ensure_constructor(); return jl_fmi3Reset(a); }
FMU_EXPORT fmi3Status fmi3GetFloat32(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Float32 d[], size_t e) { ensure_constructor(); return jl_fmi3GetFloat32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetFloat64(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Float64 d[], size_t e) { ensure_constructor(); return jl_fmi3GetFloat64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetInt8(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Int8 d[], size_t e) { ensure_constructor(); return jl_fmi3GetInt8(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetUInt8(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt8 d[], size_t e) { ensure_constructor(); return jl_fmi3GetUInt8(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetInt16(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Int16 d[], size_t e) { ensure_constructor(); return jl_fmi3GetInt16(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetUInt16(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt16 d[], size_t e) { ensure_constructor(); return jl_fmi3GetUInt16(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetInt32(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Int32 d[], size_t e) { ensure_constructor(); return jl_fmi3GetInt32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetUInt32(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt32 d[], size_t e) { ensure_constructor(); return jl_fmi3GetUInt32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetInt64(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Int64 d[], size_t e) { ensure_constructor(); return jl_fmi3GetInt64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetUInt64(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt64 d[], size_t e) { ensure_constructor(); return jl_fmi3GetUInt64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetBoolean(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Boolean d[], size_t e) { ensure_constructor(); return jl_fmi3GetBoolean(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetString(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3String d[], size_t e) { ensure_constructor(); return jl_fmi3GetString(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3GetBinary(fmi3Instance a, const fmi3ValueReference b[], size_t c, size_t d[], fmi3Binary e[], size_t f) { ensure_constructor(); return jl_fmi3GetBinary(a, b, c, d, e, f); }
FMU_EXPORT fmi3Status fmi3GetClock(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Clock d[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetFloat32(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Float32 d[], size_t e) { ensure_constructor(); return jl_fmi3SetFloat32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetFloat64(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Float64 d[], size_t e) { ensure_constructor(); return jl_fmi3SetFloat64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetInt8(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int8 d[], size_t e) { ensure_constructor(); return jl_fmi3SetInt8(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetUInt8(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt8 d[], size_t e) { ensure_constructor(); return jl_fmi3SetUInt8(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetInt16(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int16 d[], size_t e) { ensure_constructor(); return jl_fmi3SetInt16(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetUInt16(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt16 d[], size_t e) { ensure_constructor(); return jl_fmi3SetUInt16(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetInt32(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int32 d[], size_t e) { ensure_constructor(); return jl_fmi3SetInt32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetUInt32(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt32 d[], size_t e) { ensure_constructor(); return jl_fmi3SetUInt32(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetInt64(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int64 d[], size_t e) { ensure_constructor(); return jl_fmi3SetInt64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetUInt64(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt64 d[], size_t e) { ensure_constructor(); return jl_fmi3SetUInt64(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetBoolean(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Boolean d[], size_t e) { ensure_constructor(); return jl_fmi3SetBoolean(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetString(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3String d[], size_t e) { ensure_constructor(); return jl_fmi3SetString(a, b, c, d, e); }
FMU_EXPORT fmi3Status fmi3SetBinary(fmi3Instance a, const fmi3ValueReference b[], size_t c, const size_t d[], const fmi3Binary e[], size_t f) { ensure_constructor(); return jl_fmi3SetBinary(a, b, c, d, e, f); }
FMU_EXPORT fmi3Status fmi3SetClock(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Clock d[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetNumberOfVariableDependencies(fmi3Instance a, fmi3ValueReference b, size_t* c) { ensure_constructor(); return jl_fmi3GetNumberOfVariableDependencies(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetVariableDependencies(fmi3Instance a, fmi3ValueReference b, size_t c[], fmi3ValueReference d[], size_t e[], fmi3DependencyKind f[], size_t g) { ensure_constructor(); return jl_fmi3GetVariableDependencies(a, b, c, d, e, f, g); }
FMU_EXPORT fmi3Status fmi3GetFMUState(fmi3Instance a, fmi3FMUState* b) { ensure_constructor(); return jl_fmi3GetFMUState(a, b); }
FMU_EXPORT fmi3Status fmi3SetFMUState(fmi3Instance a, fmi3FMUState b) { ensure_constructor(); return jl_fmi3SetFMUState(a, b); }
FMU_EXPORT fmi3Status fmi3FreeFMUState(fmi3Instance a, fmi3FMUState* b) { ensure_constructor(); return jl_fmi3FreeFMUState(a, b); }
FMU_EXPORT fmi3Status fmi3SerializedFMUStateSize(fmi3Instance a, fmi3FMUState b, size_t* c) { ensure_constructor(); return jl_fmi3SerializedFMUStateSize(a, b, c); }
FMU_EXPORT fmi3Status fmi3SerializeFMUState(fmi3Instance a, fmi3FMUState b, fmi3Byte c[], size_t d) { ensure_constructor(); return jl_fmi3SerializeFMUState(a, b, c, d); }
FMU_EXPORT fmi3Status fmi3DeserializeFMUState(fmi3Instance a, const fmi3Byte b[], size_t c, fmi3FMUState* d) { ensure_constructor(); return jl_fmi3DeserializeFMUState(a, b, c, d); }
FMU_EXPORT fmi3Status fmi3GetDirectionalDerivative(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3ValueReference d[], size_t e, const fmi3Float64 f[], size_t g, fmi3Float64 h[], size_t i) { ensure_constructor(); return jl_fmi3GetDirectionalDerivative(a, b, c, d, e, f, g, h, i); }
FMU_EXPORT fmi3Status fmi3GetAdjointDerivative(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3ValueReference d[], size_t e, const fmi3Float64 f[], size_t g, fmi3Float64 h[], size_t i) { ensure_constructor(); return jl_fmi3GetAdjointDerivative(a, b, c, d, e, f, g, h, i); }
FMU_EXPORT fmi3Status fmi3EnterConfigurationMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3EnterConfigurationMode(a); }
FMU_EXPORT fmi3Status fmi3ExitConfigurationMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3ExitConfigurationMode(a); }
FMU_EXPORT fmi3Status fmi3GetIntervalDecimal(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Float64 d[], fmi3IntervalQualifier e[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetIntervalFraction(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt64 d[], fmi3UInt64 e[], fmi3IntervalQualifier f[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetShiftDecimal(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3Float64 d[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetShiftFraction(fmi3Instance a, const fmi3ValueReference b[], size_t c, fmi3UInt64 d[], fmi3UInt64 e[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetIntervalDecimal(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Float64 d[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetIntervalFraction(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt64 d[], const fmi3UInt64 e[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetShiftDecimal(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Float64 d[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetShiftFraction(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3UInt64 d[], const fmi3UInt64 e[]) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3EvaluateDiscreteStates(fmi3Instance a) { ensure_constructor(); return jl_fmi3EvaluateDiscreteStates(a); }
FMU_EXPORT fmi3Status fmi3UpdateDiscreteStates(fmi3Instance a, fmi3Boolean* b, fmi3Boolean* c, fmi3Boolean* d, fmi3Boolean* e, fmi3Boolean* f, fmi3Float64* g) { ensure_constructor(); return jl_fmi3UpdateDiscreteStates(a, b, c, d, e, f, g); }
FMU_EXPORT fmi3Status fmi3ActivateModelPartition(fmi3Instance a, fmi3ValueReference b, fmi3Float64 c) { ensure_constructor(); return fmi3Error; }
