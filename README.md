# Red CLI
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.12a-blue)
![GitHub License](https://img.shields.io/github/license/rayshader/cp2077-red-cli)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

A tool to bundle scripts of a mod for Cyberpunk 2077.

Usage: `red-cli <command> [arguments]`

Global options:
```
-h, --help    Print this usage information.
```

Available commands:
```
  bundle    Bundle scripts.
  install   Install scripts in your game's directory.
  pack      Pack scripts in an archive for release (include bundle step).
```

Run `red-cli help <command>` for more information about a command.

## Installation
1. Download [latest release].
2. Extract archive somewhere in your system.
3. Optionally rename `red-cli.exe` to `red.exe`.
4. Add path where you put the executable in your [environment variables] (variable `PATH`).
5. Open a terminal and run:
```shell
red-cli
```

It should show usage information if it is installed correctly.

## Configure your project

This tool use a Json file to configure and work with your environment. You must put the file `red.config.json` in the
root directory of your project. The content should look like this:
```json
{
  "name": "<name>",
  "version": "<semver>",
  "license": true,
  "game": "<path-to-game>",
  "dist": "<path-to-output>",
  "scripts": {
    "redscript": {
      "src": "<path-to-scripts>",
      "output": "<path-to-redscript>"
    }
  },
  "plugin": {
    "debug": "build\\Debug\\",
    "release": "build\\Release\\"
  }
}
```

|             Field | Required | Default            | Description                                                                                                                                                                               |
|------------------:|:--------:|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|              name |   yes    |                    | Name of your mod. It will be used as a folder name too.                                                                                                                                   |
|           version |    no    | `"0.1.0"`          | Version of your mod. It will be included in the bundle of your scripts.                                                                                                                   |
|           license |    no    | `false`            | `true` to add LICENSE file, from the root directory, when packing a release.                                                                                                              |
|              game |    no    | *auto-detect path* | Absolute path to `Cyberpunk 2077` directory. You can omit or leave empty this field to auto-detect the path (Steam, GOG, Epic).                                                           |
|              dist |   yes    | `"dist\"`          | Path to output bundle of your scripts. It is relative to the root directory of your project.                                                                                              |
|            &nbsp; |
| scripts.redscript |   yes    |
|               src |   yes    |                    | Relative path of your scripts (.reds).                                                                                                                                                    |
|            output |    no    | `"r6\scripts\"`    | Relative path of Redscript to install your bundle in game's directory. `name` will be appended for you (e.g. `"r6\scripts\<name>"`). You can omit or leave empty to use the default path. |
|            &nbsp; |
|            plugin |    no    |                    | **Only when making a RED4ext plugin**                                                                                                                                                     |
|             debug |   yes    |                    | Relative path of RED4ext plugin build in Debug mode (using `"<name>.dll"`).                                                                                                               |
|           release |   yes    |                    | Relative path of RED4ext plugin build in Release mode (using `"<name>.dll"`).                                                                                                             |

## Usage

### Bundle

You can bundle your scripts like this:
```shell
red-cli bundle
```
It will merge scripts per module. It is useful to reduce the amount of files when releasing your project. This step can
be used with the `install` command. It is always enabled with the `pack` command.

Example with the following scripts:

```swift
// Awesome.reds

module Awesome

// ...
```

```swift
// Model.reds

module Awesome.Data

// ...
```

It will be bundled as:
```swift
// Awesome.reds

module Awesome

// Code of all scripts declared in module Awesome.
// It will include distinct `import` statements too.
```

```swift
// Awesome.Data.reds

module Awesome.Data

// Code of all scripts declared in module Awesome.Data.
// It will include distinct `import` statements too.
```

If you have scripts declared in the global scope (without using `module <name>` statement), it will be bundled as:
```swift
// Awesome.Global.reds

// Code of all scripts declared in global scope.
// It will include distinct `import` statements too.
```

You can find an example in [test/] of this repository. Download this folder, open a terminal in the folder and try some 
commands to see the output.

### Install
You can install your scripts in the game's directory with a simple command, from your project's directory:
```shell
red-cli install
```

It will install scripts in `<game>\r6\scripts\<name>` for you. If you have configured RED4ext plugin, it will also 
install the library in `<game>\red4ext\plugins\<name>\<name>.dll`. It will run in `debug` mode by default to include 
test scripts.

You can use option `--bundle` to bundle your scripts before installing them. It will show you how it will look like when
releasing your project with the `pack` command. You should not use this option when debugging, as it will be harder to 
debug compilation errors.

### Pack
```shell
red-cli pack
```

It will bundle scripts and put them in an archive, ready to release to users. If you have configured RED4ext plugin, it 
will also add the library file. This is how it should look like with the example you can find in [test/]:
```
Awesome-v0.1.0.zip
|-- r6\
    |-- scripts\
        |-- Awesome\
            |-- Awesome.Data.reds
            |-- Awesome.Global.reds
            |-- Awesome.reds
            |-- Awesome.Services.reds
|-- red4ext\
    |-- plugins\
        |-- Awesome\
            |-- Awesome.dll
```

<!-- Table of links -->
[latest release]: https://github.com/rayshader/cp2077-red-cli/releases/latest
[environment variables]: https://www.google.com/search?q=add+environment+variable+windows
[test/]: https://github.com/rayshader/cp2077-red-cli/tree/master/test
