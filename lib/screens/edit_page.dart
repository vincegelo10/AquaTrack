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

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
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
