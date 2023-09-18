###-----------------------------------------------------------------------------
### Copyright (C) Dumper.jl
###
### SPDX-License-Identifier: MIT License
###-----------------------------------------------------------------------------

module Dumper

###=============================================================================
### Exports
###=============================================================================

export enable!, disable!, @dump

###=============================================================================
### Imports
###=============================================================================

include("Utilities.jl")

using Base: @kwdef
using MacroTools: @capture
using .Utilities: dump_directory, CompileTime

###=============================================================================
### Implementation
###=============================================================================

###-----------------------------------------------------------------------------
### State
###-----------------------------------------------------------------------------

@kwdef mutable struct State
    directory::String = ""
    enabled::Bool = false
    isabsolute::Bool = false
    mime::String = "text/plain"
    mode::String = "w"
end

const STATE = State()

function __init__()
    STATE.directory = get(ENV, "DUMP", dump_directory(pwd()))
end

###-----------------------------------------------------------------------------
### Management API
###-----------------------------------------------------------------------------

"""
    enable!([directory::String]; kwargs...)

Enable dump functionality.

The directory in which the files are dumped is the first valid of the following:

1.  whatever is passed in the argument;

2.  what was used when `enable!` was called previously;

3.  what the `DUMP` environment variable points to;

4.  a new directory named `dump-YYYYmmdd-HHMMSS`, using current date and time.

All other parameters in the global state are preserved, unless specified in a
keyword argument.
"""
function enable!(directory::String; kwargs...)::Nothing
    enable!(; kwargs..., directory)
    return nothing
end

function enable!(; kwargs...)::Nothing
    for (k, v) in kwargs
        (k ∈ fieldnames(State) && k != :enabled) ||
            error("Unexpected keyword argument $(k)!")
        setfield!(STATE, k, v)
    end
    mkpath(STATE.directory)
    STATE.enabled = true
    return nothing
end

"""
    disable!()

Disable dump functionality (i.e. saving the values of variables in files).
"""
function disable!()::Nothing
    STATE.enabled = false
    return nothing
end

###-----------------------------------------------------------------------------
### Dump
###-----------------------------------------------------------------------------

"""
    @dump variable arguments...

Dump the value of a variable in a file if dump functionality is enabled.

Possible arguments are (defaults come from `Dumper.STATE`):
  - `isabsolute`: whether the path is absolute or relative to `directory`;
  - `path`:       name of the dump file (default: name of the variable);
  - `directory`:  save directory;
  - `mime`:       output format (MIME string);
  - `mode`:       writing mode of the dump file.

# Examples
```jldoctest
julia> x = 2
julia> @dump x
julia> @dump x path="two.txt"
```
"""
macro dump(variable::Symbol, arguments...)
    arguments::Dict{Symbol, Any} = map(arguments) do argument
        if @capture(argument, key_ = value_)
            return key => esc(value)
        else
            error("Invalid argument")
        end
    end |> Dict{Symbol, Any}

    getarg(prop) = get(arguments, prop, :(getfield(STATE, $(QuoteNode(prop)))))

    isabsolute::CompileTime{Bool}  = getarg(:isabsolute)
    directory::CompileTime{String} = getarg(:directory)
    mime::CompileTime{String}      = getarg(:mime)
    mode::CompileTime{String}      = getarg(:mode)
    path::CompileTime{String}      = get(arguments, :path, string(variable))

    return quote
        if STATE.enabled
            let path = $isabsolute ? $path : joinpath($directory, $path)
                save(path, MIME($mime), $(esc(variable)); mode = $mode)
            end
        end
    end
end

###-----------------------------------------------------------------------------
### File API
###-----------------------------------------------------------------------------

function save(io::IO, obj)::Nothing
    save(io, MIME("text/plain"), obj)
    return nothing
end

function save(io::IO, mime::MIME, obj)::Nothing
    show(io, mime, obj)
    return nothing
end

function save(path::AbstractString, obj; mode = "w")::Nothing
    open(path, mode) do io
        save(io, obj)
    end
    return nothing
end

function save(path::AbstractString, mime::MIME, obj; mode = "w")::Nothing
    open(path, mode) do io
        save(io, mime, obj)
    end
    return nothing
end

end # module
