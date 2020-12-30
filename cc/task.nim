import os

proc build() =
  discard execShellCmd("nim c -d:release --hints:off ./src/cc.nim")

when isMainModule:
  if paramCount() != 1:
    build()
    quit(0)

  case $commandLineParams()[0]
  of "build":
    build()
  of "test":
    if not fileExists("./src/cc"):
      build()
    discard execShellCmd("./test.sh")
  of "clean":
    discard execShellCmd("rm -f tmp*")
