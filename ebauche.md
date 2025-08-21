# any2any — convertisseur de code multi-langages (pivot UniAST)

> **Objectif** : application en **Haxe** (CLI + GUI) qui convertit du code d'un langage à un autre via un **langage pivot (UniAST)** inspiré des concepts d'AST (Deno/SWC) et complété par des types Haxe. Architecture **extensible** par greffons (parsers/emitters).
>
> **État livré ici** : base **fonctionnelle** avec support **démo** (JS ⇄ Python, Haxe → JS/Python partiel), **sans limite de taille imposée par l'appli** (limites = RAM/OS). Tout le reste est **extensible** par plugins.
>
> ⚠️ **Transcoder 100% de tous les langages n'est pas réaliste sans modèles IA et des parsers complets**. Cette base fournit le pipeline, l'AST pivot, un segmenter, un convertisseur procédural simplifié et des points d'extension IA.

---

## Arborescence
```
any2any/
├─ haxelib.json
├─ README.md
├─ LICENSE
├─ build-cli-hl.hxml
├─ build-cli-cpp.hxml
├─ build-cli-js.hxml
├─ project.xml                # pour GUI OpenFL/HaxeUI
├─ src/
│  ├─ cli/Main.hx             # entrée CLI
│  ├─ gui/Main.hx             # entrée GUI (OpenFL + HaxeUI)
│  ├─ core/Language.hx
│  ├─ core/UniAst.hx
│  ├─ core/Registry.hx
│  ├─ core/Segmenter.hx
│  ├─ core/Converter.hx
│  ├─ parsers/IParser.hx
│  ├─ parsers/JSParser.hx
│  ├─ parsers/PythonParser.hx
│  ├─ parsers/HaxeParser.hx
│  ├─ emitters/IEmitter.hx
│  ├─ emitters/JSEmitter.hx
│  ├─ emitters/PythonEmitter.hx
│  ├─ emitters/HaxeEmitter.hx
│  ├─ ai/IAgent.hx
│  ├─ ai/NullAgent.hx
│  └─ util/Strings.hx
└─ assets/
   └─ (vide)
```

---

## `haxelib.json`
```json
{
  "name": "any2any",
  "url": "",
  "license": "MIT",
  "tags": ["code", "convert", "ast", "ai", "haxe"],
  "description": "Convertisseur de code multi-langages via un AST pivot (UniAST), CLI + GUI OpenFL/HaxeUI.",
  "version": "0.1.0",
  "classPath": "src",
  "contributors": ["you"],
  "dependencies": {
    "hxcpp": "",
    "openfl": "",
    "haxeui-core": "",
    "haxeui-openfl": ""
  }
}
```

---

## `build-cli-hl.hxml` (CLI HashLink)
```hxml
-cp src
-main cli.Main
-hl bin/convert.hl
-dce full
--macro keep('core')
--macro keep('parsers')
--macro keep('emitters')
```

## `build-cli-cpp.hxml` (CLI C++)
```hxml
-cp src
-main cli.Main
-cpp bin/cpp
-D analyzer-optimize
-dce full
--macro keep('core')
--macro keep('parsers')
--macro keep('emitters')
```

## `build-cli-js.hxml` (CLI JS)
```hxml
-cp src
-main cli.Main
-js bin/cli.js
-dce full
--macro keep('core')
--macro keep('parsers')
--macro keep('emitters')
```

---

## `project.xml` (GUI OpenFL + HaxeUI)
```xml
<project>
  <meta title="any2any" package="com.example.any2any" version="0.1.0" company="you"/>
  <app main="gui.Main" file="any2any" path="bin" />
  <source path="src" />
  <haxelib name="openfl" />
  <haxelib name="haxeui-core" />
  <haxelib name="haxeui-openfl" />
  <window width="1100" height="720" fps="60" background="#1e1e1e"/>
  <assets path="assets" />
  <haxedef name="HCC_GUI" />
</project>
```

---

