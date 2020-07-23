import unittest

include joynpkg/actions

suite "proc cutByCharacter":
  setup:
    const s = "foobar"
    const s2 = "あいうえお"
  test "normal: 1 character":
    let want = "f"
    let got = cutByCharacter(s, "1")
    check want == got
  test "normal: 1 multibyte character":
    let want = "あ"
    let got = cutByCharacter(s2, "1")
    check want == got
  test "normal: comma separated characters (1,2,3)":
    let want = "foo"
    let got = cutByCharacter(s, "1,2,3")
    check want == got
  test "normal: comma separated multibyte characters (1,2,3,5)":
    let want = "あいうお"
    let got = cutByCharacter(s2, "1,2,3,5")
    check want == got
  test "normal: comma separated characters (1,4)":
    let want = "fb"
    let got = cutByCharacter(s, "1,4")
    check want == got
  test "normal: comma separated characters (4,1)":
    let want = "fb"
    let got = cutByCharacter(s, "4,1")
    check want == got
  test "normal: comma separated characters (1,1,1)":
    let want = "f"
    let got = cutByCharacter(s, "1,1,1")
    check want == got
  test "normal: range (1-4)":
    let want = "foob"
    let got = cutByCharacter(s, "1-4")
    check want == got
  test "normal: range (-4)":
    let want = "foob"
    let got = cutByCharacter(s, "-4")
    check want == got
  test "normal: range (4-)":
    let want = "bar"
    let got = cutByCharacter(s, "4-")
    check want == got
  test "normal: comma and range (1,2,5-)":
    let want = "foar"
    let got = cutByCharacter(s, "1,2,5-")
    check want == got
  test "abnormal: empty":
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, "")
  test "abnormal: hiphen only":
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, "-")
  test "abnormal: commma only":
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, ",")
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, ",1")
  test "abnormal: index out of bounds":
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, "7")
    expect(InvalidCharacterParamError):
      discard cutByCharacter(s, "1-9")

