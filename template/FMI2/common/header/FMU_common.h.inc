// FMI 2.0 common functions.

// 2.1.4
const char* fmi2GetTypesPlatform(void);
const char* fmi2GetVersion(void);

// 2.1.5
fmi2Component fmi2Instantiate(fmi2String, fmi2Type, fmi2String, fmi2String, const fmi2CallbackFunctions*, fmi2Boolean, fmi2Boolean);
void fmi2FreeInstance(fmi2Component);
fmi2Status fmi2SetDebugLogging(fmi2Component, fmi2Boolean, size_t, const fmi2String[]);

// 2.1.6
fmi2Status fmi2SetupExperiment(fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real);
fmi2Status fmi2EnterInitializationMode(fmi2Component);
fmi2Status fmi2ExitInitializationMode(fmi2Component);
fmi2Status fmi2Terminate(fmi2Component);
fmi2Status fmi2Reset(fmi2Component);

// 2.1.7
fmi2Status fmi2GetReal(fmi2Component, const fmi2ValueReference[], size_t, fmi2Real[]);
fmi2Status fmi2GetInteger(fmi2Component, const fmi2ValueReference[], size_t, fmi2Integer[]);
fmi2Status fmi2GetBoolean(fmi2Component, const fmi2ValueReference[], size_t, fmi2Boolean[]);
fmi2Status fmi2GetString (fmi2Component, const fmi2ValueReference[], size_t, fmi2String[]);

fmi2Status fmi2SetReal(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Real[]);
fmi2Status fmi2SetInteger(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[]);
fmi2Status fmi2SetBoolean(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Boolean[]);
fmi2Status fmi2SetString (fmi2Component, const fmi2ValueReference[], size_t, const fmi2String[]);

// 2.1.8
fmi2Status fmi2GetFMUstate(fmi2Component, fmi2FMUstate*);
fmi2Status fmi2SetFMUstate(fmi2Component, fmi2FMUstate);
fmi2Status fmi2FreeFMUstate(fmi2Component, fmi2FMUstate*);
fmi2Status fmi2SerializedFMUstateSize(fmi2Component, fmi2FMUstate, size_t*);
fmi2Status fmi2SerializeFMUstate(fmi2Component, fmi2FMUstate, fmi2Byte[], size_t);
fmi2Status fmi2DeSerializeFMUstate(fmi2Component, const fmi2Byte[], size_t, fmi2FMUstate*);

// 2.1.9
fmi2Status fmi2GetDirectionalDerivative(
    fmi2Component,
    const fmi2ValueReference[],
    size_t,
    const fmi2ValueReference[],
    size_t,
    const fmi2Real[],
    fmi2Real[]
);