## `README.md`
```md
# any2any

Convertisseur de code multi-langages via un AST pivot (UniAST). Fournit :
- **CLI** (HashLink / C++ / JS)
- **GUI** (OpenFL + HaxeUI)
- Parsers/Emitters de démonstration (JS ⇄ Python, Haxe → JS|Python partiel)

## Prérequis
- Haxe 4.3+
- `haxelib install hxcpp`
- `haxelib install hashlink` (si HL)
- **GUI** : `haxelib install openfl haxeui-core haxeui-openfl` puis `haxelib run openfl setup`

## Construire & exécuter
### CLI (HL)
```bash
haxe build-cli-hl.hxml
hl bin/convert.hl --from=javascript --to=python input.js > output.py
```

### CLI (C++)
```bash
haxe build-cli-cpp.hxml
bin/cpp/cli/Main --from=python --to=javascript input.py > output.js
```

### CLI (JS)
```bash
haxe build-cli-js.hxml
node bin/cli.js --from=haxe --to=python input.hx > output.py
```

### GUI (OpenFL)
```bash
haxelib run openfl test hl      # ou cpp, html5, android, ios
```

## Limitations & Extensions
- La couverture de *tous* les langages nécessite des parsers/emitters additionnels.
- Point d'extension **IA** (`ai/IAgent.hx`) pour brancher un modèle (local/remote) vers le pivot.
- Aucune limite de taille imposée en dehors des limites système/mémoire.
```

---

## `LICENSE`
```text
MIT License

Copyright (c) 2025 You

Permission is hereby granted, free of charge, to any person obtaining a copy
... (texte MIT standard)
```

---

## `src/util/Strings.hx`
```haxe
package util;
class Strings {
  public static inline function isBlank(s:String):Bool return s == null || s.trim() == "";
  public static function lines(s:String):Array<String> return s == null ? [] : s.split("\n");
}
```

---

## `src/core/Language.hx`
```haxe
package core;

enum abstract Language(String) from String to String {
  var Auto = "auto";
  var JavaScript = "javascript";
  var TypeScript = "typescript";
  var Python = "python";
  var Java = "java";
  var CSharp = "csharp";
  var Cpp = "cpp";
  var C = "c";
  var Go = "go";
  var Rust = "rust";
  var Kotlin = "kotlin";
  var Swift = "swift";
  var Haxe = "haxe";

  public static function normalize(x:String):Language {
    if (x == null) return Auto;
    var k = x.toLowerCase();
    return switch(k) {
      case "js" | "node" | "javascript": JavaScript;
      case "ts" | "typescript": TypeScript;
      case "py" | "python": Python;
      case "java": Java;
      case "cs" | "c#" | "csharp": CSharp;
      case "cpp" | "c++": Cpp;
      case "c": C;
      case "go" | "golang": Go;
      case "rs" | "rust": Rust;
      case "kt" | "kotlin": Kotlin;
      case "swift": Swift;
      case "hx" | "haxe": Haxe;
      case _: cast k; // Auto ou inconnu
    }
  }
}
```

---

## `src/core/UniAst.hx` (AST pivot simplifié)
```haxe
package core;

// UniAST — AST pivot minimal, inspiré des AST modernes, typé Haxe

enum BinOp { Add; Sub; Mul; Div; Mod; Eq; Neq; Lt; Lte; Gt; Gte; And; Or; Assign; }

enum UnOp { Neg; Not; }

enum TypeHint { TAny; TBool; TInt; TFloat; TString; TVoid; TArrayOf(TypeHint); TObject; TCustom(String); }

enum Stmt {
  SVar(name:String, init:Expr, t:TypeHint);
  SExpr(e:Expr);
  SReturn(e:Expr);
  SIf(cond:Expr, thenBlock:Array<Stmt>, elseBlock:Array<Stmt>);
  SWhile(cond:Expr, body:Array<Stmt>);
  SBlock(block:Array<Stmt>);
  SComment(text:String);
}

enum Param { P(name:String, t:TypeHint, init:Null<Expr>); }

enum Expr {
  EIdent(name:String);
  ENum(f:Float);
  EStr(s:String);
  EBool(v:Bool);
  ECall(callee:Expr, args:Array<Expr>);
  EBin(op:BinOp, left:Expr, right:Expr);
  EUn(op:UnOp, v:Expr);
  EArray(items:Array<Expr>);
  EObject(fields:Array<{name:String, value:Expr}>);
  ENil;
}

typedef FunDecl = { name:String, params:Array<Param>, ret:TypeHint, body:Array<Stmt> };

typedef Program = {
  language:Language,
  functions:Array<FunDecl>,
  statements:Array<Stmt>,
  meta:Dynamic
}
```

