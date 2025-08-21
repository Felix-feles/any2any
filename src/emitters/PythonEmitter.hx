package emitters;

import core.UniAst;
import StringTools;

class PythonEmitter implements IEmitter {
  public function new() {}

  public function emit(ast:UniAstModule):String {
    var out:Array<String> = [];
    for (block in ast.blocks) {
      for (inst in block.instructions) {
        emitInstruction(inst, out, 0);
      }
    }
    return out.join("\n");
  }

  function emitInstruction(inst:UniAstInstruction, out:Array<String>, indent:Int):Void {
    var pad = StringTools.lpad("", " ", indent);
    switch (inst) {
      case FunctionDecl(name, params, body):
        out.push(pad + "def " + name + "(" + params.join(", ") + "):");
        for (sub in body.instructions) {
          emitInstruction(sub, out, indent + 2);
        }
      case Expr(expr):
        out.push(pad + emitExpr(expr));
      case Return(expr):
        out.push(pad + "return " + emitExpr(expr));
    }
  }

  function emitExpr(e:UniAstExpr):String {
    return switch (e) {
      case StringLiteral(v): '"' + v + '"';
      case Identifier(name): name;
      case NumberLiteral(v): v;
      case CallExpr(name, args):
        var pyName = (name == "console.log") ? "print" : name;
        pyName + "(" + args.map(emitExpr).join(", ") + ")";
    }
  }
}
