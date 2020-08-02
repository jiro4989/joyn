from sequtils import delete

import regex, argparse

const
  helpDoc = """joyn joins lines of two files with a common characters, field or regular expression.

Usage:
  joyn [options...] -- <delimiter> <action> [args...] <delimiter> <action> [args...] <delimiter> <left_source_file> <right_source_file>

Actions:
  c, cut   character mode
  g, grep  regular expression mode

Options of actions:
  grep
    -g, --group <group>         named capturing group.
    -d, --delimiter <delimiter> [default: " "]

  cut
    -c, --characters <characters>
    -f, --field <field>
    -d, --delimiter <delimiter>

Examples:
  joyn -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt

  joyn -o '1.1,1.2,2.2' -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt

  joyn -- / g '\s/([^/]+)/[^s]+\s' / c -d ',' -f 1 / tests/testdata/app.log tests/testdata/user2.csv

  joyn -o '1.1,1.2,1.4,1.5,2.2,1.id' -- \
    / g '\s/([^/]+)/[^s]+\s' -d ' ' -g '\s/(?P<id>[^/]+)/[^s]+\s' \
    / c -d ',' -f 1 \
    / tests/testdata/app.log tests/testdata/user2.csv
"""

type
  ActionKind* = enum
    akCut, akGrep
  ActionParam* = object
    delim*: string
    case kind*: ActionKind
    of akCut:
      chars*: string
      field*: int
    of akGrep:
      pattern*: Regex
      group*: Regex
  Args* = object
    version*: bool
    format*: string
    outfile*: string
    delim*: string
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
      try: opts.field.parseInt
      except: raise newException(InvalidArgsError, "'-f' or '--field' is invalid number: " & opts.field)
    result = ActionParam(kind: akCut, chars: opts.characters, field: field, delim: opts.delimiter)
  of "grep", "g":
    var p = newParser("regexp"):
      option("-g", "--group", default = "")
      option("-d", "--delimiter", default = " ")
      arg("pattern")
    let opts = p.parse(parts[1..^1])
    let group =
      try: re(opts.group)
      except: raise newException(InvalidArgsError, "'-g' or '--group' is invalid regexp: " & opts.group)
    let pattern =
      try: re(opts.pattern)
      except: raise newException(InvalidArgsError, "searching pattern is invalid regexp: " & opts.pattern)
    result = ActionParam(kind: akGrep, group: group, pattern: pattern, delim: opts.delimiter)
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
    help(helpDoc)
    option("-o", "--format", default = "")
    option("-O", "--outfile", default = "")
    option("-d", "--delimiter", default = " ")
    flag("-v", "--version")

  let opts = p.parse(pref)
  if opts.version:
    result.version = opts.version
    return

  result = args[pos+1 .. ^1].parseActions()
  result.format = opts.format
  result.outfile = opts.outfile
  result.delim = opts.delimiter
