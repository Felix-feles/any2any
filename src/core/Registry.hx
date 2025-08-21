package core;

import parsers.IParser;
import emitters.IEmitter;
import parsers.JSParser;
import emitters.PythonEmitter;

class Registry {
  static var parsers:Map<Language, IParser> = new Map();
  static var emitters:Map<Language, IEmitter> = new Map();
  static var initialized:Bool = false;

  static function ensureDefaults() {
    if (initialized) return;
    initialized = true;
    registerParser(Language.JavaScript, new JSParser());
    registerEmitter(Language.Python, new PythonEmitter());
  }

  public static function registerParser(lang:Language, parser:IParser):Void {
    parsers.set(lang, parser);
  }

  public static function getParser(lang:Language):Null<IParser> {
    ensureDefaults();
    return parsers.get(lang);
  }

  public static function registerEmitter(lang:Language, emitter:IEmitter):Void {
    emitters.set(lang, emitter);
  }

  public static function getEmitter(lang:Language):Null<IEmitter> {
    ensureDefaults();
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
