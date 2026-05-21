//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// This file is a modified version of the julia_init.c-file

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _MSC_VER
JL_DLLEXPORT char *dirname(char *);
#else
#include <libgen.h>
#endif

// Julia headers (for initialization and gc commands)
#include "FMU2_init.h"
#include "julia.h"
#include "uv.h"

#ifdef _WIN32
#define FMU_PATH_MAX MAX_PATH
#else
#define FMU_PATH_MAX PATH_MAX
#endif

void setup_args(int argc, char **argv) {
    uv_setup_args(argc, argv);
    jl_parse_opts(&argc, &argv);
}

const char *get_sysimage_path(const char *libname) {
    if (libname == NULL) {
        jl_error("julia: Specify `libname` when requesting the sysimage path");
        exit(1);
    }

    void *handle = jl_load_dynamic_library(libname, JL_RTLD_DEFAULT, 0);
    if (handle == NULL) {
        jl_errorf("julia: Failed to load library at %s", libname);
        exit(1);
    }

    const char *libpath = jl_pathname_for_handle(handle);
    if (libpath == NULL) {
        jl_errorf("julia: Failed to retrieve path name for library at %s",
                  libname);
        exit(1);
    }

    return libpath;
}

void set_depot_load_path(const char *root_dir) {
#ifdef _WIN32
    char *julia_share_subdir = "\\share\\julia";
#else
    char *julia_share_subdir = "/share/julia";
#endif
    char *share_dir =
        calloc(sizeof(char), strlen(root_dir) + strlen(julia_share_subdir) + 1);
    strcat(share_dir, root_dir);
    strcat(share_dir, julia_share_subdir);

#ifdef _WIN32
    _putenv_s("JULIA_DEPOT_PATH", share_dir);
    _putenv_s("JULIA_LOAD_PATH", share_dir);
#else
    setenv("JULIA_DEPOT_PATH", share_dir, 1);
    setenv("JULIA_LOAD_PATH", share_dir, 1);
#endif
    free(share_dir);
}

void init_julia(int argc, char **argv) {
    setup_args(argc, argv);

    const char *sysimage_path = get_sysimage_path(JULIAC_PROGRAM_LIBNAME);
    char *_sysimage_path = strdup(sysimage_path);
    char *root_dir = dirname(dirname(_sysimage_path));
    set_depot_load_path(root_dir);
    free(_sysimage_path);

    jl_options.image_file = sysimage_path;
    julia_init(JL_IMAGE_CWD);
}

void shutdown_julia(int retcode) { jl_atexit_hook(retcode); }

// custom

static int FMU_INITIALIZED = 0;
static char FMU_DLL_PATH[FMU_PATH_MAX + 1] = {0};

