package test;

import utest.Assert;
import utest.Test;
import emitters.PythonEmitter;
import core.UniAst;

class TestPythonEmitter extends Test {
  public function new() {
    super();
  }

  function testEmitSimpleFunction():Void {
    var ast:UniAstModule = {
      blocks: [{
        instructions: [
          FunctionDecl('hi', ['name'], {
            instructions: [
              Expr(CallExpr('console.log', [Identifier('name')]))
            ]
          })
        ]
      }]
    };
    var emitter = new PythonEmitter();
    var code = emitter.emit(ast);
    var expected = 'def hi(name):\n  print(name)';
    Assert.equals(expected, code);
  }
}
