//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 platform and interface types.

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

typedef enum
{
    fmi2ModelExchange,
    fmi2CoSimulation
} fmi2Type;

typedef struct
{
    void  (*logger)(fmi2ComponentEnvironment componentEnvironment, fmi2String instanceName, fmi2Status status, fmi2String category, fmi2String message, ...);
    void* (*allocateMemory)(size_t nobj, size_t size);
    void  (*freeMemory) (void* obj);
    void  (*stepFinished) (fmi2ComponentEnvironment componentEnvironment, fmi2Status status);
    fmi2ComponentEnvironment componentEnvironment;
} fmi2CallbackFunctions;
