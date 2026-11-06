//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Co-Simulation stubs for FMUs without Co-Simulation, they return `fmi3Error`.
// [Note] The FMU must implement all functions of `fmi3Functions.h`, even for unsupported interface types (FMI 3.0, 2.5. FMU Distribution).

FMU_EXPORT fmi3Status fmi3EnterStepMode(fmi3Instance a) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3GetOutputDerivatives(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int32 d[], fmi3Float64 e[], size_t f) { ensure_constructor(); return fmi3Error; }
FMU_EXPORT fmi3Status fmi3DoStep(fmi3Instance a, fmi3Float64 b, fmi3Float64 c, fmi3Boolean d, fmi3Boolean* e, fmi3Boolean* f, fmi3Boolean* g, fmi3Float64* h) { ensure_constructor(); return fmi3Error; }
