library remember_me;

import "dart:async";
import "dart:convert";
import "dart:html";
import "dart:js";

import "package:angular/angular.dart";
import "package:chrome/chrome_app.dart" as chrome;

@MirrorsUsed(
  targets: const ["remember_me"],
  override: "*")
import "dart:mirrors";

class localStorage {

  String _key(dynamic key) {
    if (key is! String) {
      key = JSON.encode(key);
    }
    return key;
  }

  Future get(dynamic key, dynamic default_value) {
    String normalized_key = _key(key);
    try {
      Completer completer = new Completer();
      chrome.storage.local.get([normalized_key]).then((Map<String,String> values) {
        var result;
        var value = values[normalized_key];
        if (value == null) {
          result = default_value;
        } else {
          result = JSON.decode(value);
        }
        completer.complete(result);
      });
      return completer.future;
    // for dartium
    } on NoSuchMethodError catch (_) {
      var result;
      var value = window.localStorage[normalized_key];
      if (value == null) {
        result = default_value;
      } else {
        result = JSON.decode(value);
      }
      return new Future.value(result);
    }
  }

  void set(dynamic key, dynamic value) {
    String normalized_key = _key(key);
    String normalized_value = JSON.encode(value);
    try {
      chrome.storage.local.set({normalized_key: normalized_value});
    // for dartium
    } on NoSuchMethodError catch (_) {
      window.localStorage[normalized_key] = normalized_value;
    }
  }
}

class RememberMe {

  final String _key = "save_this_browser";
  final bool _default = false;
  final String _message = "You are logged in. Please click the logout if you want logout from Google account.";
  localStorage _localStorage = new localStorage();

  bool _save_this_browser;
  bool get save_this_browser => _save_this_browser;
  set save_this_browser(bool value) {
    _save_this_browser = value;
    _localStorage.set(_key, value);
  }

  RememberMe() {
    _localStorage.get(_key, _default).then((value) {
      _save_this_browser = value;
    });
    RegExp dartString = new RegExp(r"\(dart\)");
    // workaround for https://code.google.com/p/dart/issues/detail?id=16215
    if (dartString.hasMatch(window.navigator.userAgent.toLowerCase())) {
      window.onBeforeUnload.listen((e) {
        switch (window.location.hash) {
          case "#/logout":
          case "#/leave":
            break;
          default:
            if (save_this_browser != true) {
              e.returnValue = _message;
              return true;
            }
        };
      });
    } else {
      // fail if running on Chrome Packaged Apps
      context["onbeforeunload"] = (e) {
        switch (window.location.hash) {
          case "#/logout":
          case "#/leave":
            break;
          default:
            if (save_this_browser != true) {
              return _message;
            }
        };
      };
    }
  }
}

@NgComponent(
  selector: "remember_me-component",
  templateUrl: "packages/timecard_client/component/remember_me.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class RememberMeComponent {
  @NgTwoWay("a")
  var a;

  RememberMe _remember_me;

  bool get save_this_browser => _remember_me.save_this_browser;
  set save_this_browser(bool value) {
    _remember_me.save_this_browser = value;
  }

  RememberMeComponent(RememberMe this._remember_me);
}

class RememberMeModule extends Module {
  RememberMeModule() {
    type(RememberMe);
    type(RememberMeComponent);
  }
}
