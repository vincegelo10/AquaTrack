import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/api/firebase_user_api.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:week7_networking_discussion/api/firebase_auth_api.dart';

class UserProvider with ChangeNotifier, WidgetsBindingObserver {
  late FirebaseUserAPI firebaseService;

  String _signUpStatus = '';
  User? _loggedInUser;

  UserProvider() {
    firebaseService = FirebaseUserAPI();
    initializeFromFirestore();
  }

  String get signUpStatus => _signUpStatus;
  User? get user => _loggedInUser;

  checkForExistingEmail(String email) async {
    _signUpStatus = await firebaseService.checkForExistingEmail(email);
    notifyListeners();
  }

  Future<void> initializeFromFirestore() async {
    print("initializing data from firestore");
    try {
      Map<String, dynamic> user = await firebaseService.findLoggedInUser();

      if (user["success"]) {
        _loggedInUser = User.fromJson(user);
        notifyListeners();
      }
    } catch (e) {
      print("Error initializing from Firestore: $e");
    }
  }

  void addPH(String email, double lowerPH, double upperPH) async {
    await firebaseService.addPH(email, lowerPH, upperPH);
  }

  void editPH(String email, double lowerPH, double upperPH) async {
    await firebaseService.addPH(email, lowerPH, upperPH);
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      _loggedInUser = User.fromJson(user);
      notifyListeners();
    }
  }

  void editDO(String email, double lowerDO, double upperDO) async {
    await firebaseService.addDissolvedOxygen(email, lowerDO, upperDO);
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      _loggedInUser = User.fromJson(user);
      notifyListeners();
    }
  }

  void editTemp(String email, double lowerTemp, double upperTemp,
      bool inFahrenheit) async {
    await firebaseService.addTemp(email, lowerTemp, upperTemp, inFahrenheit);
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      _loggedInUser = User.fromJson(user);
      notifyListeners();
    }
  }

  Future<void> addTemp(String email, double lowerTemp, double upperTemp,
      bool inFahrenheit) async {
    await firebaseService.addTemp(email, lowerTemp, upperTemp, inFahrenheit);
  }

  Future<void> addDissolvedOxygen(
      String email, double lowerDO, double upperDO) async {
    await firebaseService.addDissolvedOxygen(email, lowerDO, upperDO);
  }

  Future<void> getLoggedInUserDetails(String email) async {
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      _loggedInUser = User.fromJson(user);
      changeIsLoggedInToTrue();
      notifyListeners();
    } else {
      print("the credentials are invalid");
    }
  }

  Future<void> changeIsLoggedInToTrue() async {
    print("in change logged in provider");
    print(_loggedInUser!.email);

    await firebaseService.changeIsLoggedInToTrue(_loggedInUser!.email);
  }

  Future<void> changeIsLoggedInToFalse() async {
    await firebaseService.changeIsLoggedInToFalse(_loggedInUser!.email);
  }

  void removeLoggedInUserDetails() {
    changeIsLoggedInToFalse();
    _loggedInUser = null;
    notifyListeners();
  }
}
