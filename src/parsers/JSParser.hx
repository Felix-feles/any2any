package parsers;

import core.UniAst;
import parsers.TreeSitter.TsParser;
import parsers.TreeSitter.TsNode;
import parsers.TreeSitter.TsLanguage;
import parsers.ParserError;

class JSParser implements IParser {
  var parser:TsParser;

  public function new() {
    parser = new TsParser();
    parser.setLanguage(TsLanguage);
  }

  public function parse(code:String):UniAstModule {
    var tree = parser.parse(code);
    if (tree.rootNode.hasError) {
      throw new ParserError("Parse error");
    }
    var instructions = [for (child in tree.rootNode.namedChildren) mapStatement(child)];
    return { blocks: [ { instructions: instructions } ] };
  }

  function mapStatement(node:TsNode):UniAstInstruction {
    return switch node.type {
      case "function_declaration":
        var name = node.namedChildren[0].text;
        var paramsNode = node.namedChildren[1];
        var params = [for (p in paramsNode.namedChildren) p.text];
        var bodyNode = node.namedChildren[2];
        var bodyInstr = [for (c in bodyNode.namedChildren) mapStatement(c)];
        FunctionDecl(name, params, { instructions: bodyInstr });
      case "expression_statement":
        Expr(mapExpr(node.namedChildren[0]));
      case "return_statement":
        Return(mapExpr(node.namedChildren[0]));
      default:
        throw new ParserError("Unsupported node: " + node.type);
    }
  }

  function mapExpr(node:TsNode):UniAstExpr {
    return switch node.type {
      case "call_expression":
        var name = node.namedChildren[0].text;
        var argsNode = node.namedChildren[1];
        var args = [for (a in argsNode.namedChildren) mapExpr(a)];
        CallExpr(name, args);
      case "string":
        var t = node.text;
        StringLiteral(t.substr(1, t.length - 2));
      case "identifier":
        Identifier(node.text);
      case "number":
        NumberLiteral(node.text);
      default:
        StringLiteral(node.text);
    }
  }
}
