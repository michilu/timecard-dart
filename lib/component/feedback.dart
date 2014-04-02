library feedback;

import "package:angular/angular.dart";
import 'package:angular_ui/modal/modal.dart';

class FeedbackFormConfig {
  String feedback_formkey;
}

@NgComponent(
  selector: "feedback-component",
  templateUrl: "packages/timecard_client/component/feedback_link.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class FeedbackComponent {

  FeedbackFormConfig _config;
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;

  String get action_url {
    return "https://docs.google.com/spreadsheet/formResponse?formkey=${_config.feedback_formkey}";
  }

  FeedbackComponent(this.modal, this.scope, this._config);

  void open(String templateUrl) {
    modalInstance = modal.open(new ModalOptions(templateUrl:templateUrl), scope);

    modalInstance.result
      ..then((value) {
        print('Closed with selection $value');
      }, onError:(e) {
        print('Dismissed with $e');
      });
  }

  void ok(sel) {
    modalInstance.close(sel);
  }
}
