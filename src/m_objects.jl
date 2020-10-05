## -----------  Access

own_name(o :: ModelObject) = own_name(o.objId);


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
"""
function collect_model_objects(o :: ModelObject)
    outV = Vector{Any}();
    if is_model_object(o)
        push!(outV, o);
    end

    # Objects directly contained in `o`
    childObjV = get_child_objects(o);
    if !Base.isempty(childObjV)
        for i1 = 1 : length(childObjV)
            nestedObjV = collect_model_objects(childObjV[i1]);
            append!(outV, nestedObjV);
        end
    end
    return outV :: Vector
end

collect_model_objects(o) = Vector{Any}();


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
        if isa(obj, Vector)
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



"""
	$(SIGNATURES)

Find child object with a given `ObjectId`.
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