void jl_init_FMU(char*);
const char* jl_fmi2GetTypesPlatform(void);
const char* jl_fmi2GetVersion(void);
fmi2Component jl_fmi2Instantiate(fmi2String, fmi2Type, fmi2String, fmi2String, const fmi2CallbackFunctions*, fmi2Boolean, fmi2Boolean);
void jl_fmi2FreeInstance(fmi2Component);
fmi2Status jl_fmi2SetDebugLogging(fmi2Component, fmi2Boolean, size_t, const fmi2String[]);
fmi2Status jl_fmi2SetupExperiment(fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real);
fmi2Status jl_fmi2EnterInitializationMode(fmi2Component);
fmi2Status jl_fmi2ExitInitializationMode(fmi2Component);
fmi2Status jl_fmi2Terminate(fmi2Component);
fmi2Status jl_fmi2Reset(fmi2Component);
fmi2Status jl_fmi2GetReal(fmi2Component, const fmi2ValueReference[], size_t, fmi2Real[]);
fmi2Status jl_fmi2GetInteger(fmi2Component, const fmi2ValueReference[], size_t, fmi2Integer[]);
fmi2Status jl_fmi2GetBoolean(fmi2Component, const fmi2ValueReference[], size_t, fmi2Boolean[]);
fmi2Status jl_fmi2GetString(fmi2Component, const fmi2ValueReference[], size_t, fmi2String[]);
fmi2Status jl_fmi2SetReal(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Real[]);
fmi2Status jl_fmi2SetInteger(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Integer[]);
fmi2Status jl_fmi2SetBoolean(fmi2Component, const fmi2ValueReference[], size_t, const fmi2Boolean[]);
fmi2Status jl_fmi2SetString(fmi2Component, const fmi2ValueReference[], size_t, const fmi2String[]);
fmi2Status jl_fmi2SetTime(fmi2Component, fmi2Real);
fmi2Status jl_fmi2SetContinuousStates(fmi2Component, const fmi2Real[], size_t);
fmi2Status jl_fmi2EnterEventMode(fmi2Component);
fmi2Status jl_fmi2NewDiscreteStates(fmi2Component, fmi2EventInfo*);
fmi2Status jl_fmi2EnterContinuousTimeMode(fmi2Component);
fmi2Status jl_fmi2CompletedIntegratorStep(fmi2Component, fmi2Boolean, fmi2Boolean*, fmi2Boolean*);
fmi2Status jl_fmi2GetDerivatives(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetEventIndicators(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetContinuousStates(fmi2Component, fmi2Real[], size_t);
fmi2Status jl_fmi2GetNominalsOfContinuousStates(fmi2Component, fmi2Real[], size_t);

void constructor(char* path)
{
    if (FMU_INITIALIZED) {
        return;
    }

#ifdef _WIN32
    char *dll_path = strdup(path);
    char *dll_dir = dirname(dll_path);
    SetDllDirectoryA(dll_dir);
    free(dll_path);
#endif

    init_julia(0, NULL);
    jl_init_FMU(path);
    FMU_INITIALIZED = 1;
}

void ensure_constructor(void)
{
    if (!FMU_INITIALIZED) {
        constructor(FMU_DLL_PATH);
    }
}

void destructor(void)
{
    if (FMU_INITIALIZED) {
        shutdown_julia(0);
        FMU_INITIALIZED = 0;
    }
}

const char* fmi2GetTypesPlatform(void) { ensure_constructor(); return jl_fmi2GetTypesPlatform(); }
const char* fmi2GetVersion(void) { ensure_constructor(); return jl_fmi2GetVersion(); }
fmi2Component fmi2Instantiate(fmi2String a, fmi2Type b, fmi2String c, fmi2String d, const fmi2CallbackFunctions* e, fmi2Boolean f, fmi2Boolean g) { ensure_constructor(); return jl_fmi2Instantiate(a, b, c, d, e, f, g); }
void fmi2FreeInstance(fmi2Component a) { ensure_constructor(); jl_fmi2FreeInstance(a); }
fmi2Status fmi2SetDebugLogging(fmi2Component a, fmi2Boolean b, size_t c, const fmi2String d[]) { ensure_constructor(); return jl_fmi2SetDebugLogging(a, b, c, d); }
fmi2Status fmi2SetupExperiment(fmi2Component a, fmi2Boolean b, fmi2Real c, fmi2Real d, fmi2Boolean e, fmi2Real f) { ensure_constructor(); return jl_fmi2SetupExperiment(a, b, c, d, e, f); }
fmi2Status fmi2EnterInitializationMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterInitializationMode(a); }
fmi2Status fmi2ExitInitializationMode(fmi2Component a) { ensure_constructor(); return jl_fmi2ExitInitializationMode(a); }
fmi2Status fmi2Terminate(fmi2Component a) { ensure_constructor(); return jl_fmi2Terminate(a); }
fmi2Status fmi2Reset(fmi2Component a) { ensure_constructor(); return jl_fmi2Reset(a); }
fmi2Status fmi2GetReal(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Real d[]) { ensure_constructor(); return jl_fmi2GetReal(a, b, c, d); }
fmi2Status fmi2GetInteger(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Integer d[]) { ensure_constructor(); return jl_fmi2GetInteger(a, b, c, d); }
fmi2Status fmi2GetBoolean(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2Boolean d[]) { ensure_constructor(); return jl_fmi2GetBoolean(a, b, c, d); }
fmi2Status fmi2GetString(fmi2Component a, const fmi2ValueReference b[], size_t c, fmi2String d[]) { ensure_constructor(); return jl_fmi2GetString(a, b, c, d); }
fmi2Status fmi2SetReal(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Real d[]) { ensure_constructor(); return jl_fmi2SetReal(a, b, c, d); }
fmi2Status fmi2SetInteger(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Integer d[]) { ensure_constructor(); return jl_fmi2SetInteger(a, b, c, d); }
fmi2Status fmi2SetBoolean(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2Boolean d[]) { ensure_constructor(); return jl_fmi2SetBoolean(a, b, c, d); }
fmi2Status fmi2SetString(fmi2Component a, const fmi2ValueReference b[], size_t c, const fmi2String d[]) { ensure_constructor(); return jl_fmi2SetString(a, b, c, d); }
fmi2Status fmi2SetTime(fmi2Component a, fmi2Real b) { ensure_constructor(); return jl_fmi2SetTime(a, b); }
fmi2Status fmi2SetContinuousStates(fmi2Component a, const fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2SetContinuousStates(a, b, c); }
fmi2Status fmi2EnterEventMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterEventMode(a); }
fmi2Status fmi2NewDiscreteStates(fmi2Component a, fmi2EventInfo* b) { ensure_constructor(); return jl_fmi2NewDiscreteStates(a, b); }
fmi2Status fmi2EnterContinuousTimeMode(fmi2Component a) { ensure_constructor(); return jl_fmi2EnterContinuousTimeMode(a); }
fmi2Status fmi2CompletedIntegratorStep(fmi2Component a, fmi2Boolean b, fmi2Boolean* c, fmi2Boolean* d) { ensure_constructor(); return jl_fmi2CompletedIntegratorStep(a, b, c, d); }
fmi2Status fmi2GetDerivatives(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetDerivatives(a, b, c); }
fmi2Status fmi2GetEventIndicators(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetEventIndicators(a, b, c); }
fmi2Status fmi2GetContinuousStates(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetContinuousStates(a, b, c); }
fmi2Status fmi2GetNominalsOfContinuousStates(fmi2Component a, fmi2Real b[], size_t c) { ensure_constructor(); return jl_fmi2GetNominalsOfContinuousStates(a, b, c); }

