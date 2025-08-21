package ai;

class NullAgent implements IAgent {
  public function new() {}
  public function convertChunk(code:String, from:String, to:String):String {
    return code;
  }
}
