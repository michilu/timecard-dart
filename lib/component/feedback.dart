library feedback;

import "dart:html";

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
  Http _http;
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  String description;

  String get action_url {
    return "https://docs.google.com/spreadsheet/formResponse?formkey=${_config.feedback_formkey}";
  }

  FeedbackComponent(this._config, this._http, this.modal, this.scope);

  void open(String templateUrl) {
    modalInstance = modal.open(new ModalOptions(templateUrl:templateUrl), scope);

    modalInstance.result
      ..then((value) {
        print('Closed with selection $value');
      }, onError:(e) {
        print('Dismissed with $e');
      });
  }

  void ok(event) {
    modalInstance.close(event);
  }

  void submit(event) {
    var queryParameters = {
      "entry.0.single": description,
      "entry.1.single": "",
      "entry.2.single": window.location.href
    };
    String data = new Uri.http(""/*authority*/, ""/*unencodedPath*/, queryParameters).query;
    _http.post(action_url, data, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
    }).then((_response) {
      ok(event);
      description = "";
    });
  }
}

@NgDirective(
    selector: "[feedback-form-background]"
)
class FeedbackFormBackground implements NgAttachAware{
  Element element;

  FeedbackFormBackground(this.element);

  attach() {
  }
}
