# FMIBuild templates

The template tree is organized first by FMI-independent or FMI-version-specific
content, then by implementation language or build purpose.

- `core/c`: FMI-version-independent C code for initializing Julia and the FMU runtime.
- `core/precompile`: FMI-version-independent Julia precompile statements.
- `FMI2/c/common`: C types and entry points shared by FMI 2 Model Exchange and Co-Simulation.
- `FMI2/c/ME`: C entry points included only for FMI 2 Model Exchange.
- `FMI2/c/CS`: C entry points included only for FMI 2 Co-Simulation.
- `FMI2/julia`: Julia implementations that bridge exported FMI 2 C functions to the FMU object.
- `FMI2/precompile`: FMI 2 common and interface-specific Julia precompile statements.
- `FMI3/c/common`: C types and entry points shared by FMI 3 Model Exchange and Co-Simulation (including `fmi3Error`/`NULL` stubs for the unsupported clock and Scheduled Execution functions, which importers like FMPy still require to be exported).
- `FMI3/c/ME`: C entry points included only for FMI 3 Model Exchange.
- `FMI3/c/CS`: C entry points included only for FMI 3 Co-Simulation.
- `FMI3/julia`: Julia implementations that bridge exported FMI 3 C functions to the FMU object.
- `FMI3/precompile`: FMI 3 common and interface-specific Julia precompile statements.

The precompile statements cover all Julia entry points (`Base.@ccallable`) of the
FMU. They are parsed line by line by PackageCompiler, so each statement must stay
on a single line. `FMIBUILD_MODULE` is replaced by the FMU module name during the
build and all types are module qualified (e.g. `FMICore.fmi3Instance`).

`assembleBuildTemplates` selects and combines these fragments according to the
FMI version of the FMU and the interfaces declared in the model description.
FMI 3 Scheduled Execution is not supported.
