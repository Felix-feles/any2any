package test;

import utest.Assert;
import utest.Test;
import core.Segmenter;

class TestSegmenter extends Test {
  public function new() {
    super();
  }

  function testChunkSplitsLargeInput():Void {
    var lines = [for (i in 0...50) 'line' + i];
    var code = lines.join("\n");
    var chunks = Segmenter.chunk(code, 30);
    Assert.isTrue(chunks.length > 1);
    var reconstructed = chunks.join("");
    Assert.equals(code + "\n", reconstructed);
  }
}
