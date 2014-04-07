library edit_user;

import "dart:async";

import "package:angular/angular.dart";

@MirrorsUsed(
  targets: const ["edit_user"],
  override: "*")
import "dart:mirrors";

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

  Completer _completer;

  bool get isCompleted {
    if (_completer == null) {
      return true;
    } else {
      return _completer.isCompleted;
    }
  }

  void me_update() {
    _completer = a.me_update();
  }
}

class EditUserModule extends Module {
  EditUserModule() {
    type(EditUserComponent);
  }
}