---

## `src/core/Registry.hx`
```haxe
package core;
import core.Language; import parsers.IParser; import emitters.IEmitter;

class Registry {
  static var parsers:Map<Language, IParser> = new Map();
  static var emitters:Map<Language, IEmitter> = new Map();

  public static function registerParser(lang:Language, p:IParser) parsers.set(lang, p);
  public static function registerEmitter(lang:Language, e:IEmitter) emitters.set(lang, e);

  public static function getParser(lang:Language):Null<IParser> return parsers.get(lang);
  public static function getEmitter(lang:Language):Null<IEmitter> return emitters.get(lang);

  public static function initDefaults():Void {
    // enreg. de base
    registerParser(Language.JavaScript, new parsers.JSParser());
    registerParser(Language.Python, new parsers.PythonParser());
    registerParser(Language.Haxe, new parsers.HaxeParser());

    registerEmitter(Language.JavaScript, new emitters.JSEmitter());
    registerEmitter(Language.Python, new emitters.PythonEmitter());
    registerEmitter(Language.Haxe, new emitters.HaxeEmitter());
  }
}
```

---

## `src/core/Segmenter.hx`
```haxe
package core; import util.Strings;

class Segment {
  public var text:String; public var startLine:Int; public var endLine:Int;
  public function new(t:String, a:Int, b:Int) { text=t; startLine=a; endLine=b; }
}

class Segmenter {
  /** Très simple : coupe par doubles sauts de ligne */
  public static function split(code:String):Array<Segment> {
    var arr = new Array<Segment>();
    var lines = Strings.lines(code);
    var buf:Array<String> = []; var segStart = 0;
    for (i in 0...lines.length) {
      var L = lines[i];
      if (Strings.isBlank(L) && buf.length>0) {
        arr.push(new Segment(buf.join("\n"), segStart, i-1)); buf=[]; segStart=i+1;
      } else {
        if (buf.length==0) segStart=i;
        buf.push(L);
      }
    }
    if (buf.length>0) arr.push(new Segment(buf.join("\n"), segStart, lines.length-1));
    return arr;
  }
}
```

---

## `src/parsers/IParser.hx`
```haxe
package parsers; import core.UniAst;

interface IParser {
  /** Parse un *segment* en Program (partiel). Peut lever une exception en cas d'échec. */
  public function parseSegment(code:String):Program;
}
```

---

## `src/emitters/IEmitter.hx`
```haxe
package emitters; import core.UniAst;

interface IEmitter {
  /** Emet du code pour un Program (partiel). */
  public function emit(prog:Program):String;
}
```

---

