package core;

import core.Language;

typedef Parser = {
  function parseSegment(text:String):Dynamic;
}

typedef Emitter = {
  function emit(ast:Dynamic):String;
}

class Registry {
  static var parsers:Map<Language, Parser> = new Map();
  static var emitters:Map<Language, Emitter> = new Map();

  public static function initDefaults():Void {
    if (!parsers.exists(Language.JavaScript)) {
      parsers.set(Language.JavaScript, {
        parseSegment: function(text:String):Dynamic {
          return text;
        }
      });
    }
    if (!emitters.exists(Language.Python)) {
      emitters.set(Language.Python, {
        emit: function(ast:Dynamic):String {
          return Std.string(ast);
        }
      });
    }
  }

  public static function getParser(lang:Language):Parser {
    return parsers.get(lang);
  }

  public static function getEmitter(lang:Language):Emitter {
    return emitters.get(lang);
  }
}
