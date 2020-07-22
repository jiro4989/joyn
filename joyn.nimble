# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "TODO"
license       = "MIT"
srcDir        = "src"
bin           = @["joyn"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.6"
requires "regex >= 0.15.0"
requires "argparse >= 0.10.1"

import os, strformat

const
  testDataDir = "tests"/"testdata"

task archive, "Create archived assets":
  let app = "joyn"
  let assets = &"{app}_{buildOS}"
  let dir = "dist"/assets
  mkDir dir
  cpDir "bin", dir/"bin"
  cpFile "LICENSE", dir/"LICENSE"
  cpFile "README.rst", dir/"README.rst"
  withDir "dist":
    when buildOS == "windows":
      exec &"7z a {assets}.zip {assets}"
    else:
      exec &"tar czf {assets}.tar.gz {assets}"

task case1, "Run case 1":
  exec "nimble build"
  exec &"./bin/joyn -- / c -c 44-50 / c -c 1-7 / {testDataDir}/case1_access.log {testDataDir}/case1_userids.txt"

task case2, "Run case 2":
  exec "nimble build"
  exec &"./bin/joyn -- / g '/users/([^/]+)/' / c -f 2 / {testDataDir}/case1_access.log {testDataDir}/case1_userids.txt"
