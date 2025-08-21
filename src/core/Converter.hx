package core;

import ai.IAgent;
import StringTools;
import core.Registry;
import core.Segmenter;

class Converter {
  var agent:IAgent;
  public function new(agent:IAgent) {
    this.agent = agent;
  }

  /**
   * Convert source code from one language to another.
   */
  public function convert(code:String, from:Language, to:Language):String {
    var src = (from == Language.Auto) ? detectLanguage(code) : from;
    if (src == to) return code;

    Registry.ensureDefaults();
    var parser = Registry.getParser(src);
    var emitter = Registry.getEmitter(to);
    var buf = new StringBuf();

    for (chunk in Segmenter.chunk(code)) {
      var piece:String;
      if (parser != null && emitter != null) {
        var ast = parser.parse(chunk);
        piece = emitter.emit(ast);
      } else if (src == Language.JavaScript && to == Language.Python) {
        piece = jsToPython(chunk);
      } else {
        piece = agent.convertChunk(chunk, cast src, cast to);
      }
      buf.add(piece);
      buf.add("\n");
    }

    return buf.toString();
  }

  function detectLanguage(code:String):Language {
    if (~/^\s*def /m.match(code) || ~/^\s*print\(/m.match(code)) return Language.Python;
    if (~/^\s*function /m.match(code) || ~/console\.log/.match(code)) return Language.JavaScript;
    return Language.Auto;
  }

  function jsToPython(code:String):String {
    var lines = code.split("\n");
    var out:Array<String> = [];
    for (line in lines) {
      var l = StringTools.replace(line, "console.log", "print");
      l = ~/;\s*$/.replace(l, "");
      if (~/function\s+([a-zA-Z0-9_]+)\(([^)]*)\)\s*{/.match(l)) {
        l = ~/function\s+([a-zA-Z0-9_]+)\(([^)]*)\)\s*{/.replace(l, "def $1($2):");
      }
      if (l.indexOf("}") >= 0) continue;
      out.push(l);
    }
    return out.join("\n");
  }
}
