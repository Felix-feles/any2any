package emitters;

import core.UniAst;
import StringTools;

class PythonEmitter implements IEmitter {
  public function new() {}

  public function emit(ast:UniAstModule):String {
    var out:Array<String> = [];
    for (l in ast.lines) {
      var line = StringTools.replace(l, "console.log", "print");
      line = ~/;\s*$/.replace(line, "");
      if (~/function\s+([a-zA-Z0-9_]+)\(([^)]*)\)\s*{/.match(line)) {
        line = ~/function\s+([a-zA-Z0-9_]+)\(([^)]*)\)\s*{/.replace(line, "def $1($2):");
      }
      if (line.indexOf("}") >= 0) continue;
      out.push(line);
    }
    return out.join("\n");
  }
}
