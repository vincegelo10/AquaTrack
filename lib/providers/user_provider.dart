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

  checkForExistingEmail(String email) async {
    _signUpStatus = await firebaseService.checkForExistingEmail(email);
    notifyListeners();
  }

  void addPH(String email, double lowerPH, double upperPH) async {
    await firebaseService.addPH(email, lowerPH, upperPH);
  }

  void addTemp(String email, double lowerTemp, double upperTemp) async {
    await firebaseService.addTemp(email, lowerTemp, upperTemp);
  }
}
