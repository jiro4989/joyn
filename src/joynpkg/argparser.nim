from sequtils import delete

import argparse

type
  ActionKind* = enum
    akCut, akGrep
  ActionParam = object
    delim*: string
    case kind*: ActionKind
    of akCut:
      chars*: string
      fields*: string
    of akGrep:
      pattern*: string
      group*: string
  Args* = object
    format*: string
    firstAction*: ActionParam
    firstFile*: string
    secondAction*: ActionParam
    secondFile*: string
  InvalidArgsError* = object of CatchableError

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
      option("-d", "--delimiter", default = " ")
      arg("pattern")
    let opts = p.parse(parts[1..^1])
    result = ActionParam(kind: akGrep, group: opts.group, pattern: opts.pattern, delim: opts.delimiter)
  else:
    raise newException(InvalidArgsError, "error TODO")


proc parseArgs*(args: seq[string]): Args =
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

proc parseArgs2*(args: seq[string]): Args =
  var pos: int
  var pref: seq[string]
  for i, arg in args:
    if arg == "--":
      pos = i
      break
    pref.add(arg)

  var p = newParser("joyn"):
    option("-o", "--format", default = "")

  let opts = p.parse(pref)
  result = args[pos+1 .. ^1].parseArgs()
  result.format = opts.format
