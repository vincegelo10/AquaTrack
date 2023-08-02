import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:week7_networking_discussion/api/firebase_auth_api.dart';

class AuthProvider with ChangeNotifier {
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

  // Future<bool> signUp(
  //     String email,
  //     String password,
  //     String firstName,
  //     String lastName,
  //     String dateCreated,
  //     double lowerPH,
  //     double upperPH,
  //     double lowerTemp,
  //     double upperTemp) async {
  //   signUpMessage = await authService.signUp(email, password, firstName,
  //       lastName, dateCreated, lowerPH, upperPH, lowerTemp, upperTemp);
  //   notifyListeners();
  //   return signUpMessage == '';
  // }

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
}

//  Future<bool> signUp(
//       {firstName,
//       lastName,
//       email,
//       password,
//       userName,
//       location,
//       birthDate,
//       loggedIn}) async {
//     signUpMessage = await authService.signUp(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         password: password,
//         userName: userName,
//         location: location,
//         birthDate: birthDate,
//         loggedIn: loggedIn);
//     notifyListeners();
//     return signUpMessage == '';
//   }
