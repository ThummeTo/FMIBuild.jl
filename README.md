![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png "FMI.jl Logo")
# FMIBuild.jl

## What is FMIBuild.jl?
[*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl) holds dependencies that are required to compile and zip a Functional Mock-Up Unit (FMU) compliant to the FMI-standard ([fmi-standard.org](http://fmi-standard.org/)). Because this dependencies should not be part of the compiled FMU, they are out-sourced into this package.
[*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl) provides the build-commands for the Julia package [*FMIExport.jl*](https://github.com/ThummeTo/FMIExport.jl).

[![CI Testing](https://github.com/ThummeTo/FMIBuild.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/ThummeTo/FMIBuild.jl/actions)
[![Coverage](https://codecov.io/gh/ThummeTo/FMIBuild.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ThummeTo/FMIBuild.jl)

## How can I use FMIBuild.jl?
**Please note:** [*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl) is not meant to be used as it is, but as part of [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) and [*FMIExport.jl*](https://github.com/ThummeTo/FMIExport.jl). However you can install *FMIBuild.jl* by following these steps.
1. open a Julia-Command-Window, activate your preferred environment
1. goto package manager using ```]```
1. type ```add FMIBuild```

## What FMI.jl-Library should I use?
![FMI.jl Family](https://github.com/ThummeTo/FMI.jl/blob/main/docs/src/assets/FMI_JL_family.png "FMI.jl Family")
To keep dependencies nice and clean, the original package [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) had been split into new packages:
- [*FMI.jl*](https://github.com/ThummeTo/FMI.jl): High level loading, manipulating, saving or building entire FMUs from scratch
- [*FMIImport.jl*](https://github.com/ThummeTo/FMIImport.jl): Importing FMUs into Julia
- [*FMIExport.jl*](https://github.com/ThummeTo/FMIExport.jl): Exporting stand-alone FMUs from Julia Code
- [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl): C-code wrapper for the FMI-standard
- [*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl): Compiler/Compilation dependencies for FMIExport.jl
- [*FMIFlux.jl*](https://github.com/ThummeTo/FMIFlux.jl): Machine Learning with FMUs (differentiation over FMUs)
- [*FMIZoo.jl*](https://github.com/ThummeTo/FMIZoo.jl): A collection of testing and example FMUs

## What Platforms are supported?
[*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl) is tested (and testing) under Julia Versions *1.6.5 LTS* and *latest* on Windows *latest* and Ubuntu *latest*. `x64` architectures are tested. Mac and x86-architectures might work, but are not tested.

## How to cite?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** Martin Sj??lund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Link??ping, Sweden, September 20-24, 2021. Link??ping University Electronic Press, Link??ping (Link??ping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

## Related publications
Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** Journal of Physics: Conference Series 2090, 1, 012155. [DOI: 10.1088/1742-6596/2090/1/012155](https://doi.org/10.1088/1742-6596/2090/1/012155)
