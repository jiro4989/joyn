import unittest

include joyn

suite "proc splitArgs":
  test "normal: first argument is the delimiter of args":
    check splitArgs(@["/", "echo", "a", "/", "echo", "b", "/", "c.txt", "d.txt"]) ==
      Args(
        firstCmd: @["echo", "a"],
        firstFile: "c.txt",
        secondCmd: @["echo", "b"],
        secondFile: "d.txt",
        )
  test "normal: first argument is any character":
    check splitArgs(@[":", "echo", "a", ":", "echo", "b", ":", "c.txt", "d.txt"]) ==
      Args(
        firstCmd: @["echo", "a"],
        firstFile: "c.txt",
        secondCmd: @["echo", "b"],
        secondFile: "d.txt",
        )
  test "abnormal: the last part must have 2 files":
    expect(InvalidArgsError):
      discard splitArgs(@["/", "echo", "a", "/", "echo", "b", "/"])
    expect(InvalidArgsError):
      discard splitArgs(@["/", "echo", "a", "/", "echo", "b", "/", "c.txt"])
    expect(InvalidArgsError):
      discard splitArgs(@["/", "echo", "a", "/", "echo", "b", "/", "c.txt", "d.txt", "f.txt"])
  test "abnormal: args must have 3 parts":
    expect(InvalidArgsError):
      discard splitArgs(@["/", "echo", "a", "/", "echo", "b"])
    expect(InvalidArgsError):
      discard splitArgs(@["echo", "a", "echo", "b"])
  test "abnormal: need args":
    expect(InvalidArgsError):
      discard splitArgs(@[])
    expect(InvalidArgsError):
      discard splitArgs(@["/"])
    expect(InvalidArgsError):
      discard splitArgs(@["/", "/"])

suite "proc parseByCharacter":
  setup:
    const s = "foobar"
    const s2 = "あいうえお"
  test "normal: 1 character":
    let want = "f"
    let got = parseByCharacter(s, "1")
    check want == got
  test "normal: 1 multibyte character":
    let want = "あ"
    let got = parseByCharacter(s2, "1")
    check want == got
  test "normal: comma separated characters (1,2,3)":
    let want = "foo"
    let got = parseByCharacter(s, "1,2,3")
    check want == got
  test "normal: comma separated multibyte characters (1,2,3,5)":
    let want = "あいうお"
    let got = parseByCharacter(s2, "1,2,3,5")
    check want == got
  test "normal: comma separated characters (1,4)":
    let want = "fb"
    let got = parseByCharacter(s, "1,4")
    check want == got
  test "normal: comma separated characters (4,1)":
    let want = "fb"
    let got = parseByCharacter(s, "4,1")
    check want == got
  test "normal: comma separated characters (1,1,1)":
    let want = "f"
    let got = parseByCharacter(s, "1,1,1")
    check want == got
  test "normal: range (1-4)":
    let want = "foob"
    let got = parseByCharacter(s, "1-4")
    check want == got
  test "normal: range (-4)":
    let want = "foob"
    let got = parseByCharacter(s, "-4")
    check want == got
  test "normal: range (4-)":
    let want = "bar"
    let got = parseByCharacter(s, "4-")
    check want == got
  test "normal: comma and range (1,2,5-)":
    let want = "foar"
    let got = parseByCharacter(s, "1,2,5-")
    check want == got
  test "abnormal: empty":
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, "")
  test "abnormal: hiphen only":
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, "-")
  test "abnormal: commma only":
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, ",")
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, ",1")
  test "abnormal: index out of bounds":
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, "7")
    expect(InvalidCharacterParamError):
      discard parseByCharacter(s, "1-9")

suite "proc capturingGroup":
  test "normal":
    let want = {"user_id": "1234"}.toTable
    let got = capturingGroup(
      "user_name:bob user_id:1234 email:hogehoge@example.com",
      string".*user_id:(?P<user_id>[^\s]+).*")
    check want == got
  test "normal":
    let want = {"user_id": "1234", "email": "hogehoge@example.com"}.toTable
    let got = capturingGroup(
      "user_name:bob user_id:1234 email:hogehoge@example.com",
      string"user_id:(?P<user_id>[^\s]+) .*email:(?P<email>[^\s]+)")
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
