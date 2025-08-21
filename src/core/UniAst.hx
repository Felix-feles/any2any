package core;

/**
 * Root of the universal abstract syntax tree.
 * A module is composed of one or more blocks.
 */
typedef UniAstModule = {
  /** Blocks contained in the module. */
  var blocks:Array<UniAstBlock>;
}

/**
 * A block groups a sequence of instructions.
 */
typedef UniAstBlock = {
  /** Instructions that appear in the block. */
  var instructions:Array<UniAstInstruction>;
}

/**
 * Represents a single instruction of the language.
 */
enum UniAstInstruction {
  /** Declaration of a function with its name, parameters and body. */
  FunctionDecl(name:String, params:Array<String>, body:UniAstBlock);
  /** An instruction consisting solely of an expression. */
  Expr(expr:UniAstExpr);
  /** Return statement returning the given expression. */
  Return(expr:UniAstExpr);
}

/**
 * Different kinds of expressions.
 */
enum UniAstExpr {
  /** String literal value. */
  StringLiteral(value:String);
  /** Identifier usage. */
  Identifier(name:String);
  /** Numeric literal value. */
  NumberLiteral(value:String);
  /** Function call with a name and arguments. */
  CallExpr(name:String, args:Array<UniAstExpr>);
}

