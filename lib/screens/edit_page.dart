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
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';

//for firebase real time database
import 'package:firebase_database/firebase_database.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/services/local_notification_service.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late final NotificationService service;
  @override
  void initState() {
    service = NotificationService();
    service.initializePlatformNotifications();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the logic that depends on context to didChangeDependencies
    checkAndShowNotification();
  }

  void checkAndShowNotification() {
    User user = context.watch<UserProvider>().user!;
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

  @override
  Widget build(BuildContext context) {
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
        ListTile(
          title: const Text('Edit'),
          onTap: () {
            Navigator.pushNamed(context, "/editPage");
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
                  "Choose water parameter to edit",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.black, // Set the text color to white
                    fontSize: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.pushNamed(context, '/editPhPage');
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    height: 140, // Set the desired height of the square
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set the desired color of the square
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
                  Navigator.pushNamed(
                    context,
                    '/editTempPage',
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    height: 140, // Set the desired height of the square
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set the desired color of the square
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
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/editDissolvedOxygenPage',
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    height: 140, // Set the desired height of the square
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set the desired color of the square
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the radius to control the roundness
                    ),
                    child: Center(
                        child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/do-nobg.png'),
                        width: 80,
                        height: 104,
                        color: Colors.white,
                      ),
                      Text(
                        "Dissolved Oxygen",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make the text bold
                          color: Colors.white, // Set the text color to white
                        ),
                      ),
                    ])),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
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
        currentIndex: 1,
        unselectedItemColor: Colors.white,
        // selectedItemColor: Color.fromARGB(255, 106, 99, 90),
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
