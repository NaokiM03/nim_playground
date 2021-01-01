import system
import os

import tokenizer
import parser
import codegen

proc main() =
  var currentToken = Source(code: $commandLineParams()[0]).tokenize().head
  currentToken.parse().codeGen()


when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments")

  main()
  quit()
