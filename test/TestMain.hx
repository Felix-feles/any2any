package test;

import parsers.JSParser;
import parsers.ParserError;

class TestMain {
  static function main() {
    var parser = new JSParser();
    var ast = parser.parse('function hi(name){ return call("x"); }');
    if (ast.blocks.length != 1 || ast.blocks[0].instructions.length != 1) {
      throw 'Unexpected AST';
    }
    var failed = false;
    try {
      parser.parse('function {');
    } catch (e:ParserError) {
      failed = true;
    }
    if (!failed) throw 'Expected parse error';
    trace('tests passed');
  }
}
