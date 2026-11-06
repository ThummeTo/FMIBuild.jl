#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# FMI 2 attributes that may be stored as `fmi2Boolean` (`Cint`), but are written as `true`/`false`
const FMI2_BOOLEAN_FIELDS = (:canHandleMultipleSetPerTimeInstant,)

function addFieldsAsAttributes(md, node, _struct, skiplist = ())
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
            if isa(value, Bool) ||
               field ∈ FMI2_BOOLEAN_FIELDS ||
               (field == :start && isa(_struct, fmi2BooleanAttributesExt))

                value = (iszero(value) ? "false" : "true")
            elseif field == :causality

                value = causalityToString(md, value)
            elseif field == :variability

                value = variabilityToString(md, value)
            elseif field == :initial

                value = initialToString(md, value)
            elseif field == :dependencies

                # [Note] an empty list is written as `dependencies=""` (depends on no known),
                #        omitting the attribute would mean "depends on all knowns"
                value = join(value, " ")
            elseif field == :dependenciesKind

                value = join((dependencyKindToString(md, kind) for kind in value), " ")
            end

            link!(node, AttributeNode("$(field)", "$(value)"))
        end
    end
end

function saveModelDescription(md::fmi2ModelDescription, file_path::String)
    doc = XMLDocument()

    doc_root = ElementNode("fmiModelDescription")
    setroot!(doc, doc_root)
    link!(doc_root, AttributeNode("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"))

    # mandatory
    link!(doc_root, AttributeNode("fmiVersion", "2.0"))
    link!(doc_root, AttributeNode("modelName", md.modelName))
    link!(doc_root, AttributeNode("guid", "$(md.guid)"))

    # optional
    link!(
        doc_root,
        AttributeNode(
            "generationTool",
            "FMIExport.jl (https://github.com/ThummeTo/FMIExport.jl) by Tobias Thummerer, Lars Mikelsons",
        ),
    )
    if md.generationDateAndTime != nothing
        link!(
            doc_root,
            AttributeNode(
                "generationDateAndTime",
                dateTimeString(md.generationDateAndTime),
            ),
        )
    end
    if !isnothing(md.variableNamingConvention)
        link!(
            doc_root,
            AttributeNode(
                "variableNamingConvention",
                (
                    md.variableNamingConvention == fmi2VariableNamingConventionStructured ?
                    "structured" : "flat"
                ),
            ),
        )
    end
    if !isnothing(md.numberOfEventIndicators)
        link!(
            doc_root,
            AttributeNode("numberOfEventIndicators", "$(md.numberOfEventIndicators)"),
        )
    end

    if !isnothing(md.modelExchange)
        me = ElementNode("ModelExchange")
        link!(doc_root, me)
        addFieldsAsAttributes(md, me, md.modelExchange)
    end

    if !isnothing(md.coSimulation)
        cs = ElementNode("CoSimulation")
        link!(doc_root, cs)
        addFieldsAsAttributes(md, cs, md.coSimulation)
    end

    if !isnothing(md.typeDefinitions)
        td = ElementNode("TypeDefinitions")
        link!(doc_root, td)

        for typdef in md.typeDefinitions
            st = ElementNode("SimpleType")
            link!(td, st)

            addFieldsAsAttributes(md, st, typdef, (:attribute,))

            if isa(typdef.attribute, fmi2RealAttributes)
                tn = ElementNode("Real")
                addFieldsAsAttributes(md, tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2IntegerAttributes)
                tn = ElementNode("Integer")
                addFieldsAsAttributes(md, tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2BooleanAttributes)
                tn = ElementNode("Boolean")
                addFieldsAsAttributes(md, tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2StringAttributes)
                tn = ElementNode("String")
                addFieldsAsAttributes(md, tn, typdef.attribute)
                link!(st, tn)
            elseif isa(typdef.attribute, fmi2EnumerationAttributes)
                tn = ElementNode("Enumeration")
                addFieldsAsAttributes(md, tn, typdef.attribute, (:items,))
                link!(st, tn)

                for j = 1:length(typdef.attribute)
                    itemNode = ElementNode("Item")
                    addFieldsAsAttributes(md, itemNode, typdef.attribute[j])
                    link!(tn, itemNode)
                end
            else
                @warn "Unknown type for fmi2SimpleType."
            end

        end
    end

    mv = ElementNode("ModelVariables")
    link!(doc_root, mv)
    for i = 1:length(md.modelVariables)
        link!(mv, CommentNode("Index=$(i)"))

        sv = md.modelVariables[i]
        sv_node = ElementNode("ScalarVariable")
        link!(mv, sv_node)

        addFieldsAsAttributes(md, sv_node, sv, (:attribute,))

        # Real
        if sv.Real != nothing
            r_node = ElementNode("Real")
            addFieldsAsAttributes(md, r_node, sv.Real, (:attributes,))
            addFieldsAsAttributes(md, r_node, sv.attribute.attributes)
            link!(sv_node, r_node)
        end

        # Integer
        if sv.Integer != nothing
            i_node = ElementNode("Integer")
            addFieldsAsAttributes(md, i_node, sv.Integer, (:attributes,))
            addFieldsAsAttributes(md, i_node, sv.attribute.attributes)
            link!(sv_node, i_node)
        end

        # Boolean
        if sv.Boolean != nothing
            b_node = ElementNode("Boolean")
            addFieldsAsAttributes(md, b_node, sv.Boolean)
            link!(sv_node, b_node)
        end

        # String
        if sv.String != nothing
            s_node = ElementNode("String")
            addFieldsAsAttributes(md, s_node, sv.String)
            link!(sv_node, s_node)
        end

        # Enumeration
        if sv.Enumeration != nothing
            e_node = ElementNode("Enumeration")
            addFieldsAsAttributes(md, e_node, sv.Enumeration)
            link!(sv_node, e_node)
        end
    end

    ms = ElementNode("ModelStructure")
    link!(doc_root, ms)

    if md.modelStructure.outputs != nothing
        outs = ElementNode("Outputs")
        link!(ms, outs)

        for i = 1:length(md.modelStructure.outputs)
            uk = md.modelStructure.outputs[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(md, uk_node, uk)
            link!(outs, uk_node)
        end
    end

    if md.modelStructure.derivatives != nothing
        ders = ElementNode("Derivatives")
        link!(ms, ders)

        for i = 1:length(md.modelStructure.derivatives)
            uk = md.modelStructure.derivatives[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(md, uk_node, uk)
            link!(ders, uk_node)
        end
    end

    if md.modelStructure.initialUnknowns != nothing
        inis = ElementNode("InitialUnknowns")
        link!(ms, inis)

        for i = 1:length(md.modelStructure.initialUnknowns)
            uk = md.modelStructure.initialUnknowns[i]

            uk_node = ElementNode("Unknown")
            addFieldsAsAttributes(md, uk_node, uk)
            link!(inis, uk_node)
        end
    end

    # save modelDescription (with linebreaks)
    f = open(file_path, "w")
    prettyprint(f, doc)
    close(f)
end
