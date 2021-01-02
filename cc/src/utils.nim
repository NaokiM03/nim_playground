import strutils
import sequtils
import sugar

proc slice(s: string, idx: int = 0, rng: int = 1): string =
  s[idx..idx+rng-1]

proc first(s: string): char =
  s[0]

const Punctuators =
  {
    '!', '"', '#', '$', '%', '&', '\'', '(', ')',
    '*', '+', ',', '-', '.', '/',
    ':', ';', '<', '=', '>', '?',
    '@',
    '[', '\\', ']', '^', '_',
    '`',
    '{', '|', '}'
  }

proc isSingleCharsPunct(s: string): bool =
  s.first() in Punctuators

const TwoCharsPunctuators =
  [
    "==", "!=", "<=", ">="
  ]

proc isTwoCharsPunct(s: string): bool =
  TwoCharsPunctuators.any(x => x == s)

proc isPunct*(c: char): bool =
  c in Punctuators

proc firstNum*(str: string): string =
  var s = ""
  var i = 0
  while str[i].isDigit():
    s.add(str[i])
    i.inc()
    if i >= str.len():
      break
  return s

proc firstPunct*(str: string): string =
  if not str.first().isPunct():
    raise
  if str.len() >= 2 and str.slice(0, 2).isTwoCharsPunct():
    return str.slice(0, 2)
  if str.slice().isSingleCharsPunct():
    return str.slice()

proc inc*(i: var int, n: int = 1) =
  i = i + n

proc dec*(i: var int, n: int = 1) =
  i = i - n
