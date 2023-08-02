/*
  Created by: Claizel Coubeili Cepe
  Date: 27 October 2022
  Description: Sample todo app with networking
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/todo_model.dart';
import 'package:week7_networking_discussion/providers/todo_provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screens/modal_todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';

class PH_Page extends StatefulWidget {
  const PH_Page({super.key});

  @override
  State<PH_Page> createState() => _PHPageState();
}

class _PHPageState extends State<PH_Page> {
  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(height: 100),
        ListTile(
          title: const Text('Logout'),
          onTap: () {
            context.read<AuthProvider>().signOut();
            Navigator.pushNamed(context, "/");
          },
        ),
      ])),
      appBar: AppBar(
        title: Text("PH Page"),
      ),
      body: Text("PH Page!"),
      // body: StreamBuilder(
      //   stream: todosStream,
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text("Error encountered! ${snapshot.error}"),
      //       );
      //     } else if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     } else if (!snapshot.hasData) {
      //       return Center(
      //         child: Text("No Todos Found"),
      //       );
      //     }

      //     return ListView.builder(
      //       itemCount: snapshot.data?.docs.length,
      //       itemBuilder: ((context, index) {
      //         Todo todo = Todo.fromJson(
      //             snapshot.data?.docs[index].data() as Map<String, dynamic>);
      //         return Dismissible(
      //           key: Key(todo.id.toString()),
      //           onDismissed: (direction) {
      //             context.read<TodoListProvider>().changeSelectedTodo(todo);
      //             context.read<TodoListProvider>().deleteTodo();

      //             ScaffoldMessenger.of(context).showSnackBar(
      //                 SnackBar(content: Text('${todo.title} dismissed')));
      //           },
      //           background: Container(
      //             color: Colors.red,
      //             child: const Icon(Icons.delete),
      //           ),
      //           child: ListTile(
      //             title: Text(todo.title),
      //             leading: Checkbox(
      //               value: todo.completed,
      //               onChanged: (bool? value) {
      //                 context
      //                     .read<TodoListProvider>()
      //                     .toggleStatus(index, value!);
      //               },
      //             ),
      //             trailing: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 IconButton(
      //                   onPressed: () {
      //                     // showDialog(
      //                     //   context: context,
      //                     //   builder: (BuildContext context) => TodoModal(
      //                     //     type: 'Edit',
      //                     //     todoIndex: index,
      //                     //   ),
      //                     // );
      //                   },
      //                   icon: const Icon(Icons.create_outlined),
      //                 ),
      //                 IconButton(
      //                   onPressed: () {
      //                     context
      //                         .read<TodoListProvider>()
      //                         .changeSelectedTodo(todo);
      //                     showDialog(
      //                       context: context,
      //                       builder: (BuildContext context) => TodoModal(
      //                         type: 'Delete',
      //                       ),
      //                     );
      //                   },
      //                   icon: const Icon(Icons.delete_outlined),
      //                 )
      //               ],
      //             ),
      //           ),
      //         );
      //       }),
      //     );
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => TodoModal(
              type: 'Add',
            ),
          );
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
