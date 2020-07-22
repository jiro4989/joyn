import strutils, sequtils, streams, tables, unicode
from algorithm import sorted

import regex

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
  InvalidOutputFormatError = object of CatchableError

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

proc parseByField(s, delim, field: string): string =
  discard

proc parseByRegexp(s, param: string): string =
  discard

proc capturingGroup(s, regexp: string): Table[string, string] =
  let pattern =  re(regexp)
  var match: RegexMatch
  if s.find(pattern, match):
    for name in match.groupNames:
      result[name] = match.groupFirstCapture(name, s)

proc formatGroup(f, delim: string, first: Table[string, string], second: Table[string, string]): string =
  var buf: string
  var fields: seq[string]

  template addField =
    let key = buf[2..^1]
    let val =
      if buf.startsWith("1."):
        first[key]
      elif buf.startsWith("2."):
        second[key]
      else:
        raise newException(InvalidOutputFormatError, "error TODO")
    fields.add(val)
    buf = ""

  for i, ch in f:
    if ch == ',':
      addField()
      continue
    buf.add(ch)

  if 0 < buf.len:
    addField()

  result = fields.join(delim)

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

  defer:
    firstStream.close

  while not firstStream.atEnd:
    let leftLine = firstStream.readLine
    decho leftLine
    let leftGot = parseByCharacter(leftLine, args.firstCmd[1])
    decho leftGot

    var secondStream = args.secondFile.newFileStream(fmRead)
    while not secondStream.atEnd:
      let rightLine = secondStream.readLine
      decho rightLine
      let rightGot = parseByCharacter(rightLine, args.secondCmd[1])
      if leftGot == rightGot:
        echo leftLine, ":", rightLine
    secondStream.close
    secondStream = args.secondFile.newFileStream(fmRead)

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(joyn)
