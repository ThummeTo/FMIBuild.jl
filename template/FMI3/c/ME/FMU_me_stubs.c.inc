//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Model Exchange stubs for FMUs without Model Exchange, they return `fmi3Error`.
// [Note] The FMU must implement all functions of `fmi3Functions.h`, even for unsupported interface types (FMI 3.0, 2.5. FMU Distribution).

FMU_EXPORT fmi3Status fmi3EnterContinuousTimeMode(fmi3Instance a) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3CompletedIntegratorStep(fmi3Instance a, fmi3Boolean b, fmi3Boolean* c, fmi3Boolean* d) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetTime(fmi3Instance a, fmi3Float64 b) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3SetContinuousStates(fmi3Instance a, const fmi3Float64 b[], size_t c) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetContinuousStateDerivatives(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetEventIndicators(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetContinuousStates(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetNominalsOfContinuousStates(fmi3Instance a, fmi3Float64 b[], size_t c) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetNumberOfEventIndicators(fmi3Instance a, size_t* b) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetNumberOfContinuousStates(fmi3Instance a, size_t* b) { ensure_constructor(); return fmi3Error; }
