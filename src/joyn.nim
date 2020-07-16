import strutils, sequtils, streams, tables, unicode
from algorithm import sorted

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
  InvalidCharacterParamError = object of CatchableError

template decho(x) =
  when not defined release:
    debugEcho x

proc parseByCharacter(s, param: string): string =
  template raiseErr = raise newException(InvalidCharacterParamError, "need parameter")

  if param.len < 1:
    raiseErr()

  let
    runes = s.toRunes
    cols = param.split(",")
  var
    poses: Table[int, bool]

  for col in cols:
    if col.len < 1:
      raiseErr()
    let
      beginEnd = col.split("-")
    if 2 <= beginEnd.len:
      let
        beginStr = beginEnd[0]
        endStr = beginEnd[1]
      if beginStr.len < 1 and endStr.len < 1:
        raiseErr()
      var
        beginNum = 1
        endNum = runes.len
      if beginStr != "":
        beginNum = beginStr.parseInt
      if endStr != "":
        endNum = endStr.parseInt
      for i in beginNum .. endNum:
        if runes.len < i:
          raiseErr()
        poses[i-1] = true
      continue
    let i = col.parseInt
    if runes.len < i:
      raiseErr()
    poses[i-1] = true

  for k in toSeq(poses.keys).sorted:
    result.add(runes[k])

proc parseByField(s, param: string): string =
  discard

proc parseByRegexp(s, param: string): string =
  discard

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
    firstLineCnt: int
    secondStream = args.secondFile.newFileStream(fmRead)
    secondLineCnt: int

  defer:
    firstStream.close
    secondStream.close

  var
    matchLieno: Table[string, int]

  while not firstStream.atEnd:
    let line = firstStream.readLine
    inc firstLineCnt
    decho line
    let got = "a"
    decho got
    matchLieno[got] = 1
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

  echo matchLieno

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(joyn)
