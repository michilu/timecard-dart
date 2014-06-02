library timecard;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["timecard"],
  override: "*")
import "dart:mirrors";

import "package:angular/angular.dart";
import "package:angular/application_factory.dart";
import "package:di/di.dart";
import "package:logging/logging.dart";
import "package:dart_cca_example/timecard.dart";

class MyAppModule extends Module {
  MyAppModule() {
    install(new GoogleCloudEndpointModule());
    value(GoogleCloudEndpointServiceConfig, new GoogleCloudEndpointServiceConfig()
      ..client_id = "636938638718.apps.googleusercontent.com"
      ..root_url = "https://timecard-gae.appspot.com/");
    value(FeedbackFormConfig, new FeedbackFormConfig()
      ..formkey = "dFBYVXYzOUg2VzhZQ2ZoVFExZzVyVlE6MA");

    install(new TimecardModule());
  }
}

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });
  applicationFactory()
    .addModule(new MyAppModule())
    .run();
}
