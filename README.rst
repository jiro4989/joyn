====
joyn
====

|nimble-version| |nimble-install| |gh-actions|

.. contents:: Table of contents

Usage
=====

Joining CSV fields
------------------

.. code-block:: shell

  $ cat tests/testdata/user.csv
  id,name,hobby_id
  1,taro,1
  2,taro,4
  3,ichiro,3
  4,ichiro,1
  5,hanako,2
  6,hanako,3
  7,hanako,4
  8,john,1
  9,john,5
  10,bob,2

  $ cat tests/testdata/hobby.txt
  id hobby
  1 soccer
  2 baseball
  3 running
  4 cokking
  5 sleep

  $ joyn -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt
  1,taro,1 1 soccer
  2,taro,4 4 cokking
  3,ichiro,3 3 running
  4,ichiro,1 1 soccer
  5,hanako,2 2 baseball
  6,hanako,3 3 running
  7,hanako,4 4 cokking
  8,john,1 1 soccer
  9,john,5 5 sleep
  10,bob,2 2 baseball

``-o`` controls output fields.

.. code-block:: shell

  $ joyn -o '1.1,1.2,2.2' -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt
  1 taro soccer
  2 taro cokking
  3 ichiro running
  4 ichiro soccer
  5 hanako baseball
  6 hanako running
  7 hanako cokking
  8 john soccer
  9 john sleep
  10 bob baseball

Joining log files and CSV by regular expression
-----------------------------------------------

.. code-block:: shell

  $ cat tests/testdata/app.log
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/login 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] POST /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile/edit 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/logout 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/login 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] POST /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile/edit 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/logout 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/login 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] POST /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile/edit 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/logout 200 Firefox 20s

  $ cat tests/testdata/user2.csv
  id,name
  6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  68137b2e-d771-492f-980d-5862f27b8821,hanako
  0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  36858cb5-2ae5-4b7b-b94e-51170a3844f9,bob

  $ joyn -- / g '\s/([^/]+)/[^s]+\s' / c -d ',' -f 1 / tests/testdata/app.log tests/testdata/user2.csv
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/login 200 Firefox 20s 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile 200 Firefox 20s 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  2020-01-02 02:33:20 [INFO] POST /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile/edit 200 Firefox 20s 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile 200 Firefox 20s 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  2020-01-02 02:33:20 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/logout 200 Firefox 20s 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9,john
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/login 200 Firefox 20s a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile 200 Firefox 20s a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  2020-01-02 07:06:20 [INFO] POST /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile/edit 200 Firefox 20s a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile 200 Firefox 20s a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  2020-01-02 07:06:20 [INFO] GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/logout 200 Firefox 20s a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/login 200 Firefox 20s 6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile 200 Firefox 20s 6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  2020-01-02 05:49:46 [INFO] POST /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile/edit 200 Firefox 20s 6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile 200 Firefox 20s 6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  2020-01-02 05:49:46 [INFO] GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/logout 200 Firefox 20s 6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro

``-o`` controls output fields by named capturing group.

.. code-block:: shell

  $ joyn -o '1.1,1.2,1.4,1.5,2.2,1.id' -- / g '\s/([^/]+)/[^s]+\s' -d ' ' -g '\s/(?P<id>[^/]+)/[^s]+\s' / c -d ',' -f 1 / tests/testdata/app.log tests/testdata/user2.csv
  2020-01-02 02:33:20 GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/login john 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9
  2020-01-02 02:33:20 GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile john 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9
  2020-01-02 02:33:20 POST /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile/edit john 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9
  2020-01-02 02:33:20 GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/profile john 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9
  2020-01-02 02:33:20 GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/logout john 0fe2db6f-58b6-4835-9e24-200a2ac8f0a9
  2020-01-02 07:06:20 GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/login ichiro a31743ac-41ab-42bb-bee2-8825ddbe9f35
  2020-01-02 07:06:20 GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile ichiro a31743ac-41ab-42bb-bee2-8825ddbe9f35
  2020-01-02 07:06:20 POST /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile/edit ichiro a31743ac-41ab-42bb-bee2-8825ddbe9f35
  2020-01-02 07:06:20 GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/profile ichiro a31743ac-41ab-42bb-bee2-8825ddbe9f35
  2020-01-02 07:06:20 GET /a31743ac-41ab-42bb-bee2-8825ddbe9f35/logout ichiro a31743ac-41ab-42bb-bee2-8825ddbe9f35
  2020-01-02 05:49:46 GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/login taro 6ddbfb64-0b7b-488f-8300-e34cd243d4aa
  2020-01-02 05:49:46 GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile taro 6ddbfb64-0b7b-488f-8300-e34cd243d4aa
  2020-01-02 05:49:46 POST /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile/edit taro 6ddbfb64-0b7b-488f-8300-e34cd243d4aa
  2020-01-02 05:49:46 GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/profile taro 6ddbfb64-0b7b-488f-8300-e34cd243d4aa
  2020-01-02 05:49:46 GET /6ddbfb64-0b7b-488f-8300-e34cd243d4aa/logout taro 6ddbfb64-0b7b-488f-8300-e34cd243d4aa

Installation
============

TODO

LICENSE
=======

MIT

.. |gh-actions| image:: https://github.com/jiro4989/joyn/workflows/build/badge.svg
   :target: https://github.com/jiro4989/joyn/actions
.. |nimble-version| image:: https://nimble.directory/ci/badges/joyn/version.svg
   :target: https://nimble.directory/ci/badges/joyn/nimdevel/output.html
.. |nimble-install| image:: https://nimble.directory/ci/badges/joyn/nimdevel/status.svg
   :target: https://nimble.directory/ci/badges/joyn/nimdevel/output.html
