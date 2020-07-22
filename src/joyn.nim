import strutils, sequtils, streams, tables, unicode
from algorithm import sorted

import regex, argparse

const
  version = "v0.1.0"
  slideWindowWidth = 1000

type
  ActionKind = enum
    akCut, akGrep
  ActionParam = object
    case kind*: ActionKind
    of akCut:
      chars*: string
      fields*: string
      delim*: string
    of akGrep:
      pattern*: string
      group*: string
  Args = object
    firstAction: ActionParam
    firstFile: string
    secondAction: ActionParam
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
  let cols = s.split(delim)
  try:
    let index = field.parseInt - 1
    if cols.len <= index:
      return
    result = cols[index]
  except:
    # TODO:
    discard

proc parseByRegexp(s, regexp: string): string =
  let pattern = re(regexp)
  var match: RegexMatch
  if s.find(pattern, match):
    if 0 < match.groupsCount:
      for bounds in match.group(0):
        return s[bounds]

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

proc getArgsAndDelete(args: var seq[string], delim: string): ActionParam =
  var m = args.high
  var parts: seq[string]
  for i in 0..m:
    let arg = args[0]
    args.delete(0, 0)

    if arg == delim:
      break
    parts.add(arg)

  case parts[0]
  of "cut", "c":
    var p = newParser("cut"):
      option("-c", "--characters", default = "")
      option("-f", "--fields", default = "")
      option("-d", "--delimiter", default = " ")
    let opts = p.parse(parts[1..^1])
    result = ActionParam(kind: akCut, chars: opts.characters, fields: opts.fields, delim: opts.delimiter)
  of "grep", "g":
    var p = newParser("regexp"):
      option("-g", "--group", default = "")
      arg("pattern")
    let opts = p.parse(parts[1..^1])
    result = ActionParam(kind: akGrep, group: opts.group, pattern: opts.pattern)
  else:
    raise newException(InvalidArgsError, "error TODO")

proc parseArgs(args: seq[string]): Args =
  if args.len < 7:
    raise newException(InvalidArgsError, "need args")
  var args = args
  let delim = args[0]
  args.delete(0, 0)

  result.firstAction = getArgsAndDelete(args, delim)
  result.secondAction = getArgsAndDelete(args, delim)

  if args.len != 2:
    raise newException(InvalidArgsError, "need 2 files in last parts")

  result.firstFile = args[0]
  result.secondFile = args[1]

proc main(rawargs: seq[string]): int =
  var pos: int
  var pref: seq[string]
  for i, arg in rawargs:
    if arg == "--":
      pos = i
      break
    pref.add(arg)

  var p = newParser("joyn"):
    option("-o", "--format", default = "")

  let opts = p.parse(pref)
  let args = rawargs[pos+1 .. ^1].parseArgs()
  echo args

  var
    firstStream = args.firstFile.newFileStream(fmRead)

  defer:
    firstStream.close

  template action(line, act): string =
    case act.kind
    of akCut:
      if 0 < act.chars.len:
        parseByCharacter(line, act.chars)
      elif 0 < act.fields.len:
        parseByField(line, act.delim, act.fields)
      else:
        raise newException(InvalidArgsError, "error TODO")
    of akGrep:
      parseByRegexp(line, act.pattern)

  while not firstStream.atEnd:
    let leftLine = firstStream.readLine
    decho leftLine
    let leftGot = action(leftLine, args.firstAction)
    decho leftGot

    var secondStream = args.secondFile.newFileStream(fmRead)
    while not secondStream.atEnd:
      let rightLine = secondStream.readLine
      decho rightLine
      let rightGot = action(rightLine, args.secondAction)
      if leftGot == rightGot:
        let line =
          if 0 < opts.format.len:
            ""
          else:
            leftLine & " " & rightLine
        echo line
    secondStream.close
    secondStream = args.secondFile.newFileStream(fmRead)

when isMainModule and not defined modeTest:
  quit main(commandLineParams())