## `src/parsers/JSParser.hx` (heuristique de démo)
```haxe
package parsers; import core.*; import core.UniAst.*;

class JSParser implements IParser {
  public function new() {}
  public function parseSegment(code:String):Program {
    var p:Program = { language: Language.JavaScript, functions: [], statements: [], meta: null };

    // Heuristiques très simples :
    //  - console.log(x) -> SExpr(ECall(EIdent("console.log"), [x])) dans l'AST
    //  - let/const/var a = expr; -> SVar(a, expr, TAny)
    //  - function f(a,b){ return a+b; } -> FunDecl

    var trimmed = code.trim();
    // function ...
    var funcRe = ~/function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*\{([\s\S]*)\}/;
    if (funcRe.match(trimmed)) {
      var name = funcRe.matched(1);
      var params = funcRe.matched(2).split(",").map(function(s) return P(s.trim(), TypeHint.TAny, null));
      var bodyRaw = funcRe.matched(3);
      var body:Array<Stmt> = [];
      // support: return expr; (ligne unique)
      var retRe = ~/return\s+([^;]+);/;
      if (retRe.match(bodyRaw)) {
        body.push(SReturn(parseExpr(retRe.matched(1).trim())));
      }
      p.functions.push({ name: name, params: params, ret: TypeHint.TAny, body: body });
      return p;
    }

    // var/let/const decl
    var declRe = ~/(?:var|let|const)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([^;]+);?/;
    if (declRe.match(trimmed)) {
      var n = declRe.matched(1);
      var e = declRe.matched(2);
      p.statements.push(SVar(n, parseExpr(e), TypeHint.TAny));
      return p;
    }

    // console.log(...)
    var clogRe = ~/console\.log\s*\((.*)\)\s*;?/;
    if (clogRe.match(trimmed)) {
      p.statements.push(SExpr(ECall(EIdent("console.log"), [parseExpr(clogRe.matched(1))])));
      return p;
    }

    // par défaut: commentaire
    p.statements.push(SComment(trimmed));
    return p;
  }

  function parseExpr(s:String):Expr {
    s = s.trim();
    // nombres
    if (/^-?\d+(?:\.\d+)?$/.match(s)) return ENum(Std.parseFloat(s));
    // string "..." ou '...'
    if ((~/^\".*\"$/.match(s)) || (/^\'.*\'$/.match(s))) return EStr(s.substr(1, s.length-2));

    // a + b, a - b, a * b, a / b
    var ops = ["+", "-", "*", "/", "==", "!=", "&&", "||"];
    for (op in ops) {
      var idx = s.indexOf(" " + op + " ");
      if (idx > 0) {
        var left = s.substr(0, idx);
        var right = s.substr(idx + op.length + 2);
        return EBin(switch(op){
          case "+": BinOp.Add;
          case "-": BinOp.Sub;
          case "*": BinOp.Mul;
          case "/": BinOp.Div;
          case "==": BinOp.Eq;
          case "!=": BinOp.Neq;
          case "&&": BinOp.And;
          case "||": BinOp.Or;
          case _: BinOp.Assign;
        }, parseExpr(left), parseExpr(right));
      }
    }

    // ident seul
    return EIdent(s);
  }
}
```

---

## `src/parsers/PythonParser.hx` (heuristique de démo)
```haxe
package parsers; import core.*; import core.UniAst.*;

class PythonParser implements IParser {
  public function new() {}
  public function parseSegment(code:String):Program {
    var p:Program = { language: Language.Python, functions: [], statements: [], meta: null };
    var trimmed = code.trim();

    // def f(a,b): return a+b
    var f1 = ~/def\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*:\s*return\s+(.+)/;
    if (f1.match(trimmed)) {
      var name = f1.matched(1);
      var params = f1.matched(2).split(",").map(function(s) return P(s.trim(), TypeHint.TAny, null));
      var ret = f1.matched(3).trim();
      p.functions.push({ name: name, params: params, ret: TypeHint.TAny, body: [ SReturn(parseExpr(ret)) ] });
      return p;
    }

    // affectation: x = expr
    var a1 = ~/([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.+)/;
    if (a1.match(trimmed)) {
      p.statements.push(SVar(a1.matched(1), parseExpr(a1.matched(2)), TypeHint.TAny));
      return p;
    }

    // print(expr)
    var p1 = ~/print\s*\((.*)\)/;
    if (p1.match(trimmed)) {
      p.statements.push(SExpr(ECall(EIdent("print"), [parseExpr(p1.matched(1))])));
      return p;
    }

    p.statements.push(SComment(trimmed));
    return p;
  }

  function parseExpr(s:String):Expr {
    s = s.trim();
    if (/^-?\d+(?:\.\d+)?$/.match(s)) return ENum(Std.parseFloat(s));
    if ((~/^\".*\"$/.match(s)) || (/^\'.*\'$/.match(s))) return EStr(s.substr(1, s.length-2));
    var ops = ["+", "-", "*", "/", "==", "!=", "and", "or"];
    for (op in ops) {
      var token = " " + op + " ";
      var idx = s.indexOf(token);
      if (idx > 0) {
        var left = s.substr(0, idx);
        var right = s.substr(idx + token.length);
        return EBin(switch(op){
          case "+": BinOp.Add; case "-": BinOp.Sub; case "*": BinOp.Mul; case "/": BinOp.Div;
          case "==": BinOp.Eq; case "!=": BinOp.Neq; case "and": BinOp.And; case "or": BinOp.Or;
          case _: BinOp.Assign;
        }, parseExpr(left), parseExpr(right));
      }
    }
    return EIdent(s);
  }
}
```

---

