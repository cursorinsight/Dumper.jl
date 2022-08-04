###-----------------------------------------------------------------------------
### Copyright (C) Dumper.jl
###
### SPDX-License-Identifier: MIT License
###-----------------------------------------------------------------------------

module Utilities

###=============================================================================
### Imports
###=============================================================================

using Dates: now, format

###=============================================================================
### Functions
###=============================================================================

function dump_directory(path::AbstractString = "")::String
    date::String = format(now(), "YYYYmmdd-HHMMSS")
    return joinpath(path, "dump-$date")
end

const CompileTime{T} = Union{Expr, T}

end # module
