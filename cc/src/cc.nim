import system
import os

import codegen

when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments")

  Source(code: $commandLineParams()[0])
    .tokenize()
    .codegen()

  quit()
