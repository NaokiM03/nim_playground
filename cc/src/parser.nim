import lists
import strutils

import tokenizer

type
  NodeKind* = enum
    Add # +
    Sub # -
    Mul # *
    Div # /
    Num # Integer
  Node* = ref object
    case kind*: NodeKind
    of Num: value*: int
    of Add, Sub, Mul, Div: lhs*, rhs*: Node

proc newNode(kind: NodeKind): Node =
  Node(kind: kind)

proc newBinary(kind: NodeKind, lhs: Node, rhs: Node): Node =
  var n = kind.newNode()
  n.lhs = lhs
  n.rhs = rhs
  return n
proc newNum(i: int): Node =
  var n = Num.newNode()
  n.value = i
  return n

proc expr(tn: var DoublyLinkedNode[Token]): Node
proc mul(tn: var DoublyLinkedNode[Token]): Node
proc primary(tn: var DoublyLinkedNode[Token]): Node

proc expr(tn: var DoublyLinkedNode[Token]): Node =
  var n = mul(tn)

  while true:
    if tn.value.equal('+'):
      tn = tn.next
      n = Add.newBinary(n, tn.mul())
      continue

    if tn.value.equal('-'):
      tn = tn.next
      n = Sub.newBinary(n, tn.mul())
      continue

    return n

proc mul(tn: var DoublyLinkedNode[Token]): Node =
  var n = primary(tn)

  while true:
    if tn.value.equal('*'):
      tn = tn.next
      n = Mul.newBinary(n, tn.primary())
      continue

    if tn.value.equal('/'):
      tn = tn.next
      n = Div.newBinary(n, tn.primary())
      continue

    return n

proc primary(tn: var DoublyLinkedNode[Token]): Node =
  if tn.value.equal('('):
    tn = tn.next
    let n = tn.expr()
    tn = tn.skip(')')
    return n

  if tn.value.isNum():
    let n = tn.value.getNum().parseInt().newNum()
    tn = tn.next
    return n

  tn.value.errorAt("expected an expression")

proc parse*(tn: var DoublyLinkedNode[Token]): Node =
  let n = tn.expr

  if not tn.value.isEof():
    quit("extra token")

  return n
