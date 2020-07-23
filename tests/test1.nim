import unittest, os

include joyn

suite "proc capturingGroup":
  test "normal":
    let want = {"user_id": "1234"}.toTable
    let got = capturingGroup(
      "user_name:bob user_id:1234 email:hogehoge@example.com",
      re".*user_id:(?P<user_id>[^\s]+).*")
    check want == got
  test "normal":
    let want = {"user_id": "1234", "email": "hogehoge@example.com"}.toTable
    let got = capturingGroup(
      "user_name:bob user_id:1234 email:hogehoge@example.com",
      re"user_id:(?P<user_id>[^\s]+) .*email:(?P<email>[^\s]+)")
    check want == got

suite "proc formatGroup":
  test "normal":
    let want = "john john.org john john@example.com"
    let got = formatGroup(
      "1.1,1.2,2.1,2.2",
      " ",
      {"1": "john", "2": "john.org"}.toTable,
      {"1": "john", "2": "john@example.com"}.toTable)
    check want == got
  test "normal":
    let want = "1234,john,1234,john@example.com"
    let got = formatGroup(
      "1.id,1.name,2.id,2.email",
      ",",
      {"id": "1234", "name": "john"}.toTable,
      {"id": "1234", "email": "john@example.com"}.toTable)
    check want == got

suite "iterator doMain":
  setup:
    const
      tdir = "tests"/"testdata"
      ff = tdir/"do_main1.tmp"
      sf = tdir/"do_main2.tmp"
  teardown:
    removeFile(ff)
    removeFile(sf)
  test "normal: cut char and cut char":
    let want = @["1 hello 1 world"]
    writeFile(ff, "1 hello")
    writeFile(sf, "1 world")
    let fact = ActionParam(kind: akCut, delim: " ", chars: "1", field: -1)
    let sact = ActionParam(kind: akCut, delim: " ", chars: "1", field: -1)
    let args = Args(delim: " ", firstAction: fact, secondAction: sact, firstFile: ff, secondFile: sf)
    var got: seq[string]
    for line in doMain(args):
      got.add(line)
    check want == got
  test "normal: cut field and cut field":
    let want = @["abcd HELLO WORLD,abcd"]
    writeFile(ff, "AA 1234\nabcd HELLO")
    writeFile(sf, "BB,5678\nWORLD,abcd")
    let fact = ActionParam(kind: akCut, delim: " ", field: 1)
    let sact = ActionParam(kind: akCut, delim: ",", field: 2)
    let args = Args(delim: " ", firstAction: fact, secondAction: sact, firstFile: ff, secondFile: sf)
    var got: seq[string]
    for line in doMain(args):
      got.add(line)
    check want == got
  test "normal: grep and grep":
    let want = @["abcd HELLO WORLD,abcd"]
    writeFile(ff, "AA 1234\nabcd HELLO")
    writeFile(sf, "BB,5678\nWORLD,abcd")
    let fact = ActionParam(kind: akGrep, pattern: re"^([^\s]+)\s")
    let sact = ActionParam(kind: akGrep, pattern: re",(.*)")
    let args = Args(delim: " ", firstAction: fact, secondAction: sact, firstFile: ff, secondFile: sf)
    var got: seq[string]
    for line in doMain(args):
      got.add(line)
    check want == got
  test "normal: format output":
    let want = @["1 hello,1 world,hello,world"]
    writeFile(ff, "1 hello")
    writeFile(sf, "1 world")
    let fact = ActionParam(kind: akCut, delim: " ", chars: "1", field: -1)
    let sact = ActionParam(kind: akCut, delim: " ", chars: "1", field: -1)
    let args = Args(delim: ",", format: "1.0,2.0,1.2,2.2", firstAction: fact, secondAction: sact, firstFile: ff, secondFile: sf)
    var got: seq[string]
    for line in doMain(args):
      got.add(line)
    check want == got
