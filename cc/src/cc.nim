import system
import os

proc inc(i: var int, n = 1) =
  i = i + n

proc firstNumStr(str: string): string =
  var s = ""
  var i = 0
  while str[i].isDigit:
    s.add(str[i])
    i.inc
    if i >= str.len:
      break
  return s

when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments\n", 1)

  echo "  .globl main"
  echo "main:"
  echo "  mov $", $commandLineParams()[0], ", %rax"
  echo "  ret"

  quit(0)
