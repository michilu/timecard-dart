library footer;

import "dart:async";
import "dart:html";

import "package:angular/angular.dart";
import 'package:intl/intl.dart';

@Component(
  selector: "footer-component",
  templateUrl: "packages/timecard_client/component/footer.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class FooterComponent {

  Future _loaded;
  Http _http;
  String version;
  final versionUri = "/packages/timecard_client/component/version";
  final year = new DateFormat("y").format(new DateTime.now());

  FooterComponent(this._http) {
    var load = _get_version();
    if (load != null) {
      _loaded = Future.wait([load]);
    }
  }

  Future _get_version() {
    return _http.get(versionUri).then((response) {
      version = response.data;
    });
  }

}

class FooterModule extends Module {
  FooterModule() {
    type(FooterComponent);
  }
}
