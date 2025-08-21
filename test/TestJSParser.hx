package test;

import utest.Assert;
import utest.Test;
import parsers.JSParser;
import parsers.ParserError;
import core.UniAst;

class TestJSParser extends Test {
  public function new() {
    super();
  }

  function testParseFunction():Void {
    var parser = new JSParser();
    var ast = parser.parse('function hi(name){ return call("x"); }');
    Assert.equals(1, ast.blocks.length);
    var block = ast.blocks[0];
    Assert.equals(1, block.instructions.length);
    switch (block.instructions[0]) {
      case FunctionDecl(name, params, body):
        Assert.equals('hi', name);
        Assert.equals(1, params.length);
        Assert.equals('name', params[0]);
        Assert.equals(1, body.instructions.length);
      default:
        Assert.fail("Expected FunctionDecl");
    }
  }

  function testParseError():Void {
    var parser = new JSParser();
    var thrown = false;
    try parser.parse('function {') catch (e:ParserError) thrown = true;
    Assert.isTrue(thrown);
  }
}
