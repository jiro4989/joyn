import unittest

include joynpkg/argparser

template checkAction(k, want, got) =
  case k
  of akCut:
    check want.firstAction.chars == got.firstAction.chars
    check want.firstAction.field == got.firstAction.field
    check want.firstAction.delim == got.firstAction.delim
  of akGrep:
    discard

suite "proc parseActions":
  setup:
    let want1 = Args(
      firstAction: ActionParam(
        kind: akCut,
        chars: "1-15",
        delim: " ",
        field: -1,
        ),
      firstFile: "c.txt",
      secondAction: ActionParam(
        kind: akCut,
        chars: "1,2,3",
        delim: " ",
        field: -1,
        ),
      secondFile: "d.txt",
    )
  test "normal: first argument is the delimiter of args":
    let want = want1
    let got = parseActions(@["/", "c", "-c", "1-15", "/", "cut", "--characters", "1,2,3", "/", "c.txt", "d.txt"])
    checkAction(akCut, want, got)
  test "normal: first argument is any character":
    let want = want1
    let got = parseActions(@[":", "c", "-c", "1-15", ":", "cut", "--characters", "1,2,3", ":", "c.txt", "d.txt"])
    checkAction(akCut, want, got)
  test "abnormal: the last part must have 2 files":
    expect(InvalidArgsError):
      discard parseActions(@["/", "c", "-c", "1-15", "/", "c", "-c", "1,2,3", "/"])
    expect(InvalidArgsError):
      discard parseActions(@["/", "c", "-c", "1-15", "/", "c", "-c", "1,2,3", "/", "c.txt"])
    expect(InvalidArgsError):
      discard parseActions(@["/", "c", "-c", "1-15", "/", "c", "-c", "1,2,3", "/", "c.txt", "d.txt", "f.txt"])
  test "abnormal: args must have 3 parts":
    expect(InvalidArgsError):
      discard parseActions(@["/", "c", "-c", "1-15", "/", "c", "-c", "1,2,3"])
    expect(InvalidArgsError):
      discard parseActions(@["c", "-c", "1-15"])
  test "abnormal: need args":
    expect(InvalidArgsError):
      discard parseActions(@[])
    expect(InvalidArgsError):
      discard parseActions(@["/"])
    expect(InvalidArgsError):
      discard parseActions(@["/", "/"])

