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

`assembleBuildTemplates` selects and combines these fragments according to the
interfaces declared in the model description.
