import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
import 'package:week7_networking_discussion/providers/water_parameter_annotation_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

import 'package:week7_networking_discussion/screen_arguments/data_sensor_arguments.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterTemperatureAnnotationPage extends StatefulWidget {
  const WaterTemperatureAnnotationPage({super.key});

  @override
  _WaterTemperatureAnnotationPageState createState() =>
      _WaterTemperatureAnnotationPageState();
}

class _WaterTemperatureAnnotationPageState
    extends State<WaterTemperatureAnnotationPage> {
  double? lowerPHLevel;
  double? upperPHLevel;
  TextEditingController lowerPHTextController = TextEditingController();
  TextEditingController higherPHTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;

    var lowerTemp = user!.inFahrenheit == false
        ? user!.lowerTemp
        : ((user!.lowerTemp * 9 / 5) + 32);

    var upperTemp = user!.inFahrenheit == false
        ? user!.upperTemp
        : ((user!.upperTemp * 9 / 5) + 32);

    final TextEditingController _annotationController = TextEditingController();
    QuerySnapshot<Object?>? queryResult =
        context.watch<WaterParameterAnnotationProvider>().query;
    final args =
        ModalRoute.of(context)!.settings.arguments as DataSensorArguments;
    List<Widget> annotationWidgets = [];
    List<TextEditingController> textControllers = [];
    Widget _temperatureColumnBuilder() {
      if (user!.inFahrenheit) {
        return Expanded(
            child: Column(children: [
          SizedBox(height: 10),
          Text("Temp",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          for (int i = 0; i < args.dataList.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(top: 20),
              child: Text(
                "${args.dataList[i].waterTempInFahrenheit}",
                style: TextStyle(fontSize: 21),
              ),
            )
        ]));
      } else {
        return Expanded(
            child: Column(children: [
          SizedBox(height: 10),
          Text("Temp",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          for (int i = 0; i < args.dataList.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(top: 20),
              child: Text(
                "${args.dataList[i].waterTemperature}",
                style: TextStyle(fontSize: 21),
              ),
            )
        ]));
      }
    }

    for (int i = 0; i < args.dataList.length; i++) {
      textControllers.add(TextEditingController());
    }

    for (int i = 0; i < args.dataList.length; i++) {
      var text = "None";

      for (var document in queryResult!.docs) {
        // Access the data within each document
        String time = DateFormat("h:mm a").format(args.dataList[i].timeUpload);
        var data = document.data() as Map<String, dynamic>;

        // Access the "value" field
        var value = data['value'];

        // Print the value and the entire data

        if (data["time"] == time) {
          text = value;
          textControllers[i].text = text;
        }
      }
      annotationWidgets.add(SizedBox(
        height: 47,
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Water Temperature Annotation'),
                    actions: <Widget>[
                      Expanded(
                        child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter annotation here',
                            ),
                            controller: textControllers[i],
                            maxLines: null),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                          onPressed: () async {
                            var date = args.date;
                            var time = DateFormat("h:mm a")
                                .format(args.dataList[i].timeUpload);
                            var water_parameter = "water_temperature";

                            await context
                                .read<WaterParameterAnnotationProvider>()
                                .deleteAnnotation(
                                    date, time, water_parameter, user.email);
                            Navigator.of(context).pop(); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Annotation deleted successfully'),
                              ),
                            );
                          },
                          child: Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () async {
                            print("args.date: ${args.date}");
                            print(DateFormat("h:mm a")
                                .format(args.dataList[i].timeUpload));

                            var date = args.date;
                            var time = DateFormat("h:mm a")
                                .format(args.dataList[i].timeUpload);
                            var water_parameter = "water_temperature";
                            var value = textControllers[i].text;
                            print("water parameter is $water_parameter");

                            await context
                                .read<WaterParameterAnnotationProvider>()
                                .addAnnotation(date, time, water_parameter,
                                    value, user.email);
                            Navigator.of(context).pop(); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Annotation saved successfully'),
                              ),
                            );
                          },
                          child: Text('Save'),
                        ),
                      ])
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "$text",
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
      ));
    }

    print("args.date: ${args.date}");
    DateTime inputDate = DateTime.parse(args.date);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(inputDate);
    print(formattedDate);
    print("Before the build");
    for (int i = 0; i < args.dataList.length; i++) {
      print(args.dataList[i].ph);
      print(DateFormat("h:mm a").format(args.dataList[i].timeUpload));
    }
    // print("After the build");
    // for (int i = 0; i < args.dataList.length; i++) {
    //   print("user in fahrenheit: ${user!.inFahrenheit}");
    //   (user!.inFahrenheit == true &&
    //           (args.dataList[i].waterTempInFahrenheit < lowerTemp ||
    //               args.dataList[i].waterTempInFahrenheit > upperTemp))
    //       ? print("fahrenheit and red")
    //       : (user!.inFahrenheit == true &&
    //               (args.dataList[i].waterTempInFahrenheit == lowerTemp ||
    //                   args.dataList[i].waterTempInFahrenheit == upperTemp))
    //           ? print("fahrenheit and orange")
    //           : (user!.inFahrenheit == true &&
    //                   (args.dataList[i].waterTempInFahrenheit > lowerTemp &&
    //                       args.dataList[i].waterTempInFahrenheit < upperTemp))
    //               ? print("fahrenheit and green")
    //               : (user!.inFahrenheit == false &&
    //                       (args.dataList[i].waterTemperature < lowerTemp ||
    //                           args.dataList[i].waterTemperature > upperTemp))
    //                   ? print("celsius and red")
    //                   : (user!.inFahrenheit == false &&
    //                           (args.dataList[i].waterTemperature == lowerTemp ||
    //                               args.dataList[i].waterTemperature ==
    //                                   upperTemp))
    //                       ? print("celsius and orange")
    //                       : print("celsisus and green");
    // }

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
      appBar: AppBar(title: Text("Water Temperature Annotation")),
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
                        SizedBox(height: 10),
                        Text("Time",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          Padding(
                            padding: EdgeInsetsDirectional.only(top: 20),
                            child: Text(
                              DateFormat("HH:mm")
                                  .format(args.dataList[i].timeUpload),
                              style: TextStyle(fontSize: 21),
                            ),
                          )
                      ])), // time
                      _temperatureColumnBuilder(),
                      Expanded(
                          child: Column(children: [
                        SizedBox(height: 10),
                        Text("Status",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        for (int i = 0; i < args.dataList.length; i++)
                          //if fahrenheit,
                          (user!.inFahrenheit == true &&
                                  (args.dataList[i].waterTempInFahrenheit < lowerTemp ||
                                      args.dataList[i].waterTempInFahrenheit >
                                          upperTemp))
                              ? Padding(
                                  padding: EdgeInsetsDirectional.only(top: 20),
                                  child: Container(
                                    width: 40,
                                    height: 27,
                                    decoration:
                                        BoxDecoration(color: Colors.red),
                                  ))
                              : (user!.inFahrenheit == true &&
                                      (args.dataList[i].waterTempInFahrenheit == lowerTemp ||
                                          args.dataList[i].waterTempInFahrenheit ==
                                              upperTemp))
                                  ? Padding(
                                      padding:
                                          EdgeInsetsDirectional.only(top: 20),
                                      child: Container(
                                        width: 40,
                                        height: 27,
                                        decoration:
                                            BoxDecoration(color: Colors.orange),
                                      ))
                                  : (user!.inFahrenheit == true &&
                                          (args.dataList[i].waterTempInFahrenheit > lowerTemp &&
                                              args.dataList[i].waterTempInFahrenheit <
                                                  upperTemp))
                                      ? Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              top: 20),
                                          child: Container(
                                            width: 40,
                                            height: 27,
                                            decoration: BoxDecoration(
                                                color: Colors.green),
                                          ))
                                      : (user!.inFahrenheit == false &&
                                              (args.dataList[i].waterTemperature < lowerTemp ||
                                                  args.dataList[i].waterTemperature >
                                                      upperTemp))
                                          ? Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                  top: 20),
                                              child: Container(
                                                width: 40,
                                                height: 27,
                                                decoration: BoxDecoration(
                                                    color: Colors.red),
                                              ))
                                          : (user!.inFahrenheit == false &&
                                                  (args.dataList[i].waterTemperature == lowerTemp ||
                                                      args.dataList[i].waterTemperature == upperTemp))
                                              ? Padding(
                                                  padding: EdgeInsetsDirectional.only(top: 20),
                                                  child: Container(
                                                    width: 40,
                                                    height: 27,
                                                    decoration: BoxDecoration(
                                                        color: Colors.orange),
                                                  ))
                                              : Padding(
                                                  padding: EdgeInsetsDirectional.only(top: 20),
                                                  child: Container(
                                                    width: 40,
                                                    height: 27,
                                                    decoration: BoxDecoration(
                                                        color: Colors.green),
                                                  ))
                      ])), // status
                      Expanded(
                          child: Column(children: [
                        SizedBox(height: 10),
                        Text("Annotation",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        ...annotationWidgets,
                        SizedBox(height: 10)
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
