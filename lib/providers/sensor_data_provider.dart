import 'package:flutter/material.dart';
import 'package:week7_networking_discussion/models/sensor_data_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class SensorDataProvider with ChangeNotifier {
  List<SensorData> dataList = [];
  List<SensorData> dataFromOtherDates = [];
  var recentPH = '';
  var recentWaterTemp = '';
  var recentDO = '';
  SensorData? recentData;

  final ref = FirebaseDatabase(
      databaseURL: "https://sp2-2-5df1c-default-rtdb.firebaseio.com/");

  SensorDataProvider() {
    //initial fetch- this is the data being fetched right after the user logs in
    fetchData();
    //schedule fetch
    _scheduleMidnightFetch();
  }

  String get phLevel => recentPH;
  String get waterTemp => recentWaterTemp;
  String get dissolvedOxygen => recentDO;
  SensorData? get updatedSensorData => recentData;

  List<SensorData> get dataFromSensor => dataList;
  List<SensorData> get dataFromOtherDate => dataFromOtherDates;

  Future<bool> fetchDataFromOtherDate(String date) async {
    DataSnapshot snapshot = await ref.reference().child("ATLAS/$date").get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value
          as Map<dynamic, dynamic>; // Assuming the snapshot value is a Map

      if (data != null) {
        dataFromOtherDates.clear();
        data.forEach((key, value) {
          print("Key: $key, Value: $value");
          var pH =
              double.parse(value["ph"].replaceAll(',', '').replaceAll('"', ''));
          var waterTemperature = double.parse(value["water_temperature"]
              .replaceAll(',', '')
              .replaceAll('"', ''));
          var waterTempInFahrenheit = ((waterTemperature * 9 / 5) + 32);
          var dissolvedOxygen =
              double.parse(value["do"].replaceAll(',', '').replaceAll('"', ''));
          var timestamp = int.parse(key); // Parse the timestamp from the key
          var millis = timestamp;
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
          dataFromOtherDates.add(SensorData(waterTemperature, pH, timestamp, dt,
              waterTempInFahrenheit, dissolvedOxygen));
        });
        dataFromOtherDates.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        notifyListeners();
        return true;
      } else {
        print('Data is null.');
        return false;
      }
    } else {
      dataFromOtherDates = [];
      notifyListeners();
      return false;
    }
  }

  void fetchData() async {
    dataList.clear();
    DateTime current_date = DateTime.now();
    String date_today = current_date.toString().split(' ')[0];
    print("fetching data...");
    void streamSubscription = await ref
        .reference()
        .child("ATLAS/$date_today")
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value == null) {
        print(
            "no collection available yet in firebase realtime database for the date: $date_today");
      } else {
        Map<dynamic, dynamic> sensorDataMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        if (sensorDataMap != null) {
          sensorDataMap.forEach((key, value) {
            if (value != null) {
              var pH = double.parse(
                  value["ph"].replaceAll(',', '').replaceAll('"', ''));
              var waterTemperature = double.parse(value["water_temperature"]
                  .replaceAll(',', '')
                  .replaceAll('"', ''));
              var waterTempInFahrenheit = ((waterTemperature * 9 / 5) + 32);
              var dissolvedOxygen = double.parse(
                  value["do"].replaceAll(',', '').replaceAll('"', ''));
              var timestamp =
                  int.parse(key); // Parse the timestamp from the key
              var millis = timestamp;
              DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
              print(timestamp);
              dataList.add(SensorData(waterTemperature, pH, timestamp, dt,
                  waterTempInFahrenheit, dissolvedOxygen));
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
          recentDO = dataList[dataList.length - 1].dissolvedOxygen.toString();
          recentData = dataList[dataList.length - 1];
          notifyListeners();
        } else {
          recentPH = 'No data found.';
          recentWaterTemp = 'No data found.';
          recentDO = 'No data found.';
          recentData = null;
          notifyListeners();
        }
      }
    });
  }

  void _scheduleMidnightFetch() {
    Timer.periodic(Duration(hours: 24), (timer) {
      DateTime now = DateTime.now();
      DateTime midnight = DateTime(now.year, now.month, now.day, 0, 0, 0);

      if (now.isAfter(midnight)) {
        // It's after midnight, schedule fetch and reset timer for the next midnight
        print("in schedule midnight fetch");
        print("fetching data again....");
        fetchData();
        _scheduleMidnightFetch();
        timer.cancel();
      }
    });
  }
}
