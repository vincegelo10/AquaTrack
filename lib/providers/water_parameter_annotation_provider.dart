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

  WaterParameterAnnotationProvider() {
    firebaseService = FirebaseWaterParameterAnnotationAPI();
  }

  Future<void> addAnnotation(
      String date, String time, String water_parameter, String value) async {
    await firebaseService.addAnnotation(date, time, water_parameter, value);
  }

  void deleteAnnotation() async {}
}
