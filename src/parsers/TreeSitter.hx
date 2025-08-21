package parsers;

@:jsRequire("tree-sitter")
extern class TsParser {
  function new():Void;
  function setLanguage(lang:Dynamic):Void;
  function parse(code:String):TsTree;
}

extern class TsTree {
  var rootNode:TsNode;
}

extern class TsNode {
  var type:String;
  var text:String;
  var namedChildren:Array<TsNode>;
  var hasError:Bool;
}

@:jsRequire("tree-sitter-javascript")
extern class TsLanguage {}
