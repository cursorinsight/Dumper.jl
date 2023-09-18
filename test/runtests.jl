###-----------------------------------------------------------------------------
### Copyright (C) Dumper.jl
###
### SPDX-License-Identifier: MIT License
###-----------------------------------------------------------------------------

###=============================================================================
### Imports
###=============================================================================

using Test

using Dumper: enable!, disable!, @dump

###=============================================================================
### Tests
###=============================================================================

@testset "Dump" begin
    x::Int = 1 + 1

    mktempdir() do directory
        enable!(directory)
        @test isdir(directory)

        @dump x
        @test isfile("$directory/x")
        @test readlines("$directory/x") == ["2"]

        @dump x path="two.txt"
        @test isfile("$directory/two.txt")
        @test readlines("$directory/two.txt") == ["2"]

        @dump x path="$x.txt"
        @test isfile("$directory/2.txt")
        @test readlines("$directory/2.txt") == ["2"]

        disable!()

        x += 1

        @dump x
        @test isfile("$directory/x")
        @test readlines("$directory/x") != ["3"]

        @dump x path="3.txt"
        @test !isfile("$directory/3.txt")

        enable!(directory = "$directory/sub")
        @test isdir("$directory/sub")

        @dump x
        @test isfile("$directory/sub/x")
        @test readlines("$directory/sub/x") == ["3"]

        @dump x path="three.txt"
        @test isfile("$directory/sub/three.txt")
        @test readlines("$directory/sub/three.txt") == ["3"]

        @dump x path="$x.txt"
        @test isfile("$directory/sub/3.txt")
        @test readlines("$directory/sub/3.txt") == ["3"]

        disable!()
    end
end

@testset "Dump - dynamically" begin
    x::Int = 1 + 1

    function dump()
        @dump x
    end

    mktempdir() do directory
        enable!(; directory, isabsolute = false)
        @test isdir(directory)

        dump()
        @test isfile("$directory/x")
        @test readlines("$directory/x") == ["2"]

        disable!()

        x += 1

        dump()
        @test isfile("$directory/x")
        @test readlines("$directory/x") != ["3"]

        enable!("$directory/sub"; mode = "w")
        @test isdir("$directory/sub")

        dump()
        @test isfile("$directory/sub/x")
        @test readlines("$directory/sub/x") == ["3"]

        disable!()
    end
end
