part of timecard_client;

@Component(
  selector: "footer-component",
  templateUrl: "packages/timecard_client/component/footer.html",
  useShadowDom: false,
  publishAs: "c"
)
class FooterComponent {

  String get version => _version_service.version;
  VersionService _version_service;
  final year = new DateFormat("y").format(new DateTime.now());

  FooterComponent(this._version_service);

}

class FooterModule extends Module {
  FooterModule() {
    type(FooterComponent);
  }
}
