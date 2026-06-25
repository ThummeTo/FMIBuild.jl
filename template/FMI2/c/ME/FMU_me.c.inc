//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 Model Exchange Julia entry points and exported C wrappers.

fmi2Status jl_fmi2SetTime(fmi2Component, fmi2Real);
fmi2Status jl_fmi2SetContinuousStates(fmi2Component, const fmi2Real[], size_t);
fmi2Status jl_fmi2EnterEventMode(fmi2Component);
fmi2Status jl_fmi2NewDiscreteStates(fmi2Component, fmi2EventInfo*);
fmi2Status jl_fmi2EnterContinuousTimeMode(fmi2Component);
fmi2Status jl_fmi2CompletedIntegratorStep(fmi2Component, fmi2Boolean, fmi2Boolean*, fmi2Boolean*);
fmi2Status jl_fmi2GetDerivatives(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetEventIndicators(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetContinuousStates(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetNominalsOfContinuousStates(fmi2Component, fmi2Real[], size_t);

FMU_EXPORT fmi2Status fmi2SetTime(fmi2Component a, fmi2Real b) { ensure_constructor(); return jl_fmi2SetTime(a, b); }
FMU_EXPORT fmi2Status fmi2SetContinuousStates(fmi2Component a, const fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2SetContinuousStates(a, b, c); }
FMU_EXPORT fmi2Status fmi2EnterEventMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterEventMode(a); }
FMU_EXPORT fmi2Status fmi2NewDiscreteStates(fmi2Component a, fmi2EventInfo* b) { ensure_constructor(); return jl_fmi2NewDiscreteStates(a, b); }
FMU_EXPORT fmi2Status fmi2EnterContinuousTimeMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterContinuousTimeMode(a); }
FMU_EXPORT fmi2Status fmi2CompletedIntegratorStep(fmi2Component a, fmi2Boolean b, fmi2Boolean* c, fmi2Boolean* d) { ensure_constructor(); return jl_fmi2CompletedIntegratorStep(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2GetDerivatives(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetDerivatives(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetEventIndicators(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetEventIndicators(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetContinuousStates(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetContinuousStates(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetNominalsOfContinuousStates(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetNominalsOfContinuousStates(a, b, c); }
