# Dumper.jl

[![CI](https://github.com/cursorinsight/Dumper.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/cursorinsight/Dumper.jl/actions/workflows/CI.yml)

Dumper.jl is a Julia package that allows you to effortlessly save the values
of variables in files.

## Installation

Dumper.jl can be installed after adding Cursor Insight's [own registry][CIJR] to
the Julia environment:

```julia
julia> ]
pkg> registry add https://github.com/cursorinsight/julia-registry
     Cloning registry from "https://github.com/cursorinsight/julia-registry"
       Added registry `CursorInsightJuliaRegistry` to
       `~/.julia/registries/CursorInsightJuliaRegistry`

pkg> add Dumper
```

## Usage

Load the package via:

```julia
using Dumper
```

This exports two functions and a macro: `enable!`, `disable!` and `@dump`.

Enable dump capability with `enable!()`. Without parameters, this enables
dumping into the directory pointed to by the `DUMP` environment variable, or if
that is unset, then into a `dump-YYYYmmdd-HHMMSS` directory, using the current
date and time.

You can set the environment variable from Julia as follows:

```julia
ENV["DUMP"] = "./directory_to_dump"
```

You can also add this line to the user configuration file
`~/.julia/config/startup.jl` for a more permanent effect.

To turn off dump capability, simply call `disable!()`.

```julia
# Without parameters, dump files into the default directory explained before
enable!()

# You may pass the path of the dump directory, too
enable!("./dump")

# Disable dump functionality
disable!()
```

You can dump the value of a variable into a file with `@dump`. This saves the
file only when the dump capability is enabled (it's off by default).

Possible arguments are (defaults come from `Dumper.STATE`):
  - `isabsolute`: whether the path is absolute or relative to `directory`;
  - `path`:       name of the dump file (default: name of the variable);
  - `directory`:  save directory;
  - `mime`:       output format (MIME string);
  - `mode`:       writing mode of the dump file.

```julia
enable!("./dump")

x = 2

@dump x                 # creates ./dump/x
@dump x path="two.txt"  # creates ./dump/two.txt

disable!()

@dump x                 # will not be saved
```

[CIJR]: https://github.com/cursorinsight/julia-registry
