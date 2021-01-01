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

proc genExpr(n: Node, stk: Stack) =
  case n.kind:
  of NkNum:
    echo "  mov $", $n.value, ", %rax"
    return
  of NkNeg:
    n.lhs.genExpr(stk)
    echo "  neg %rax"
    return
  of NkAdd, NkSub, NkMul, NkDiv:
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
  of NkNum, NkNeg:
    discard

  quit("invalid expression")

proc codeGen*(n: Node) =
  echo "  .globl main"
  echo "main:"

  var stk = Stack()
  n.genExpr(stk)

  echo "  ret"

  if not stk.depth == 0:
    quit("stack error")
