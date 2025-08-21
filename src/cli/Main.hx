package cli;

import core.Converter;
import core.Language;
import ai.NullAgent;

class Main {
  static function usage() {
    Sys.println('Usage: convert --from=<src> --to=<dst> [input-file]');
    Sys.exit(1);
  }

  public static function main() {
    var from:Language = Language.Auto;
    var to:Language = Language.Python;
    var input:String = null;

    for (arg in Sys.args()) {
      if (StringTools.startsWith(arg, "--from=")) from = Language.normalize(arg.substr(7));
      else if (StringTools.startsWith(arg, "--to=")) to = Language.normalize(arg.substr(5));
      else if (!StringTools.startsWith(arg, "--")) input = arg;
    }

    if (input == null) {
      usage();
      return;
    }

    var code = sys.io.File.getContent(input);
    var conv = new Converter(new NullAgent());
    var out = conv.convert(code, from, to);
    Sys.print(out);
  }
}
