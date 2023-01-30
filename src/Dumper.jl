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

# TODO maybe use some timestamped folder by default
@kwdef mutable struct State
    enabled::Bool = false
    isabsolute::Bool = false
    mime::MIME = MIME("text/plain")
    directory::String = get(ENV, "DUMP", dump_directory("."))
    mode::String = "w"
end

const _STATE = State()

# This is only for the dynamic macro expression
STATE() = _STATE

###-----------------------------------------------------------------------------
### Management API
###-----------------------------------------------------------------------------

"""
    enable!()::Nothing

Enable dump functionality.

If `enable!` has already been called previously, use the same directory as
before. If it is called for the first time, save the dump files into the
directory pointed to by the `DUMP` environment variable, or lacking that, into a
directory named `dump-YYYYmmdd-HHMMSS`, using the current date and time.
"""
function enable!()::Nothing
    _STATE.enabled = true
    mkpath(_STATE.directory)
    return nothing
end

"""
    enable!(directory::AbstractString)::Nothing

Enable dump functionality.

The dump files will be saved in the given `directory`.
"""
function enable!(directory::AbstractString)::Nothing
    _STATE.directory = directory
    mkpath(_STATE.directory)
    enable!()
    return nothing
end

"""
    disable!()::Nothing

Disable dump functionality (i.e. saving the values of variables in files).
"""
function disable!()::Nothing
    _STATE.enabled = false
    return nothing
end

###-----------------------------------------------------------------------------
### Dump
###-----------------------------------------------------------------------------

"""
    @dump variable arguments...

Dump the value of a variable in a file if dump functionality is enabled.

Possible arguments are:
  - `isabsolute`:   `true` if the path is absolute (default: `false`)
  - `path`:         name of the dump file (default: name of the variable)
  - `directory`:    save directory (default: enabled directory)
  - `mime`:         output format (default: `MIME("text/plain")`)
  - `mode`:         writing mode of the dump file (default: `"w"`)

# Examples
```jldoctest
julia> x = 2
julia> @dump x
julia> @dump x path="two.txt"
```
"""
macro dump(variable::Symbol, arguments...)
    arguments::Dict = map(arguments) do argument
        if @capture(argument, key_ = value_)
            return key => value
        else
            error("Invalid argument")
        end
    end |> Dict

    isabsolute::CompileTime{Bool} =
        get(arguments, :isabsolute, :($STATE().isabsolute))
    path::CompileTime{String} =
        get(arguments, :path, string(variable))
    directory::CompileTime{String} =
        get(arguments, :directory, :($STATE().directory))
    mime::CompileTime{Union{MIME, String}} =
        get(arguments, :mime, :($STATE().mime))
    mode::CompileTime{String} =
        get(arguments, :mode, :($STATE().mode))

    return quote
        if $STATE().enabled
            let _path = $isabsolute ? $path : joinpath($directory, $path)
                $save(_path, MIME($mime), $variable; $mode)
            end
        end
    end |> esc
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
