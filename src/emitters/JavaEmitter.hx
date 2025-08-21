package emitters;

import core.UniAst;
import emitters.EmitterError;

class JavaEmitter implements IEmitter {
  public function new() {}

  public function emit(ast:UniAstModule):String {
    throw new EmitterError("Java emitting not implemented");
  }
}
