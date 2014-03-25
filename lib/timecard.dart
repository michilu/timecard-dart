library timecard_controller;

import "dart:html";

import "package:angular/angular.dart";
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:timecard_dev_api/timecard_dev_api_browser.dart";
import "package:timecard_dev_api/timecard_dev_api_client.dart";
import 'package:intl/intl.dart';

import "package:timecard_client/component/remember_me.dart";
import "package:timecard_client/service/api_service.dart";

@NgController(
    selector: "[app]",
    publishAs: "a")
class Controller {

  APIService _api;
  RememberMe _remember_me;
  dynamic get model => _api.model;

  Controller(APIService this._api, RememberMe this._remember_me);

  bool loading() {
    return _api.loading();
  }

  bool logged_in() {
    return _api.logged_in();
  }

  Completer login() {
    var completer = _api.loading_completer();
    _api.login().whenComplete(() {
      completer.complete();
      switch (window.location.hash) {
        case "#/logout":
        case "#/leave":
          window.location.hash = "";
          break;
      };
    });
    return completer;
  }

  void logout({String redirect_to: "/logout"}) {
    _api.logout(redirect_to: redirect_to);
  }

  Completer me_create(String name) {
    var new_user = _api.new_user({});
    new_user.name = name;
    var completer = _api.loading_completer();
    _api.me.create(new_user).then((response) {
      model.me = response;
      window.location.hash = "";
    })
    .whenComplete(() {
      completer.complete();
    });
    return completer;
  }

  Completer me_update() {
    var completer = _api.loading_completer();
    _api.me.update(model.me).then((response) {
      model.me = response;
    })
    .whenComplete(() {
      completer.complete();
    });
    return completer;
  }

  Completer me_delete() {
    var completer = _api.loading_completer();
    _api.me.delete(model.me).then((_response) {
      logout(redirect_to: "/leave");
    })
    .whenComplete(() {
      completer.complete();
    });
    return completer;
  }
}
