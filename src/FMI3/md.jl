#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# returns the field value, `nothing` if the field is not defined
definedField(_struct, field::Symbol) =
    (isdefined(_struct, field) ? getfield(_struct, field) : nothing)

# FMI 3 attributes that may be stored as `fmi3Boolean` (`UInt8`), but are written as `true`/`false`
const FMI3_BOOLEAN_FIELDS = (
    :canHandleMultipleSetPerTimeInstant,
    :intermediateUpdate,
    :relativeQuantity,
    :unbounded,
    :reinit,
    :canBeDeactivated,
    :supportsFraction,
)

function addFMI3FieldsAsAttributes(md::fmi3ModelDescription, node, _struct, skiplist = ())
    for field in fieldnames(typeof(_struct))
        if field ∈ skiplist
            continue
        end

        value = definedField(_struct, field)
        if isnothing(value)
            continue
        end

        name = "$(field)"

        # special formatters
        if isa(value, Bool) ||
           field ∈ FMI3_BOOLEAN_FIELDS ||
           (field == :start && isa(_struct, fmi3VariableBoolean))

            value = (iszero(value) ? "false" : "true")
        elseif field == :causality

            value = causalityToString(md, value)
        elseif field == :variability

            value = variabilityToString(md, value)
        elseif field == :initial

            value = initialToString(md, value)
        elseif field ∈ (:clocks, :dependencies)

            value = join(value, " ")
        elseif field == :dependenciesKind

            value = join((dependencyKindToString(md, kind) for kind in value), " ")
        elseif field == :index

            # [Note] `fmi3VariableDependency` stores the value reference in field `index`
            name = "valueReference"
        end

        link!(node, AttributeNode(name, "$(value)"))
    end
end

# fields of the model structure and their element names,
# [Note] element order is defined by the FMI 3 schema
const FMI3_MODEL_STRUCTURE_ELEMENTS = (
    (:outputs, "Output"),
    (:continuousStateDerivatives, "ContinuousStateDerivative"),
    (:clockedStates, "ClockedState"),
    (:initialUnknowns, "InitialUnknown"),
    (:eventIndicators, "EventIndicator"),
)

# element name of a type definition, e.g. `Float64Type` for `fmi3Float64Type`
typeDefinitionName(::fmi3FloatType{T}) where {T} = "$(nameof(T))Type"
typeDefinitionName(::fmi3IntegerType{T}) where {T} = "$(nameof(T))Type"
typeDefinitionName(st::fmi3SimpleType) = replace("$(nameof(typeof(st)))", "fmi3" => "")

# fields of a variable or type definition that reference undefined units or types,
# they are not exported, because they would be invalid (e.g. if the model description has no definitions),
# `units` maps the unit names to the names of their display units, `types` maps the type names to the types
function undefinedReferences(_struct, units::Dict, types::Dict)
    skiplist = Symbol[]

    declaredType = definedField(_struct, :declaredType)
    if !isnothing(declaredType) && !haskey(types, declaredType)
        push!(skiplist, :declaredType)
        declaredType = nothing
    end

    unit = definedField(_struct, :unit)
    if !isnothing(unit) && !haskey(units, unit)
        push!(skiplist, :unit)
        unit = nothing
    end

    # the display unit belongs to the unit, which may be defined by the declared type
    if isnothing(unit) && !isnothing(declaredType)
        unit = definedField(types[declaredType], :unit)
    end
    displayUnit = definedField(_struct, :displayUnit)
    if !isnothing(displayUnit) &&
       (isnothing(unit) || displayUnit ∉ get(units, unit, String[]))
        push!(skiplist, :displayUnit)
    end

    return skiplist
end

