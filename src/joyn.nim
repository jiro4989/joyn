import sequtils, streams

const
  version = "v0.1.0"
  slideWindowWidth = 1000

type
  Args = object
    firstCmd: seq[string]
    firstFile: string
    secondCmd: seq[string]
    secondFile: string
  InvalidArgsError = object of CatchableError

proc getArgsAndDelete(args: var seq[string], delim: string): seq[string] =
  var m = args.high
  for i in 0..m:
    let arg = args[0]
    args.delete(0, 0)

    if arg == delim:
      break
    result.add(arg)

proc splitArgs(args: seq[string]): Args =
  if args.len < 1:
    raise newException(InvalidArgsError, "need args")
  var args = args
  let delim = args[0]
  args.delete(0, 0)

  result.firstCmd = getArgsAndDelete(args, delim)
  result.secondCmd = getArgsAndDelete(args, delim)

  if args.len != 2:
    raise newException(InvalidArgsError, "need 2 files in last parts")
  result.firstFile = args[0]
  result.secondFile = args[1]

proc joyn(rawargs: seq[string]): int =
  let args = rawargs.splitArgs()

  var
    firstStream = args.firstFile.newFileStream(fmRead)
    secondStream = args.secondFile.newFileStream(fmRead)
    firstLineCnt: int
    secondLineCnt: int

  defer:
    firstStream.close
    secondStream.close

  while not firstStream.atEnd:
    let line = firstStream.readLine
    inc firstLineCnt
    if firstLineCnt == slideWindowWidth:
      echo firstLineCnt, ":", line
      firstLineCnt = 0

      while not secondStream.atEnd:
        let line = secondStream.readLine
        inc secondLineCnt
        if secondLineCnt == slideWindowWidth:
          echo secondLineCnt, ":", line
          secondLineCnt = 0

      secondStream.close
      secondStream = args.secondFile.newFileStream(fmRead)

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(joyn)
