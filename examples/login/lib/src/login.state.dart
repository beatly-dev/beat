import 'dart:io';
import 'dart:math';

import 'package:beat/beat.dart';

part 'login.state.beat.dart';

@BeatStation()
@Beat(event: 'logout', to: UserState.loggedOut)
@Beat(event: 'login', to: UserState.validating, actions: [])
enum UserState {
  loggedOut,
  @Invokes([
    InvokeFuture(login,
        onDone: AfterInvoke(to: UserState.loggedIn, actions: [logLoginSucess]),
        onError: AfterInvoke(to: UserState.loggedOut, actions: [logLoginFail]))
  ])
  validating,
  loggedIn,
}

logLoginFail() {
  print("Login Failed!");
}

logLoginSucess() {
  print("Login Succeeded!");
}

login(_, __, ___) async {
  await Future.delayed(Duration(milliseconds: 2000));
  final rand = Random().nextInt(10000);
  if (rand < 1000) {
    /// fails with 10% probability
    throw HttpException('unable to login');
  }
}
