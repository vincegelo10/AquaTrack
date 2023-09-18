// void addAnnotation(
//     String water_parameter, String value, String annotation) async {}

// void deleteAnnotation() async {

// }
import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/api/firebase_water_parameter_annotation_api.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterParameterAnnotationProvider with ChangeNotifier {
  late FirebaseWaterParameterAnnotationAPI firebaseService;
  QuerySnapshot<Object?>? queryResult;

  WaterParameterAnnotationProvider() {
    firebaseService = FirebaseWaterParameterAnnotationAPI();
  }

  //getter for queryResult
  QuerySnapshot<Object?>? get query => queryResult;

  //add annotation
  Future<void> addAnnotation(
      String date, String time, String water_parameter, String value) async {
    await firebaseService.addAnnotation(date, time, water_parameter, value);
    queryResult = await firebaseService.fetchAnnotation(date, water_parameter);
    notifyListeners();
  }

  //fetch a annotation using date and water parameter
  Future<void> fetchAnnotation(String date, String water_parameter) async {
    print("fetching annotation");
    queryResult = await firebaseService.fetchAnnotation(date, water_parameter);
    notifyListeners();

    //iterate through the documents in the QuerySnapshot
    // for (var document in queryResult!.docs) {
    //   // Access the data within each document
    //   var data = document.data() as Map<String, dynamic>;

    //   // Access the "value" field
    //   var value = data['value'];

    //   // Print the value and the entire data
    //   print("Value: $value");
    //   print(data);
    // }
  }

  void deleteAnnotation() async {}
}
