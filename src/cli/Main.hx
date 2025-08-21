package cli;

import core.Converter;
import core.Language;
import ai.NullAgent;

class Main {
  static function usage() {
    Sys.println('Usage: convert --from=<src> --to=<dst> [--out=FILE] [input-file]');
    Sys.exit(1);
  }

  public static function main() {
    var from:Language = Language.Auto;
    var to:Language = Language.Python;
    var input:Null<String> = null;
    var output:Null<String> = null;

    for (arg in Sys.args()) {
      if (StringTools.startsWith(arg, "--from=")) from = Language.normalize(arg.substr(7));
      else if (StringTools.startsWith(arg, "--to=")) to = Language.normalize(arg.substr(5));
      else if (StringTools.startsWith(arg, "--out=")) output = arg.substr(6);
      else if (!StringTools.startsWith(arg, "--")) input = arg;
    }

    var code = (input != null) ? sys.io.File.getContent(input) : Sys.stdin().readAll().toString();
    var conv = new Converter(new NullAgent());
    var out = conv.convert(code, from, to);

    if (output != null) sys.io.File.saveContent(output, out);
    else Sys.print(out);
  }
}
