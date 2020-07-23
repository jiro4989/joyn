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

suite "proc cutByField":
  setup:
    const
      s1 = "1 japan 日本 east 東洋"
      s2 = "1,japan,日本,east,東洋"
  test "normal: first field":
    let want = "1"
    let got = cutByField(s1, " ", 1)
    check want == got
  test "normal: second field":
    let want = "japan"
    let got = cutByField(s1, " ", 2)
    check want == got
  test "normal: last field":
    let want = "東洋"
    let got = cutByField(s1, " ", 5)
    check want == got
  test "normal: comma delimiter":
    let want = "日本"
    let got = cutByField(s2, ",", 3)
    check want == got
  test "normal: no error if field doesn't exist":
    let want = ""
    let got = cutByField(s2, ",", 99)
    check want == got
  test "normal: no error if field doesn't exist":
    let want = ""
    let got = cutByField(s2, ",", -99)
    check want == got

suite "proc searchByRegexp":
  setup:
    const
      s1 = "山田 たろう"
      s2 = "1 apple りんご"
  test "normal: group match":
    let want = "たろう"
    let got = searchByRegexp(s1, re"山田 (太郎|たろう)")
    check want == got
  test "normal: match parts":
    let want = "apple"
    let got = searchByRegexp(s2, re"\d+\s+(apple)\s+.*")
    check want == got
  test "abnormal: no match when no group":
    let want = ""
    let got = searchByRegexp(s2, re"apple")
    check want == got
