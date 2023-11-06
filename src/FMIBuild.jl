#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMIBuild

using FMICore: FMU2, FMU2Component, fmi2ModelDescription, fmi2ValueReference, fmi2Component, fmi2ComponentEnvironment, fmi2Status, fmi2EventInfo
using FMICore: fmi2Type, fmi2TypeModelExchange, fmi2TypeCoSimulation
using FMICore: fmi2True, fmi2False
using FMICore: fmi2ModelDescriptionModelExchange, fmi2ModelDescriptionCoSimulation, fmi2VariableNamingConventionStructured
using FMICore: fmi2CausalityToString, fmi2VariabilityToString, fmi2InitialToString, fmi2DependencyKindToString
using FMICore: fmi2RealAttributes, fmi2IntegerAttributes, fmi2BooleanAttributes, fmi2StringAttributes, fmi2EnumerationAttributes
using FMICore: fmi2RealAttributesExt, fmi2IntegerAttributesExt, fmi2BooleanAttributesExt, fmi2StringAttributesExt, fmi2EnumerationAttributesExt
#using FMIExport: fmi2SaveModelDescription

import PackageCompiler
import Pkg
import ZipFile
using EzXML
import Dates

# exports
export fmi2Save

# returns the path for a given package name (`nothing` if not installed)
function packagePath(pkg; )
    path = Base.find_package(pkg)

    if isnothing(path)
        return nothing 
    end

    splits = splitpath(path)
    
    return joinpath(splits[1:end-2]...)
end

