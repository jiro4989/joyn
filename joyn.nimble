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

task example1, "Joining CSV fields":
  exec "nimble build"
  exec &"./bin/joyn -- / c -d , -f 3 / c -d ' ' -f 1 / {testDataDir}/user.csv {testDataDir}/hobby.txt"

task example2, "Joining log files and CSV by regular expression":
  exec "nimble build"
  exec &"""./bin/joyn -- / g '\s/([^/]+)/[^s]+\s' / c -d ',' -f 1 / {testDataDir}/app.log {testDataDir}/user2.csv"""

task example3, "Run example 3":
  exec "nimble build"
  exec &"./bin/joyn -o '1.1,2.2' -- / g '/users/([^/]+)/' / c -f 2 / {testDataDir}/access.log {testDataDir}/userids.txt"

task example4, "Run example 4":
  exec "nimble build"
  exec &"./bin/joyn -o '2.1,1.userName' -- / g '/users/([^/]+)/' -g '/users/(?P<userName>[^/]+)/' / c -f 2 / {testDataDir}/access.log {testDataDir}/userids.txt"

task example5, "Run example 5":
  exec "nimble build"
  exec &"./bin/joyn -- / c -c 44-50 / c -c 1-7 / {testDataDir}/access.log {testDataDir}/userids.txt"

task example6, "Run example 6":
  exec "nimble build"
  exec &"./bin/joyn -- / g '/users/([^/]+)/' / c -f 2 / {testDataDir}/access.log {testDataDir}/userids.txt"

