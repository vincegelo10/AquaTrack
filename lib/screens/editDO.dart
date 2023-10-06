import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

class EditDissolvedOxygenPage extends StatefulWidget {
  const EditDissolvedOxygenPage({super.key});

  @override
  _EditDissolvedOxygenPageState createState() =>
      _EditDissolvedOxygenPageState();
}

class _EditDissolvedOxygenPageState extends State<EditDissolvedOxygenPage> {
  double? lowerDO;
  double? upperDO;

  TextEditingController lowerDOTextController = TextEditingController();
  TextEditingController upperDOTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    lowerDOTextController.text = user!.lowerDO.toString();
    upperDOTextController.text = user!.upperDO.toString();

    final lowerDOField = TextFormField(
        controller: lowerDOTextController,

        // initialValue: user!.lowerPH.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Lower DO Threshold",
          labelText: "Lower DO Threshold",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lower DO is required';
          }
          try {
            double DO = double.parse(value!);
            try {
              double upperDO = double.parse(upperDOTextController.text);
              if (DO > upperDO) {
                return 'This value should be less than the higher DO';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Input must be a floating point';
          }
        },
        onSaved: ((String? value) {
          lowerDO = double.parse(value!);
        }));

    final upperDOField = TextFormField(
        controller: upperDOTextController,
        // initialValue: user!.upperPH.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Upper DO Threshold",
          labelText: "Upper DO Threshold",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher PH Level is required';
          }
          try {
            double DO = double.parse(value!);

            try {
              double lowerDO = double.parse(lowerDOTextController.text);
              if (DO < lowerDO) {
                return 'This value should be greater than the lower DO';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Input must be a floating point';
          }
        },
        onSaved: ((String? value) {
          upperDO = double.parse(value!);
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
                .editDO(user!.email, lowerDO!, upperDO!);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('DO Threshold edit has been successful.'),
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
              "Edit Dissolved Oxygen Threshold",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            lowerDOField,
            upperDOField,
            saveButton,
            backButton,
          ],
        ),
      )),
    );
  }
}