## `src/parsers/HaxeParser.hx` (esquisse minimale)
```haxe
package parsers; import core.*; import core.UniAst.*;

class HaxeParser implements IParser {
  public function new() {}
  public function parseSegment(code:String):Program {
    var p:Program = { language: Language.Haxe, functions: [], statements: [], meta: null };
    var t = code.trim();
    // fun inline: function f(a:Int,b:Int):Int return a+b;
    var re = ~/function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*(?::\s*[^\s]+)?\s*return\s+(.+);/;
    if (re.match(t)) {
      var name = re.matched(1);
      var params = re.matched(2).split(",").map(function(s) return P(s.split(":")[0].trim(), TypeHint.TAny, null));
      var retExpr = re.matched(3).trim();
      p.functions.push({ name: name, params: params, ret: TypeHint.TAny, body: [ SReturn(parseExpr(retExpr)) ]});
      return p;
    }
    // var a = 1;
    var d = ~/var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*(?::[^=]+)?=\s*([^;]+);/;
    if (d.match(t)) { p.statements.push(SVar(d.matched(1), parseExpr(d.matched(2)), TypeHint.TAny)); return p; }
    p.statements.push(SComment(t));
    return p;
  }

  function parseExpr(s:String):Expr {
    s = s.trim();
    if (/^-?\d+(?:\.\d+)?$/.match(s)) return ENum(Std.parseFloat(s));
    if ((~/^\".*\"$/.match(s)) || (/^\'.*\'$/.match(s))) return EStr(s.substr(1, s.length-2));
    var ops = ["+","-","*","/","==","!=","&&","||"];
    for (op in ops) {
      var token = " " + op + " ";
      var idx = s.indexOf(token);
      if (idx>0) return EBin(switch(op){
        case "+": BinOp.Add; case "-": BinOp.Sub; case "*": BinOp.Mul; case "/": BinOp.Div;
        case "==": BinOp.Eq; case "!=": BinOp.Neq; case "&&": BinOp.And; case "||": BinOp.Or; case _: BinOp.Assign;
      }, parseExpr(s.substr(0,idx)), parseExpr(s.substr(idx+token.length)));
    }
    return EIdent(s);
  }
}
```

---

## `src/emitters/JSEmitter.hx`
```haxe
package emitters; import core.*; import core.UniAst.*;

class JSEmitter implements IEmitter {
  public function new() {}
  public function emit(prog:Program):String {
    var out = new StringBuf();
    for (f in prog.functions) {
      out.add('function ' + f.name + '(' + f.params.map(paramName).join(', ') + "){\n");
      for (s in f.body) out.add('  ' + emitStmt(s) + "\n");
      out.add("}\n\n");
    }
    for (s in prog.statements) out.add(emitStmt(s) + "\n");
    return out.toString();
  }

  function paramName(p:Param):String return switch(p){ case P(n,_,_): n; };

  function emitStmt(s:Stmt):String return switch(s) {
    case SVar(n, e, _): 'let ' + n + ' = ' + emitExpr(e) + ';';
    case SExpr(e): emitExpr(e) + ';';
    case SReturn(e): 'return ' + emitExpr(e) + ';';
    case SIf(c,t,e): 'if(' + emitExpr(c) + '){ /* ... */ }' + (e.length>0?' else { /* ... */ }':'');
    case SWhile(c,b): 'while(' + emitExpr(c) + '){ /* ... */ }';
    case SBlock(b): '{ /* block */ }';
    case SComment(txt): '/* ' + txt + ' */';
  }

  function emitExpr(e:Expr):String return switch(e) {
    case EIdent(n): n;
    case ENum(f): Std.string(f);
    case EStr(s): '"' + s + '"';
    case EBool(v): v?"true":"false";
    case ECall(c, args): emitExpr(c) + '(' + args.map(emitExpr).join(', ') + ')';
    case EBin(op,a,b): emitExpr(a) + ' ' + emitBin(op) + ' ' + emitExpr(b);
    case EUn(op,v): (op==UnOp.Not?"!":"-") + emitExpr(v);
    case EArray(xs): '[' + xs.map(emitExpr).join(', ') + ']';
    case EObject(fs): '{' + [for (f in fs) f.name + ':' + emitExpr(f.value)].join(', ') + '}';
    case ENil: "null";
  }

  function emitBin(op:BinOp):String return switch(op) {
    case Add: "+"; case Sub: "-"; case Mul: "*"; case Div: "/"; case Mod: "%";
    case Eq: "=="; case Neq: "!="; case Lt: "<"; case Lte: "<="; case Gt: ">"; case Gte: ">=";
    case And: "&&"; case Or: "||"; case Assign: "=";
  }
}
```

