import lists

import tokenizer
export tokenizer

proc codegen*(tl: DoublyLinkedList[Token]) =
  echo "  .globl main"
  echo "main:"

  var tok = tl.head

  echo "  mov $", tok.value.getNum(), ", %rax"

  tok = tok.next

  while tok.value.kind != TokenKind.Eof:
    if tok.value.equal('+'):
      tok = tok.next
      echo "  add $", tok.value.getNum, ", %rax"
      tok = tok.next
      continue

    tok = tok.skip('-')
    echo "  sub $", tok.value.getNum, ", %rax"
    tok = tok.next
    continue

  echo "  ret"
