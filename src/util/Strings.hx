package util;

class Strings {
  public static function normalizeNewlines(s:String):String {
    return s.split("\r\n").join("\n");
  }
}
