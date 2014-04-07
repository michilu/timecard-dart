library timecard;

import "package:angular/angular.dart";
import "package:angular/routing/module.dart";
import "package:angular_ui/angular_ui.dart";
import "package:angular_ui/modal/modal.dart";
import "package:angular_ui/utils/timeout.dart";
import "package:di/di.dart";
import "package:logging/logging.dart";

import "package:timecard_client/timecard.dart";
import "package:timecard_client/service/api_service.dart";
import "package:timecard_client/service/google_cloud_endpoints_api_service.dart";
import "package:timecard_client/routing/timecard_router.dart";
import "package:timecard_client/component/nav.dart";
import "package:timecard_client/component/footer.dart";
import "package:timecard_client/component/feedback.dart";
import "package:timecard_client/component/edit_user.dart";
import "package:timecard_client/component/remember_me.dart";

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["api_service",
                  "timecard_dev_api",
                  "google_cloud_endpoints_api_service",
                  "remember_me",
                  "edit_user",
                  "timecard", "timecard_routing"],
  override: "*")
import "dart:mirrors";

class MyAppModule extends Module {
  MyAppModule() {
    value(GoogleCloudEndpointServiceConfig, new GoogleCloudEndpointServiceConfig()
      ..client_id = "636938638718.apps.googleusercontent.com"
      ..root_url = "http://localhost:8080/");
    factory(APIService, (Injector inj){
      return inj.get(GoogleCloudEndpointService);
    });
    type(GoogleCloudEndpointService);
    type(Controller);
    type(NavComponent);
    type(FooterComponent);
    value(FeedbackFormConfig, new FeedbackFormConfig()
      ..feedback_formkey = "dFBYVXYzOUg2VzhZQ2ZoVFExZzVyVlE6MA");
    type(FeedbackComponent);
    type(Modal);
    type(Timeout);
    type(EditUserComponent);
    type(RememberMe);
    type(RememberMeComponent);
    value(RouteInitializerFn, timecardRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });
  ngBootstrap(module: new MyAppModule());
}
