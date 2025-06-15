# Red CLI
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.13-blue)
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
  install   Install scripts in game's directory.
  watch     Watch scripts to hot reload them automatically in game's directory.
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
```json5
{
  "name": "<name>",
  "version": "<semver>",
  "license": true,
  "game": "<path-to-game>",
  "stage": "<path-of-bundle>",
  "scripts": {
    "redscript": {                        // Define only if you use redscript
      "debounceTime": 3000,
      "src": "<path-to-scripts>",
      "output": "<path-to-redscript>",
      "storage": "<path-to-storage>"      // Optional, when using RedFileSystem
    },
    "cet": {                              // Define only if you use CET
      "src": "<path-to-scripts>",
      "output": "<path-to-cet>"
    }
  },
  "plugin": {                             // Define only if you build a RED4ext plugin
    "debug": "build\\Debug\\",
    "release": "build\\Release\\"
  }
}
```

|             Field | Required | Default                                       | Description                                                                                                                                                                                                        |
|------------------:|:--------:|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|              name |   yes    |                                               | Name of your mod. It will be used as a folder name too.                                                                                                                                                            |
|           version |    no    | `"0.1.0"`                                     | Version of your mod. It will be included in the bundle of your scripts.                                                                                                                                            |
|           license |    no    | `false`                                       | `true` to add LICENSE file, from the root directory, when packing a release.                                                                                                                                       |
|              game |    no    | *auto-detect path*                            | Absolute path to `Cyberpunk 2077` directory. You can omit or leave empty this field to auto-detect the path (Steam, GOG, Epic).                                                                                    |
|             stage |    no    | `"stage\"`                                    | Path to output bundle of your scripts. It is relative to the root directory of your project. This is temporary directory to allow red-cli to prepare and bundle files.                                             |
|            &nbsp; |          |                                               |                                                                                                                                                                                                                    |
|         watchTime |    no    | 0                                             | Total amount of time recorded when using [watch](#watch) command. You should leave this value as-is.                                                                                                               |
|            &nbsp; |          |                                               |                                                                                                                                                                                                                    |
| scripts.redscript |    no    |                                               | **Required when `scripts.cet` is not defined.**                                                                                                                                                                    |
|      debounceTime |    no    | 3000                                          | Amount of time to debounce between new type checks and triggering a hot reload (in milliseconds). Minimum is 1000ms. See [watch](#watch) command.                                                                  |
|               src |   yes    |                                               | Relative path of your scripts (.reds).                                                                                                                                                                             |
|            output |    no    | `"r6\scripts\"`                               | Relative path of Redscript to install your bundle in game's directory. `name` will be appended for you (e.g. `"r6\scripts\<name>"`). You can omit or leave empty to use the default path.                          |
|           storage |    no    |                                               | Relative path of files for RedFileSystem storage.                                                                                                                                                                  |
|            &nbsp; |          |                                               |                                                                                                                                                                                                                    |
|       scripts.cet |    no    |                                               | **Required when `scripts.redscript` is not defined.**                                                                                                                                                              |
|               src |   yes    |                                               | Relative path of your scripts (.lua).                                                                                                                                                                              |
|            output |    no    | `"bin\x64\plugins\cyber_engine_tweaks\mods\"` | Relative path of CET to install your scripts in game's directory. `name` will be appended for you (e.g. `"bin\x64\plugins\cyber_engine_tweaks\mods\<name>"`). You can omit or leave empty to use the default path. |
|            &nbsp; |          |                                               |                                                                                                                                                                                                                    |
|            plugin |    no    |                                               | **Only when making a RED4ext plugin**                                                                                                                                                                              |
|             debug |   yes    |                                               | Relative path of RED4ext plugin build in Debug mode (using `"<name>.dll"`).                                                                                                                                        |
|           release |   yes    |                                               | Relative path of RED4ext plugin build in Release mode (using `"<name>.dll"`).                                                                                                                                      |

## Usage

If you're using a custom game's path, you can configure an environment variable instead. This is convenient to avoid 
pushing your local game's path in `red.config.json` when versioning your project.

Define path in `REDCLI_GAME` environment variable, red-cli will use it instead. Reading game's path is done in this 
order:
- environment variable
- `game` key in `red.config.json`
- auto-detect path (Steam, GOG, Epic)

### Bundle

> [!NOTE]
> This feature is redscript only.

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

You can find an example in [test/] of this repository. Download this folder, open a terminal in the folder, and try some 
commands to see the output.

### Install

You can install your scripts in the game's directory with a simple command, from your project's directory:
```shell
red-cli install
```
- install redscript files in `<game>\r6\scripts\<name>` (when configured).
- install RedFileSystem files in `<game>\r6\storages\<name>\` (when configured).
- install CET files in `<game>\bin\x64\plugins\cyber_engine_tweaks\mods\<name>` (when configured).
- install RED4ext library in `<game>\red4ext\plugins\<name>\<name>.dll` (when configured).

It will run in `debug` mode by default to include test scripts.

You can use option `--bundle` to bundle your scripts before installing them. It will show you what it will look like 
when releasing your project with the `pack` command. You should not use this option when debugging, as it will be harder
to debug compilation errors.

> [!NOTE]
> If option `plugin` is enabled, it will silently fail to install the DLL while the game is running. All scripts will be 
> installed anyway.

### Watch

> [!NOTE]
> This feature is redscript only for now.

This command will automatically:
1. Detect changes in scripts (.reds)
2. Install changes in game's directory
3. Test type checks are successful (using [Redscript Language Server])
4. Trigger a hot reload (using [Red Hot Tools])

You can now switch back to the game, scripts are already reloaded.

This process will run continuously until you stop it using `CTRL + C`. This feature is similar to what is available in 
popular frameworks like Angular, React, Vue, Flutter, and others.

To prevent spamming the game engine to hot reload scripts, a debounced time setting is used. It will wait for 
`debounceTime` (in milliseconds) until no new type checks are emitted by [Redscript Language Server], to finally trigger
a hot reload. This setting can be configured in `red.config.json` to your convenience.
If the game engine is already hot reloading, it will not trigger again and wait until the next changes.

> [!TIP]
> This command will record the watch time and increment it in `red.config.json`. It keeps track of the time you spent 
> working on your mod.

#### Advanced configuration

In order to detect type checks successfully, a `.redscript-ide` must be present in the folder / workspace of your 
project. This is used by [Redscript Language Server]. By default, `red-cli` will prompt you to create the file if it is
not present. It will be configured such as RLS emits the file `.reds-ready` when type checks successfully (after saving
a file with VS Code). If you wish, or if you already generated this file in your project, you'll need to define the
following TOML key, so `red-cli` knows which file to watch for changes when type checks successfully:
```toml
[[hooks.successful_check]]
create_file = "{workspace_dir}\\.reds-ready"
```
`{workspace_dir}` will be interpreted as the current working directory where `red-cli` is executed. You can use an 
absolute path instead.

### Pack

```shell
red-cli pack
```

It will prepare an archive with scripts / files / plugin, ready to release to users:
- add bundled redscript files (when configured)
- add RedFileSystem files (when configured)
- add CET files (when configured)
- add RED4ext library (when configured)

This is what it should look like with the example you can find in [test/]:
```
Awesome-0.1.0.zip
|-- bin\
    |-- x64\
        |-- plugins\
            |-- cyber_engine_tweaks\
                |-- mods\
                    |-- Awesome\
                        |-- modules\
                            |-- gui.lua
                        |-- init.lua
|-- r6\
    |-- scripts\
        |-- Awesome\
            |-- Awesome.Data.reds
            |-- Awesome.Global.reds
            |-- Awesome.reds
            |-- Awesome.Services.reds
    |-- storages\
        |-- Awesome\
            |-- test.json
|-- red4ext\
    |-- plugins\
        |-- Awesome\
            |-- Awesome.dll
```

## Questions

If you have a bug, please fill an [issue].
If you have questions or feedback, don't hesitate to ask me on [Discord].

<!-- Table of links -->
[latest release]: https://github.com/rayshader/cp2077-red-cli/releases/latest
[environment variables]: https://www.google.com/search?q=add+environment+variable+windows
[test/]: https://github.com/rayshader/cp2077-red-cli/tree/master/test
[issue]: https://github.com/rayshader/cp2077-red-cli/issues
[Discord]: https://discord.com/channels/717692382849663036/1254464502968356965
[Redscript Language Server]: https://github.com/jac3km4/redscript-ide
[Red Hot Tools]: https://github.com/psiberx/cp2077-red-hot-tools/
