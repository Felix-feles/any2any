package parsers;

import core.UniAst;
import StringTools;

class JSParser implements IParser {
  public function new() {}

  public function parse(code:String):UniAstModule {
    var lines = code.split("\n");
    var instructions = new Array<UniAstInstruction>();
    var i = 0;
    while (i < lines.length) {
      var line = StringTools.trim(lines[i]);
      if (line == "" || line == "}") {
        i++;
        continue;
      }
      var funcRe = ~/^function\s+([a-zA-Z0-9_]+)\(([^)]*)\)\s*{/;
      if (funcRe.match(line)) {
        var name = funcRe.matched(1);
        var params = funcRe.matched(2).split(",").map(StringTools.trim).filter(function(p) return p != "");
        i++;
        var bodyLines = [];
        while (i < lines.length && lines[i].indexOf("}") < 0) {
          bodyLines.push(lines[i]);
          i++;
        }
        var bodyBlock = { instructions: parseBlock(bodyLines) };
        instructions.push(FunctionDecl(name, params, bodyBlock));
        i++; // skip closing brace
        continue;
      }
      instructions.push(parseInstruction(line));
      i++;
    }
    return { blocks: [ { instructions: instructions } ] };
  }

  function parseBlock(lines:Array<String>):Array<UniAstInstruction> {
    var out = new Array<UniAstInstruction>();
    for (l in lines) {
      var t = StringTools.trim(l);
      if (t == "") continue;
      out.push(parseInstruction(t));
    }
    return out;
  }

  function parseInstruction(line:String):UniAstInstruction {
    var returnRe = ~/^return\s+(.+)/;
    if (returnRe.match(line)) {
      var expr = parseExpr(returnRe.matched(1));
      return Return(expr);
    }
    return Expr(parseExpr(line));
  }

  function parseExpr(text:String):UniAstExpr {
    text = ~/;\s*$/.replace(StringTools.trim(text), "");
    var callRe = ~/^([a-zA-Z0-9_\.]+)\((.*)\)$/;
    if (callRe.match(text)) {
      var name = callRe.matched(1);
      var argsText = StringTools.trim(callRe.matched(2));
      var args = (argsText == "") ? [] : argsText.split(",").map(function(a) return parseExpr(StringTools.trim(a)));
      return CallExpr(name, args);
    }
    if (text.length >= 2 && StringTools.startsWith(text, "\"") && StringTools.endsWith(text, "\"")) {
      return StringLiteral(text.substr(1, text.length - 2));
    }
    return StringLiteral(text);
  }
}
