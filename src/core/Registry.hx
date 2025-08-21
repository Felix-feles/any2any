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
    return emitters.get(lang);
  }
}
