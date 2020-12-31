import system
import os
import strutils
import lists

const Punctuators = {'+', '-'}

proc isPunct(c: char): bool =
  c in Punctuators

proc inc(i: var int, n = 1) =
  i = i + n

proc firstNum(str: string): string =
  var s = ""
  var i = 0
  while str[i].isDigit():
    s.add(str[i])
    i.inc()
    if i >= str.len():
      break
  return s

type Source = object
  code: string
  cur: int

# global variable for error messages
var src: Source

proc len(src: Source): int =
  src.code.len()

proc peek(src: Source): char =
  src.code[src.cur]

proc isEnd(src: Source): bool =
  src.cur >= src.len()

proc firstNum(src: Source): string =
  src.code[src.cur..src.len()-1].firstNum()

proc errorAt(src: Source, i: int, e: string) =
  echo src.code
  echo ' '.repeat(i), "^ ", e
  quit(QuitFailure)

type TokenKind = enum
  Punct     # Punctuators
  Num       # Numeric literals
  Eof       # End-of-file markers

type Token = tuple [
  str: string,
  kind: TokenKind,
  pos: int,
  ]

proc equal(t: Token, c: char): bool =
  t.str == $c

proc skip(tn: DoublyLinkedNode[Token], c: char): DoublyLinkedNode[Token] =
  if not tn.value.equal(c):
    src.errorAt(tn.value.pos, "expected: $1" % $c)
  return tn.next

proc getNum(t: Token): string =
  try:
    discard t.str.parseInt()
  except ValueError:
    src.errorAt(t.pos, getCurrentExceptionMsg())
  return t.str

proc tokenize(src: var Source): DoublyLinkedList[Token] =
  var tokenList = initDoublyLinkedList[Token]()

  while not src.isEnd():
    if src.peek.isSpaceAscii():
      src.cur.inc()
      continue

    if src.peek.isDigit():
      let s = src.firstNum()
      let p = src.cur
      src.cur.inc(s.len())
      let token: Token = (str: s, kind: TokenKind.Num, pos: p)
      tokenList.append(token)
      continue

    if src.peek.isPunct():
      let c = src.peek()
      let p = src.cur
      src.cur.inc()
      let token: Token = (str: $c, kind: TokenKind.Punct, pos: p)
      tokenList.append(token)
      continue

    src.errorAt(src.cur, "invalid token")

  let token: Token = (str: "", kind: TokenKind.Eof, pos: src.cur)
  tokenList.append(token)
  return tokenList

when isMainModule:
  if paramCount() != 1:
    quit("invalid number of arguments")

  src = Source(code: $commandLineParams()[0], cur: 0)
  let tokenList = src.tokenize()
  var currentToken = tokenList.head

  echo "  .globl main"
  echo "main:"

  echo "  mov $", currentToken.value.getNum(), ", %rax"

  currentToken = currentToken.next

  while currentToken.value.kind != TokenKind.Eof:
    if currentToken.value.equal('+'):
      currentToken = currentToken.next
      echo "  add $", currentToken.value.getNum ,", %rax"
      currentToken = currentToken.next
      continue

    currentToken = currentToken.skip('-')
    echo "  sub $", currentToken.value.getNum ,", %rax"
    currentToken = currentToken.next
    continue

  echo "  ret"

  quit()
