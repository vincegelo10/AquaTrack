import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

class SetTempPage extends StatefulWidget {
  const SetTempPage({super.key});

  @override
  _SetTempPageState createState() => _SetTempPageState();
}

class _SetTempPageState extends State<SetTempPage> {
  static final List<String> _dropdownOptions = ["°C", "°F"];
  String dropdownValue = _dropdownOptions.first;

  double? lowerTemp;
  double? upperTemp;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as UserScreenArguments;
    print("the email is: ");
    print(args.email);

    TextEditingController lowerTempController = TextEditingController();
    TextEditingController upperTempController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    final dropdownTempUnit = DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
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

    final SignUpButton = Padding(
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
              context
                  .read<UserProvider>()
                  .addTemp(args.email, lowerTempCelsius, upperTempCelsius);

              // User user = User.setupTempThreshold(
              //     email: widget.user.email,
              //     firstName: widget.user.firstName,
              //     lastName: widget.user.lastName,
              //     dateCreated: widget.user.dateCreated,
              //     lowerPH: widget.user.lowerPH,
              //     upperPH: widget.user.upperPH,
              //     lowerTemp: lowerTempCelsius,
              //     upperTemp: upperTempCelsius,
              //     password: widget.user.password);
              // print("The details of the user\n");
              // print("User email: ${user.email}\n");
              // print("User firstName: ${user.firstName}\n");
              // print("User lastName: ${user.lastName}\n");
              // print("User date created: ${user.dateCreated}");
              // print("User lower PH: ${user.lowerPH}");
              // print("User upper PH: ${user.upperPH}");
              // print("User lower temp: ${user.lowerTemp}");
              // print("User upper temp: ${user.upperTemp}");
            } else {
              print("unit is in celsius");
              context
                  .read<UserProvider>()
                  .addTemp(args.email, lowerTemp!, upperTemp!);
              // User user = User.setupTempThreshold(
              //     email: widget.user.email,
              //     firstName: widget.user.firstName,
              //     lastName: widget.user.lastName,
              //     dateCreated: widget.user.dateCreated,
              //     lowerPH: widget.user.lowerPH,
              //     upperPH: widget.user.upperPH,
              //     lowerTemp: lowerTemp,
              //     upperTemp: upperTemp,
              //     password: widget.user.password);
              // print("The details of the user\n");
              // print("User email: ${user.email}\n");
              // print("User firstName: ${user.firstName}\n");
              // print("User lastName: ${user.lastName}\n");
              // print("User date created: ${user.dateCreated}");
              // print("User lower PH: ${user.lowerPH}");
              // print("User upper PH: ${user.upperPH}");
              // print("User lower temp: ${user.lowerTemp}");
              // print("User upper temp: ${user.upperTemp}");
              // await context.read<AuthProvider>().signUp(
              //     user.email,
              //     user.password,
              //     user.firstName,
              //     user.lastName,
              //     user.dateCreated,
              //     user.lowerPH!,
              //     user.upperPH!,
              //     user.lowerTemp!,
              //     user.upperTemp!);
            }
            Navigator.pushNamed(context, '/');

            // bool success = await context
            //     .read<AuthProvider>()
            //     .signUp(emailValue!, passwordValue!);
            // if (success) {
            //   print("data saved successfully!");
            //   print("email: $emailValue");
            //   print("first name: $firstNameValue");
            //   print("last name: $lastNameValue");
            //   print("dateCreated: $dateCreated");
            // }
          }
        },
        child: const Text('Next', style: TextStyle(color: Colors.white)),
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
              "Set Temperature Threshold",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            // Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //   Expanded(child: lowerTempField),
            //   SizedBox.square(child: dropdownTempUnit)
            // ]),
            // Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //   Expanded(child: upperTempField),
            //   SizedBox.square(child: dropdownTempUnit)
            // ]),
            Row(children: [
              Text("Temperature Unit: "),
              dropdownTempUnit,
            ]),
            lowerTempField,
            upperTempField,
            SignUpButton,
            // backButton
          ],
        ),
      )),
    );
  }
}
