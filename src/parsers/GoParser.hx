package parsers;

import core.UniAst;
import parsers.ParserError;

class GoParser implements IParser {
  public function new() {}

  public function parse(code:String):UniAstModule {
    throw new ParserError("Go parsing not implemented");
  }
}
