import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
import 'package:week7_networking_discussion/providers/water_parameter_annotation_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

import 'package:week7_networking_discussion/screen_arguments/data_sensor_arguments.dart';
import 'package:intl/intl.dart';

class PhAnnotationPage extends StatefulWidget {
  const PhAnnotationPage({super.key});

  @override
  _PhAnnotationPageState createState() => _PhAnnotationPageState();
}

class _PhAnnotationPageState extends State<PhAnnotationPage> {
  double? lowerPHLevel;
  double? upperPHLevel;
  TextEditingController lowerPHTextController = TextEditingController();
  TextEditingController higherPHTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;

    final args =
        ModalRoute.of(context)!.settings.arguments as DataSensorArguments;
    print("args.date: ${args.date}");
    DateTime inputDate = DateTime.parse(args.date);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(inputDate);
    print(formattedDate);
    print("Before the build");
    for (int i = 0; i < args.dataList.length; i++) {
      print(args.dataList[i].ph);
      print(DateFormat("h:mm a").format(args.dataList[i].timeUpload));
    }
    print("After the build");

    final backButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
        },
        child: const Text('Back', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("PH Level Annotation")),
      body: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Text("$formattedDate",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "\t Legend:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align to the left
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Vertically centered
                        children: [
                          Text("\t \t \t \t \t"),
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(color: Colors.green),
                          ),
                          Text("\t Within the threshold"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align to the left
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Vertically centered
                        children: [
                          Text("\t \t \t \t \t"),
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(color: Colors.red),
                          ),
                          Text("\t Outside the threshold"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align to the left
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Vertically centered
                        children: [
                          Text("\t \t \t \t \t"),
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(color: Colors.orange),
                          ),
                          Text("\t Equal to one of the thresholds"),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(children: [
                        Text("Time",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: 20),
                            child: Text(
                              DateFormat("h:mm a")
                                  .format(args.dataList[i].timeUpload),
                              style: TextStyle(fontSize: 21),
                            ),
                          )
                      ])), // time
                      Expanded(
                          child: Column(children: [
                        Text("pH level",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: 20),
                            child: Text(
                              "${args.dataList[i].ph}",
                              style: TextStyle(fontSize: 21),
                            ),
                          )
                      ])), // ph
                      Expanded(
                          child: Column(children: [
                        Text("Status",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          args.dataList[i].ph < user!.lowerPH ||
                                  args.dataList[i].ph > user!.upperPH
                              ? Padding(
                                  padding: EdgeInsetsDirectional.only(top: 20),
                                  child: Container(
                                    width: 40,
                                    height: 25,
                                    decoration:
                                        BoxDecoration(color: Colors.red),
                                  ))
                              : args.dataList[i].ph == user!.lowerPH ||
                                      args.dataList[i].ph == user!.upperPH
                                  ? Padding(
                                      padding:
                                          EdgeInsetsDirectional.only(top: 20),
                                      child: Container(
                                        width: 40,
                                        height: 25,
                                        decoration:
                                            BoxDecoration(color: Colors.orange),
                                      ))
                                  : Padding(
                                      padding:
                                          EdgeInsetsDirectional.only(top: 20),
                                      child: Container(
                                        width: 40,
                                        height: 25,
                                        decoration:
                                            BoxDecoration(color: Colors.green),
                                      ))
                      ])), // status
                      Expanded(
                          child: Column(children: [
                        Text("Annotation",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          SizedBox(
                            height: 45,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('PH level Annotation'),
                                        actions: <Widget>[
                                          Expanded(
                                            child: TextField(
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'Enter annotation here',
                                                ),
                                                maxLines: null),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              print("args.date: ${args.date}");
                                              print(DateFormat("h:mm a").format(
                                                  args.dataList[i].timeUpload));

                                              var date = args.date;
                                              var time = DateFormat("h:mm a")
                                                  .format(args
                                                      .dataList[i].timeUpload);
                                              var water_parameter = "ph";
                                              var value = "sample";

                                              await context
                                                  .read<
                                                      WaterParameterAnnotationProvider>()
                                                  .addAnnotation(date, time,
                                                      water_parameter, value);
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Annotation saved successfully'),
                                                ),
                                              );
                                            },
                                            child: Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${args.dataList[i].timeUpload}",
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis, //r
                                          maxLines: 1, // Add this line
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                      ])), // annotation
                    ],
                  ),
                ),
              ),
              backButton
            ],
          )),
    );
  }
}
