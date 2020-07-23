import strutils, streams, tables, unicode
from os import commandLineParams
from sequtils import toSeq
from algorithm import sorted

import regex

import joynpkg/argparser

const
  version = "v0.1.0"
  slideWindowWidth = 1000

type
  InvalidCharacterParamError = object of CatchableError
  InvalidOutputFormatError = object of CatchableError

template decho(x) =
  when not defined release:
    debugEcho x

proc toIndexTable(s, delim: string): Table[string, string] =
  var i: int
  for f in s.split(delim):
    inc i
    result[$i] = f

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
        if first.hasKey(key): first[key]
        else: ""
      elif buf.startsWith("2."):
        if second.hasKey(key): second[key]
        else: ""
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

proc main(args: seq[string]): int =
  let args = parseArgs(args)
  var firstStream = args.firstFile.newFileStream(fmRead)

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
    let leftGot = action(leftLine, args.firstAction)

    var secondStream = args.secondFile.newFileStream(fmRead)
    while not secondStream.atEnd:
      let rightLine = secondStream.readLine
      let rightGot = action(rightLine, args.secondAction)
      if leftGot == rightGot:
        let line =
          if 0 < args.format.len:
            var li = leftLine.toIndexTable(args.firstAction.delim)
            if args.firstAction.kind == akGrep and args.firstAction.group != "":
              for k, v in leftLine.capturingGroup(args.firstAction.group):
                li[k] = v

            var ri = rightLine.toIndexTable(args.secondAction.delim)
            if args.secondAction.kind == akGrep and args.secondAction.group != "":
              for k, v in rightLine.capturingGroup(args.secondAction.group):
                ri[k] = v

            formatGroup(args.format, " ", li, ri)
          else:
            leftLine & " " & rightLine
        echo line
    secondStream.close
    secondStream = args.secondFile.newFileStream(fmRead)

when isMainModule and not defined modeTest:
  quit main(commandLineParams())
