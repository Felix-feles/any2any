package core;

enum abstract Language(String) {
  var Auto = "auto";
  var JavaScript = "javascript";
  var Python = "python";
  var Haxe = "haxe";

  public static function normalize(id:String):Language {
    switch(id.toLowerCase()) {
      case "javascript" | "js": return JavaScript;
      case "python" | "py": return Python;
      case "haxe": return Haxe;
      default: return Auto;
    }
  }
}
