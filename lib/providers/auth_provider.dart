import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:week7_networking_discussion/api/firebase_auth_api.dart';

// class AuthProvider with ChangeNotifier {
//   late FirebaseAuthAPI authService;
//   User? userObj;

//   String signUpMessage = '';
//   String loginMessage = '';

//   AuthProvider() {
//     authService = FirebaseAuthAPI();
//     authService.getUser().listen((User? newUser) {
//       userObj = newUser;
//       print("LOGGING IN");
//       print('AuthProvider - FirebaseAuth - onAuthStateChanged - $newUser');

//       notifyListeners();
//     }, onError: (e) {
//       // provide a more useful error
//       print('AuthProvider - FirebaseAuth - onAuthStateChanged - $e');
//     });

//   }

//   //getters
//   User? get user => userObj;
//   String get signUpStatus => signUpMessage;
//   String get loginStatus => loginMessage;

//   bool get isAuthenticated {
//     return user != null;
//   }

//   Future<bool> signIn(String email, String password) async {
//     loginMessage = await authService.signIn(email, password);
//     notifyListeners();
//     return loginMessage == '';
//   }

//   void signOut() {
//     authService.signOut();
//   }

//   Future<bool> signUp(
//     String email,
//     String password,
//     String firstName,
//     String lastName,
//     String dateCreated,
//   ) async {
//     signUpMessage = await authService.signUp(
//         email, password, firstName, lastName, dateCreated);
//     notifyListeners();
//     return signUpMessage == '';
//   }

//   void resetSignUpMessage() {
//     signUpMessage = '';
//     notifyListeners();
//   }
// }
class AuthProvider with ChangeNotifier, WidgetsBindingObserver {
  late FirebaseAuthAPI authService;
  User? userObj;

  String signUpMessage = '';
  String loginMessage = '';

  AuthProvider() {
    authService = FirebaseAuthAPI();
    authService.getUser().listen((User? newUser) {
      userObj = newUser;
      print("LOGGING IN");
      print('AuthProvider - FirebaseAuth - onAuthStateChanged - $newUser');

      notifyListeners();
    }, onError: (e) {
      // provide a more useful error
      print('AuthProvider - FirebaseAuth - onAuthStateChanged - $e');
    });

    // Add observer to listen for app lifecycle events
    // WidgetsBinding.instance?.addObserver(this);
  }

  //getters
  User? get user => userObj;
  String get signUpStatus => signUpMessage;
  String get loginStatus => loginMessage;

  bool get isAuthenticated {
    return user != null;
  }

  Future<bool> signIn(String email, String password) async {
    loginMessage = await authService.signIn(email, password);
    notifyListeners();
    return loginMessage == '';
  }

  void signOut() {
    authService.signOut();
  }

  Future<bool> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String dateCreated,
  ) async {
    signUpMessage = await authService.signUp(
        email, password, firstName, lastName, dateCreated);
    notifyListeners();
    return signUpMessage == '';
  }

  void resetSignUpMessage() {
    signUpMessage = '';
    notifyListeners();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.detached) {
  //     // The app is about to be suspended or terminated
  //     signOut();
  //   }
  // }

  @override
  void dispose() {
    // Remove the observer when the AuthProvider is disposed
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
