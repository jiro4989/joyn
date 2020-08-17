import os, times, random, strutils

let args = commandLineParams()
let maxNum = args[0].parseInt

randomize()

for i in 1..maxNum:
  echo now(), " ", $i, " success user_id=", rand(999999)