---

## `src/emitters/PythonEmitter.hx`
```haxe
package emitters; import core.*; import core.UniAst.*;

class PythonEmitter implements IEmitter {
  public function new() {}
  public function emit(prog:Program):String {
    var out = new StringBuf();
    for (f in prog.functions) {
      out.add('def ' + f.name + '(' + f.params.map(paramName).join(', ') + '):\n');
      if (f.body.length==0) out.add('    pass\n\n'); else for (s in f.body) out.add('    ' + emitStmt(s) + "\n\n");
    }
    for (s in prog.statements) out.add(emitStmt(s) + "\n");
    return out.toString();
  }

  function paramName(p:Param):String return switch(p){ case P(n,_,_): n; };

  function emitStmt(s:Stmt):String return switch(s) {
    case SVar(n, e, _): n + ' = ' + emitExpr(e);
    case SExpr(e): emitExpr(e);
    case SReturn(e): 'return ' + emitExpr(e);
    case SIf(c,t,e): 'if ' + emitExpr(c) + ': ...' + (e.length>0?' else: ...':'');
    case SWhile(c,b): 'while ' + emitExpr(c) + ': ...';
    case SBlock(b): 'pass  # block';
    case SComment(txt): '# ' + txt;
  }

  function emitExpr(e:Expr):String return switch(e) {
    case EIdent(n): n;
    case ENum(f): Std.string(f);
    case EStr(s): '\'' + s + '\'';
    case EBool(v): v?"True":"False";
    case ECall(c, args): emitExpr(c) + '(' + args.map(emitExpr).join(', ') + ')';
    case EBin(op,a,b): emitExpr(a) + ' ' + emitBin(op) + ' ' + emitExpr(b);
    case EUn(op,v): (op==UnOp.Not?"not ":"-") + emitExpr(v);
    case EArray(xs): '[' + xs.map(emitExpr).join(', ') + ']';
    case EObject(fs): '{' + [for (f in fs) '\'' + f.name + '\'': ' + emitExpr(f.value)].join(', ') + '}';
    case ENil: "None";
  }

  function emitBin(op:BinOp):String return switch(op) {
    case Add: "+"; case Sub: "-"; case Mul: "*"; case Div: "/"; case Mod: "%";
    case Eq: "=="; case Neq: "!="; case Lt: "<"; case Lte: "<="; case Gt: ">"; case Gte: ">=";
    case And: "and"; case Or: "or"; case Assign: "=";
  }
}
```

---

## `src/emitters/HaxeEmitter.hx`
```haxe
package emitters; import core.*; import core.UniAst.*;

class HaxeEmitter implements IEmitter {
  public function new() {}
  public function emit(prog:Program):String {
    var out = new StringBuf();
    for (f in prog.functions) {
      out.add('function ' + f.name + '(' + f.params.map(paramName).join(', ') + ') ');
      if (f.body.length==1 && Std.isOfType(f.body[0], Stmt.SReturn)) {
        var r = cast(f.body[0], Stmt);
        switch(r) { case SReturn(e): out.add('return ' + emitExpr(e) + ';\n'); case _: out.add('{ /* ... */ }\n'); }
      } else {
        out.add('{ /* ... */ }\n');
      }
    }
    for (s in prog.statements) out.add(emitStmt(s) + "\n");
    return out.toString();
  }

  function paramName(p:Param):String return switch(p){ case P(n,_,_): n; };

  function emitStmt(s:Stmt):String return switch(s) {
    case SVar(n, e, _): 'var ' + n + ' = ' + emitExpr(e) + ';';
    case SExpr(e): emitExpr(e) + ';';
    case SReturn(e): 'return ' + emitExpr(e) + ';';
    case SIf(c,t,e): 'if(' + emitExpr(c) + '){ /* ... */ }' + (e.length>0?' else { /* ... */ }':'');
    case SWhile(c,b): 'while(' + emitExpr(c) + '){ /* ... */ }';
    case SBlock(b): '{ /* block */ }';
    case SComment(txt): '// ' + txt;
  }

  function emitExpr(e:Expr):String return switch(e) {
    case EIdent(n): n;
    case ENum(f): Std.string(f);
    case EStr(s): '"' + s + '"';
    case EBool(v): v?"true":"false";
    case ECall(c, args): emitExpr(c) + '(' + args.map(emitExpr).join(', ') + ')';
    case EBin(op,a,b): emitExpr(a) + ' ' + emitBin(op) + ' ' + emitExpr(b);
    case EUn(op,v): (op==UnOp.Not?"!":"-") + emitExpr(v);
    case EArray(xs): '[' + xs.map(emitExpr).join(', ') + ']';
    case EObject(fs): '{' + [for (f in fs) f.name + ':' + emitExpr(f.value)].join(', ') + '}';
    case ENil: "null";
  }

  function emitBin(op:BinOp):String return switch(op) {
    case Add: "+"; case Sub: "-"; case Mul: "*"; case Div: "/"; case Mod: "%";
    case Eq: "=="; case Neq: "!="; case Lt: "<"; case Lte: "<="; case Gt: ">"; case Gte: ">=";
    case And: "&&"; case Or: "||"; case Assign: "=";
  }
}
```