"""
    fmi2Save(fmu::FMU2, 
     fmu_path::String, 
     fmu_src_file::Union{Nothing, String}=nothing; 
     standalone=true, 
     compress=true, 
     cleanup=true, 
     removeLibDependency=true,
     removeNoExportBlocks=true,
     surpressWarnings::Bool=false,
     debug::Bool=false,
     pkg_comp_kwargs...)

Initiates the FMU building process. 

The current package is detected, duplicated and extended by the FMI-functions. The resulting package is compiled and a suitable FMI-model-description is deployed. Finally, all files are zipped into a standard-compliant FMU that can be executed in a variety of tools without having Julia installed.

# Arguments
    - `fmu_path` path to the (future) FMU file, must end on `*.fmu`
    - `fmu_src_file` file with the FMU constructor, if `nothing` file is determined automatically and the file from the call to `fmi2Save` is assumed (default=`nothing`)

# Keyword arguments
    - `standalone` if the FMU should be build in standalone-mode, meaning without external dependencies to a Julia-Installation (default=`true`) 
    - `compress` if the FMU archive should be compressed to save disk space. On the other hand, this may enlarge loading time (default=`true`) 
    - `cleanup` if the unzipped FMU archive should be deleted after creation (default=`true`) 
    - `removeLibDependency` removes the FMIBuild.jl-dependency, so it will not be part of the resulting FMU (default=`true`) 
    - `removeNoExportBlocks` removes the blocks marked with `### FMIBUILD_NO_EXPORT_BEGIN ###` and `### FMIBUILD_NO_EXPORT_END ###` from the `fmu_src_file`, so it will not be part of the resulting FMU (default=`true`) 
    - `ressources` a Dictionary of ressources (srcPath::String => dstPath::String) for files to ship as part of the FMU
    - `debug` compiles the FMU in debug mode, including full exception handling for all FMI functions. Exception stack is printed through the FMI callback pipeline. This is extremly useful during FMU development, but slows down the FMU's simulation performance (defaul=false)
    - `surpressWarnings::Bool` an indicator wheater warnings should be surpressed (default=false)
"""
function fmi2Save(fmu::FMU2, fmu_path::String, fmu_src_file::Union{Nothing, String}=nothing; 
    standalone=true, 
    compress=true, 
    cleanup=true, 
    removeLibDependency=true,
    removeNoExportBlocks=true,
    resources::Union{Dict{String, String}, Nothing}=nothing,
    debug::Bool=false,
    surpressWarnings::Bool=false,
    pkg_comp_kwargs...)

    startCompilation = time()

    # @assert fmi2Check(fmu) == true ["fmiBuild(...): FMU-Pre-Check failed. See messages above for further information."]

    fmu_fname, fmu_ext = splitext(basename(fmu_path))
    @assert fmu_ext == ".fmu" "FMU must have file extension `.fmu`, has `$(fmu_ext)`."

    # warnings

    if !surpressWarnings
        if fmu.modelDescription.modelName != fmu_fname
            @warn "This FMU has a model name `$(fmu.modelDescription.modelName)` that does not fit the FMU filename `$(fmu_fname).fmu`. Is this intended?"
        end

        if !isnothing(fmu.modelDescription.modelExchange)
            if fmu.modelDescription.modelExchange.modelIdentifier != fmu_fname
                @warn "This FMU has a model exchange identifier `$(fmu.modelDescription.modelExchange.modelIdentifier)` that does not fit the FMU filename `$(fmu_fname).fmu`. Is this intended?"
            end
        end

        if !isnothing(fmu.modelDescription.coSimulation)
            if fmu.modelDescription.coSimulation.modelIdentifier != fmu_fname
                @warn "This FMU has a co simulation identifier `$(fmu.modelDescription.coSimulation.modelIdentifier)` that does not fit the FMU filename `$(fmu_fname).fmu`. Is this intended?"
            end
        end
    end

    # searching the source file ...
    if fmu_src_file == nothing
        stack = stacktrace(backtrace())
        for i in 1:length(stack)
            if !endswith("$(stack[i].file)", "FMIBuild.jl") 
                fmu_src_file = "$(stack[i].file)"
                break
            end
        end
        @assert (fmu_src_file != nothing) ["fmi2Save(...): Cannot automatically determine `fmu_src_file`, please provide manually via keyword-argument."]
        @info "[Build FMU] Automatically determined build file at: `$(fmu_src_file)`."
    end

    @assert standalone == true ["fmiBuild(...): Currently, only `standalone=true` is supported."]

    pkg_dir = "$(@__DIR__)/../template"
    (fmu_name, fmu_ext) = splitext(basename(fmu_path))
    pkg_dir = joinpath(pkg_dir, "FMU2")

    @assert fmu_ext != "fmu" ["fmiBuild(...): `fmu_path` must end with `.fmu`."]

    fmu_dir = dirname(fmu_path)

    ### dirs 
    target_dir = joinpath(fmu_dir) 
    # save evrything in a temporary directory
    if cleanup
       target_dir = mktempdir(; prefix="fmibuildjl_", cleanup=false) 
    end 
    mkpath(joinpath(target_dir, fmu_name))
    md_path = joinpath(target_dir, fmu_name, "modelDescription.xml")

    bin_dir = joinpath(target_dir, fmu_name, "binaries")
    libext = nothing

    # checking architecture
    juliaArch = Sys.WORD_SIZE
    if juliaArch == 64
        if Sys.iswindows()
            bin_dir = joinpath(bin_dir, "win64")
            libext = "dll"
        elseif Sys.islinux()
            bin_dir = joinpath(bin_dir, "x86_64-linux")
            libext = "so"
        elseif Sys.isapple()
            bin_dir = joinpath(bin_dir, "x86_64-darwin")
            libext = "dylib"
        end
    elseif juliaArch == 32
        if Sys.iswindows()
            bin_dir = joinpath(bin_dir, "win32")
            libext = "dll"
        elseif Sys.islinux()
            # pass
        elseif Sys.isapple()
            # pass
        end
    end

    @assert !isnothing(libext) "fmiBuild(...): Unsupported target platform. Supporting Windows (64-, 32-bit), Linux (64-bit) and MacOS (64-bit). Please open an issue online if you need further architectures."

    mkpath(bin_dir)

    pkg_dir = replace(pkg_dir, "\\"=>"/") 
    target_dir = replace(target_dir, "\\"=>"/")    

    @info "[Build FMU] Generating package ..."
    source_pkf_dir = dirname(fmu_src_file)
    fmu_src_in_merge_dir = splitpath(fmu_src_file)[end]
    while !isfile(joinpath(source_pkf_dir, "Project.toml")) && length(source_pkf_dir) > 0
        pathcomp = splitpath(source_pkf_dir)
        source_pkf_dir = (length(pathcomp) > 1 ? joinpath(pathcomp[1:end-1]...) : "")
        fmu_src_in_merge_dir = joinpath(pathcomp[end], fmu_src_in_merge_dir)
    end
    @assert length(source_pkf_dir) > 0 ["fmiBuild(...): Cannot find a package where this file is stored in. For FMU-Export, this source file needs to be inside of a package."]
    merge_dir = joinpath(target_dir, "merged_" * fmu_name)
    cp(source_pkf_dir, merge_dir; force=true)
    chmod(target_dir, 0o777; recursive=true)
    @info "[Build FMU] Source package is $(source_pkf_dir), deployed at $(merge_dir)"
    @info "[Build FMU] Relative src file path is $(fmu_src_in_merge_dir)"

    fmu_res = "$(@__DIR__)/../template/ME/FMU2/src/FMU2_content.jl"
    if debug
        fmu_res = "$(@__DIR__)/../template/ME/FMU2/src/FMU2_content_debug.jl"
    end

    @info "[Build FMU] ... reading FMU template file at $(fmu_res)"
    f = open(fmu_res, "r")
    fmu_code = read(f, String);
    close(f)

    @info "[Build FMU] ... reading old FMU source file at $(joinpath(merge_dir, fmu_src_in_merge_dir))"
    f = open(joinpath(merge_dir, fmu_src_in_merge_dir), "r")
    cdata = read(f, String);
    close(f)

    # ToDo: This will fail badly on `fmi2Save(a, (b, c), d)` -> use Julia code parser
    
    if removeNoExportBlocks
        @info "[Build FMU] Removing `FMIBUILD_NO_EXPORT_*` blocks ..."
        cdata = replace(cdata, r"### FMIBUILD_NO_EXPORT_BEGIN ###(.|\n|\r)*### FMIBUILD_NO_EXPORT_END ###" => "")
        @info "[Build FMU] ... removed `FMIBUILD_NO_EXPORT_*` blocks."
    end

    # projectToml = joinpath(merge_dir, "Project.toml")
    # s = stat(projectToml)
    # println(Int(s.mode))
    # println(s.uid)
    # println(s.gid)
    # chmod(projectToml, 0o777)
    # println(Int(s.mode))
    # println(s.uid)
    # println(s.gid)

    @info "[Build FMU] Adding/removing dependencies ..."
    currentEnv = Base.active_project()
    currentCompState = get(ENV, "JULIA_PKG_PRECOMPILE_AUTO", 1)
    ENV["JULIA_PKG_PRECOMPILE_AUTO"] = 0

    defaultEnv = get(ENV, "FMIExport_DefaultEnv", nothing)
    if !isnothing(defaultEnv)
        @info "[Build FMU]    > Using default environment `$(defaultEnv)` from environment variable `FMIExport_DefaultEnv`."
    else 
        defaultEnv = Base.active_project()
        @info "[Build FMU]    > Using active environment `$(defaultEnv)`."
    end
    Pkg.activate(defaultEnv)
    default_fmiexportPath = packagePath("FMIExport")
    default_fmicorePath = packagePath("FMICore")
    
    # adding Pkgs
    Pkg.activate(merge_dir)

    if isnothing(default_fmicorePath)
        @info "[Build FMU]    > Default environment `$(defaultEnv)` has no dependency on `FMICore`, adding `FMICore` from registry."
        Pkg.add("FMICore")
    else
        old_fmicorePath = packagePath("FMICore")
        if isnothing(old_fmicorePath)
            @info "[Build FMU]    > `FMICore` not installed, adding at `$(default_fmicorePath)`, adding `FMICore` from default environment."
            Pkg.add(path=default_fmicorePath)
        elseif lowercase(old_fmicorePath) == lowercase(default_fmicorePath)
            @info "[Build FMU]    > Most recent version (as in default environment) of `FMICore` already checked out, is `$(default_fmicorePath)`."
        else
            @info "[Build FMU]    > Replacing `FMICore` at `$(old_fmicorePath)` with the default environment installation at `$(default_fmicorePath)`."
            Pkg.add(path=default_fmicorePath)
        end    
    end
    
    # redirect FMIExport.jl package in case the active environment (the env the installer is called from)
    # has a *more recent* version of FMIExport.jl than the registry (necessary for Github-CI to use the current version from a PR)
    if isnothing(default_fmiexportPath) # the environemnt the exporter is called from *has no* FMIExport.jl installed   
        @info "[Build FMU]    > Default environment `$(defaultEnv)` has no dependency on `FMIExport`."
    else # the environemnt the exporter is called from *has* FMIExport.jl installed
        old_fmiexportPath = packagePath("FMIExport")
        if isnothing(old_fmiexportPath) # the FMU has no dependency to FMIExport.jl
            @info "[Build FMU]    > `FMIExport` for FMU not installed, adding at `$(default_fmiexportPath)`, adding `FMIExport` from default environment."
            Pkg.add(path=default_fmiexportPath)
        elseif lowercase(old_fmiexportPath) == lowercase(default_fmiexportPath) # the FMU is already using the most recent version of FMIExport.jl
            @info "[Build FMU]    > Most recent version of `FMIExport` already checked out for FMU, is `$(default_fmiexportPath)`."
        else
            @info "[Build FMU]    > Replacing `FMIExport` at `$(old_fmiexportPath)` with the current installation at `$(default_fmiexportPath)` for FMU ."
            Pkg.add(path=default_fmiexportPath)
        end   
    end

    if removeLibDependency
        cdata = replace(cdata, r"(using|import) FMIBuild" => "")
        try
            Pkg.rm("FMIBuild")
            @info "[Build FMU]    > Removed FMIBuild"
        catch e
            @info "[Build FMU]    > Not used FMIBuild (nothing removed)"
        end
    end

    Pkg.activate(currentEnv)
    ENV["JULIA_PKG_PRECOMPILE_AUTO"] = currentCompState
    @info "[Build FMU] ... adding/removing dependencies done."
    
    @info "[Build FMU] ... generating new FMU source file at $(joinpath(merge_dir, fmu_src_in_merge_dir))"
    
    f = open(joinpath(merge_dir, fmu_src_in_merge_dir), "w")
    assertline = "" # "\n@assert FMIBUILD_FMU != nothing \"`FMIBUILD_FMU = nothing`, did you forget to mark the FMU instance to export with `FMIBUILD_FMU = myFMUInstance`?\"\n"

    cdata_start = "" # "\nBase.@ccallable function init_FMU()::Cvoid\n"
    cdata_end = "" # "\nnothing\nend\n"
    write(f, "module " * fmu_name * "\n" * fmu_code * cdata_start * cdata * cdata_end * assertline * "\nend");
    close(f)

    @info "[Build FMU] ... generating package done."

    @info "[Build FMU] Compiling FMU ..."
    PackageCompiler.create_library(merge_dir, joinpath(target_dir, "_" * fmu_name);
                                    lib_name=fmu_name,
                                    precompile_execution_file=[joinpath(merge_dir, fmu_src_in_merge_dir)], # "$(@__DIR__)/../template/ME/precompile/FMU2_generate.jl"
                                    precompile_statements_file=["$(@__DIR__)/../template/ME/precompile/FMU2_additional.jl"],
                                    incremental=false,
                                    filter_stdlibs=false,
                                    julia_init_c_file = "$(@__DIR__)/../template/ME/header/FMU2_init.c",
                                    header_files = ["$(@__DIR__)/../template/ME/header/FMU2_init.h"], 
                                    force=true,
                                    include_transitive_dependencies=true,
                                    include_lazy_artifacts=true,                                    
                                    pkg_comp_kwargs...)
    @info "[Build FMU] ... compiling FMU done."

    cp(joinpath(target_dir, "_" * fmu_name, "bin"), joinpath(bin_dir); force=true)
    cp(joinpath(target_dir, "_" * fmu_name, "share"), joinpath(bin_dir, "..", "share"); force=true)
    cp(joinpath(target_dir, "_" * fmu_name, "include"), joinpath(bin_dir, "..", "include"); force=true)

    if resources != nothing 
        @info "[Build FMU] Adding resource files ..."
        mkdir(joinpath(bin_dir, "..", "..", "resources"))
        for (key, val) in resources
            cp(key, joinpath(bin_dir, "..", "..", "resources", val); force=true)
            @info "[Build FMU] \t $val"
        end
        @info "[Build FMU] ... adding resoruce files done."
    end

    @info "[Build FMU] Patching libjulia.$(libext) @ `$(bin_dir)`..."
    patchJuliaLib(joinpath(bin_dir, "libjulia.$(libext)"))
    @info "[Build FMU] ... patching libjulia.$(libext) done."

    stopCompilation = time()
    startPacking = time()

    @info "[Build FMU] Building model description ..."
    fmi2SaveModelDescription(fmu.modelDescription, md_path)
    @info "[Build FMU] ... building model description done."

    # parse and zip directories
    @info "[Build FMU] Zipping FMU ..."
    zipfile = joinpath(target_dir, fmu_name * ".zip")
    zdir = ZipFile.Writer(zipfile) 
    for (root, dirs, files) in walkdir(joinpath(target_dir, fmu_name))
        for file in files
            filepath = joinpath(root, file)
            f = open(filepath, "r")
            content = read(f, String)
            close(f)

            zippath = subtractPath(filepath, joinpath(target_dir, fmu_name) * "/")
            println("\t$(zippath)")
            zf = ZipFile.addfile(zdir, zippath; method=(compress ? ZipFile.Deflate : ZipFile.Store));
            write(zf, content)
        end
    end
    close(zdir)

    # Rename ZIP-file to FMU-file
    cp(joinpath(target_dir, fmu_name * ".zip"), joinpath(fmu_dir, fmu_name * ".fmu"); force=true) 
    @info "[Build FMU] ... zipping FMU done."

    if cleanup
        @info "[Build FMU] Clean up ..."
        # ToDo: Clean-up is done by saving in a temporary directory (which may be deleted by the OS) 
        @info "[Build FMU] ... clean up done."
    end 

    stopPacking = time()

    # output message 
    dt = stopPacking-startCompilation
    per = (stopPacking-startPacking) / dt * 100.0
    mins = 0
    secs = round(Integer, dt)
    while secs >= 60
        mins += 1
        secs -= 60
    end

    @info "FMU-Export succeeded after $(mins)m $(secs)s ($(round(per; digits=1))% packing time)"

    return true
