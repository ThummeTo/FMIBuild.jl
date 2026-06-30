//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 2.0 Co-Simulation Julia entry points and exported C wrappers.

fmi2Status jl_fmi2SetRealInputDerivatives(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[], const fmi2Real[]);
fmi2Status jl_fmi2GetRealOutputDerivatives(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[], fmi2Real[]);
fmi2Status jl_fmi2DoStep(fmi2Component, fmi2Real, fmi2Real, fmi2Boolean);
fmi2Status jl_fmi2CancelStep(fmi2Component);
fmi2Status jl_fmi2GetStatus(fmi2Component, fmi2StatusKind, fmi2Status*);
fmi2Status jl_fmi2GetRealStatus(fmi2Component, fmi2StatusKind, fmi2Real*);
fmi2Status jl_fmi2GetIntegerStatus(fmi2Component, fmi2StatusKind, fmi2Integer*);
fmi2Status jl_fmi2GetBooleanStatus(fmi2Component, fmi2StatusKind, fmi2Boolean*);
fmi2Status jl_fmi2GetStringStatus(fmi2Component, fmi2StatusKind, fmi2String*);

FMU_EXPORT fmi2Status fmi2SetRealInputDerivatives(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Integer d[], const fmi2Real e[]) { ensure_constructor(); return jl_fmi2SetRealInputDerivatives(a, b, c, d, e); }
FMU_EXPORT fmi2Status fmi2GetRealOutputDerivatives(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Integer d[], fmi2Real e[]) { ensure_constructor(); return jl_fmi2GetRealOutputDerivatives(a, b, c, d, e); }
FMU_EXPORT fmi2Status fmi2DoStep(fmi2Component a, fmi2Real b, fmi2Real c, fmi2Boolean d) { ensure_constructor(); return jl_fmi2DoStep(a, b, c, d); }
FMU_EXPORT fmi2Status fmi2CancelStep(fmi2Component a) { ensure_constructor(); return jl_fmi2CancelStep(a); }
FMU_EXPORT fmi2Status fmi2GetStatus(fmi2Component a, fmi2StatusKind b, fmi2Status* c) { ensure_constructor(); return jl_fmi2GetStatus(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetRealStatus(fmi2Component a, fmi2StatusKind b, fmi2Real* c) { ensure_constructor(); return jl_fmi2GetRealStatus(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetIntegerStatus(fmi2Component a, fmi2StatusKind b, fmi2Integer* c) { ensure_constructor(); return jl_fmi2GetIntegerStatus(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetBooleanStatus(fmi2Component a, fmi2StatusKind b, fmi2Boolean* c) { ensure_constructor(); return jl_fmi2GetBooleanStatus(a, b, c); }
FMU_EXPORT fmi2Status fmi2GetStringStatus(fmi2Component a, fmi2StatusKind b, fmi2String* c) { ensure_constructor(); return jl_fmi2GetStringStatus(a, b, c); }
