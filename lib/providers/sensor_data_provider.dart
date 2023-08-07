import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/models/sensor_data_model.dart';
import 'package:firebase_database/firebase_database.dart';

class SensorDataProvider with ChangeNotifier {
  List<SensorData> dataList = [];
  var recentPH = '';
  var recentWaterTemp = '';

  SensorDataProvider() {
    fetchData();
  }

  String get phLevel => recentPH;
  String get waterTemp => recentWaterTemp;
  List<SensorData> get dataFromSensor => dataList;

  void fetchData() async {
    DateTime current_date = DateTime.now();
    String date_today = current_date.toString().split(' ')[0];

    final ref = FirebaseDatabase(
        databaseURL:
            "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/");

    void streamSubscription = await ref
        .reference()
        .child("$date_today")
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value == null) {
        print(
            "no collection available yet in firebase realtimed database for the date: $date_today");
      } else {
        Map<dynamic, dynamic> sensorDataMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        if (sensorDataMap != null) {
          sensorDataMap.forEach((key, value) {
            if (value != null) {
              var pH = value["ph"].toDouble();
              var waterTemperature = value["water_temperature"].toDouble();
              var timestamp =
                  int.parse(key); // Parse the timestamp from the key
              var millis = timestamp;
              DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
              dataList.add(SensorData(waterTemperature, pH, timestamp, dt));
            }
          });
          dataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
        }

        // Update ph level and water temperature to the recently updated value in the database
        if (dataList.isNotEmpty) {
          recentPH = dataList[dataList.length - 1].ph.toString();
          recentWaterTemp =
              dataList[dataList.length - 1].waterTemperature.toString();
          notifyListeners();
        } else {
          recentPH = 'No data found.';
          recentWaterTemp = 'No data found.';
          notifyListeners();
        }
      }
    });
  }
}