import system
import os

when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments\n", 1)

  echo "  .globl main"
  echo "main:"
  echo "  mov $", $commandLineParams()[0], ", %rax"
  echo "  ret"

  quit(0)
