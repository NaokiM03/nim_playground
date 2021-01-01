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
  of NodeKind.Num:
    echo "  mov $", $n.value, ", %rax"
    return
  of Nodekind.Neg:
    n.lhs.genExpr(stk)
    echo "  neg %rax"
    return
  of NodeKind.Add, NodeKind.Sub, NodeKind.Mul, NodeKind.Div:
    discard

  n.rhs.genExpr(stk)
  stk.push()
  n.lhs.genExpr(stk)
  stk.pop("%rdi")

  case n.kind:
  of NodeKind.Add:
    echo "  add %rdi, %rax"
    return
  of NodeKind.Sub:
    echo "  sub %rdi, %rax"
    return
  of NodeKind.Mul:
    echo "  imul %rdi, %rax"
    return
  of NodeKind.Div:
    echo "  cqo"
    echo "  idiv %rdi"
    return
  of NodeKind.Num, NodeKind.Neg:
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
