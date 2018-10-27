using Test
using DataStructures
include("../src/loadAnimations.jl")
include("../src/dinogame.jl")

function test_firstWord()
    @testset "testing firstWord" begin
        @test firstWord("abc") == "abc"
        @test firstWord("abcd") == "abcd"
        @test firstWord("abcd ") == "abcd"
        @test firstWord(" hei paa deg") == "hei"
        @test firstWord("")==""
        @test firstWord("   ")==""
    end
end

function test_wordsStartEnd()
    @testset "testing wordsStartEnd" begin
        @test wordsStartEnd("abc def ghi") == [("abc",1,3), ("def",5,7), ("ghi", 9,11)]
        @test wordsStartEnd(" hei jeg heter ") == [("hei",2,4), ("jeg",6,8), ("heter",10,14)]
        @test wordsStartEnd("") == Array{Tuple{String,Int64,Int64},1}()
        @test wordsStartEnd("     ")==Array{Tuple{String,Int64,Int64},1}()
    end
end

function test_makeXsections()
    @testset "testing makeXsections" begin
        @test makeXsections("abc", 1, 1) == [Xsection("abc", 1, 1)]
        @test makeXsections("abc", 2, 1) == [Xsection("abc",2, 1)]
        @test makeXsections("abc def", 1, 1) == [Xsection("abc"::String, 1::Int64, 1::Int64), Xsection("def"::String, 5::Int64, 1::Int64)]
    end
end

function test_makeFrame()
    @testset "testing makeFrame" begin
        @test (makeFrame(Dict("string"=>"o\n ||\n  hei hei"::String, "x"=> 1::Int64, "y"=> 6::Int64))== Frame([Xsection("o",1,6), Xsection("||",2,7), Xsection("hei",3,8), Xsection("hei"::String,7::Int64,8::Int64)]::Array{Xsection,1}))
    end
end

function test_pollKeyboard!()
    q = Queue{Char}()
    p = Queue{Char}()
    enqueue!(q,'a')
    @testset "testing pollKeyboard!" begin
        @test pollKeyboard!(q)==Event(KeyPressed::EventType, 'a')
        @test pollKeyboard!(q)==Event(Nothing::EventType, ' ')
    end
end

println("                Running tests                ")
println("=============================================")
@testset "Testing loadAnimations.jl" begin
    test_firstWord()
    test_wordsStartEnd()
    test_makeXsections()
    test_makeFrame()
end
@testset "Testing dinogame.jl" begin
    test_pollKeyboard!()
end
