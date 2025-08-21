package core;

class Segmenter {
  public static function chunk(code:String, approxSize:Int = 4000):Array<String> {
    if (code.length <= approxSize) return [code];
    var lines = code.split("\n");
    var chunks:Array<String> = [];
    var buf = new StringBuf();
    var size = 0;
    for (line in lines) {
      buf.add(line);
      buf.add("\n");
      size += line.length + 1;
      if (size >= approxSize) {
        chunks.push(buf.toString());
        buf = new StringBuf();
        size = 0;
      }
    }
    if (buf.length > 0) chunks.push(buf.toString());
    return chunks;
  public static function split(code:String):Array<{text:String}> {
    return [{ text: code }];
  }
}
