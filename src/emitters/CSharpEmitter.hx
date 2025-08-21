package emitters;

import core.UniAst;
import emitters.EmitterError;

class CSharpEmitter implements IEmitter {
  public function new() {}

  public function emit(ast:UniAstModule):String {
    throw new EmitterError("C# emitting not implemented");
  }
}
