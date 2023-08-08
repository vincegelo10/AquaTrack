/*
  Created by: Claizel Coubeili Cepe
  Date: 27 October 2022
  Description: Sample todo app with networking
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/todo_model.dart';
import 'package:week7_networking_discussion/providers/todo_provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screens/modal_todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//for firebase real time database
import 'package:firebase_database/firebase_database.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

class SensorData {
  final double waterTemperature;
  final double pH;
  final int timestamp;

  SensorData(this.waterTemperature, this.pH, this.timestamp);
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   _subscribeToSensorData();
  // }

  // void _subscribeToSensorData() async {
  //   DateTime current_date = DateTime.now();
  //   String date_today = current_date.toString().split(' ')[0];
  //   final ref = FirebaseDatabase(
  //       databaseURL:
  //           "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/");

  //   void streamSubscription = await ref
  //       .reference()
  //       .child("data_sensor/$date_today")
  //       .onValue
  //       .listen((DatabaseEvent event) {
  //     // Update lastVal and trigger a rebuild
  //     setState(() {
  //       Map<dynamic, dynamic> sensorDataMap =
  //           event.snapshot.value as Map<dynamic, dynamic>;
  //       List<SensorData> dataList = [];
  //       if (sensorDataMap != null) {
  //         sensorDataMap.forEach((key, value) {
  //           if (value != null) {
  //             var waterTemperature = value["water_temperature"].toDouble();
  //             var pH = value["pH"].toDouble();
  //             var timestamp =
  //                 int.parse(key); // Parse the timestamp from the key

  //             dataList.add(SensorData(waterTemperature, pH, timestamp));
  //           }
  //         });

  //         // Sort the dataList based on the timestamp in ascending order
  //         dataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  //       }

  //       // Update lastVal with the latest pH value
  //       if (dataList.isNotEmpty) {
  //         setState(() {
  //           lastVal = dataList[dataList.length - 1].pH.toString();
  //         });

  //         print("recent pH value: $lastVal");
  //       } else {
  //         lastVal = 'No data found.';
  //         print("No data found.");
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // User? user = context.read<AuthProvider>().user;
    // access the list of todos in the provider
    // Stream<QuerySnapshot> todosStream = context.watch<TodoListProvider>().todos;
    // var lastVal = 'none';
    User? user = context.watch<UserProvider>().user;
    return Scaffold(
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          SizedBox(height: 100),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthProvider>().signOut();
              context.read<UserProvider>().removeLoggedInUserDetails();
              Navigator.pop(context);
            },
          ),
        ])),
        appBar: AppBar(
          title: Text("AquaTrack"),
        ),
        body: Center(
          // Wrap the ListView with a Container and set the width
          child: Container(
            width: 250, // Set the desired width for the ListView
            child: ListView(
              // Use children property to define the list of widgets
              children: [
                SizedBox(height: 40),
                Align(
                  alignment:
                      Alignment.center, // Center the text within the container
                  child: Text(
                    "Hello, What do you want to track?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.black, // Set the text color to white
                      fontSize: 30,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    //sample of writing data to firebase realtime database

                    // final firebaseRef = FirebaseDatabase(
                    //         databaseURL:
                    //             "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/")
                    //     .reference()
                    //     .child("data_sensor/2");

                    // await firebaseRef.set({
                    //   "pH": 7.5,
                    //   "water_temperature": 23.5,
                    // });

                    //reading of data from firebase realtime database - read once with get()
                    // DateTime current_date = DateTime.now();
                    // print("current date: $current_date");
                    // String date_today = current_date.toString().split(' ')[0];
                    // final ref = FirebaseDatabase(
                    //     databaseURL:
                    //         "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/");
                    // Stream<DataSnapshot> todosStream = await ref.reference().child('data_sensor/$date_today').get();
                    // print("2");
                    // if (snapshot.exists) {
                    //   print(snapshot.value);
                    // } else {
                    //   print('No data available.');
                    // }

                    // DateTime current_date = DateTime.now();
                    // String date_today = current_date.toString().split(' ')[0];
                    // // String date_today = "2023-08-03";
                    // final ref = FirebaseDatabase(
                    //     databaseURL:
                    //         "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/");
                    // print(date_today);
                    // StreamSubscription<DatabaseEvent> stream = await ref
                    //     .reference()
                    //     .child("data_sensor/$date_today")
                    //     .onValue
                    //     .listen((DatabaseEvent event) {
                    //   Map<Object?, Object?> sensor_data =
                    //       event.snapshot.value as Map<Object?, Object?>;
                    //   sensor_data.forEach((key, value) {
                    //     print("key: $key");
                    //     print('value: $value');

                    //     // Access the timestamp of the update
                    //   });
                    // });
                    // print(stream);

                    // StreamSubscription<DatabaseEvent> stream = await ref
                    //     .reference()
                    //     .child("data_sensor/$date_today")
                    //     .onValue
                    //     .listen((DatabaseEvent event) {
                    //   Map<dynamic, dynamic> sensorDataMap =
                    //       event.snapshot.value as Map<dynamic, dynamic>;
                    //   List<SensorData> dataList = [];
                    //   print("no problems here");
                    //   if (sensorDataMap != null) {
                    //     sensorDataMap.forEach((key, value) {
                    //       if (value != null) {
                    //         var waterTemperature =
                    //             value["water_temperature"].toDouble();
                    //         var pH = value["pH"].toDouble();
                    //         var timestamp = int.parse(
                    //             key); // Parse the timestamp from the key

                    //         dataList.add(
                    //             SensorData(waterTemperature, pH, timestamp));
                    //       }
                    //     });

                    //     // Sort the dataList based on the timestamp in ascending order
                    //     dataList
                    //         .sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    //   }

                    // Print the data in ascending order of timestamp
                    //   if (dataList.isNotEmpty) {
                    //     print("Data in Ascending Order based on Timestamp:");
                    //     for (var data in dataList) {
                    //       print("Timestamp: ${data.timestamp}");
                    //       print("Water Temperature: ${data.waterTemperature}");
                    //       print("pH Value: ${data.pH}");
                    //       print("");
                    //     }
                    //     setState(() {
                    //       lastVal = dataList[dataList.length - 1].pH.toString();
                    //       print("recent pH value: $lastVal");
                    //     });
                    //   } else {
                    //     print("No data found.");
                    //   }
                    // });

                    // Map<Object?, Object?> sensor_data =
                    //     event.snapshot.value as Map<Object?, Object?>;
                    // sensor_data.forEach((key, value) {
                    //   print("key: $key");
                    //   print('value: $value');

                    //   // Access the timestamp of the update
                    // });
                    // Stream<Qu
                    Navigator.pushNamed(context, "/phPage");

                    // try {
                    //   await ref
                    //       .child("path")
                    //       .set({"pH": 2.3, "water_temperature": 23.2});
                    // } catch (e) {
                    //   print("Error: $e");
                    // }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      height: 140, // Set the desired height of the square
                      decoration: BoxDecoration(
                        color:
                            Colors.blue, // Set the desired color of the square
                        borderRadius: BorderRadius.circular(
                            20), // Adjust the radius to control the roundness
                      ),
                      child: Center(
                          child: Column(children: [
                        Image(
                          image: AssetImage('assets/images/PHLevel-nobg.png'),
                          width: 80,
                          height: 104,
                          color: Colors.white,
                        ),
                        Text(
                          "PH Level",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the text bold
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                      ])),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tempPage');
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      height: 140, // Set the desired height of the square
                      decoration: BoxDecoration(
                        color:
                            Colors.blue, // Set the desired color of the square
                        borderRadius: BorderRadius.circular(
                            20), // Adjust the radius to control the roundness
                      ),
                      child: Center(
                          child: Column(children: [
                        Image(
                          image: AssetImage('assets/images/temp-nobg2.png'),
                          width: 80,
                          height: 104,
                          color: Colors.white,
                        ),
                        Text(
                          "Temperature",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Make the text bold
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                      ])),
                    ),
                  ),
                )

                // Add more items to the ListView as needed...
              ],
            ),
          ),
        ));
  }
}

// Center(
//           // Wrap the ListView with a Container and set the width
//           child: Container(
//             width: 200, // Set the desired width for the ListView
//             child: ListView(
//               // Use children property to define the list of widgets
//               children: [
//                 Container(
//                   padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
//                   height: 120, // Set the desired height of the square
//                   decoration: BoxDecoration(
//                     color: Colors.blue, // Set the desired color of the square
//                     borderRadius: BorderRadius.circular(
//                         20), // Adjust the radius to control the roundness
//                   ),
//                   child: Center(child: Text("PH Level")),
//                 ),
//                 // Add more items to the ListView as needed...
//               ],
//             ),
//           ),
// )


// StreamSubscription<DatabaseEvent> stream = await ref
//   .reference()
//   .child("data_sensor/$date_today")
//   .onValue
//   .listen((DatabaseEvent event) {
//     Map<dynamic, dynamic> sensorDataMap = event.snapshot.value;
//     List<SensorData> dataList = [];

//     if (sensorDataMap != null) {
//       sensorDataMap.forEach((key, value) {
//         var waterTemperature = value["water_temperature"] as String;
//         var pH = value["pH"] as String;
//         var timestamp = int.parse(key); // Parse the timestamp from the key
//         dataList.add(SensorData(waterTemperature, pH, timestamp));
//       });

//       // Sort the dataList based on the timestamp in ascending order
//       dataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//     }

//     // Print the data in ascending order of timestamp
//     if (dataList.isNotEmpty) {
//       print("Data in Ascending Order based on Timestamp:");
//       for (var data in dataList) {
//         print("Timestamp: ${data.timestamp}");
//         print("Water Temperature: ${data.waterTemperature}");
//         print("pH Value: ${data.pH}");
//         print("");
//       }
//     } else {
//       print("No data found.");
//     }
// });