## -----------  Access

own_name(o :: ModelObject) = own_name(get_object_id(o));


"""
	$(SIGNATURES)

Is `o` a `ModelObject`?
This can be used to apply all of the code of this package to objects that are not sub-types of `ModelObject`. But this is not fully implemented.
"""
is_model_object(o :: ModelObject) = true;
is_model_object(o) = false;


"""
	$(SIGNATURES)

Retrieve an objects ObjectId. Return `nothing` if not found.
"""
get_object_id(o :: ModelObject) = o.objId :: ObjectId
get_object_id(o) = nothing;



## ------------  Collect objects inside a ModelObject


"""
	$(SIGNATURES)

Collect all ObjectId's from an object as a `Vector{ObjectId}`.
"""
collect_object_ids(o :: ModelObject) = 
    get_object_id.(collect_model_objects(o));


"""
    $(SIGNATURES)

Collect all model objects inside an object, including the object itself. 
Only those that satisfy `is_model_object`.
Recursive. Also collects objects inside child objects and so on.
Returns empty `Vector` if no objects found.

# Arguments
- flatten: If `true`, return a single `Vector` with all objects. If `false`, return a nested `Vector`.

# Example
```julia
struct O1
    c1
    c2
end
v = collect_model_objects(o; flatten = true);
v == [o, o.c1, o.c1.c1, o.c2, o.c2.c1, o.c2.c2];
# Each element contains an objects and all its children (and their children).
v = collect_model_objects(o; flatten = false);
v[1] == o;
v[2] == [o.c1, o.c1.c1]
v[3] == [o.c2, o.c2.c1, o.c2.c2]
```
"""
function collect_model_objects(o :: ModelObject; flatten :: Bool = true)
    outV = Vector{Any}();
    if is_model_object(o)
        push!(outV, o);
    end

    # Objects directly contained in `o`
    childObjV = get_child_objects(o);
    if !Base.isempty(childObjV)
        for i1 = 1 : length(childObjV)
            nestedObjV = collect_model_objects(childObjV[i1]);
            if flatten
                append!(outV, nestedObjV);
            else
                push!(outV, nestedObjV);
            end
        end
    end
    return outV :: Vector
end

collect_model_objects(o; flatten :: Bool = true) = Vector{Any}();


"""
    $(SIGNATURES)

Find the child objects inside a model object.
Returns empty Vector if no objects found.
"""
function get_child_objects(o :: ModelObject)
    childV = Vector{Any}();
    for pn in propertynames(o)
        @assert isdefined(o, pn)  "$pn undefined in $o"
        obj = getproperty(o, pn);
        if isa(obj, Vector)  &&  !isempty(obj)
            # This check is not quite right. But objects should all be the same type.
            if is_model_object(obj[1])
                append!(childV, obj);
            end
        else
            if is_model_object(obj)
                push!(childV, obj);
            end
        end
    end
    return childV :: Vector
end

get_child_objects(o) = Vector{Any}();


# """
# 	$(SIGNATURES)

# Model objects as nested Vector.
# """
# function model_object_dict(o :: ModelObject)
#     # Objects directly contained in `o`
#     childObjV = get_child_objects(o);
#     if !Base.isempty(childObjV)
#         for i1 = 1 : length(childObjV)
#             nestedObjV = model_object_dict(childObjV[i1]);
#             push! = nestedObjV;
#         end
#     end
#     return d
# end

# model_object_dict(o) = Dict{Any, Any}




"""
	$(SIGNATURES)

Find child object with a given `ObjectId`. Expects that all ModelObjects have ObjectIds.
Returns `nothing` if not found.
"""
function find_object(o :: ModelObject, id :: ObjectId)
    oOut = nothing;
    objV = collect_model_objects(o);
    if !isempty(objV)
        for obj in objV
            if isequal(get_object_id(obj), id)
                oOut = obj;
                break;
            end
        end
    end
    return oOut
end

# find_object(o :: ModelObject, name :: Symbol) = find_object(o)

find_object(o, id) = nothing;


"""
	$(SIGNATURES)

Find all child objects that have a name given by a `Symbol`. Easier than having to specify an entire `ObjectId`.
"""
function find_object(o :: ModelObject, oName :: Symbol)
    outV = Vector{Any}();
    objV = collect_model_objects(o);
    if !isempty(objV)
        for obj in objV
            if own_name(obj) == oName
                push!(outV, obj);
            end
        end
    end
    return outV
end

find_object(o, oName :: Symbol) = Vector{Any}();

"""
	$(SIGNATURES)

Find the only object that matches the name `oName`. Errors if not found.
"""
function find_only_object(o :: ModelObject, oName :: Symbol)
    return only(find_object(o, oName));
end

find_only_object(o, oName :: Symbol) = nothing;


"""
	$(SIGNATURES)

Retrieve the value of a field in a `ModelObject` or its children.
Object name `oName` must be unique. This is the name in the `ObjectId`, not what the object is called as a field in the model object.
"""
function get_value(x :: ModelObject, oName :: Symbol, pName :: Symbol)
    objV = find_object(x, oName);
    @assert length(objV) == 1  "Found $(length(objV)) matches for $oName / $pName"
    return getfield(objV[1], pName)
end


## -----------  Show

"""
	$(SIGNATURES)

Show structure of a `ModelObject`.
"""
function Base.show(io :: IO,  o :: ModelObject)
    show_object_structure(o; io = io);
end


"""
	$(SIGNATURES)

Show the "tree" structure of a ModelObject. Returns a Vector of formatted strings that show objects, children, grandchildren with their types.
"""
function show_object_structure(o; io :: IO = stdout)
    idV, typeV = object_structure(o);
    if !isempty(idV)
        for j = 1 : length(idV)
            println(io,  indent_string(n_parents(idV[j])),  own_name(idV[j]),  
                "\t",  typeV[j]);
        end
    end
    return nothing
end

indent_string(n) = "   " ^ n;


"""
	$(SIGNATURES)

Represent the "tree" structure of a ModelObject.

Returns ObjectIds and DataTypes.
"""
function object_structure(o)
    objV = collect_model_objects(o);
    idV = Vector{ObjectId}();
    typeV = Vector{DataType}();
    if !isempty(objV)
        for obj in objV
            # (id = objId, nparents = n_parents(objId))
            push!(idV, get_object_id(obj))
            push!(typeV, typeof(obj));
        end
    end
    return idV, typeV
end




# -------------