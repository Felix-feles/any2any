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

  public function convert(code:String, from:Language, to:Language):String {
    var src = from == Language.Auto ? detectLanguage(code) : from;
    if (src == to) return code;
    var parser = Registry.getParser(src);
    var emitter = Registry.getEmitter(to);
    var buf = new StringBuf();
    for (chunk in Segmenter.chunk(code)) {
      if (parser != null && emitter != null) {
        var ast = parser.parse(chunk);
        buf.add(emitter.emit(ast));
      } else if (src == Language.JavaScript && to == Language.Python) {
        buf.add(jsToPython(chunk));
      } else {
        buf.add(agent.convertChunk(chunk, cast src, cast to));
      }
      buf.add("\n");
    }
    return buf.toString();

    Registry.initDefaults();
    var parser = Registry.getParser(src);
    var emitter = Registry.getEmitter(to);
    if (parser != null && emitter != null) {
      try {
        var segments = Segmenter.split(code);
        var buf = new StringBuf();
        for (seg in segments) {
          var ast = parser.parseSegment(seg.text);
          buf.add(emitter.emit(ast));
        }
        return buf.toString();
      } catch (e:Dynamic) {}
    }

    if (src == Language.JavaScript && to == Language.Python) {
      return jsToPython(code);
    }

    return agent.convertChunk(code, cast src, cast to);
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
