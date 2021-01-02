import lists
import strutils

import parser
import utils

type Stack = ref object
  depth: int

proc push(stk: Stack) =
  echo "  push %rax"
  stk.depth.inc()

proc pop(stk: Stack, s: string) =
  echo "  pop ", s
  stk.depth.dec()

proc genAddr(n: Node) =
  if n.kind == NkVar:
    let offset = (n.name.toInt() - 'a'.toInt() + 1) * 8
    echo "  lea ", -offset, "(%rbp), %rax"
    return

  quit("not an lvalue")

proc genExpr(n: Node, stk: Stack) =
  case n.kind:
  of NkNum:
    echo "  mov $", $n.value, ", %rax"
    return
  of NkNeg:
    n.lhs.genExpr(stk)
    echo "  neg %rax"
    return
  of NkVar:
    n.genAddr()
    echo "  mov (%rax), %rax"
    return
  of NkAssign:
    n.lhs.genAddr()
    stk.push()
    n.rhs.genExpr(stk)
    stk.pop("%rdi")
    echo "  mov %rax, (%rdi)"
    return
  else:
    discard

  n.rhs.genExpr(stk)
  stk.push()
  n.lhs.genExpr(stk)
  stk.pop("%rdi")

  case n.kind:
  of NkAdd:
    echo "  add %rdi, %rax"
    return
  of NkSub:
    echo "  sub %rdi, %rax"
    return
  of NkMul:
    echo "  imul %rdi, %rax"
    return
  of NkDiv:
    echo "  cqo"
    echo "  idiv %rdi"
    return
  of NkEq, NkNe, NkLt, NkLe:
    echo "  cmp %rdi, %rax"

    case n.kind:
    of NkEq:
      echo "  sete %al"
    of NkNe:
      echo "  setne %al"
    of NkLt:
      echo "  setl %al"
    of NkLe:
      echo "  setle %al"
    else:
      discard

    echo "  movzb %al, %rax"
    return
  else:
    discard

  quit("invalid expression. NodeKind: $1" % $n.kind)

proc genStmt(n: Node, stk: Stack) =
  if n.kind == NkExprStmt:
    n.lhs.genExpr(stk)
    return

  quit("invalid statement")

proc codeGen*(nl: SinglyLinkedList[Node]) =
  echo "  .globl main"
  echo "main:"

  echo "  push %rbp"
  echo "  mov %rsp, %rbp"
  echo "  sub $208, %rsp"

  var stk = Stack()

  for n in nl:
    n.genStmt(stk)
    if not stk.depth == 0:
      quit("stack error")

  echo "  mov %rbp, %rsp"
  echo "  pop %rbp"
  echo "  ret"
