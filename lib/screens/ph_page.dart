/*
  Created by: Claizel Coubeili Cepe
  Date: 27 October 2022
  Description: Sample todo app with networking
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/todo_model.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/screens/modal_todo.dart';
import 'package:week7_networking_discussion/models/sensor_data_model.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class PH_Page extends StatefulWidget {
  const PH_Page({super.key});

  @override
  State<PH_Page> createState() => _PHPageState();
}

class _PHPageState extends State<PH_Page> {
  TextEditingController dateController = TextEditingController();

  Widget _currentDateGraphBuilder(List<SensorData> dataList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: SfCartesianChart(
          backgroundColor: Colors.white,
          primaryXAxis: DateTimeAxis(
            title: AxisTitle(
                text: "PH level over time",
                textStyle: TextStyle(
                    color: Colors.deepOrange,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300)),
            majorGridLines: MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('hh:mm a'), // Use custom time format here
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Enable panning
            enablePinching: true, // Enable zooming
            zoomMode: ZoomMode.x, // Zoom in the X-axis direction only
          ),
          series: [
            LineSeries<SensorData, DateTime>(
              dataSource: dataList,
              xValueMapper: (SensorData data, _) => data.timeUpload,
              yValueMapper: (SensorData data, _) => data.ph,
              markerSettings: MarkerSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDateToday = currentDate.toString().split(' ')[0];

    User? user = context.watch<UserProvider>().user;
    String labelData = dateController.text != formattedDateToday &&
            dateController.text.isNotEmpty
        ? "PH Level trends on ${dateController.text}"
        : "PH Level trends today";

    // access the list of todos in the provider
    // DateTime current_date = DateTime.now();
    // String date_today = current_date.toString();
    // final ref = FirebaseDatabase(
    //   databaseURL:
    //       "https://sp2-firebase-default-rtdb.asia-southeast1.firebasedatabase.app/");
    // var stream = await ref.reference().child("data_sensor/$date_today").onValue.listen((DatabaseEvent event){
    //   print("Received data: ${event.snapshot.value}");
    // });

    // Stream<QuerySnapshot> todosStream = await ref.reference().child('data_sensor/$date_today').get();

    // StreamSubscription<Event> _databaseSubscription = await ref.reference().child(date_today).onValue.listen((Event event) {
    //   // Handle data updates here
    //   // The most recent data will be available in 'event.snapshot.value'
    //   print("Received data: ${event.snapshot.value}");
    // });
    //}
    // List<SensorData> dataList =
    //     context.watch<SensorDataProvider>().dataFromOtherDate.isNotEmpty
    //         ? context.watch<SensorDataProvider>().dataFromOtherDate
    //         : context.watch<SensorDataProvider>().dataFromSensor;
    List<SensorData> dataList = dateController.text != formattedDateToday &&
            dateController.text.isNotEmpty
        ? context.watch<SensorDataProvider>().dataFromOtherDate
        : context.watch<SensorDataProvider>().dataFromSensor;
    print("the date today isi $formattedDateToday");
    print("----------------------");
    print(dateController.text);
    print(formattedDateToday);
    print(dateController.text != formattedDateToday);
    print("----------------------");
    // print(context.watch<SensorDataProvider>().dataFromOtherDate);
    // print(context.watch<SensorDataProvider>().dataFromOtherDate.isEmpty);
    // print(context.watch<SensorDataProvider>().dataFromSensor);
    // print(context.watch<SensorDataProvider>().dataFromOtherDate == []);
    var phVal = context.watch<SensorDataProvider>().phLevel == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().phLevel;

    void showNoDataDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Data Available'),
            content: Text('Sorry, no data is available.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    Widget recentTimeUpload(BuildContext context) {
      List<SensorData> data =
          context.watch<SensorDataProvider>().dataFromSensor;

      if (data.length == 0) {
        return Text("Data not available",
            style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white, // Set the text color to white
                fontSize: 10));
      } else {
        DateTime lastUpload = data[data.length - 1].timeUpload;
        String formattedTime =
            DateFormat('hh:mm a').format(lastUpload).toString();
        return Text("last uploaded by Arduino at $formattedTime",
            style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white, // Set the text color to white
                fontSize: 10));
      }
    }

    return Scaffold(
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          SizedBox(height: 100),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthProvider>().signOut();
              context.read<UserProvider>().removeLoggedInUserDetails();
              Navigator.pushNamed(context, "/");
            },
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, "/");
            },
          ),
        ])),
        appBar: AppBar(
          title: Text("PH Level Page"),
        ),
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            height: 140, // Set the desired height of the square
                            decoration: BoxDecoration(
                              color: Colors
                                  .green, // Set the desired color of the square
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust the radius to control the roundness
                            ),
                            child: Column(children: [
                              Text(
                                "PH Level",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                  color: Colors
                                      .white, // Set the text color to white
                                ),
                              ),
                              SizedBox(height: 25),
                              Text(
                                "$phVal",
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                    color: Colors
                                        .white, // Set the text color to white
                                    fontSize: 40),
                              ),
                              Expanded(
                                  child: Align(
                                alignment: Alignment.bottomCenter,
                                child: recentTimeUpload(context),
                              )),
                              SizedBox(height: 8),
                            ])),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: 140, // Set the desired height of the square
                          decoration: BoxDecoration(
                            color: Colors
                                .yellow, // Set the desired color of the square
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius to control the roundness
                          ),
                          child: Column(children: [
                            Text(
                              "PH Threshold",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "${user!.lowerPH} - ${user!.upperPH}",
                              style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                  color: Colors
                                      .white, // Set the text color to white
                                  fontSize: 35),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    // Text("PH Level: $phVal"),
                    // Text("PH Threshold: ${user!.lowerPH}-${user!.upperPH}"),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  labelData,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.black, // Set the text color to white
                      fontSize: 20),
                ),
                Center(child: _currentDateGraphBuilder(dataList)),
                TextField(
                    controller:
                        dateController, //editing controller of this TextField
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText:
                            "Enter a date from which to see PH trends" //label text of field

                        ),
                    readOnly: true, // when true user cannot edit text

                    onTap: () async {
                      //when click we have to show the datepicker

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), //get today's date
                        firstDate:
                            DateTime(2000), // Set your desired start date
                        lastDate: DateTime.now(),
                      ); // Disable future dates);

                      if (pickedDate != null) {
                        print(
                            pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                        String formattedDate = DateFormat('yyyy-MM-dd').format(
                            pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                        print(
                            formattedDate); //formatted date output using intl package =>  2022-07-04
                        //You can format date as per your need

                        setState(() {
                          dateController.text =
                              formattedDate; //set foratted date to TextField value.
                        });
                        bool success = await context
                            .read<SensorDataProvider>()
                            .fetchDataFromOtherDate(formattedDate);

                        if (!success) {
                          showNoDataDialog(context);
                        }
                      } else {
                        print("Date is not selected");
                      }
                    })
              ],
            )));
  }
}
