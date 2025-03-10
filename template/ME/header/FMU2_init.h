//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// 2.1.2
typedef void* fmi2Component;
typedef void* fmi2ComponentEnvironment;
typedef void* fmi2FMUstate;
typedef unsigned int fmi2ValueReference;
typedef double fmi2Real;
typedef int fmi2Integer;
typedef int fmi2Boolean;
typedef char fmi2Char;
typedef const fmi2Char* fmi2String;
typedef char fmi2Byte;

#define fmi2True 1
#define fmi2False 0

// 2.1.3
typedef enum
{
    fmi2OK,
    fmi2Warning,
    fmi2Discard,
    fmi2Error,
    fmi2Fatal,
    fmi2Pending
} fmi2Status;

// 2.1.4
const char* fmi2GetTypesPlatform(void);
const char* fmi2GetVersion(void);

// 2.1.5
typedef enum
{
    fmi2ModelExchange,
    fmi2CoSimulation
}fmi2Type;

typedef struct
{
    void  (*logger)(fmi2ComponentEnvironment componentEnvironment, fmi2String instanceName, fmi2Status status, fmi2String category, fmi2String message, ...);
    void* (*allocateMemory)(size_t nobj, size_t size);
    void  (*freeMemory) (void* obj);
    void  (*stepFinished) (fmi2ComponentEnvironment componentEnvironment, fmi2Status status);
    fmi2ComponentEnvironment componentEnvironment;
} fmi2CallbackFunctions;

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
// ToDo: Set/Get FMU state

// 2.1.9
// ToDo: Directional Derivatives

// 3.2.1
fmi2Status fmi2SetTime(fmi2Component, fmi2Real);
fmi2Status fmi2SetContinuousStates(fmi2Component, const fmi2Real[],size_t);

// 3.2.2
fmi2Status fmi2EnterEventMode(fmi2Component);
typedef struct
{
    fmi2Boolean newDiscreteStatesNeeded;
    fmi2Boolean terminateSimulation;
    fmi2Boolean nominalsOfContinuousStatesChanged;
    fmi2Boolean valuesOfContinuousStatesChanged;
    fmi2Boolean nextEventTimeDefined;
    fmi2Real nextEventTime; // next event if nextEventTimeDefined=fmi2True
} fmi2EventInfo;
fmi2Status fmi2NewDiscreteStates(fmi2Component,fmi2EventInfo*);
fmi2Status fmi2EnterContinuousTimeMode(fmi2Component);
fmi2Status fmi2CompletedIntegratorStep(fmi2Component,fmi2Boolean, fmi2Boolean*, fmi2Boolean*);
fmi2Status fmi2GetDerivatives (fmi2Component, fmi2Real[], size_t);
fmi2Status fmi2GetEventIndicators(fmi2Component, fmi2Real[], size_t);
fmi2Status fmi2GetContinuousStates(fmi2Component, fmi2Real[], size_t);
fmi2Status fmi2GetNominalsOfContinuousStates(fmi2Component, fmi2Real[], size_t);

// Pure C-Implementations (windows-specific)
#ifdef _WIN32
#include <WinDef.h>
#include <stdbool.h>
#define BOOL bool
BOOL WINAPI DllMain(HINSTANCE, DWORD, LPVOID);
#endif

void init_FMU(char*);

// from julia_init.h
//void init_julia(int argc, char *argv[]);
//void shutdown_julia(int retcode);