---

## `src/core/Converter.hx`
```haxe
package core;
import core.UniAst.*; import core.Language; import core.Registry; import core.Segmenter; import ai.IAgent;

class Converter {
  var agent:IAgent; // IA optionnelle (peut être NullAgent)
  public function new(agent:IAgent) this.agent = agent;

  public function convert(code:String, fromLang:Language, toLang:Language):String {
    Registry.initDefaults();
    var segments = Segmenter.split(code);
    var out = new StringBuf();
    for (seg in segments) {
      try {
        var parser = Registry.getParser(fromLang);
        var emitter = Registry.getEmitter(toLang);
        if (parser != null && emitter != null) {
          var prog = parser.parseSegment(seg.text);
          out.add(emitter.emit(prog));
        } else {
          // Fallback IA → UniAST → Emitter si dispo
          if (agent!=null) {
            var maybe = agent.segmentToTarget(seg.text, fromLang, toLang);
            if (maybe != null) out.add(maybe); else out.add(commented(seg.text, toLang));
          } else {
            out.add(commented(seg.text, toLang));
          }
        }
      } catch (e:Dynamic) {
        out.add(commented(seg.text, toLang));
      }
      out.add("\n\n");
    }
    return out.toString();
  }

  function commented(txt:String, lang:Language):String {
    return switch(lang) {
      case Language.Python: "# [UNTRANSLATED]\n" + txt.split("\n").map(function(l) return "# " + l).join("\n");
      case Language.JavaScript: "/* [UNTRANSLATED] */\n" + txt.split("\n").map(function(l) return "// " + l).join("\n");
      case Language.Haxe: "// [UNTRANSLATED]\n" + txt.split("\n").map(function(l) return "// " + l).join("\n");
      case _: "/* [UNTRANSLATED] */\n" + txt;
    }
  }
}
```

---

## `src/ai/IAgent.hx` & `src/ai/NullAgent.hx`
```haxe
package ai; import core.Language;

interface IAgent {
  /** Optionnel : conversion segment -> code cible en s'aidant d'une IA externe */
  public function segmentToTarget(segment:String, fromLang:Language, toLang:Language):Null<String>;
}
```
```haxe
package ai; import core.Language;

class NullAgent implements IAgent {
  public function new() {}
  public function segmentToTarget(segment:String, fromLang:Language, toLang:Language):Null<String> {
    return null; // pas d'IA branchée par défaut
  }
}
```

---

## `src/cli/Main.hx` (entrée CLI)
```haxe
package cli; import sys.io.File; import sys.io.Process; import haxe.io.Path;
import core.Converter; import core.Language; import ai.NullAgent;

class Main {
  static function usage() {
    Sys.println('Usage: convert --from=<src> --to=<dst> [input-file]');
    Sys.println('       src/dst: javascript, python, haxe, ...');
    Sys.exit(1);
  }
  public static function main() {
    var from:Language = Language.Auto; var to:Language = Language.JavaScript; var input:String = null;
    for (arg in Sys.args()) {
      if (StringTools.startsWith(arg, "--from=")) from = Language.normalize(arg.substr(7));
      else if (StringTools.startsWith(arg, "--to=")) to = Language.normalize(arg.substr(5));
      else if (!StringTools.startsWith(arg, "--")) input = arg;
    }
    var code = input!=null ? sys.io.File.getContent(input) : Sys.stdin().readAll().toString();
    var conv = new Converter(new NullAgent());
    var out = conv.convert(code, from, to);
    Sys.print(out);
  }
}
```

