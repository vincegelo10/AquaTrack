import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/services/local_notification_service.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';

class EditPhPage extends StatefulWidget {
  const EditPhPage({super.key});

  @override
  _EditPhPageState createState() => _EditPhPageState();
}

class _EditPhPageState extends State<EditPhPage> {
  double? lowerPHLevel;
  double? upperPHLevel;
  TextEditingController lowerPHTextController = TextEditingController();
  TextEditingController higherPHTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final NotificationService service;
  @override
  void initState() {
    service = NotificationService();
    service.initializePlatformNotifications();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    lowerPHTextController.text = user!.lowerPH.toString();
    higherPHTextController.text = user!.upperPH.toString();
    checkAndShowNotification();
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
              "Edit pH Threshold",
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
