library footer;

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
}
