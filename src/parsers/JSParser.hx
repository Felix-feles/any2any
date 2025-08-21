package parsers;

import core.UniAst;

class JSParser implements IParser {
  public function new() {}

  public function parse(code:String):UniAstModule {
    return { lines: code.split("\n") };
  }
}
