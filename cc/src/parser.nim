import lists
import strutils

import tokenizer

type
  NodeKind* = enum
    NkAdd # +
    NkSub # -
    NkMul # *
    NkDiv # /
    NkNeg # unary -
    NkNum # Integer
  Node* = ref object
    case kind*: NodeKind
    of NkNum: value*: int
    of NkAdd, NkSub, NkMul, NkDiv, NkNeg: lhs*, rhs*: Node

proc newNode(kind: NodeKind): Node =
  Node(kind: kind)

proc newUnary(kind: NodeKind, expr: Node): Node =
  var n = kind.newNode()
  n.lhs = expr
  return n

proc newBinary(kind: NodeKind, lhs: Node, rhs: Node): Node =
  var n = kind.newNode()
  n.lhs = lhs
  n.rhs = rhs
  return n

proc newNum(i: int): Node =
  var n = NkNum.newNode()
  n.value = i
  return n

proc expr(tn: var DoublyLinkedNode[Token]): Node
proc mul(tn: var DoublyLinkedNode[Token]): Node
proc unaray(tn: var DoublyLinkedNode[Token]): Node
proc primary(tn: var DoublyLinkedNode[Token]): Node

proc expr(tn: var DoublyLinkedNode[Token]): Node =
  var n = mul(tn)

  while true:
    if tn.value.equal('+'):
      tn = tn.next
      n = NkAdd.newBinary(n, tn.mul())
      continue

    if tn.value.equal('-'):
      tn = tn.next
      n = NkSub.newBinary(n, tn.mul())
      continue

    return n

proc mul(tn: var DoublyLinkedNode[Token]): Node =
  var n = tn.unaray()

  while true:
    if tn.value.equal('*'):
      tn = tn.next
      n = NkMul.newBinary(n, tn.unaray())
      continue

    if tn.value.equal('/'):
      tn = tn.next
      n = NkDiv.newBinary(n, tn.unaray())
      continue

    return n

proc unaray(tn: var DoublyLinkedNode[Token]): Node =
  if tn.value.equal('+'):
    tn = tn.next
    return tn.unaray()

  if tn.value.equal('-'):
    tn = tn.next
    return NkNeg.newUnary(tn.unaray())

  return tn.primary()

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