# FMI 3 `Enumeration` variables require a `declaredType`, so the ones without (exported) type definition
# are skipped (e.g. if the model description has no type definitions),
# this is only possible if they are not part of the FMU interface or model structure
function skippedEnumerations(md::fmi3ModelDescription, types::Dict)
    enumerations = filter(md.modelVariables) do sv
        isa(sv, fmi3VariableEnumeration) &&
            !haskey(types, something(definedField(sv, :declaredType), ""))
    end
    if length(enumerations) == 0
        return enumerations
    end

    for sv in enumerations
        if sv.causality ∈ (fmi3CausalityInput, fmi3CausalityOutput)
            error(
                "saveModelDescription(...): The FMI3 Enumeration variable `$(sv.name)` has no type definition, but is an $(causalityToString(md, sv.causality)).",
            )
        end
    end

    vrs = Set(sv.valueReference for sv in enumerations)
    for (field, _) in FMI3_MODEL_STRUCTURE_ELEMENTS
        unknowns = getfield(md.modelStructure, field)
        if isnothing(unknowns)
            continue
        end

        for uk in unknowns
            dependencies = definedField(uk, :dependencies)
            for vr in (uk.index, something(dependencies, ())...)
                if vr ∈ vrs
                    error(
                        "saveModelDescription(...): The FMI3 Enumeration variable with value reference $(vr) has no type definition, but is part of the model structure.",
                    )
                end
            end
        end
    end

    @warn "saveModelDescription(...): FMI3 Enumeration variables require a type definition, skipping $(length(enumerations)) variable(s) without: $(join(("`$(sv.name)`" for sv in enumerations), ", "))."
    return enumerations
end

function saveUnitDefinitions(md::fmi3ModelDescription, doc_root, units)
    ud = ElementNode("UnitDefinitions")
    link!(doc_root, ud)

    for unit in units
        u_node = ElementNode("Unit")
        link!(ud, u_node)
        addFMI3FieldsAsAttributes(md, u_node, unit, (:baseUnit, :displayUnits))

        if !isnothing(unit.baseUnit)
            b_node = ElementNode("BaseUnit")
            link!(u_node, b_node)
            addFMI3FieldsAsAttributes(md, b_node, unit.baseUnit)
        end

        for displayUnit in unit.displayUnits
            d_node = ElementNode("DisplayUnit")
            link!(u_node, d_node)
            addFMI3FieldsAsAttributes(md, d_node, displayUnit)
        end
    end
end

function saveTypeDefinitions(md::fmi3ModelDescription, doc_root, types, skiplist)
    td = ElementNode("TypeDefinitions")
    link!(doc_root, td)

    for st in types
        st_node = ElementNode(typeDefinitionName(st))
        link!(td, st_node)
        addFMI3FieldsAsAttributes(md, st_node, st, [:items, skiplist(st)...])

        if isa(st, fmi3EnumerationType)
            for item in st.items
                i_node = ElementNode("Item")
                link!(st_node, i_node)
                addFMI3FieldsAsAttributes(md, i_node, item)
            end
        end
    end
end

