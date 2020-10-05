using ModelObjectsLH
using Test

include("test_model.jl");

@testset "All" begin
    include("single_id_test.jl");
    include("object_id_test.jl");
    include("m_objects_test.jl");
end

# ----------
