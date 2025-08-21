package parsers;

import core.UniAst;
import parsers.ParserError;

class CSharpParser implements IParser {
  public function new() {}

  public function parse(code:String):UniAstModule {
    throw new ParserError("C# parsing not implemented");
  }
}
