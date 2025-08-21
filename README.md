# any2any

any2any is a progressive code converter written in Haxe. It reads source
code, maps it to a tiny universal AST (UniAST) and emits code for another
language. The project ships with a command-line tool and an experimental
OpenFL/HaxeUI interface.

## Highlights
- Universal AST (UniAST) inspired by Deno AST and Haxe types.
- Pluggable parsers and emitters registered via `core.Registry`.
- Minimal JavaScript → Python pipeline, falling back to an AI agent for unknown
  conversions.
- Command-line tool and desktop GUI with swap and clear actions.

## Getting Started
### Build the CLI
```bash
haxe build-cli.hxml
```

Convert a file or stdin:

```bash
# from file to stdout
neko bin/cli.n --from=javascript --to=python path/to/source.js
# pipe from stdin and save to file
cat source.js | neko bin/cli.n --from=javascript --to=python --out=out.py
```

### Launch the GUI
Install dependencies (OpenFL and HaxeUI), then:

```bash
haxelib run openfl test project.xml html5
```

## Architecture
The converter works in three stages:

1. **Segmenter** splits large inputs into manageable chunks.
2. **Parser** translates each chunk into the UniAST structure.
3. **Emitter** produces code in the target language.

Missing parsers or emitters are delegated to an `IAgent` implementation, which
can integrate an AI model.

### Adding a Language
Implement `parsers.IParser` and `emitters.IEmitter`, then register them:

```haxe
Registry.registerParser(Language.Haxe, new MyHaxeParser());
Registry.registerEmitter(Language.CSharp, new CSharpEmitter());
```

## Development
- `src/core` contains the conversion pipeline and utilities.
- `src/cli` and `src/gui` host entry points for CLI and GUI.
- The project builds to Neko by default; other targets are defined in
  `build-*` files.

## License
MIT

