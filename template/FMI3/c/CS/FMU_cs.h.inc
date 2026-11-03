//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Co-Simulation functions.

fmi3Status fmi3EnterStepMode(fmi3Instance);
fmi3Status fmi3GetOutputDerivatives(fmi3Instance, const fmi3ValueReference[], size_t, const fmi3Int32[], fmi3Float64[], size_t);
fmi3Status fmi3DoStep(fmi3Instance, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Boolean*, fmi3Boolean*, fmi3Boolean*, fmi3Float64*);
