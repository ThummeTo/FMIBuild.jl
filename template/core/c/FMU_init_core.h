//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// Shared FMU/JULIA initialization declarations.
#ifdef _WIN32
#include <windows.h>
BOOL WINAPI DllMain(HINSTANCE, DWORD, LPVOID);
#endif

void init_FMU(char*);

// from julia_init.h
//void init_julia(int argc, char *argv[]);
//void shutdown_julia(int retcode);
