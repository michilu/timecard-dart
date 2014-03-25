library edit_user;

import "package:angular/angular.dart";

@NgComponent(
  selector: "edit_user-component",
  templateUrl: "packages/timecard_client/component/edit_user.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class EditUserComponent {
  @NgTwoWay("a")
  var a;
  @NgTwoWay("me")
  var me;

  Completer completer;

  void me_update() {
    completer = a.me_update();
  }
}