#ifdef _WIN32
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved)
{
    switch (fdwReason)
    {
    case DLL_PROCESS_ATTACH:

        // get DLL path for resource location
        HMODULE hm = NULL;

        DisableThreadLibraryCalls(hinstDLL);

        if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR) &init_julia, &hm) == 0)
        {
            int ret = GetLastError();
            fprintf(stderr, "GetModuleHandle failed, error = %d\n", ret);
            return (FALSE);
        }
        if (GetModuleFileNameA(hm, FMU_DLL_PATH, sizeof(FMU_DLL_PATH)) == 0)
        {
            int ret = GetLastError();
            fprintf(stderr, "GetModuleFileName failed, error = %d\n", ret);
            return (FALSE);
        }
        break;
    case DLL_PROCESS_DETACH:
        destructor();
        break;
    }
    return (TRUE);
}

#else
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef __cplusplus
#define CP_BEGIN_EXTERN_C extern "C" {
#define CP_END_EXTERN_C }
#else
#define CP_BEGIN_EXTERN_C
#define CP_END_EXTERN_C
#endif

CP_BEGIN_EXTERN_C

__attribute__((constructor))
static void Initializer(int argc, char** argv, char** envp)
{
    char pid[20];
    sprintf(pid, "/proc/%d/exe", getpid());
    readlink(pid, FMU_DLL_PATH, sizeof(FMU_DLL_PATH));

    constructor(FMU_DLL_PATH); 
}

__attribute__((destructor))
static void Finalizer()
{
    destructor();
}

CP_END_EXTERN_C

#endif
