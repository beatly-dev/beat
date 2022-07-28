import 'package:login/src/login.state.dart';

void main(List<String> arguments) async {
  final station = UserStateBeatStation(UserStateBeatState(
    state: UserState.loggedOut,
  ));
  station.addListener(() {
    station.exec(
      onLoggedIn: () {
        print("Succefully Logined");
      },
      onLoggedOut: () {
        print("Logged Out");
      },
      onValidating: () {
        print("Validating...");
      },
      orElse: () {},
    );
  });
  while (true) {
    station.exec(
      onLoggedIn: () {
        station.$logout();
      },
      onLoggedOut: () {
        station.$login();
      },
      orElse: () {
        print("Still Validating...");
      },
    );
    await Future.delayed(Duration(milliseconds: 1000));
  }
}
