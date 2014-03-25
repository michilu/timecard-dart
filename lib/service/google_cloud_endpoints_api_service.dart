library google_cloud_endpoints_api_service;

import "dart:async";
import "dart:html";

import "package:angular/angular.dart";
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:timecard_dev_api/timecard_dev_api_browser.dart";
import "package:timecard_dev_api/timecard_dev_api_client.dart";

import "package:timecard_client/service/api_service.dart";

class GoogleCloudEndpointModel extends Model {
  Future _loaded;
  GoogleCloudEndpointService _api;
  Map get _model => inner_model;
  Map get _resource => inner_resource;
  set me (dynamic value) {
    _model["me"] = value;
    _resource["me"] = value.toJson();
  }

  GoogleCloudEndpointModel(GoogleCloudEndpointService this._api) {
    inner_model = new Map();
    inner_resource = new Map();
    var load = _get_me();
    if (load != null) {
      _loaded = Future.wait([load]);
    }
  }

  Future _get_me() {
    if (!_api.autoLogin()) {
      return null;
    }
    var completer = _api.loading_completer();
    return _api.me.get().then((response) {
      me = response;
    })
    .catchError((error) {
      window.location.hash = "/signup";
    }, test: (e) => e is APIRequestError)
    .whenComplete(() {
      completer.complete();
    });
  }

  bool edited(String name) {
    var model = _model[name];
    var resource = _resource[name];
    if (model != null) {
      model = model.toJson();
    }
    if (model == resource) {
      return false;
    }
    if (model.length != resource.length) {
      return true;
    }
    for (var key in resource.keys) {
      if (model[key] != resource[key]) {
        return true;
      };
    }
    return false;
  }
}

class GoogleCloudEndpointServiceConfig {
  String client_id;
  String root_url;
}

class GoogleCloudEndpointService extends APIService {
  final _REVOKE_URL = "https://accounts.google.com/o/oauth2/revoke?token=";
  final _SCOPES = ["https://www.googleapis.com/auth/userinfo.email"];

  Http _http;
  Timecard _endpoint;

  dynamic get comment   => _endpoint.comment ;
  dynamic get issue     => _endpoint.issue   ;
  dynamic get me        => _endpoint.me ;
  dynamic get project   => _endpoint.project ;
  dynamic get user      => _endpoint.user    ;
  dynamic get workload  => _endpoint.workload;

  GoogleCloudEndpointService(GoogleCloudEndpointServiceConfig c, Http this._http) {
    GoogleOAuth2 auth = new GoogleOAuth2(c.client_id, _SCOPES, autoLogin:autoLogin());
    _endpoint = new Timecard(auth);
    _endpoint.rootUrl = c.root_url;
    _endpoint.makeAuthRequests = true;
    model = new GoogleCloudEndpointModel(this);
  }

  bool autoLogin() {
    switch (window.location.hash) {
      case "#/logout":
      case "#/leave":
        return false;
        break;
      default:
        return true;
        break;
    };
  }

  MainApiV1MessageUserRequest new_user(data) => new MainApiV1MessageUserRequest.fromJson(data);

  bool logged_in() {
    return _endpoint.auth.token != null;
  }

  Future login() {
    return _endpoint.auth.login();
  }

  void logout({String redirect_to: "/"}) {
    String revoke_url = _REVOKE_URL + _endpoint.auth.token.data;
    var completer = loading_completer();
    _http.get(revoke_url).then((_response) {
      _endpoint.auth.logout();
      redirect(redirect_to);
    })
    .whenComplete(() {
      completer.complete();
    });
  }
}
