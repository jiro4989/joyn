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
