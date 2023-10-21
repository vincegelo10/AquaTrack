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
import 'package:week7_networking_discussion/providers/water_parameter_annotation_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/data_sensor_arguments.dart';
import 'package:week7_networking_discussion/screens/modal_todo.dart';
import 'package:week7_networking_discussion/models/sensor_data_model.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:week7_networking_discussion/services/local_notification_service.dart';

class DO_Page extends StatefulWidget {
  const DO_Page({super.key});

  @override
  State<DO_Page> createState() => _DOPageState();
}

class _DOPageState extends State<DO_Page> {
  late final NotificationService service;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    service = NotificationService();
    service.initializePlatformNotifications();
    super.initState();
  }

  void checkAndShowNotification() {
    User? user = context.watch<UserProvider>().user;
    if (user == null) {
      return;
    }
    DateTime currentDate = DateTime.now();
    DateTime now = DateTime.now();
    int timestampInSeconds = now.millisecondsSinceEpoch ~/ 1000;
    var updatedData = context.watch<SensorDataProvider>().updatedSensorData;
    String phVal = context.watch<SensorDataProvider>().phLevel == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().phLevel;
    String doVal = context.watch<SensorDataProvider>().dissolvedOxygen == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().dissolvedOxygen;
    String tempVal = context.watch<SensorDataProvider>().waterTemp == ''
        ? 'NA'
        : user!.inFahrenheit == false
            ? context.watch<SensorDataProvider>().recentWaterTemp
            : ((double.parse(context
                            .watch<SensorDataProvider>()
                            .recentWaterTemp) *
                        9 /
                        5) +
                    32)
                .toString();
    double lowerTemp = user!.inFahrenheit == false
        ? user!.lowerTemp
        : ((user!.lowerTemp * 9 / 5) + 32);

    double upperTemp = user!.inFahrenheit == false
        ? user!.upperTemp
        : ((user!.upperTemp * 9 / 5) + 32);

    if (updatedData?.timestamp != null) {
      //notification for PH outside of threshold
      if (phVal != 'NA' &&
          (double.parse(phVal) < user!.lowerPH ||
              double.parse(phVal) > user!.upperPH) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        print("Showing notification for ph");
        service.showNotification(
          id: 1,
          title: 'PH Level out of range!',
          body:
              'Current PH Level: $phVal is not within the set threshold of ${user!.lowerPH}-${user!.upperPH}',
        );
      }
      //notification for temperature outside of threshold
      if (tempVal != 'NA' &&
          (double.parse(tempVal) < lowerTemp ||
              double.parse(tempVal) > upperTemp) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 2,
          title: 'Water Temperature out of range!',
          body:
              'Current Water Temperature: $tempVal is not within the set threshold of $lowerTemp-$upperTemp',
        );
      }

      //notification for DO outside of threshold
      if (doVal != 'NA' &&
          (double.parse(doVal) < user!.lowerDO ||
              double.parse(doVal) > user!.upperDO) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 3,
          title: 'Dissolved Oxygen out of range!',
          body:
              'Current Dissolved Oxygen: $doVal is not within the set threshold of ${user!.lowerDO}-${user!.upperDO}',
        );
      }
    }
  }

  Widget _graphBuilder(List<SensorData> dataList, user) {
    //User user = context.watch<UserProvider>().user as User;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: SfCartesianChart(
          backgroundColor: Colors.white,
          primaryXAxis: DateTimeAxis(
            title: AxisTitle(
                text: "DO trends over time",
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
                color: Colors.black,
                dataSource: dataList,
                xValueMapper: (SensorData data, _) => data.timeUpload,
                yValueMapper: (SensorData data, _) => data.dissolvedOxygen,
                markerSettings: MarkerSettings(isVisible: true),
                pointColorMapper: (SensorData data, _) {
                  if (data.dissolvedOxygen < user.lowerDO ||
                      data.dissolvedOxygen > user.upperDO) {
                    print("return red");
                    return Colors.red;
                  } else if (data.dissolvedOxygen == user.lowerDO ||
                      data.dissolvedOxygen == user.upperDO) {
                    print("return orange");
                    return Colors.orange;
                  } else {
                    print("return green");
                    return Colors.green;
                  }
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    DateTime currentDate = DateTime.now();
    String formattedDateToday = currentDate.toString().split(' ')[0];

    String labelData = dateController.text != formattedDateToday &&
            dateController.text.isNotEmpty
        ? "DO trends on ${dateController.text}"
        : "Dissolved Oxygen trends today";

    List<SensorData> dataList = dateController.text != formattedDateToday &&
            dateController.text.isNotEmpty
        ? context.watch<SensorDataProvider>().dataFromOtherDate
        : context.watch<SensorDataProvider>().dataFromSensor;

    var doVal = context.watch<SensorDataProvider>().dissolvedOxygen == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().dissolvedOxygen;
    checkAndShowNotification();

    _onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/');
          break;
        case 1:
          Navigator.pushNamed(context, '/editPage');
          break;
      }
    }

    if (user != null) {
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

      void showPhThresholdDialog(BuildContext context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('DO Threshold'),
              content: Text(
                  'The Dissolved Oxygen threshold is between ${user.lowerDO}-${user.upperDO}. Do you want to edit it?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        SizedBox(width: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, "/editDissolvedOxygenPage");
                            },
                            child: Text("Yes")),
                      ]),
                ),
              ],
            );
          },
        );
      }

      void showDOAnnotationDialog(BuildContext context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Dissolved Oxygen'),
              content: Text(
                  'Do you want to view and annotate the Dissolved Oxygen data?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        SizedBox(width: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Background color
                            ),
                            onPressed: () {
                              String dateArgument = dateController.text.isEmpty
                                  ? formattedDateToday
                                  : dateController.text;
                              //DO ME
                              context
                                  .read<WaterParameterAnnotationProvider>()
                                  .fetchAnnotation(
                                      dateArgument, "do", user.email);
                              Navigator.pop(context);
                              //DO ME
                              Navigator.pushNamed(
                                  context, '/DissolvedOxygenAnnotationPage',
                                  arguments: DataSensorArguments(
                                      dataList, dateArgument));
                            },
                            child: Text("Yes")),
                      ]),
                ),
              ],
            );
          },
        );
      }

      void showDODialog(BuildContext context) {
        String status;
        try {
          if (double.parse(doVal) > user.lowerDO &&
              double.parse(doVal) < user.upperDO) {
            status = "which is within the defined DO theshold";
          } else if (double.parse(doVal) == user.lowerPH ||
              double.parse(doVal) == user.upperPH) {
            if (double.parse(doVal) == user.lowerPH) {
              status = "which is equal to the defined lower PH threshold";
            } else {
              status = "which is equal to the defined upper PH threshold";
            }
          } else {
            status = "which is outside the defined PH theshold";
          }
        } catch (e) {
          status = "which means that no data is being uploaded by the Arduino";
          print(e);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Dissolved Oxygen'),
              content: Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // Adjust the width as needed
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'The current dissolved oxygen is $doVal, $status. The color of this widget changes according to the ff:',
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Within the threshold:"),
                        SizedBox(width: 10),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Equal to one of the threshold: "),
                        SizedBox(width: 10),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.orange),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Outside the threshold: "),
                        SizedBox(width: 10),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Data not available: "),
                        SizedBox(width: 10),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("OK")),
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

      Widget dissolvedOxygenWidgetBuilder() {
        var colorOfWidget;

        try {
          if (double.parse(doVal) > user.lowerDO &&
              double.parse(doVal) < user.upperDO) {
            colorOfWidget = Colors.green;
          } else if (double.parse(doVal) == user.lowerDO ||
              double.parse(doVal) == user.upperDO) {
            colorOfWidget = Colors.orange;
          } else {
            colorOfWidget = Colors.red;
          }
        } catch (e) {
          colorOfWidget = Colors.black;
          print(e);
        }

        return Padding(
          padding: EdgeInsets.all(5),
          child: Container(
              height: 140, // Set the desired height of the square
              decoration: BoxDecoration(
                color: colorOfWidget, // Set the desired color of the square
                borderRadius: BorderRadius.circular(
                    20), // Adjust the radius to control the roundness
              ),
              child: Column(children: [
                Text(
                  "Dissolved Oxygen",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.white, // Set the text color to white
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "$doVal",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.white, // Set the text color to white
                      fontSize: 40),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: recentTimeUpload(context),
                )),
                SizedBox(height: 8),
              ])),
        );
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
          title: Text(
            "Dissolved Oxygen Page",
            style: TextStyle(
              color: Colors.white, // Set the text color here
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        showDODialog(context);
                      },
                      child: dissolvedOxygenWidgetBuilder(),
                    )),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showPhThresholdDialog(context);
                        },
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
                                "DO Threshold",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                  color: Colors
                                      .white, // Set the text color to white
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(
                                "${user.lowerDO} - ${user.upperDO}",
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
                    ),

                    // Text("PH Level: $phVal"),
                    // Text("PH Threshold: ${user!.lowerPH}-${user!.upperPH}"),
                  ],
                ),
                SizedBox(height: 10),
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .cyan, // Set the desired color of the square
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius to control the roundness
                          ),
                          child: Column(children: [
                            SizedBox(height: 10),
                            Center(
                              child: Text(
                                labelData,
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                    color: Colors
                                        .white, // Set the text color to white
                                    fontSize: 20),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(child: _graphBuilder(dataList, user)),
                            SizedBox(height: 10),
                          ])),
                    ),
                    onTap: () {
                      showDOAnnotationDialog(context);
                      //pass screen arguments here - data from sensor and the date
                    }),
                TextField(
                    controller:
                        dateController, //editing controller of this TextField
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText:
                            "Enter a date from which to see DO trends" //label text of field

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
                    }),
              ],
            )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.cyan,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
            ),
          ],
          currentIndex: 0,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          unselectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          onTap: _onItemTapped,
        ),
      );
    } else {
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
          title: Text(
            "Dissolved Oxygen Page",
            style: TextStyle(
              color: Colors.white, // Set the text color here
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [CircularProgressIndicator()],
            )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.cyan,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
            ),
          ],
          currentIndex: 0,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          unselectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          onTap: _onItemTapped,
        ),
      );
    }
  }
}
