part of timecard_client;

@Component(
  selector: "nav-component",
  templateUrl: "packages/timecard_client/component/nav.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class NavComponent {
  @NgTwoWay("a")
  var a;

  bool menu = false;
}

class NavModule extends Module {
  NavModule() {
    type(NavComponent);
  }
}
