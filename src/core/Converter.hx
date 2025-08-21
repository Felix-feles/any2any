package core;

import ai.IAgent;
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
        try {
          var ast = parser.parse(chunk);
          piece = emitter.emit(ast);
        } catch (e:Dynamic) {
          piece = agent.convertChunk(chunk, cast src, cast to);
        }
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

}
