# Red CLI
![Cyberpunk 2077](https://img.shields.io/badge/Cyberpunk%202077-v2.12a-blue)
![GitHub License](https://img.shields.io/github/license/rayshader/cp2077-red-cli)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

**red-cli v0.1.0**

A tool to bundle scripts of a mod for Cyberpunk 2077.

Usage: `red-cli <command> [arguments]`

Global options:
```
-h, --help    Print this usage information.
```

Available commands:
```
  bundle    Bundle scripts.
  install   Install scripts in your game's directory (include bundle step).
  pack      Pack scripts in an archive for release (include bundle step).
```

Run `red-cli help <command>` for more information about a command.

GitHub: https://github.com/rayshader/cp2077-red-cli

## Configure your project

You must provide a `red.config.json` file to configure your project. You can leave some fields empty to use default 
values. If your setup is unique, you should have enough options to configure red-cli with your environment:
```jsonc
{
  "name": "Awesome",
  "version": "0.1.0",
  "game": "<path-to-game>",         // Leave empty to auto-detect game path.
  "dist": "<path-to-output>",       // Directory to output bundle to.
                                    // (default is "dist\")
  "scripts": {
    "redscript": {
      "src": "scripts\\Awesome\\",  // Root directory to look for your .reds 
                                    // files.
      "output": ""                  // Path to output scripts to when 
                                    // installing in game's directory. It will 
                                    // append <name> of your project for you.
                                    // (default is "r6\scripts\")
    }
  }
}
```
