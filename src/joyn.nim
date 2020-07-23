import strutils, streams, tables, unicode
from os import commandLineParams

import regex

import joynpkg/[argparser, actions]

const
  version = "v0.1.0"
  slideWindowWidth = 1000

template decho(x) =
  when not defined release:
    debugEcho x

proc toIndexTable(s, delim: string): Table[string, string] =
  var i: int
  for f in s.split(delim):
    inc i
    result[$i] = f

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

proc capturingGroup(s: string, pattern: Regex): Table[string, string] =
  var match: RegexMatch
  if s.find(pattern, match):
    for name in match.groupNames:
      result[name] = match.groupFirstCapture(name, s)

iterator doMain(args: Args): string =
  var firstStream = args.firstFile.newFileStream(fmRead)

  defer:
    firstStream.close

  template action(line, act): string =
    case act.kind
    of akCut:
      if 0 < act.chars.len:
        cutByCharacter(line, act.chars)
      elif 0 < act.field:
        cutByField(line, act.delim, act.field)
      else:
        raise newException(InvalidArgsError, "error TODO")
    of akGrep:
      searchByRegexp(line, act.pattern)

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
            li["0"] = leftLine
            if args.firstAction.kind == akGrep:
              for k, v in leftLine.capturingGroup(args.firstAction.group):
                li[k] = v

            var ri = rightLine.toIndexTable(args.secondAction.delim)
            ri["0"] = rightLine
            if args.secondAction.kind == akGrep:
              for k, v in rightLine.capturingGroup(args.secondAction.group):
                ri[k] = v

            formatGroup(args.format, args.delim, li, ri)
          else:
            leftLine & args.delim & rightLine
        yield line
    secondStream.close

proc main(args: seq[string]): int =
  let args = parseArgs(args)

  if args.outfile.len == 0:
    for line in doMain(args):
      echo line
    return

  var strm = newFileStream(args.outfile, fmWrite)
  defer:
    strm.close
  for line in doMain(args):
    strm.writeLine(line)

when isMainModule and not defined modeTest:
  quit main(commandLineParams())
