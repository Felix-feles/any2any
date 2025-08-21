package parsers;

import core.UniAst;
import parsers.ParserError;

class JavaParser implements IParser {
  public function new() {}

  public function parse(code:String):UniAstModule {
    throw new ParserError("Java parsing not implemented");
  }
}
