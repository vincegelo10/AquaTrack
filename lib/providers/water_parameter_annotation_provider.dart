// void addAnnotation(
//     String water_parameter, String value, String annotation) async {}

// void deleteAnnotation() async {

// }
import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/api/firebase_water_parameter_annotation_api.dart';
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
  Future<void> addAnnotation(String date, String time, String waterParameter,
      String value, String email) async {
    print("ADD ANNOTATION");
    print("water parameter: $waterParameter");
    await firebaseService.addAnnotation(
        date, time, waterParameter, value, email);
    queryResult =
        await firebaseService.fetchAnnotation(date, waterParameter, email);
    notifyListeners();
  }

  //fetch a annotation using date and water parameter
  Future<void> fetchAnnotation(
      String date, String waterParameter, String email) async {
    print("fetching annotation");
    queryResult =
        await firebaseService.fetchAnnotation(date, waterParameter, email);
    notifyListeners();
  }

  Future<void> deleteAnnotation(
      String date, String time, String waterParameter, String email) async {
    await firebaseService.deleteAnnotation(date, time, waterParameter, email);
    queryResult =
        await firebaseService.fetchAnnotation(date, waterParameter, email);
    notifyListeners();
  }
}
