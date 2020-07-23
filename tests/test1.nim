import unittest

include joyn

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
