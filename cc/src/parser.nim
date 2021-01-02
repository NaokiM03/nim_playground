import lists
import strutils

import tokenizer

type
  NodeKind* = enum
    NkAdd       # +
    NkSub       # -
    NkMul       # *
    NkDiv       # /
    NkNeg       # unary -
    NkEq        # ==
    NkNe        # !=
    NkLt        # <
    NkLe        # <=
    NkExprStmt  # Expression statement
    NkNum       # Integer
  Node* = ref object
    case kind*: NodeKind
    of NkNum:
      value*: int
    of NkAdd, NkSub, NkMul, NkDiv, NkNeg,
        NkEq, NkNe, NkLt, NkLe,
        NkExprStmt:
      lhs*, rhs*: Node

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
proc exprStmt(tn: var DoublyLinkedNode[Token]): Node
proc equality(tn: var DoublyLinkedNode[Token]): Node
proc relational(tn: var DoublyLinkedNode[Token]): Node
proc add(tn: var DoublyLinkedNode[Token]): Node
proc mul(tn: var DoublyLinkedNode[Token]): Node
proc unaray(tn: var DoublyLinkedNode[Token]): Node
proc primary(tn: var DoublyLinkedNode[Token]): Node

proc stmt(tn: var DoublyLinkedNode[Token]): Node =
  tn.exprStmt()

proc exprStmt(tn: var DoublyLinkedNode[Token]): Node =
  let n = NkExprStmt.newUnary(tn.expr())
  tn = tn.skip(';')
  return n

proc expr(tn: var DoublyLinkedNode[Token]): Node =
  tn.equality()

proc equality(tn: var DoublyLinkedNode[Token]): Node =
  var n = tn.relational()

  while true:
    if tn.value.equal("=="):
      tn = tn.next
      n = NkEq.newBinary(n, tn.relational())
      continue

    if tn.value.equal("!="):
      tn = tn.next
      n = NkNe.newBinary(n, tn.relational())
      continue

    return n

proc relational(tn: var DoublyLinkedNode[Token]): Node =
  var n = tn.add()

  while true:
    if tn.value.equal("<"):
      tn = tn.next
      n = NkLt.newBinary(n, tn.add())
      continue

    if tn.value.equal("<="):
      tn = tn.next
      n = NkLe.newBinary(n, tn.add())
      continue

    if tn.value.equal(">"):
      tn = tn.next
      n = NkLt.newBinary(tn.add(), n)
      continue

    if tn.value.equal(">="):
      tn = tn.next
      n = NkLe.newBinary(tn.add(), n)
      continue

    return n

proc add(tn: var DoublyLinkedNode[Token]): Node =
  var n = tn.mul()

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

proc parse*(tn: var DoublyLinkedNode[Token]): SinglyLinkedList[Node] =
  var nodeList = initSinglyLinkedList[Node]()

  while not tn.value.isEof():
    nodeList.append(tn.stmt())

  return nodeList
