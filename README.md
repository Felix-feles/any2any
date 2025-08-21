# HaxeCodeConvert

HaxeCodeConvert is a progressive code converter written in Haxe. It demonstrates a pipeline that reads source code, maps it to a tiny universal AST and emits code for another language. The project ships with a command-line tool and a GUI skeleton based on OpenFL/HaxeUI.

## Features
- Language normalization helper (`core/Language.hx`)
- Pluggable parsers and emitters registered through `core/Registry.hx`
- Minimal JavaScript → Python conversion via a pivot AST
- Command-line interface (`cli.Main`) and an experimental GUI (`gui.Main`)

## Building
The CLI can be compiled for the Neko runtime:

```bash
haxe build-cli.hxml
```

Run a conversion:

```bash
neko bin/cli.n --from=javascript --to=python path/to/source.js
```

The GUI uses OpenFL and HaxeUI. Once the dependencies are installed, launch it with:

```bash
haxelib run openfl test project.xml html5
```

## License
MIT
