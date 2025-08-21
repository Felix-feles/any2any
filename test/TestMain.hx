package test;

import utest.Runner;
import utest.ui.Report;

class TestMain {
  static function main() {
    var runner = new Runner();
    runner.addCase(new TestSegmenter());
    runner.addCase(new TestJSParser());
    runner.addCase(new TestPythonEmitter());
    runner.addCase(new TestConverter());
    Report.create(runner);
    runner.run();
  }
}
