timecard-dart
=============

Timecard - Time tracking for your project.

Set up
------

First, checkout this repository:

    $ git clone https://github.com/MiCHiLU/timecard-dart.git
    $ cd timecard-dart
    $ bundle install

Then, install cca (Cordova Chrome Apps):

    $ nvm install 0.10
    $ nvm use 0.10
    $ nvm alias default 0.10
    $ npm install -g ios-deploy
    $ npm install -g ios-sim
    $ npm install -g cca

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

    $ make chrome-apps

Launch the Chrome Apps via iOS Simulator
----------------------------------------

    $ make ios-sim

Launch the Chrome Apps via iOS device
-------------------------------------

    $ make ios

Open project for iOS with Xcode
-------------------------------

    $ make xcode

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
