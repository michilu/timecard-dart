library remember_me;

import "dart:convert";
import "dart:html";
import "package:angular/angular.dart";

class localStorage {
  Storage _localStorage = window.localStorage;

  String _key(dynamic key) {
    if (key is! String) {
      key = JSON.encode(key);
    }
    return key;
  }

  dynamic get(dynamic key, dynamic default_value) {
    var value = _localStorage[_key(key)];
    if (value == null) {
      return default_value;
    } else {
      return JSON.decode(value);
    }
  }

  set(dynamic key, dynamic value) {
    _localStorage[_key(key)] = JSON.encode(value);
  }
}

class RememberMe {

  final String _key = "save_this_browser";
  final bool _default = false;
  final String _message = "You are logged in. Please click the logout if you want logout from Google account.";
  localStorage _localStorage = new localStorage();

  bool get save_this_browser {
    return _localStorage.get(_key, _default);
  }
  set save_this_browser(bool value) {
    _localStorage.set(_key, value);
  }

  RememberMe() {
    window.onBeforeUnload.listen((e) {
      switch (window.location.hash) {
        case "#/logout":
        case "#/leave":
          break;
        default:
          if (save_this_browser != true) {
            return _message;
          }
      };
    });
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
