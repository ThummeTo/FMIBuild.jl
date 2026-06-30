//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 Co-Simulation functions.

typedef enum
{
    fmi2DoStepStatus,
    fmi2PendingStatus,
    fmi2LastSuccessfulTime,
    fmi2Terminated
} fmi2StatusKind;

// 4.2.1, 4.2.2, 4.2.3
fmi2Status fmi2SetRealInputDerivatives(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[], const fmi2Real[]);
fmi2Status fmi2GetRealOutputDerivatives(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[], fmi2Real[]);
fmi2Status fmi2DoStep(fmi2Component, fmi2Real, fmi2Real, fmi2Boolean);
fmi2Status fmi2CancelStep(fmi2Component);
fmi2Status fmi2GetStatus(fmi2Component, fmi2StatusKind, fmi2Status*);
fmi2Status fmi2GetRealStatus(fmi2Component, fmi2StatusKind, fmi2Real*);
fmi2Status fmi2GetIntegerStatus(fmi2Component, fmi2StatusKind, fmi2Integer*);
fmi2Status fmi2GetBooleanStatus(fmi2Component, fmi2StatusKind, fmi2Boolean*);
fmi2Status fmi2GetStringStatus(fmi2Component, fmi2StatusKind, fmi2String*);
