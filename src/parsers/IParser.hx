package parsers;

import core.UniAst;

interface IParser {
  public function parse(code:String):UniAstModule;
}
