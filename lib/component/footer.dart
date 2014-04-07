library footer;

import "dart:async";
import "dart:html";

import "package:angular/angular.dart";
import 'package:intl/intl.dart';

@NgComponent(
  selector: "footer-component",
  templateUrl: "packages/timecard_client/component/footer.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class FooterComponent {
  final year = new DateFormat("y").format(new DateTime.now());

  final versionUri = "/packages/timecard_client/component/version";
  Future _loaded;
  String version;
  Http _http;

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
