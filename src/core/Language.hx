package core;

enum abstract Language(String) {
  var Auto = "auto";
  var JavaScript = "javascript";
  var Python = "python";
  var Haxe = "haxe";
  var CSharp = "csharp";
  var Java = "java";
  var Go = "go";

  public static function normalize(id:String):Language {
    switch(id.toLowerCase()) {
      case "javascript" | "js": return JavaScript;
      case "python" | "py": return Python;
      case "haxe": return Haxe;
      case "csharp" | "c#" | "cs": return CSharp;
      case "java": return Java;
      case "go" | "golang": return Go;
      default: return Auto;
    }
  }
}
