import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
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
    final lowerPHField = TextFormField(
        controller: lowerPHTextController,

        // initialValue: user!.lowerPH.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Lower PH Threshold",
          labelText: "Lower PH Threshold",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lower PH Level is required';
          }
          try {
            double PH = double.parse(value!);
            if ((PH < 0 || PH > 14)) {
              return 'PH level should be between 0 and 14 inclusive';
            }
            try {
              double higherPH = double.parse(higherPHTextController.text);
              if (PH > higherPH) {
                return 'This value should be less than the higher PH level';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Input must be a floating point';
          }
        },
        onSaved: ((String? value) {
          lowerPHLevel = double.parse(value!);
        }));

    final upperPHField = TextFormField(
        controller: higherPHTextController,
        // initialValue: user!.upperPH.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Upper PH Threshold",
          labelText: "Upper PH Threshold",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher PH Level is required';
          }
          try {
            double PH = double.parse(value!);
            if ((PH < 0 || PH > 14)) {
              return 'PH level should be between 0 and 14 inclusive';
            }
            try {
              double lowerPH = double.parse(lowerPHTextController.text);
              if (PH < lowerPH) {
                return 'This value should be greater than the lower PH level';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Input must be a floating point';
          }
        },
        onSaved: ((String? value) {
          upperPHLevel = double.parse(value!);
        }));

    final saveButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          //call the auth provider here
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();
            context
                .read<UserProvider>()
                .editPH(user!.email, lowerPHLevel!, upperPHLevel!);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('PH Threshold edit has been successful.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Close the form screen
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );

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
                                  print("clicked!");
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
                                          overflow: TextOverflow.ellipsis, //
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
