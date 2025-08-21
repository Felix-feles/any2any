package emitters;

import core.UniAst;

interface IEmitter {
  public function emit(ast:UniAstModule):String;
}