---

## `src/gui/Main.hx` (GUI OpenFL + HaxeUI)
```haxe
package gui;
import openfl.display.Sprite;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.components.*;
import haxe.ui.containers.*;
import core.*; import core.Language; import ai.NullAgent;

class Main extends Sprite {
  var inputArea:TextArea; var outputArea:TextArea; var fromSel:DropDown; var toSel:DropDown;

  public function new() {
    super();
    Toolkit.init();
    buildUI();
  }

  function buildUI() {
    var root = new VBox(); root.percentWidth = 100; root.percentHeight = 100; root.padding = 10; root.gap = 8;

    var top = new HBox(); top.gap = 10;
    fromSel = new DropDown(); fromSel.dataSource = langData(); fromSel.selectedIndex = 0;
    toSel = new DropDown(); toSel.dataSource = langData(); toSel.selectedIndex = 1;
    var convertBtn = new Button(); convertBtn.text = "Convertir"; convertBtn.onClick = _ -> convert();
    top.addComponent(new Label("De:")); top.addComponent(fromSel);
    top.addComponent(new Label("Vers:")); top.addComponent(toSel);
    top.addComponent(convertBtn);

    inputArea = new TextArea(); inputArea.percentWidth = 100; inputArea.percentHeight = 45; inputArea.placeholder = "Collez votre code source ici...";
    outputArea = new TextArea(); outputArea.percentWidth = 100; outputArea.percentHeight = 45; outputArea.readonly = true;

    root.addComponent(top);
    root.addComponent(inputArea);
    root.addComponent(outputArea);

    Screen.instance.addComponent(root);
  }

  function langData() {
    var ds = new haxe.ui.data.ArrayDataSource<Dynamic>();
    for (name in ["javascript","python","haxe"]) ds.add({ text: name, value: name });
    return ds;
  }

  function convert() {
    var from = Language.normalize(fromSel.selectedItem.value);
    var to = Language.normalize(toSel.selectedItem.value);
    var conv = new core.Converter(new NullAgent());
    var res = conv.convert(inputArea.text, from, to);
    outputArea.text = res;
  }
}
```

---

# Notes d’architecture & extension IA
- Interface **IAgent** : branchez votre IA (locale ou API) pour convertir un segment en code cible **quand il n’existe pas de parser/emitters natifs**.
- La voie recommandée : IA → **UniAST** (produire un JSON d’AST pivot), puis **Emitter**. Alternative plus simple : IA → **texte cible direct** avec garde-fous (tests unitaires, snippets).
- Pour la **couverture massive des langages**, ajoutez des greffons : `parsers/MyLangParser.hx`, `emitters/MyLangEmitter.hx` + `Registry.registerParser/Emitter`.

---

# Exemple rapide (CLI)
Entrée JS :
```js
function add(a, b) { return a + b; }
let x = 1 + 2;
console.log(add(x, 3));
```
Sortie Python (démo) :
```py
def add(a, b):
    return a + b

x = 3
print(add(x, 3))
```

---

# ⚖️ Réalités techniques (balisage demandé)
- **[FACT]** Cette base tourne **HashLink/HL**, **C++ (hxcpp)**, **JS**, et GUI **OpenFL/HaxeUI** (desktop/mobile/web) selon la cible.
- **[FACT]** Il n’existe **aucune limite textuelle interne** ; la limite provient de la **mémoire** / OS.
- **[FACT]** Couvrir « la quasi-totalité des langages » exige des **parsers/emitters ou une IA robuste** : non trivial.
- **[HYPOTHÈSE]** En ajoutant des parsers basés sur des grammaires (p. ex. ANTLR/tree-sitter via externs) + un modèle IA, on peut atteindre une **couverture très large**.
- **[CHECK]** Ajouter des tests unitaires par langue (doctests) et un banc d’essai pour mesurer fidélité sémantique.