function saveModelDescription(md::fmi3ModelDescription, file_path::String)
    doc = XMLDocument()

    doc_root = ElementNode("fmiModelDescription")
    setroot!(doc, doc_root)
    link!(doc_root, AttributeNode("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"))

    # mandatory
    link!(doc_root, AttributeNode("fmiVersion", "3.0"))
    link!(doc_root, AttributeNode("modelName", md.modelName))
    link!(doc_root, AttributeNode("instantiationToken", md.instantiationToken))

    # optional
    for field in (:description, :author, :version, :copyright, :license)
        value = definedField(md, field)
        if !isnothing(value)
            link!(doc_root, AttributeNode("$(field)", value))
        end
    end
    link!(
        doc_root,
        AttributeNode(
            "generationTool",
            "FMIExport.jl (https://github.com/ThummeTo/FMIExport.jl) by Tobias Thummerer, Lars Mikelsons",
        ),
    )
    generationDateAndTime = definedField(md, :generationDateAndTime)
    if !isnothing(generationDateAndTime)
        link!(
            doc_root,
            AttributeNode("generationDateAndTime", dateTimeString(generationDateAndTime)),
        )
    end
    if !isnothing(md.variableNamingConvention)
        link!(
            doc_root,
            AttributeNode(
                "variableNamingConvention",
                variableNamingConventionToString(md, md.variableNamingConvention),
            ),
        )
    end

    if !isnothing(md.modelExchange)
        me = ElementNode("ModelExchange")
        link!(doc_root, me)
        addFMI3FieldsAsAttributes(md, me, md.modelExchange)
    end

    if !isnothing(md.coSimulation)
        cs = ElementNode("CoSimulation")
        link!(doc_root, cs)
        # [Note] `needsCompletedIntegratorStep` is ME only, `canInterpolateInputs` is FMI 2 only
        addFMI3FieldsAsAttributes(
            md,
            cs,
            md.coSimulation,
            (:needsCompletedIntegratorStep, :canInterpolateInputs),
        )
    end

    unitDefinitions = something(definedField(md, :unitDefinitions), fmi3Unit[])
    typeDefinitions = something(definedField(md, :typeDefinitions), fmi3SimpleType[])
    units = Dict(
        unit.name => [displayUnit.name for displayUnit in unit.displayUnits] for
        unit in unitDefinitions
    )
    types = Dict(st.name => st for st in typeDefinitions)

    # references to undefined units or types are skipped (with a warning)
    undefined = Set{String}()
    skiplist = function (_struct)
        fields = undefinedReferences(_struct, units, types)
        for field in fields
            push!(undefined, getfield(_struct, field))
        end
        return fields
    end

    if length(unitDefinitions) > 0
        saveUnitDefinitions(md, doc_root, unitDefinitions)
    end
    if length(typeDefinitions) > 0
        saveTypeDefinitions(md, doc_root, typeDefinitions, skiplist)
    end

    logCategories = definedField(md, :logCategories)
    if !isnothing(logCategories) && length(logCategories) > 0
        lc = ElementNode("LogCategories")
        link!(doc_root, lc)

        for category in logCategories
            c_node = ElementNode("Category")
            addFMI3FieldsAsAttributes(md, c_node, category)
            link!(lc, c_node)
        end
    end

    if !isnothing(md.defaultExperiment)
        de = ElementNode("DefaultExperiment")
        link!(doc_root, de)
        addFMI3FieldsAsAttributes(md, de, md.defaultExperiment)
    end

    skippedVariables = skippedEnumerations(md, types)

    mv = ElementNode("ModelVariables")
    link!(doc_root, mv)
    for sv in md.modelVariables
        if any(skipped -> skipped === sv, skippedVariables)
            continue
        end

        # element name is the data type, e.g. `fmi3VariableFloat64` -> `Float64`
        sv_node = ElementNode(replace("$(nameof(typeof(sv)))", "fmi3Variable" => ""))
        link!(mv, sv_node)

        fields = [:annotations, :dependencies, :dependenciesKind, skiplist(sv)...]
        # `canHandleMultipleSetPerTimeInstant` is only allowed for inputs
        if sv.causality != fmi3CausalityInput
            push!(fields, :canHandleMultipleSetPerTimeInstant)
        end
        # `initial` is not allowed for the independent variable (FMIImport sets a default)
        if sv.causality == fmi3CausalityIndependent
            push!(fields, :initial)
        end
        # String and Binary start values are child elements
        if isa(sv, fmi3VariableString) || isa(sv, fmi3VariableBinary)
            push!(fields, :start)
        end
        addFMI3FieldsAsAttributes(md, sv_node, sv, fields)

        if isa(sv, fmi3VariableString) && !isnothing(sv.start)
            s_node = ElementNode("Start")
            link!(s_node, AttributeNode("value", sv.start))
            link!(sv_node, s_node)
        elseif isa(sv, fmi3VariableBinary) && !isnothing(sv.start)
            @warn "saveModelDescription(...): Exporting start values of FMI3 Binary variables is not supported yet, skipping start value of `$(sv.name)`."
        end
    end

    if length(undefined) > 0
        @warn "saveModelDescription(...): Skipping references to undefined units or types: $(join(("`$(name)`" for name in sort(collect(undefined))), ", "))."
    end

    ms = ElementNode("ModelStructure")
    link!(doc_root, ms)

    for (field, name) in FMI3_MODEL_STRUCTURE_ELEMENTS
        unknowns = getfield(md.modelStructure, field)
        if isnothing(unknowns)
            continue
        end

        for uk in unknowns
            uk_node = ElementNode(name)
            addFMI3FieldsAsAttributes(md, uk_node, uk)
            link!(ms, uk_node)
        end
    end

    # save modelDescription (with linebreaks)
    f = open(file_path, "w")
    prettyprint(f, doc)
    close(f)
end
