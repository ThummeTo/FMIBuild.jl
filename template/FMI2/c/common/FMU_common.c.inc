//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 common Julia entry points and exported C wrappers.

const char* jl_fmi2GetTypesPlatform(void);
const char* jl_fmi2GetVersion(void);
fmi2Component jl_fmi2Instantiate(fmi2String, fmi2Type, fmi2String, fmi2String, const fmi2CallbackFunctions*, fmi2Boolean, fmi2Boolean);
void jl_fmi2FreeInstance(fmi2Component);
fmi2Status jl_fmi2SetDebugLogging(fmi2Component, fmi2Boolean, size_t, const fmi2String[]);
fmi2Status jl_fmi2SetupExperiment(fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real);
fmi2Status jl_fmi2EnterInitializationMode(fmi2Component);
fmi2Status jl_fmi2ExitInitializationMode(fmi2Component);
fmi2Status jl_fmi2Terminate(fmi2Component);
fmi2Status jl_fmi2Reset(fmi2Component);
fmi2Status jl_fmi2GetReal(fmi2Component, const fmi2ValueReference[], size_t, fmi2Real[]);
fmi2Status jl_fmi2GetInteger(fmi2Component, const fmi2ValueReference[], size_t, fmi2Integer[]);
fmi2Status jl_fmi2GetBoolean(fmi2Component, const fmi2ValueReference[], size_t, fmi2Boolean[]);
fmi2Status jl_fmi2GetString(fmi2Component, const fmi2ValueReference[], size_t, fmi2String[]);
fmi2Status jl_fmi2SetReal(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Real[]);
fmi2Status jl_fmi2SetInteger(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[]);
fmi2Status jl_fmi2SetBoolean(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Boolean[]);
fmi2Status jl_fmi2SetString(fmi2Component, const fmi2ValueReference[], size_t, const fmi2String[]);

FMU_EXPORT const char* fmi2GetTypesPlatform(void) { ensure_constructor(); return jl_fmi2GetTypesPlatform(); }
FMU_EXPORT const char* fmi2GetVersion(void) { ensure_constructor(); return jl_fmi2GetVersion(); }
FMU_EXPORT fmi2Component fmi2Instantiate(fmi2String a, fmi2Type b, fmi2String c, fmi2String d, const fmi2CallbackFunctions* e, fmi2Boolean f, fmi2Boolean g) { ensure_constructor(); return jl_fmi2Instantiate(a, b, c, d, e, f, g); }
FMU_EXPORT void fmi2FreeInstance(fmi2Component a) { ensure_constructor(); jl_fmi2FreeInstance(a); }
FMU_EXPORT fmi2Status fmi2SetDebugLogging(fmi2Component a, fmi2Boolean b, size_t c, const fmi2String d[]) { ensure_constructor(); return jl_fmi2SetDebugLogging(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2SetupExperiment(fmi2Component a, fmi2Boolean b, fmi2Real c, fmi2Real d, fmi2Boolean e, fmi2Real f) { ensure_constructor(); return jl_fmi2SetupExperiment(a, b, c, d, e, f); }
FMU_EXPORT fmi2Status fmi2EnterInitializationMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterInitializationMode(a); }
FMU_EXPORT fmi2Status fmi2ExitInitializationMode(fmi2Component a) { ensure_constructor(); return jl_fmi2ExitInitializationMode(a); }
FMU_EXPORT fmi2Status fmi2Terminate(fmi2Component a) { ensure_constructor(); return jl_fmi2Terminate(a); }
FMU_EXPORT fmi2Status fmi2Reset(fmi2Component a) { ensure_constructor(); return jl_fmi2Reset(a); }
FMU_EXPORT fmi2Status fmi2GetReal(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Real d[]) { ensure_constructor(); return jl_fmi2GetReal(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2GetInteger(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Integer d[]) { ensure_constructor(); return jl_fmi2GetInteger(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2GetBoolean(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Boolean d[]) { ensure_constructor(); return jl_fmi2GetBoolean(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2GetString(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2String d[]) { ensure_constructor(); return jl_fmi2GetString(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2SetReal(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Real d[]) { ensure_constructor(); return jl_fmi2SetReal(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2SetInteger(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Integer d[]) { ensure_constructor(); return jl_fmi2SetInteger(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2SetBoolean(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Boolean d[]) { ensure_constructor(); return jl_fmi2SetBoolean(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2SetString(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2String d[]) { ensure_constructor(); return jl_fmi2SetString(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2GetFMUstate(fmi2Component a, fmi2FMUstate* b) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2SetFMUstate(fmi2Component a, fmi2FMUstate b) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2FreeFMUstate(fmi2Component a, fmi2FMUstate* b) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2SerializedFMUstateSize(fmi2Component a, fmi2FMUstate b, size_t* c) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2SerializeFMUstate(fmi2Component a, fmi2FMUstate b, fmi2Byte c[], size_t d) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2DeSerializeFMUstate(fmi2Component a, const fmi2Byte b[], size_t c, fmi2FMUstate* d) { ensure_constructor(); return fmi2Error; }
FMU_EXPORT fmi2Status fmi2GetDirectionalDerivative(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2ValueReference d[], size_t e, const fmi2Real f[], fmi2Real g[]) { ensure_constructor(); return fmi2Error; }
