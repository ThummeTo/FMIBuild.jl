//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Co-Simulation Julia entry points and exported C wrappers.

fmi3Status jl_fmi3EnterStepMode(fmi3Instance);
fmi3Status jl_fmi3GetOutputDerivatives(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int32[], fmi3Float64[], size_t);
fmi3Status jl_fmi3DoStep(fmi3Instance, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Float64*);

FMU_EXPORT fmi3Status fmi3EnterStepMode(fmi3Instance a) { ensure_constructor(); return jl_fmi3EnterStepMode(a); }
FMU_EXPORT fmi3Status fmi3GetOutputDerivatives(fmi3Instance a, const fmi3ValueReference b[], size_t c, const fmi3Int32 d[], fmi3Float64 e[], size_t f) { ensure_constructor(); return jl_fmi3GetOutputDerivatives(a, b, c, d, e, f); }
FMU_EXPORT fmi3Status fmi3DoStep(fmi3Instance a, fmi3Float64 b, fmi3Float64 c, fmi3Boolean d, fmi3Boolean* e, fmi3Boolean* f, fmi3Boolean* g, fmi3Float64* h) { ensure_constructor(); return jl_fmi3DoStep(a, b, c, d, e, f, g, h); }