end

# removes all leading elements of pathA that fit pathB 
function subtractPath(pathA::String, pathB::String)
    pathA = replace(pathA, "\\"=>"/") 
    pathB = replace(pathB, "\\"=>"/") 

    if length(pathA) <= 0 || length(pathB) <= 0
        return pathA 
    end

    while (length(pathA) > 0 && length(pathB) > 0) && (pathA[1] == pathB[1])
        pathA = pathA[2:end]
        pathB = pathB[2:end]
    end 

    return pathA
end

# Thank you @staticfloat
# based on: https://github.com/JuliaLang/PackageCompiler.jl/issues/658
# patches the compiled DLL, so the lib does not have "bad" relative paths like "../bin/", where "bin" is the directory of the DLL itself
function patchJuliaLib(libjulia_path)
    
    if !isfile(libjulia_path)
        error("Unable to open libjulia.* at $(libjulia_path)")
    end
    
    open(libjulia_path, read=true, write=true) do io
        # Search for `../bin/` string:
        needle = "../bin/"
        readuntil(io, needle)
        skip(io, -length(needle))
        libpath_offset = position(io)
    
        libpath = split(String(readuntil(io, UInt8(0))), ":")
        @info("Found embedded libpath", libpath, libpath_offset)
    
        # Get rid of `../bin/` prefix:
        libpath = map(libpath) do l
            if startswith(l, "../bin/")
                return l[8:end]
            elseif startswith(l, "@../bin/")
                return "@$(l[9:end])"
            else
                return l
            end
        end
    
        @info("Filtered libpath", libpath)
    
        # Write filtered libpath out to the file, terminate with NULL.
        seek(io, libpath_offset)
        write(io, join(libpath, ":"))
        write(io, UInt8(0))
    end
