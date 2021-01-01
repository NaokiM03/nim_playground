import strutils
import lists

import utils

type Source* = ref object
  code*: string
  cur: int

proc len(src: Source): int =
  src.code.len()

proc peek(src: Source): char =
  src.code[src.cur]

proc isEnd(src: Source): bool =
  src.cur >= src.len()

proc firstNum(src: Source): string =
  src.code[src.cur..src.len()-1].firstNum()

proc errorAt(src: Source, e: string) =
  echo src.code
  echo ' '.repeat(src.cur), "^ ", e
  quit(QuitFailure)

type TokenKind* = enum
  TkPunct # Punctuators
  TkNum   # Numeric literals
  TkEof   # End-of-file markers

type Token* = tuple [
  str: string,
  kind: TokenKind,
  code: string,
  pos: int,
  ]

proc errorAt*(t: Token, e: string) =
  echo t.code
  echo ' '.repeat(t.pos), "^ ", e
  quit(QuitFailure)

proc equal*(t: Token, c: char): bool =
  t.str == $c

proc isNum*(t: Token): bool =
  t.kind == TkNum

proc isEof*(t: Token): bool =
  t.kind == TkEof

proc skip*(tn: DoublyLinkedNode[Token], c: char): DoublyLinkedNode[Token] =
  if not tn.value.equal(c):
    tn.value.errorAt("expected: $1" % $c)
  return tn.next

proc getNum*(t: Token): string =
  try:
    discard t.str.parseInt()
  except ValueError:
    t.errorAt(getCurrentExceptionMsg())
  return t.str

proc tokenize*(src: Source): DoublyLinkedList[Token] =
  var tokenList = initDoublyLinkedList[Token]()

  while not src.isEnd():
    if src.peek.isSpaceAscii():
      src.cur.inc()
      continue

    if src.peek.isDigit():
      let s = src.firstNum()
      let p = src.cur
      src.cur.inc(s.len())
      let token: Token = (str: s, kind: TkNum, code: src.code, pos: p)
      tokenList.append(token)
      continue

    if src.peek.isPunct():
      let c = src.peek()
      let p = src.cur
      src.cur.inc()
      let token: Token = (str: $c, kind: TkPunct, code: src.code, pos: p)
      tokenList.append(token)
      continue

    src.errorAt("invalid token")

  let token: Token = (str: "", kind: TkEof, code: src.code, pos: src.cur)
  tokenList.append(token)
  return tokenList
