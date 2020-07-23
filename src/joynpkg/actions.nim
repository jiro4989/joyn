import strutils, tables, unicode
from sequtils import toSeq
from algorithm import sorted

import regex

type
  InvalidCharacterParamError* = object of CatchableError
  InvalidOutputFormatError* = object of CatchableError

proc cutByCharacter*(s, param: string): string =
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

proc cutByField*(s, delim: string, field: int): string =
  let cols = s.split(delim)
  let index = field - 1
  if cols.len <= index:
    return
  result = cols[index]

proc searchByRegexp*(s, regexp: string): string =
  let pattern = re(regexp)
  var match: RegexMatch
  if s.find(pattern, match):
    if 0 < match.groupsCount:
      for bounds in match.group(0):
        return s[bounds]
