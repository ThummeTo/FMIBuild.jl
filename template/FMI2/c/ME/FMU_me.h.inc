//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 Model Exchange functions.

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
