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
    lowerPHTextController.text = user!.lowerPH.toString();
    higherPHTextController.text = user!.upperPH.toString();
    final args =
        ModalRoute.of(context)!.settings.arguments as DataSensorArguments;
    print("args.date: ${args.date}");
    DateTime inputDate = DateTime.parse(args.date);
    String formattedDate = DateFormat('EEEE, MMM d, y').format(inputDate);
    print(formattedDate);
    for (int i = 0; i < args.dataList.length; i++) {
      print(args.dataList[i].ph);
      print(DateFormat("h:mm a").format(args.dataList[i].timeUpload));
    }
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
      backgroundColor: Colors.white,
      body: Center(
          child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Text(
              "Set pH Threshold",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            lowerPHField,
            upperPHField,
            saveButton,
            backButton,
          ],
        ),
      )),
    );
  }
}