end

function dependencyString(dependencies::AbstractArray)
    if isnothing(dependencies)
        return ""
    end

    if length(dependencies) <= 0
        return "" 
    end

    depStr = "$(dependencies[1])"
    for d in 2:length(dependencies)
        depStr *= " $(dependencies[d])"
    end

    return depStr
end

function dependencyKindString(dependencies::AbstractArray)
    if isnothing(dependencies)
        return ""
    end

    if length(dependencies) <= 0
        return "" 
    end

    depStr = "$(fmi2DependencyKindToString(dependencies[1]))"
    for d in 2:length(dependencies)
        depStr *= " $(fmi2DependencyKindToString(dependencies[d]))"
    end

    return depStr
end

function addFieldsAsAttributes(node, _struct, skiplist=())
    for field in fieldnames(typeof(_struct))
        if field ∉ skiplist

            if !isdefined(_struct, field)
                continue
            end

            value = getfield(_struct, field)

            if isnothing(value)
               continue
            end

            # special formatters
            if isa(value, Bool)

                value = (value ? "true" : "false")
            elseif field == :causality

                value = fmi2CausalityToString(value)
            elseif field == :variability

                value = fmi2VariabilityToString(value)
            elseif field == :initial

                value = fmi2InitialToString(value)
            elseif field == :dependencies

                if length(value) <= 0
                    return "" 
                end
                depStr = "$(value[1])"
                for d in 2:length(value)
                    depStr *= " $(value[d])"
                end
                value = depStr
            elseif field == :dependenciesKind

                if length(value) <= 0
                    return "" 
                end
                depStr = "$(fmi2DependencyKindToString(value[1]))"
                for d in 2:length(value)
                    depStr *= " $(fmi2DependencyKindToString(value[d]))"
                end
                value = depStr
            end

            link!(node, AttributeNode("$(field)", "$(value)"))
        end
    end
