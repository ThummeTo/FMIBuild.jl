//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Model Exchange Julia entry points and exported C wrappers.

fmi3Status jl_fmi3EnterContinuousTimeMode(fmi3Instance);
fmi3Status jl_fmi3CompletedIntegratorStep(fmi3Instance, fmi3Boolean, fmi3Boolean*, fmi3Boolean*);
fmi3Status jl_fmi3SetTime(fmi3Instance, fmi3Float64);
fmi3Status jl_fmi3SetContinuousStates(fmi3Instance, const fmi3Float64[], size_t);
fmi3Status jl_fmi3GetContinuousStateDerivatives(fmi3Instance, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetEventIndicators(fmi3Instance, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetContinuousStates(fmi3Instance, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetNominalsOfContinuousStates(fmi3Instance, fmi3Float64[], size_t);
fmi3Status jl_fmi3GetNumberOfEventIndicators(fmi3Instance, size_t*);
fmi3Status jl_fmi3GetNumberOfContinuousStates(fmi3Instance, size_t*);

FMU_EXPORT fmi3Status fmi3EnterContinuousTimeMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3EnterContinuousTimeMode(a); }
FMU_EXPORT fmi3Status fmi3CompletedIntegratorStep(fmi3Instance a, fmi3Boolean b, fmi3Boolean* c, fmi3Boolean* d) { ensure_constructor(); return jl_fmi3CompletedIntegratorStep(a, b, c, d); }
FMU_EXPORT fmi3Status fmi3SetTime(fmi3Instance a, fmi3Float64 b) { ensure_constructor(); return jl_fmi3SetTime(a, b); }
FMU_EXPORT fmi3Status fmi3SetContinuousStates(fmi3Instance a, const fmi3Float64 b[], size_t c) { ensure_constructor(); return jl_fmi3SetContinuousStates(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetContinuousStateDerivatives(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return jl_fmi3GetContinuousStateDerivatives(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetEventIndicators(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return jl_fmi3GetEventIndicators(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetContinuousStates(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return jl_fmi3GetContinuousStates(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetNominalsOfContinuousStates(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return jl_fmi3GetNominalsOfContinuousStates(a, b, c); }
FMU_EXPORT fmi3Status fmi3GetNumberOfEventIndicators(fmi3Instance a, size_t* b) { ensure_constructor(); return jl_fmi3GetNumberOfEventIndicators(a, b); }
FMU_EXPORT fmi3Status fmi3GetNumberOfContinuousStates(fmi3Instance a, size_t* b) { ensure_constructor(); return jl_fmi3GetNumberOfContinuousStates(a, b); }
