import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/services/local_notification_service.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';

class EditTempPage extends StatefulWidget {
  const EditTempPage({super.key});

  @override
  _EditTempPageState createState() => _EditTempPageState();
}

class _EditTempPageState extends State<EditTempPage> {
  static final List<String> _dropdownOptions = ["°C", "°F"];

  TextEditingController lowerTempController = TextEditingController();
  TextEditingController upperTempController = TextEditingController();

  double? lowerTemp;
  double? upperTemp;

  String dropdownValue = "";

  late final NotificationService service;

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
  void initState() {
    User? user = context.read<UserProvider>().user;

    // Initialize dropdownValue based on user preference
    dropdownValue =
        user!.inFahrenheit ? _dropdownOptions[1] : _dropdownOptions[0];

    lowerTempController.text = user.inFahrenheit
        ? ((user.lowerTemp * 9 / 5) + 32).toString()
        : user.lowerTemp.toString();

    upperTempController.text = user.inFahrenheit
        ? ((user.upperTemp * 9 / 5) + 32).toString()
        : user.upperTemp.toString();
    service = NotificationService();
    service.initializePlatformNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.read<UserProvider>().user;
    final _formKey = GlobalKey<FormState>();
    checkAndShowNotification();
    final dropdownTempUnit = DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        print("i am selecting: $value");
        setState(() {
          dropdownValue = value!;
          print("dropdownValue: $dropdownValue");
        });
      },
      items: _dropdownOptions.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );

    var lowerTempField = TextFormField(
        controller: lowerTempController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Lower Temperature Threshold",
          labelText: "Lower Temperature Threshold",
          suffixText: dropdownValue,
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lower Temperature is required';
          }

          try {
            double temp = double.parse(value!);
            try {
              double upperTempValue = double.parse(upperTempController.text);
              if (temp > upperTempValue) {
                return 'This value should be less than the higher temperature field';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Temperature should be a number';
          }
        },
        onSaved: ((String? value) {
          lowerTemp = double.parse(value!)!;
        }));

    final upperTempField = TextFormField(
        controller: upperTempController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Upper Temperature Threshold",
          labelText: "Upper Temperature Threshold",
          suffixText: dropdownValue,
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher Temperature is required';
          }

          try {
            double temp = double.parse(value!);
            try {
              double lowerTempValue = double.parse(lowerTempController.text);
              if (temp < lowerTempValue) {
                return 'Thie value should be higher than the lower temperature field';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Temperature should be a number';
          }
        },
        onSaved: ((String? value) {
          upperTemp = double.parse(value!)!;
        }));

    final saveButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          //call the auth provider here
          if (_formKey.currentState!.validate()) {
            //if temperature is in fahrenheit, convert to celsius
            // if (dropdownValue == _dropdownOptions[1]) {
            //   print('the temperature is in fahrenheit');
            //   print(lowerTempController.text);
            //   print(upperTempController.text);
            // }
            // DateTime current_date = DateTime.now();
            // String dateCreated = current_date.toString().split(' ')[0];
            _formKey.currentState?.save();
            if (dropdownValue == _dropdownOptions[1]) {
              print("lower temp (fahrenheit): $lowerTemp");
              print("upper temp (fahrenheit): $upperTemp");
              print("converting to celsius...");
              double lowerTempCelsius = (lowerTemp! - 32) * (5 / 9);
              double upperTempCelsius = (upperTemp! - 32) * (5 / 9);
              print("lower temp (celsius): $lowerTempCelsius");
              print("upper temp (celsius): $upperTempCelsius");

              context.read<UserProvider>().editTemp(
                  user!.email, lowerTempCelsius, upperTempCelsius, true);
            } else {
              print("unit is in celsius");
              context
                  .read<UserProvider>()
                  .editTemp(user!.email, lowerTemp!, upperTemp!, false);
            }

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text(
                      'Water temperature threshold edit has been successful.'),
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
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          children: <Widget>[
            const Text(
              "Edit Temperature Threshold",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            Row(children: [
              Text("Temperature Unit: "),
              dropdownTempUnit,
            ]),
            lowerTempField,
            upperTempField,
            saveButton,
            backButton
          ],
        ),
      )),
    );
  }
}
