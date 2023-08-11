import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/api/firebase_user_api.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  late FirebaseUserAPI firebaseService;
  String _signUpStatus = '';
  User? _loggedInUser;

  UserProvider() {
    firebaseService = FirebaseUserAPI();
  }

  String get signUpStatus => _signUpStatus;
  User? get user => _loggedInUser;
  checkForExistingEmail(String email) async {
    _signUpStatus = await firebaseService.checkForExistingEmail(email);
    notifyListeners();
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

  Future<void> getLoggedInUserDetails(String email) async {
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      _loggedInUser = User.fromJson(user);
      notifyListeners();
    } else {
      print("the credentials are invalid");
    }
  }

  void removeLoggedInUserDetails() {
    _loggedInUser = null;
    notifyListeners();
  }
}
