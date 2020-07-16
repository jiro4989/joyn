====
joyn
====

|nimble-version| |nimble-install| |gh-actions|

.. contents:: Table of contents

Usage
=====

.. code-block:: shell

  $ cat user.csv
  id,name,hobby_id
  1,taro,1
  2,ichiro,3
  3,hanako,4
  4,john,5
  5,bob,2

  $ hobby.txt
  id hobby
  1 soccer
  2 baseball
  3 running
  4 cokking
  5 sleep

  $ joyn -- / -d , -f 3 / -d " " -f 1 / user.csv hobby.txt
  1,taro,1,soccer
  2,ichiro,3,running
  3,hanako,4,cokking
  4,john,5,sleep
  5,bob,2,baseball

.. code-block:: shell

  $ cat app.log
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/logout 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] POST /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile/edit 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/logout 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/logout 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] POST /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile/edit 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/logout 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/logout 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/profile 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] POST /73be8aa5-f619-4274-a0da-9531114cbaf9/profile/edit 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/profile 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/logout 200 Firefox 20s
  2020-01-02 13:17:13 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/logout 200 Firefox 20s

  $ user.csv
  id,name
  6ddbfb64-0b7b-488f-8300-e34cd243d4aa,taro
  a31743ac-41ab-42bb-bee2-8825ddbe9f35,ichiro
  68137b2e-d771-492f-980d-5862f27b8821,hanako
  9fb7c8e0-6276-409a-8815-051a9f354cd0,john
  36858cb5-2ae5-4b7b-b94e-51170a3844f9,bob

  $ joyn -- \
         / bash -c "grep -E '\s/([^/]+)/[^s]+\s' | sed -e 's,^/,,g' -e 's,/.*,,g'" \
         / cut -d , -f 2 \
         / app.log user.csv
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/logout 200 Firefox 20s 
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] POST /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile/edit 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/profile 200 Firefox 20s
  2020-01-02 02:33:20 [INFO] GET /6724ee60-01f3-4605-b4fb-8ca23af7085a/logout 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/logout 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] POST /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile/edit 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/profile 200 Firefox 20s
  2020-01-02 07:06:20 [INFO] GET /944db4d1-35ec-45a5-8f1e-c3d2d437b8cb/logout 200 Firefox 20s
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/logout 200 Firefox 20s 73be8aa5-f619-4274-a0da-9531114cbaf9 john
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/profile 200 Firefox 20s 73be8aa5-f619-4274-a0da-9531114cbaf9 john
  2020-01-02 05:49:46 [INFO] POST /73be8aa5-f619-4274-a0da-9531114cbaf9/profile/edit 200 Firefox 20s 73be8aa5-f619-4274-a0da-9531114cbaf9 john
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/profile 200 Firefox 20s 73be8aa5-f619-4274-a0da-9531114cbaf9 john
  2020-01-02 05:49:46 [INFO] GET /73be8aa5-f619-4274-a0da-9531114cbaf9/logout 200 Firefox 20s 73be8aa5-f619-4274-a0da-9531114cbaf9 john
  2020-01-02 13:17:13 [INFO] GET /0fe2db6f-58b6-4835-9e24-200a2ac8f0a9/logout 200 Firefox 20s

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
