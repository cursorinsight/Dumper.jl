# Dumper.jl

Dumper.jl is a Julia package that allows you to save the value of variables in
files easily.

## Installation

```julia
julia>]
pkg> add https://github.com/cursorinsight/Dumper.jl
```

## Usage

Load the package via

```julia
using Dumper
```

This exports two functions and a macro: `enable!`, `disable!` and `@dump`.

Enable dump functionality with `enable!`. Without parameter it will enable
dumping in the directory set in the `DUMP` environmental variable or if it does
not exists in a `dump-YYYYmmdd-HHMMSS"` directory with the current date and
time.

You can set the environmental variable in the following way:

```julia
ENV["DUMP"] = "./directory_to_dump"
```

You can also add it to the user configuration file `~/.julia/config/startup.jl`
too to have permanent effect.

To disable dump functionality simply call `disable!()`.

```julia
# Without parameter it dump files in the default directory explained before
enable!()

# You can pass the path of the directory too
enable!("./dump")

# Disable dump functionalty
disable!()
```

You can dump the value of a variable into a file with `@dump`. This will only
save the file if the dump functionality is enabled (it is disabled by default).

Possible arguments are:
  - `isabsolute`:   `true` if the path is absolute (default: `false`)
  - `path`:         name of the dumped file (default: name of the variable)
  - `directory`:    save directory (default: enabled directory)
  - `mime`:         output format (default: `MIME("text/plain")`)
  - `mode`:         writing mode of the dumped file (default: `"w"`)

```julia
enable!("./dump")

x = 2

@dump x                 # creates ./dump/x
@dump x path="two.txt"  # creates ./dump/two.txt

disable!()

@dump x                 # will not be saved
```
