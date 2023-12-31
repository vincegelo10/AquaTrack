import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> checkForExistingEmail(String email) async {
    final userQuery =
        await db.collection("users").where("email", isEqualTo: email).get();
    //return userQuery.docs.isNotEmpty ? userQuery.docs[0] : null;
    if (userQuery.docs.isNotEmpty) {
      return 'Account already exists for that email';
    } else {
      return '';
    }
  }

  Future<String> addPH(String email, double lowerPH, double upperPH) async {
    await db
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference
                  .update({"lowerPH": lowerPH, "upperPH": upperPH})
            });

    return 'Setting PH Level successfull';
  }

  Future<String> addTemp(String email, double lowerTemp, double upperTemp,
      bool inFahrenheit) async {
    await db
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference.update({
                "lowerTemp": lowerTemp,
                "upperTemp": upperTemp,
                "inFahrenheit": inFahrenheit
              })
            });

    return 'Setting Temperature successfull';
  }

  Future<String> addDissolvedOxygen(
      String email, double lowerDO, double upperDO) async {
    await db
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference
                  .update({"lowerDO": lowerDO, "upperDO": upperDO})
            });

    return 'Setting Dissolved Oxygen successfull';
  }

  Future<Map<String, dynamic>> getLoggedInUserDetails(String email) async {
    Map<String, dynamic> user;
    try {
      var querySnapshot =
          await db.collection("users").where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        user = querySnapshot.docs.first.data();
        user["success"] = true;
      } else {
        // Handle the case when no user is found with the given email
        user = {"success": false};
      }
    } catch (e) {
      print("Error: $e");
      user = {"success": false};
    }
    return user;
  }

  Future<void> changeIsLoggedInToTrue(String email) async {
    await db
        .collection("users")
        .where('email', isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference.update({"isLoggedIn": true})
            });
  }

  Future<void> changeIsLoggedInToFalse(String email) async {
    await db
        .collection("users")
        .where('email', isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference.update({"isLoggedIn": false})
            });
  }

  Future<void> changeFcmTokenFirestore(String email, String token) async {
    await db
        .collection("users")
        .where('email', isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference.update({"fcmToken": token})
            });
  }

  Future<Map<String, dynamic>> findLoggedInUserWithSpecificFCMToken(
      String token) async {
    print("in the API");
    print("the token in the file is $token");
    Map<String, dynamic> user;
    try {
      var querySnapshot = await db
          .collection("users")
          .where('isLoggedIn', isEqualTo: true)
          .where('fcmToken', isEqualTo: token)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        user = querySnapshot.docs.first.data();
        user["success"] = true;
      } else {
        // Handle the case when no user is found with the given email
        user = {"success": false};
      }
    } catch (e) {
      print("Error: $e");
      user = {"success": false};
    }
    return user;
  }
}
