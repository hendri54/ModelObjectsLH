module ModelObjectsLH

using DocStringExtensions

export SingleId, has_index, make_string, make_single_id
export ObjectId, make_object_id, make_child_id, own_name, n_parents, description
export ModelSwitches
export ModelObject, is_model_object, get_object_id, 
    collect_model_objects, collect_model_objects_for_any, collect_object_ids, get_child_objects, find_object, find_only_object, get_value
export object_structure, show_object_structure

const ObjIdSeparator = " > ";

"""
    ModelObject

Abstract model object
Must have field `objId :: ObjectId` that uniquely identifies it
May contain a ParamVector, but need not.

Child objects may be vectors. Then the vector must have a fixed element type that is
a subtype of `ModelObject`
"""
abstract type ModelObject end

"""
	$(SIGNATURES)

Switches from which `ModelObject` is constructed.
"""
abstract type ModelSwitches end


include("single_id.jl");
include("object_id.jl");
# include("model_switches.jl");
include("m_objects.jl");

end # module
