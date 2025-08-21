package cli;

import core.Converter;
import core.Language;
import ai.NullAgent;

class Main {
#if sys
  static function usage(?code:Int = 0) {
    Sys.println('Usage: convert --from=<src> --to=<dst> [--out=FILE] [input-file]');
    Sys.exit(code);
  }
#end

  public static function parseArgs(args:Array<String>):{
    var from:Null<Language>;
    var to:Null<Language>;
    var input:Null<String>;
    var output:Null<String>;
    var help:Bool;
  } {
    var from:Null<Language> = null;
    var to:Null<Language> = null;
    var input:Null<String> = null;
    var output:Null<String> = null;
    var help = false;

    for (arg in args) {
      if (arg == "--help" || arg == "-h") help = true;
      else if (StringTools.startsWith(arg, "--from=")) from = Language.normalize(arg.substr(7));
      else if (StringTools.startsWith(arg, "--to=")) to = Language.normalize(arg.substr(5));
      else if (StringTools.startsWith(arg, "--out=")) output = arg.substr(6);
      else if (!StringTools.startsWith(arg, "--")) input = arg;
    }

    return {
      from: from,
      to: to,
      input: input,
      output: output,
      help: help
    };
  }

#if sys
  public static function main() {
    var opts = parseArgs(Sys.args());
    if (opts.help) usage(0);
    if (opts.from == null || opts.to == null) usage(1);

    var code = (opts.input != null) ? sys.io.File.getContent(opts.input) : Sys.stdin().readAll().toString();
    var conv = new Converter(new NullAgent());
    var out = conv.convert(code, opts.from, opts.to);

    if (opts.output != null) sys.io.File.saveContent(opts.output, out);
    else Sys.print(out);
  }
#end
}