end

function fmi2SaveModelDescription(md::fmi2ModelDescription, file_path::String)
    doc = XMLDocument()
    
    doc_root = ElementNode("fmiModelDescription") 
    setroot!(doc, doc_root)
    link!(doc_root, AttributeNode("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"))

    # mandatory
    link!(doc_root, AttributeNode("fmiVersion", "2.0"))
    link!(doc_root, AttributeNode("modelName", md.modelName))
    link!(doc_root, AttributeNode("guid", "$(md.guid)"))

    # optional
    link!(doc_root, AttributeNode("generationTool", "FMIExport.jl (https://github.com/ThummeTo/FMIExport.jl) by Tobias Thummerer, Lars Mikelsons"))
    if md.generationDateAndTime != nothing
        dateTimeString = ""
        if isa(md.generationDateAndTime, Dates.DateTime)
            dateTimeString = Dates.format(md.generationDateAndTime, "yyyy-mm-dd") * "T" * Dates.format(md.generationDateAndTime, "HH:MM:SS") * "Z" 
        elseif isa(md.generationDateAndTime, String)
            dateTimeString = md.generationDateAndTime
        else 
            @warn "fmi2SaveModelDescription(...): Unkown data type for field `generationDateAndTime`. Supported is `DateTime` and `String`, but given `$(md.generationDateAndTime)` (typeof `$(typeof(md.generationDateAndTime))`)."
        end
        link!(doc_root, AttributeNode("generationDateAndTime", dateTimeString))
    end
    if !isnothing(md.variableNamingConvention)
        link!(doc_root, AttributeNode("variableNamingConvention", (md.variableNamingConvention == fmi2VariableNamingConventionStructured ? "structured" : "flat")))
    end
    if !isnothing(md.numberOfEventIndicators)
        link!(doc_root, AttributeNode("numberOfEventIndicators", "$(md.numberOfEventIndicators)"))
    end

    if !isnothing(md.modelExchange)
        me = ElementNode("ModelExchange")
        link!(doc_root, me)
        addFieldsAsAttributes(me, md.modelExchange)
    end

    if !isnothing(md.coSimulation)
        cs = ElementNode("CoSimulation")
        link!(doc_root, cs)
        addFieldsAsAttributes(cs, md.coSimulation)
    end

    if !isnothing(md.typeDefinitions)
        td = ElementNode("TypeDefinitions")
        link!(doc_root, td)

        for typdef in md.typeDefinitions
            st = ElementNode("SimpleType")
            link!(td, st)

            addFieldsAsAttributes(st, typdef, (:attribute,))

            if isa(typdef.attribute, fmi2RealAttributes)
                tn = ElementNode("Real")
                addFieldsAsAttributes(tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2IntegerAttributes)
                tn = ElementNode("Integer")
                addFieldsAsAttributes(tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2BooleanAttributes)
                tn = ElementNode("Boolean")
                addFieldsAsAttributes(tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2StringAttributes)
                tn = ElementNode("String")
                addFieldsAsAttributes(tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2EnumerationAttributes)
                tn = ElementNode("Enumeration")
                addFieldsAsAttributes(tn, typdef.attribute, (:items,))
                link!(st, tn)

                for j in 1:length(typdef.attribute)
                    itemNode = ElementNode("Item")
                    addFieldsAsAttributes(itemNode, typdef.attribute[j])
                    link!(tn, itemNode)
                end
            else
                @warn "Unknown type for fmi2SimpleType."
            end

        end
    end

    mv = ElementNode("ModelVariables")
    link!(doc_root, mv)
    for i in 1:length(md.modelVariables)
        link!(mv, CommentNode("Index=$(i)"))

        sv = md.modelVariables[i]
        sv_node = ElementNode("ScalarVariable")
        link!(mv, sv_node)

        addFieldsAsAttributes(sv_node, sv, (:attribute,))

        # Real
        if sv.Real != nothing
            r_node = ElementNode("Real")
            addFieldsAsAttributes(r_node, sv.Real, (:attributes,))
            addFieldsAsAttributes(r_node, sv.attribute.attributes)
            link!(sv_node, r_node)
        end

        # Integer
        if sv.Integer != nothing
            i_node = ElementNode("Integer")
            addFieldsAsAttributes(i_node, sv.Integer, (:attributes,))
            addFieldsAsAttributes(i_node, sv.attribute.attributes)
            link!(sv_node, i_node)
        end

        # Boolean
        if sv.Boolean != nothing
            b_node = ElementNode("Boolean")
            addFieldsAsAttributes(b_node, sv.Boolean)
            link!(sv_node, b_node)
        end

        # String
        if sv.String != nothing
            s_node = ElementNode("String")
            addFieldsAsAttributes(s_node, sv.String)
            link!(sv_node, s_node)
        end

        # Enumeration
        if sv.Enumeration != nothing
            e_node = ElementNode("Enumeration")
            addFieldsAsAttributes(e_node, sv.Enumeration)
            link!(sv_node, e_node)
        end
    end

    ms = ElementNode("ModelStructure")
    link!(doc_root, ms)

    if md.modelStructure.outputs != nothing
        outs = ElementNode("Outputs")
        link!(ms, outs)

        for i in 1:length(md.modelStructure.outputs)
            uk = md.modelStructure.outputs[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(uk_node, uk)
            link!(outs, uk_node)
        end
    end

    if md.modelStructure.derivatives != nothing
        ders = ElementNode("Derivatives")
        link!(ms, ders)

        for i in 1:length(md.modelStructure.derivatives)
            uk = md.modelStructure.derivatives[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(uk_node, uk)
            link!(ders, uk_node)
        end
    end

    if md.modelStructure.initialUnknowns != nothing
        inis = ElementNode("InitialUnknowns")
        link!(ms, inis)

        for i in 1:length(md.modelStructure.initialUnknowns)
            uk = md.modelStructure.initialUnknowns[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(uk_node, uk)
            link!(inis, uk_node)
        end
    end
    
    # save modelDescription (with linebreaks)
    f = open(file_path, "w")
    prettyprint(f, doc)
    close(f)
end

end # module
