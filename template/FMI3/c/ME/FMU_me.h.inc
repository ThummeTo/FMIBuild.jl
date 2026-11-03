//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// FMI 3.0 Model Exchange functions.

fmi3Status fmi3EnterContinuousTimeMode(fmi3Instance);
fmi3Status fmi3CompletedIntegratorStep(fmi3Instance, fmi3Boolean, fmi3Boolean*, fmi3Boolean*);

// providing independent variables and re-initialization of caching
fmi3Status fmi3SetTime(fmi3Instance, fmi3Float64);
fmi3Status fmi3SetContinuousStates(fmi3Instance, const fmi3Float64[], size_t);

// evaluation of the model equations
fmi3Status fmi3GetContinuousStateDerivatives(fmi3Instance, fmi3Float64[], size_t);
fmi3Status fmi3GetEventIndicators(fmi3Instance, fmi3Float64[], size_t);
fmi3Status fmi3GetContinuousStates(fmi3Instance, fmi3Float64[], size_t);
fmi3Status fmi3GetNominalsOfContinuousStates(fmi3Instance, fmi3Float64[], size_t);
fmi3Status fmi3GetNumberOfEventIndicators(fmi3Instance, size_t*);
fmi3Status fmi3GetNumberOfContinuousStates(fmi3Instance, size_t*);
