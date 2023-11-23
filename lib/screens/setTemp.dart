import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    TextEditingController lowerTempController = TextEditingController();
    TextEditingController upperTempController = TextEditingController();

    final formKey = GlobalKey<FormState>();

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
          border: const OutlineInputBorder(),
          hintText: "Lower Temperature Threshold",
          labelText: "Lower Temperature Threshold",
          suffixText: dropdownValue,
          contentPadding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lower Temperature is required';
          }

          try {
            double temp = double.parse(value);
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
          return null;
        },
        onSaved: ((String? value) {
          lowerTemp = double.parse(value!);
        }));

    final upperTempField = TextFormField(
        controller: upperTempController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: "Upper Temperature Threshold",
          labelText: "Upper Temperature Threshold",
          suffixText: dropdownValue,
          contentPadding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher Temperature is required';
          }

          try {
            double temp = double.parse(value);
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
          return null;
        },
        onSaved: ((String? value) {
          upperTemp = double.parse(value!);
        }));

    final nextButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          //call the auth provider here
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            if (dropdownValue == _dropdownOptions[1]) {
              double lowerTempCelsius = (lowerTemp! - 32) * (5 / 9);
              double upperTempCelsius = (upperTemp! - 32) * (5 / 9);
              await context.read<UserProvider>().addTemp(
                  args.email, lowerTempCelsius, upperTempCelsius, true);
            } else {
              await context
                  .read<UserProvider>()
                  .addTemp(args.email, lowerTemp!, upperTemp!, false);
            }

            Navigator.pushNamed(context, '/setDissolvedOxygenPage',
                arguments: UserScreenArguments(args.email));
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
        key: formKey,
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
              const Text("Temperature Unit: "),
              dropdownTempUnit,
            ]),
            lowerTempField,
            upperTempField,
            nextButton,
            // backButton
          ],
        ),
      )),
    );
  }
}
