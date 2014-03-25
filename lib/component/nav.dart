library nav;

import "package:angular/angular.dart";

@NgComponent(
  selector: "nav-component",
  templateUrl: "packages/timecard_client/component/nav.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class NavComponent {
  @NgTwoWay("a")
  var a;
}
