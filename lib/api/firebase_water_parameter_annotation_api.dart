import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:week7_networking_discussion/models/user_model.dart';

class FirebaseWaterParameterAnnotationAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addAnnotation(
      String date, String time, String water_parameter, String value) async {
    try {
      print("I am here");
      final query = await db
          .collection("annotations")
          .where("date", isEqualTo: date)
          .where("water_parameter", isEqualTo: water_parameter)
          .where("time", isEqualTo: time);

      final querySnapshot = await query.get();
      if (querySnapshot.docs.length == 0) {
        try {
          await db.collection("annotations").add({
            "date": date,
            "time": time,
            "water_parameter": water_parameter,
            "value": value
          });
          // The annotation was added successfully.
          // You can add any success handling code here.
        } catch (e) {
          // Handle errors here
          print("Error adding annotation: $e");
          // You may want to throw the exception again or handle it differently.
          // For example, you could show an error message to the user.
        }
      } else {
        for (final docSnapshot in querySnapshot.docs) {
          final docReference = docSnapshot.reference;
          await docReference.update({"value": value});
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<QuerySnapshot> fetchAnnotation(
      String date, String water_parameter) async {
    try {
      var querySnapshot = await db
          .collection("annotations")
          .where("date", isEqualTo: date)
          .where("water_parameter", isEqualTo: water_parameter)
          .get();
      return querySnapshot;
    } catch (e) {
      print("an error occured bro");
      print("Error: $e");
      throw e;
    }
  }

  // Future<String> checkForExistingEmail(String email) async {
  //   final userQuery =
  //       await db.collection("users").where("email", isEqualTo: email).get();
  //   //return userQuery.docs.isNotEmpty ? userQuery.docs[0] : null;
  //   if (userQuery.docs.isNotEmpty) {
  //     return 'Account already exists for that email';
  //   } else {
  //     return '';
  //   }
  // }

  // Future<String> addPH(String email, double lowerPH, double upperPH) async {
  //   await db
  //       .collection("users")
  //       .where("email", isEqualTo: email)
  //       .get()
  //       .then((querySnapshot) => {
  //             querySnapshot.docs[0].reference
  //                 .update({"lowerPH": lowerPH, "upperPH": upperPH})
  //           });

  //   return 'Setting PH Level successfull';
  // }

  // Future<String> addTemp(String email, double lowerTemp, double upperTemp,
  //     bool inFahrenheit) async {
  //   await db
  //       .collection("users")
  //       .where("email", isEqualTo: email)
  //       .get()
  //       .then((querySnapshot) => {
  //             querySnapshot.docs[0].reference.update({
  //               "lowerTemp": lowerTemp,
  //               "upperTemp": upperTemp,
  //               "inFahrenheit": inFahrenheit
  //             })
  //           });

  //   return 'Setting Temperature successfull';
  // }

  // Future<Map<String, dynamic>> getLoggedInUserDetails(String email) async {
  //   Map<String, dynamic> user;
  //   try {
  //     var querySnapshot =
  //         await db.collection("users").where('email', isEqualTo: email).get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       user = querySnapshot.docs.first.data();
  //       user["success"] = true;
  //     } else {
  //       // Handle the case when no user is found with the given email
  //       user = {"success": false};
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     user = {"success": false};
  //   }
  //   return user;
  // }
}
