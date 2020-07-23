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
      field*: int
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

proc getActionAndDelete(args: var seq[string], delim: string): ActionParam =
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
      option("-f", "--field", default = "-1")
      option("-d", "--delimiter", default = " ")
    let opts = p.parse(parts[1..^1])
    let field =
      try:
        opts.field.parseInt
      except:
        raise newException(InvalidArgsError, "'-f' or '--field' is invalid number: " & opts.field)
    result = ActionParam(kind: akCut, chars: opts.characters, field: field, delim: opts.delimiter)
  of "grep", "g":
    var p = newParser("regexp"):
      option("-g", "--group", default = "")
      option("-d", "--delimiter", default = " ")
      arg("pattern")
    let opts = p.parse(parts[1..^1])
    result = ActionParam(kind: akGrep, group: opts.group, pattern: opts.pattern, delim: opts.delimiter)
  else:
    raise newException(InvalidArgsError, "error TODO")


proc parseActions*(args: seq[string]): Args =
  if args.len < 7:
    raise newException(InvalidArgsError, "need args")
  var args = args
  let delim = args[0]
  args.delete(0, 0)

  result.firstAction = getActionAndDelete(args, delim)
  result.secondAction = getActionAndDelete(args, delim)

  if args.len != 2:
    raise newException(InvalidArgsError, "need 2 files in last parts")

  result.firstFile = args[0]
  result.secondFile = args[1]

proc parseArgs*(args: seq[string]): Args =
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
  result = args[pos+1 .. ^1].parseActions()
  result.format = opts.format
