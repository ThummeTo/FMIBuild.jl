#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMIBuild

using FMICore: FMU2, FMU2Component, fmi2ModelDescription, fmi2ValueReference, fmi2Component, fmi2ComponentEnvironment, fmi2Status, fmi2EventInfo
using FMICore: fmi2Type, fmi2TypeModelExchange, fmi2TypeCoSimulation
using FMICore: fmi2True, fmi2False
using FMICore: fmi2ModelDescriptionModelExchange, fmi2ModelDescriptionCoSimulation, fmi2VariableNamingConventionStructured
using FMICore: fmi2CausalityToString, fmi2VariabilityToString, fmi2InitialToString
#using FMIExport: fmi2SaveModelDescription

import PackageCompiler
import Pkg
import ZipFile
using EzXML
import Dates

# exports
export fmi2Save

"""
    fmi2Save(fmu::FMU2, 
     fmu_path::String, 
     fmu_src_file::Union{Nothing, String}=nothing; 
     standalone=true, 
     compress=false, 
     cleanup=true, 
     modelExchange=true,
     coSimulation=false,
     removeLibDependency=true,
     removeNoExportBlocks=true,
     pkg_comp_kwargs...)

Initiates the FMU building process. 

The current package is detected, duplicated and extended by the FMI-functions. The resulting package is compiled and a suitable FMI-model-description is deployed. Finally, all files are zipped into a standard-compliant FMU that can be executed in a variety of tools without having Julia installed.

# Arguments
    - `fmu_path` path to the (future) FMU file, must end on `*.fmu`
    - `fmu_src_file` file with the FMU constructor, if `nothing` file is determined automatically and the file from the call to `fmi2Save` is assumed (default=`nothing`)

# Keyword arguments
    - `standalone` if the FMU should be build in standalone-mode, meaning without external dependencies to a Julia-Installation (default=`true`) 
    - `compress` if the FMU archive should be compressed to save disk space. On the other hand, this may enlarge loading time (default=`false`) 
    - `cleanup` if the unzipped FMU archive should be deleted after creation (default=`true`) 
    - `modelExchange` if the FMU should support ME (model exchange) (default=`true`) 
    - `coSimulation` *currently not supported* if the FMU should support CS (co simulation) (default=`false`) 
    - `removeLibDependency` removes the FMIBuild.jl-dependency, so it will not be part of the resulting FMU (default=`true`) 
    - `removeNoExportBlocks` removes the blocks marked with `### FMIBUILD_NO_EXPORT_BEGIN ###` and `### FMIBUILD_NO_EXPORT_END ###` from the `fmu_src_file`, so it will not be part of the resulting FMU (default=`true`) 
"""
function fmi2Save(fmu::FMU2, fmu_path::String, fmu_src_file::Union{Nothing, String}=nothing; 
    standalone=true, 
    compress=false, 
    cleanup=true, 
    modelExchange=true,
    coSimulation=false,
    removeLibDependency=true,
    removeNoExportBlocks=true,
    resources::Union{Dict{String, String}, Nothing}=nothing,
    pkg_comp_kwargs...)

    # @assert fmi2Check(fmu) == true ["fmiBuild(...): FMU-Pre-Check failed. See messages above for further information."]

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

    if modelExchange && coSimulation
        #pkg_dir = joinpath(pkg_dir, "ME_CS")
        @assert false ["fmiBuild(...): `modelExchange` and `coSimulation` is under development."]
    elseif modelExchange
        pkg_dir = joinpath(pkg_dir, "ME")

        if fmu.modelDescription.modelExchange == nothing
            fmu.modelDescription.modelExchange = fmi2ModelDescriptionModelExchange()
        end 
        fmu.modelDescription.modelExchange.modelIdentifier = fmu_name

    elseif coSimulation
        #pkg_dir = joinpath(pkg_dir, "CS")
        @assert false ["fmiBuild(...): `coSimulation` only is under development."]
    else
        @assert false ["fmiBuild(...): At least one of `modelExchange` or `coSimulation` must be supported."]
    end 

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
    libext = ""

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

    @assert length(libext) > 0 "fmiBuild(...): Unsupported target platform. Supporting Windows (64-, 32-bit), Linux (64-bit) and MacOS (64-bit). Please open an issue online if you need further architectures."

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
    @assert length(source_pkf_dir) > 0 ["fmiBuild(...): Connot find a package where this file is stored in. For FMU-Export, this source file needs to be inside of a package."]
    merge_dir = joinpath(target_dir, "merged_" * fmu_name)
    cp(source_pkf_dir, merge_dir; force=true)
    chmod(target_dir, 0o777; recursive=true)
    @info "[Build FMU] Source package is $(source_pkf_dir), deployed at $(merge_dir)"
    @info "[Build FMU] Relative src file path is $(fmu_src_in_merge_dir)"

    fmu_res = "$(@__DIR__)/../template/ME/FMU2/src/FMU2_content.jl"

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
    preCompState = 1
    try 
        preCompState = ENV["JULIA_PKG_PRECOMPILE_AUTO"]
    catch e 
        preCompState = 1
    end
    ENV["JULIA_PKG_PRECOMPILE_AUTO"] = 0

    Pkg.activate(merge_dir)
    Pkg.add("FMICore") 
    #Pkg.add(name="FMICore", version="0.7.1")
    @info "[Build FMU]    > Added FMICore"
    if removeLibDependency
        cdata = replace(cdata, r"(using|import) FMIBuild" => "")
        try
            Pkg.rm("FMIBuild")
            @info "[Build FMU]    > Removed FMIBuild"
        catch e
            @info "[Build FMU]    > Not used FMIBuild"
        end
    end

    Pkg.activate(currentEnv)
    #Pkg.resolve()
    ENV["JULIA_PKG_PRECOMPILE_AUTO"]=preCompState
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
    
    @info "[Build FMU] Building model description ..."
    #buildModelDescription(md_path, fmu_name, fmu_src_file)
    fmi2SaveModelDescription(fmu.modelDescription, md_path)
    @info "[Build FMU] ... building model description done."

    @info "[Build FMU] Zipping FMU ..."
    # parse and zip directories
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
        # Clean-up is done by saving in a temporary directory (which may be deleted by the OS) 
        @info "[Build FMU] ... clean up done."
    end 

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
# src: https://github.com/JuliaLang/PackageCompiler.jl/issues/658
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
            end
        end
    
        @info("Filtered libpath", libpath)
    
        # Write filtered libpath out to the file, terminate with NULL.
        seek(io, libpath_offset)
        write(io, join(libpath, ":"))
        write(io, UInt8(0))
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
    link!(doc_root, AttributeNode("generationTool", "FMIExport.jl (0.1.0) / FMIBuild.jl (0.1.0) by Tobias Thummerer, Lars Mikelsons"))
    if md.generationDateAndTime != nothing
        dateTimeString = ""
        if typeof(md.generationDateAndTime) == Dates.DateTime
            dateTimeString = Dates.format(md.generationDateAndTime, "yyyy-mm-dd") * "T" * Dates.format(md.generationDateAndTime, "HH:MM:SS") * "Z" 
        elseif typeof(md.generationDateAndTime) == String
            dateTimeString = md.generationDateAndTime
        else 
            @warn "fmi2SaveModelDescription(...): Unkown data type for field `generationDateAndTime`. Supported is `DateTime` and `String`, but given `$(md.generationDateAndTime)` (typeof `$(typeof(md.generationDateAndTime))`)."
        end
        link!(doc_root, AttributeNode("generationDateAndTime", dateTimeString))
    end
    if md.variableNamingConvention != nothing
        link!(doc_root, AttributeNode("variableNamingConvention", (md.variableNamingConvention == fmi2VariableNamingConventionStructured ? "structured" : "flat")))
    end
    if md.numberOfEventIndicators != nothing
        link!(doc_root, AttributeNode("numberOfEventIndicators", "$(md.numberOfEventIndicators)"))
    end

    if md.modelExchange != nothing
        me = ElementNode("ModelExchange")
        link!(doc_root, me)

        # mandatory
        link!(me, AttributeNode("modelIdentifier", md.modelExchange.modelIdentifier))

        # optional
        if md.modelExchange.canGetAndSetFMUstate != nothing
            link!(me, AttributeNode("canGetAndSetFMUstate", (md.modelExchange.canGetAndSetFMUstate ? "true" : "false"))) 
        end
        if md.modelExchange.canSerializeFMUstate != nothing
            link!(me, AttributeNode("canSerializeFMUstate", (md.modelExchange.canSerializeFMUstate ? "true" : "false"))) 
        end
        if md.modelExchange.providesDirectionalDerivative != nothing
            link!(me, AttributeNode("providesDirectionalDerivative", (md.modelExchange.providesDirectionalDerivative ? "true" : "false"))) 
        end
    end

    mv = ElementNode("ModelVariables")
    link!(doc_root, mv)
    for i in 1:length(md.modelVariables)
        link!(mv, CommentNode("Index=$(i)"))

        sv = md.modelVariables[i]
        sv_node = ElementNode("ScalarVariable")
        link!(mv, sv_node)

        # mandatory
        link!(sv_node, AttributeNode("name", sv.name))
        link!(sv_node, AttributeNode("valueReference", "$(sv.valueReference)"))

        # optional
        if sv.description != nothing
            link!(sv_node, AttributeNode("description", sv.description))
        end
        if sv.causality != nothing
            link!(sv_node, AttributeNode("causality", fmi2CausalityToString(sv.causality)))
        end
        if sv.variability != nothing
            link!(sv_node, AttributeNode("variability", fmi2VariabilityToString(sv.variability)))
        end
        if sv.initial != nothing
            link!(sv_node, AttributeNode("initial", fmi2InitialToString(sv.initial)))
        end
        if sv.canHandleMultipleSetPerTimeInstant != nothing
            link!(sv_node, AttributeNode("canHandleMultipleSetPerTimeInstant", (sv.canHandleMultipleSetPerTimeInstant ? "true" : "false")))
        end

        # Real
        if sv._Real != nothing
            r_node = ElementNode("Real")

            if sv._Real.start != nothing 
                link!(r_node, AttributeNode("start", "$sv._Real.start)"))
            end
            if sv._Real.derivative != nothing 
                link!(r_node, AttributeNode("derivative", "$(sv._Real.derivative)"))
            end

            # ToDo: Implement remaining attributes 

            link!(sv_node, r_node)
        end

        # Integer
        if sv._Integer != nothing
            i_node = ElementNode("Integer")

            if sv._Integer.start != nothing 
                link!(i_node, AttributeNode("start", "$sv._Integer.start)"))
            end

            # ToDo: Implement remaining attributes 

            link!(sv_node, i_node)
        end

        # Boolean
        if sv._Boolean != nothing
            b_node = ElementNode("Boolean")

            if sv._Boolean.start != nothing 
                link!(b_node, AttributeNode("start", "$sv._Boolean.start)"))
            end

            # ToDo: Implement remaining attributes 

            link!(sv_node, b_node)
        end

        # String
        if sv._String != nothing
            s_node = ElementNode("String")

            if sv._String.start != nothing 
                link!(s_node, AttributeNode("start", "$sv._String.start)"))
            end

            # ToDo: Implement remaining attributes 

            link!(sv_node, s_node)
        end

        # _Enumeration
        if sv._Enumeration != nothing
            e_node = ElementNode("Enumeration")

            # if sv._Enumeration.start != nothing 
            #     link!(e_node, AttributeNode("start", "$sv._Enumeration.start)"))
            # end

            # ToDo: Implement remaining attributes 

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
            link!(outs, uk_node)
            link!(uk_node, AttributeNode("index", "$(uk.index)"))
            if uk.dependencies != nothing
                link!(uk_node, AttributeNode("dependencies", ""))
                # ToDo: Actually save them!
            end
            if uk.dependenciesKind != nothing
                link!(uk_node, AttributeNode("dependenciesKind", ""))
                # ToDo: Actually save them!
            end
        end
    end

    if md.modelStructure.derivatives != nothing
        ders = ElementNode("Derivatives")
        link!(ms, ders)

        for i in 1:length(md.modelStructure.derivatives)
            uk = md.modelStructure.derivatives[i]

            uk_node = ElementNode("Unknown")
            link!(ders, uk_node)
            link!(uk_node, AttributeNode("index", "$(uk.index)"))
            if uk.dependencies != nothing
                link!(uk_node, AttributeNode("dependencies", ""))
                # ToDo: Actually save them!
            end
            if uk.dependenciesKind != nothing
                link!(uk_node, AttributeNode("dependenciesKind", ""))
                # ToDo: Actually save them!
            end
        end
    end

    if md.modelStructure.initialUnknowns != nothing
        inis = ElementNode("InitialUnknowns")
        link!(ms, inis)

        for i in 1:length(md.modelStructure.initialUnknowns)
            uk = md.modelStructure.initialUnknowns[i]

            uk_node = ElementNode("Unknown")
            link!(inis, uk_node)
            link!(uk_node, AttributeNode("index", "$(uk.index)"))
            if uk.dependencies != nothing
                link!(uk_node, AttributeNode("dependencies", ""))
                # ToDo: Actually save them!
            end
            if uk.dependenciesKind != nothing
                link!(uk_node, AttributeNode("dependenciesKind", ""))
                # ToDo: Actually save them!
            end
        end
    end
    
    # save modelDescription (with linebreaks)
    f = open(file_path, "w")
    prettyprint(f, doc)
    close(f)
end

end # module
