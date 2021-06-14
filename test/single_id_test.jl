using ModelObjectsLH, Test

mo = ModelObjectsLH;

function single_id_test()
    @testset "SingleId" begin
        id1 = SingleId(:id1, [1, 2])
        println(id1);
        @test mo.index(id1) == [1,2]
        @test has_index(id1)

        id11 = SingleId(:id1, [1, 2]);
        @test isequal(id1, id11)

        id2 = SingleId(:id2, 3)
        @test mo.index(id2) == [3]

        id3 = SingleId(:id3);
        @test isempty(mo.index(id3))
        @test !has_index(id3)
        @test isequal(id3, SingleId(:id3))

        @test isequal([id1, id2], [id1, id2])
        @test !isequal([id1, id1], [id2, id1])
        @test !isequal([id1, id2], [id1])

        id4 = SingleId(:id4);
        s4 = make_string(id4);
        @test isequal(s4, "id4")
        id4a = make_single_id(s4);
        @test isequal(id4, id4a)

        id5 = SingleId(:id5, [4, 2]);
        s5 = make_string(id5);
        id5a = make_single_id(s5);
        @test isequal(id5, id5a)

        id6 = SingleId(:id6, 4)
        s6 = make_string(id6);
        id6a = make_single_id(s6);
        @test isequal(id6, id6a)
    end
end

function dict_single_id_test()
    @testset "Dict Single Id" begin
        d = Dict{SingleId, Any}([SingleId(:id1) => 1, SingleId(:id2, 1) => 2]);
        for (id1, val) in d
            @test id1 isa SingleId;
            @test val isa Integer;
        end
    end
end

@testset "SingleId" begin
    single_id_test();
    dict_single_id_test();
end

# -------------