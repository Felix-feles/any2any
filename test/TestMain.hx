package test;

import parsers.JSParser;
import parsers.ParserError;
import cli.Main;
import core.Language;

class TestMain {
  static function testParser() {
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
  }

  static function testCliArgs() {
    var opts = Main.parseArgs(["--from=js", "--to=python", "input.txt"]);
    if (opts.from != Language.JavaScript) throw 'from not parsed';
    if (opts.to != Language.Python) throw 'to not parsed';
    if (opts.input != "input.txt") throw 'input not parsed';
    var helpOpts = Main.parseArgs(["-h"]);
    if (!helpOpts.help) throw 'help flag not detected';
    var missing = Main.parseArgs(["--from=js"]);
    if (missing.to != null) throw 'missing to not detected';
  }

  static function main() {
    testParser();
    testCliArgs();
    trace('tests passed');
  }
}
