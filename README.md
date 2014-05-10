timecard-dart
=============

Timecard - Time tracking for your project.

Set up
------

    $ git clone https://github.com/MiCHiLU/timecard-dart.git
    $ cd timecard-dart
    $ bundle install

Optional, if you use watchlion:

    $ mkvirtualenv timecard-dart
    (timecard-dart)$ pip install -r packages.txt

Build and Test
--------------

    $ make

Run development server
----------------------

    $ make pubserve

then access to:

* http://localhost:8080/

Build the Chrome Apps
---------------------

    $ make release

Launch the Chrome Apps via iOS Simulator
----------------------------------------

    $ make ios

Dependencies
------------

* Bundler
* GNU Make
* Node.js v0.10+ (dependenced by cordova)
  * npm@1.4.5+
  * ios-deploy@1.0.6
  * cca@0.0.11

Known Bugs
----------

* https://github.com/MobileChromeApps/mobile-chrome-apps/pull/158
