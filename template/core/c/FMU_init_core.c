//
// Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

// This file is a modified version of the julia_init.c-file

#ifndef _WIN32
#define _GNU_SOURCE
#endif

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef _MSC_VER
JL_DLLEXPORT char *dirname(char *);
#else
#include <libgen.h>
#endif

// Julia headers (for initialization and gc commands)
#include "FMU_init.h"
#include "julia.h"
#include "uv.h"

#ifdef _WIN32
#define FMU_PATH_MAX MAX_PATH
#define FMU_EXPORT __declspec(dllexport)
#else
#define FMU_PATH_MAX PATH_MAX
#define FMU_EXPORT __attribute__((visibility("default")))
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
#ifdef _WIN32
    char *abs_sysimage_path = _fullpath(NULL, sysimage_path, 0);
#else
    char *abs_sysimage_path = realpath(sysimage_path, NULL);
#endif
    char *_sysimage_path = strdup(abs_sysimage_path);
    char *root_dir = dirname(dirname(_sysimage_path));
    set_depot_load_path(root_dir);

#if JULIA_VERSION_MAJOR == 1 && JULIA_VERSION_MINOR <= 11
    jl_options.image_file = abs_sysimage_path;
    julia_init(JL_IMAGE_CWD);
#else
    size_t bindir_len = strlen(root_dir) + 5;
    char *bindir = (char *)malloc(bindir_len);
    snprintf(bindir, bindir_len, "%s/bin", root_dir);
    jl_init_with_image_file(bindir, abs_sysimage_path);
    free(bindir);
#endif
    free(_sysimage_path);
}

void shutdown_julia(int retcode) { jl_atexit_hook(retcode); }

static int FMU_INITIALIZED = 0;
static char FMU_DLL_PATH[FMU_PATH_MAX + 1] = {0};

void jl_init_FMU(char*);

void constructor(char* path)
{
    if (FMU_INITIALIZED) {
        return;
    }

#ifdef _WIN32
    // Let Windows find the bundled Julia DLLs next to the FMU binary.
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
    // FMI entry points lazily initialize Julia after the platform loader returns.
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

#ifdef _WIN32
// Windows DLL entry point: record the FMU DLL path, defer Julia startup to FMI calls.
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
        // Windows can shut Julia down on DLL unload without blocking FMPy.
        destructor();
        break;
    }
    return (TRUE);
}

#else
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>

#ifdef __cplusplus
#define CP_BEGIN_EXTERN_C extern "C" {
#define CP_END_EXTERN_C }
#else
#define CP_BEGIN_EXTERN_C
#define CP_END_EXTERN_C
#endif

CP_BEGIN_EXTERN_C

// Linux loader hook: only record the FMU shared-library path during dlopen.
__attribute__((constructor))
static void Initializer(int argc, char** argv, char** envp)
{
    Dl_info info;
    if (dladdr((void *)&Initializer, &info) != 0 && info.dli_fname != NULL) {
        if (realpath(info.dli_fname, FMU_DLL_PATH) == NULL) {
            strncpy(FMU_DLL_PATH, info.dli_fname, sizeof(FMU_DLL_PATH) - 1);
        }
    }
}

// Keep Linux unload lightweight; Julia shutdown during dlclose can block importers.
__attribute__((destructor))
static void Finalizer()
{
}

CP_END_EXTERN_C

#endif
