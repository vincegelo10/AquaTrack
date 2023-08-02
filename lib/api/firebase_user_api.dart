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

  Future<String> addTemp(
      String email, double lowerTemp, double upperTemp) async {
    await db
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs[0].reference
                  .update({"lowerTemp": lowerTemp, "upperTemp": upperTemp})
            });

    return 'Setting Temperature successfull';
  }
}
