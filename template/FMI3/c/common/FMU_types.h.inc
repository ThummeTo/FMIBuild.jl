//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 platform and interface types (fmi3PlatformTypes.h, fmi3FunctionTypes.h).

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// platform types
typedef float fmi3Float32;
typedef double fmi3Float64;
typedef int8_t fmi3Int8;
typedef uint8_t fmi3UInt8;
typedef int16_t fmi3Int16;
typedef uint16_t fmi3UInt16;
typedef int32_t fmi3Int32;
typedef uint32_t fmi3UInt32;
typedef int64_t fmi3Int64;
typedef uint64_t fmi3UInt64;
typedef bool fmi3Boolean;
typedef char fmi3Char;
typedef const fmi3Char* fmi3String;
typedef uint8_t fmi3Byte;
typedef const fmi3Byte* fmi3Binary;
typedef bool fmi3Clock;

#define fmi3True true
#define fmi3False false

typedef uint32_t fmi3ValueReference;
typedef void* fmi3Instance;
typedef void* fmi3InstanceEnvironment;
typedef void* fmi3FMUState;

// status returned by functions
typedef enum
{
    fmi3OK,
    fmi3Warning,
    fmi3Discard,
    fmi3Error,
    fmi3Fatal
} fmi3Status;

typedef enum
{
    fmi3Independent,
    fmi3Constant,
    fmi3Fixed,
    fmi3Tunable,
    fmi3Discrete,
    fmi3Dependent
} fmi3DependencyKind;

typedef enum
{
    fmi3IntervalNotYetKnown,
    fmi3IntervalUnchanged,
    fmi3IntervalChanged
} fmi3IntervalQualifier;

// callback functions
typedef void (*fmi3LogMessageCallback)(fmi3InstanceEnvironment instanceEnvironment, fmi3Status status, fmi3String category, fmi3String message);
typedef void (*fmi3ClockUpdateCallback)(fmi3InstanceEnvironment instanceEnvironment);
typedef void (*fmi3IntermediateUpdateCallback)(fmi3InstanceEnvironment instanceEnvironment, fmi3Float64 intermediateUpdateTime, fmi3Boolean intermediateVariableSetRequested, fmi3Boolean intermediateVariableGetAllowed, fmi3Boolean intermediateStepFinished, fmi3Boolean canReturnEarly, fmi3Boolean* earlyReturnRequested, fmi3Float64* earlyReturnTime);
typedef void (*fmi3LockPreemptionCallback)(void);
typedef void (*fmi3UnlockPreemptionCallback)(void);
