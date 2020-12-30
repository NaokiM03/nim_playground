import system
import os
import strutils

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

type Source = object
  code: string
  cur: int

proc len(src: Source): int =
  src.code.len

proc peek(src: Source): char =
  src.code[src.cur]

proc isEnd(src: Source): bool =
  src.cur >= src.len()

proc firstNumStr(src: Source): string =
  src.code[src.cur..src.len-1].firstNumStr

type TokenKind = enum
  Num

type Token = tuple [
  str: string,
  kind: TokenKind,
  pos: int,
  ]

proc getKind(c: char): TokenKind =
  if c.isDigit:
    return TokenKind.Num

proc getNextToken(src: var Source): Token =
  var s = ""
  var p = src.cur

  case src.peek.getKind
  of TokenKind.Num:
    s = src.firstNumStr

  src.cur.inc(s.len)
  return (str: s, kind: TokenKind.Num, pos: p)

when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments\n", 1)

  echo "  .globl main"
  echo "main:"

  var src = Source(code: $commandLineParams()[0], cur: 0)

  echo "  mov $", src.getNextToken.str, ", %rax"

  while not src.isEnd:
    if src.peek == '+':
      src.cur.inc
      var s = src.firstNumStr
      src.cur.inc(s.len)
      echo "  add $", s ,", %rax"
      continue

    if src.peek == '-':
      src.cur.inc
      var s = src.firstNumStr
      src.cur.inc(s.len)
      echo "  sub $", s ,", %rax"
      continue

    quit("unexpected charactor: $1" % $src.peek, 1)

  echo "  ret"

  quit(0)
