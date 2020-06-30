const
  version = "v0.1.0"

proc joyn(args: seq[string]): int =
  echo args

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(joyn)
