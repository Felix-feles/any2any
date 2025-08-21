package emitters;

import core.UniAst;
import emitters.EmitterError;

class GoEmitter implements IEmitter {
  public function new() {}

  public function emit(ast:UniAstModule):String {
    throw new EmitterError("Go emitting not implemented");
  }
}
