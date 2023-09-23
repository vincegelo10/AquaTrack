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
  Future<void> addAnnotation(String date, String time, String water_parameter,
      String value, String email) async {
    print("ADD ANNOTATION");
    print("water parameter: $water_parameter");
    await firebaseService.addAnnotation(
        date, time, water_parameter, value, email);
    queryResult =
        await firebaseService.fetchAnnotation(date, water_parameter, email);
    notifyListeners();
  }

  //fetch a annotation using date and water parameter
  Future<void> fetchAnnotation(
      String date, String water_parameter, String email) async {
    print("fetching annotation");
    queryResult =
        await firebaseService.fetchAnnotation(date, water_parameter, email);
    notifyListeners();
  }

  Future<void> deleteAnnotation(
      String date, String time, String water_parameter, String email) async {
    await firebaseService.deleteAnnotation(date, time, water_parameter, email);
    queryResult =
        await firebaseService.fetchAnnotation(date, water_parameter, email);
    notifyListeners();
  }
}
