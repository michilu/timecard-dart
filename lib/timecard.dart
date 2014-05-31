library timecard_client;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["timecard_client"],
  override: "*")
import "dart:mirrors";

import "dart:async";
import "dart:convert";
import "dart:html";
import "dart:js";

import "package:angular/angular.dart";
import "package:angular/routing/module.dart";
import "package:angular_ui/modal/modal.dart";
import "package:chrome/chrome_app.dart" as chrome;
import "package:timecard_client/service/api_service.dart";
import "package:timecard_client/service/google_cloud_endpoints_api_service.dart";
import 'package:intl/intl.dart';

export "package:timecard_client/service/google_cloud_endpoints_api_service.dart" show GoogleCloudEndpointModule, GoogleCloudEndpointServiceConfig;

part "component/edit_user.dart";
part "component/feedback.dart";
part "component/footer.dart";
part "component/nav.dart";
part "component/remember_me.dart";
part "routing/timecard_router.dart";
part "service/version.dart";

@Controller(
    selector: "[app]",
    publishAs: "a")
class TimecardController {

  APIService _api;
  RememberMe _remember_me;
  dynamic get model => _api.model;

  TimecardController(this._api, this._remember_me);

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

class TimecardModule extends Module {
  TimecardModule() {

    install(new EditUserModule());
    install(new FeedbackModule());
    install(new FooterModule());
    install(new NavModule());
    install(new RememberMeModule());
    install(new VersionServiceModule());

    type(TimecardController);
    value(RouteInitializerFn, timecardRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}
