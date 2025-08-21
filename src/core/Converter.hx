package core;

import ai.IAgent;

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
      } else {
        buf.add(agent.convertChunk(chunk, cast src, cast to));
      }
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
