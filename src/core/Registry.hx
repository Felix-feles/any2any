package core;

import parsers.IParser;
import parsers.JSParser;
import parsers.CSharpParser;
import parsers.JavaParser;
import parsers.GoParser;
import emitters.IEmitter;
import emitters.PythonEmitter;
import emitters.CSharpEmitter;
import emitters.JavaEmitter;
import emitters.GoEmitter;

/**
 * Global registry for parser and emitter implementations.
 */
class Registry {
  static var parsers:Map<Language, IParser> = new Map();
  static var emitters:Map<Language, IEmitter> = new Map();
  static var initialized:Bool = false;

  /**
   * Ensure demo parsers and emitters are registered.
   */
  public static function ensureDefaults():Void {
    if (initialized) return;
    initialized = true;
    registerParser(Language.JavaScript, new JSParser());
    registerEmitter(Language.Python, new PythonEmitter());

    registerParser(Language.CSharp, new CSharpParser());
    registerEmitter(Language.CSharp, new CSharpEmitter());

    registerParser(Language.Java, new JavaParser());
    registerEmitter(Language.Java, new JavaEmitter());

    registerParser(Language.Go, new GoParser());
    registerEmitter(Language.Go, new GoEmitter());
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

