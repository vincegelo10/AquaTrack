import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/api/firebase_user_api.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/file_storage.dart';

class UserProvider with ChangeNotifier, WidgetsBindingObserver {
  late FirebaseUserAPI firebaseService;

  String _signUpStatus = '';
  String fcmToken = '';
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
      FileStorage fileHandler = FileStorage("fcmtoken.txt");
      List<String>? fileContents = await fileHandler.readFile();
      if (fileContents != null && fileContents.isNotEmpty) {
        String token = fileContents[0];
        Map<String, dynamic> user =
            await firebaseService.findLoggedInUserWithSpecificFCMToken(token);
        if (user["success"]) {
          _loggedInUser = User.fromJson(user);
          notifyListeners();
        }
      } else {
        print("Error reading file or file is empty.");
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
    FileStorage fileHandler = FileStorage("fcmtoken.txt");
    Map<String, dynamic> user =
        await firebaseService.getLoggedInUserDetails(email);
    if (user["success"]) {
      await changeFcmTokenFirestore(email);
      user = await firebaseService.getLoggedInUserDetails(email);
      _loggedInUser = User.fromJson(user);
      changeIsLoggedInToTrue();
      //write data for persistence
      fileHandler.writeString("$fcmToken\n");
      notifyListeners();
    } else {
      print("the credentials are invalid");
    }
  }

  Future<void> changeIsLoggedInToTrue() async {
    await firebaseService.changeIsLoggedInToTrue(_loggedInUser!.email);
  }

  Future<void> changeIsLoggedInToFalse() async {
    await firebaseService.changeIsLoggedInToFalse(_loggedInUser!.email);
  }

  Future<void> changeFcmTokenFirestore(String email) async {
    await firebaseService.changeFcmTokenFirestore(email, fcmToken);
  }

  void changeFcmToken(String value) {
    print(value);
    fcmToken = value;
  }

  void removeLoggedInUserDetails() async {
    FileStorage fileHandler = FileStorage("fcmtoken.txt");
    await fileHandler.clearFile();
    changeIsLoggedInToFalse();
    fcmToken = "";
    changeFcmTokenFirestore(_loggedInUser!.email);
    _loggedInUser = null;
    notifyListeners();
  }
}
