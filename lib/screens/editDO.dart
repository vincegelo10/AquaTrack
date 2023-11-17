import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/services/local_notification_service.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';

class EditDissolvedOxygenPage extends StatefulWidget {
  const EditDissolvedOxygenPage({super.key});

  @override
  _EditDissolvedOxygenPageState createState() =>
      _EditDissolvedOxygenPageState();
}

class _EditDissolvedOxygenPageState extends State<EditDissolvedOxygenPage> {
  double? lowerDO;
  double? upperDO;
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
        : user.inFahrenheit == false
            ? context.watch<SensorDataProvider>().recentWaterTemp
            : ((double.parse(context
                            .watch<SensorDataProvider>()
                            .recentWaterTemp) *
                        9 /
                        5) +
                    32)
                .toString();
    double lowerTemp = user.inFahrenheit == false
        ? user.lowerTemp
        : ((user.lowerTemp * 9 / 5) + 32);

    double upperTemp = user.inFahrenheit == false
        ? user.upperTemp
        : ((user.upperTemp * 9 / 5) + 32);

    if (updatedData?.timestamp != null) {
      //notification for PH outside of threshold
      if (phVal != 'NA' &&
          (double.parse(phVal) < user.lowerPH ||
              double.parse(phVal) > user.upperPH) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 1,
          title: 'PH Level out of range!',
          body:
              'Current PH Level: $phVal is not within the set threshold of ${user.lowerPH}-${user.upperPH}',
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
          (double.parse(doVal) < user.lowerDO ||
              double.parse(doVal) > user.upperDO) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 3,
          title: 'Dissolved Oxygen out of range!',
          body:
              'Current Dissolved Oxygen: $doVal is not within the set threshold of ${user.lowerDO}-${user.upperDO}',
        );
      }
    }
  }

  TextEditingController lowerDOTextController = TextEditingController();
  TextEditingController upperDOTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    lowerDOTextController.text = user!.lowerDO.toString();
    upperDOTextController.text = user.upperDO.toString();
    checkAndShowNotification();
    final lowerDOField = TextFormField(
        controller: lowerDOTextController,

        // initialValue: user!.lowerPH.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Lower DO Threshold",
          labelText: "Lower DO Threshold",
          suffixText: "mg/L",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lower DO is required';
          }
          try {
            double DO = double.parse(value);
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
          return null;
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
          suffixText: "mg/L",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher PH Level is required';
          }
          try {
            double DO = double.parse(value);

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
          return null;
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
                .editDO(user.email, lowerDO!, upperDO!);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('DO Threshold edit has been successful.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Close the form screen
                      },
                      child: const Text('OK'),
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
