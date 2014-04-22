library timecard;

import "package:angular/angular.dart";
import "package:di/di.dart";
import "package:logging/logging.dart";

import "package:timecard_client/component/feedback.dart";
import "package:timecard_client/service/google_cloud_endpoints_api_service.dart";
import "package:timecard_client/timecard.dart";

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["timecard", "timecard_dev_api"],
  override: "*")
import "dart:mirrors";

class MyAppModule extends Module {
  MyAppModule() {
    install(new GoogleCloudEndpointModule());
    value(GoogleCloudEndpointServiceConfig, new GoogleCloudEndpointServiceConfig()
      ..client_id = "636938638718.apps.googleusercontent.com"
      ..root_url = "http://localhost:8081/");
    value(FeedbackFormConfig, new FeedbackFormConfig()
      ..formkey = "dFBYVXYzOUg2VzhZQ2ZoVFExZzVyVlE6MA");

    install(new TimecardModule());
  }
}

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });
  ngBootstrap(module: new MyAppModule());
}
