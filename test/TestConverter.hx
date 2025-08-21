package test;

import utest.Assert;
import utest.Test;
import core.Converter;
import core.Language;
import ai.IAgent;

class MockAgent implements IAgent {
  public var called:Bool = false;
  public function new() {}
  public function convertChunk(code:String, from:String, to:String):String {
    called = true;
    return 'agent';
  }
}

class TestConverter extends Test {
  public function new() {
    super();
  }

  function testConvertUsesParsers():Void {
    var agent = new MockAgent();
    var conv = new Converter(agent);
    var output = conv.convert('function hi(name){ console.log(name); }', Language.JavaScript, Language.Python);
    var expected = 'def hi(name):\n  print(name)\n';
    Assert.equals(expected, output);
    Assert.isFalse(agent.called);
  }
}
