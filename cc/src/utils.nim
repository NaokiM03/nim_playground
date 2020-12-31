import strutils

const Punctuators = {'+', '-'}

proc isPunct*(c: char): bool =
  c in Punctuators

proc inc*(i: var int, n = 1) =
  i = i + n

proc firstNum*(str: string): string =
  var s = ""
  var i = 0
  while str[i].isDigit():
    s.add(str[i])
    i.inc()
    if i >= str.len():
      break
  return s