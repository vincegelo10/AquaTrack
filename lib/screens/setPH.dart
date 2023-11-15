import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

class SetPhPage extends StatefulWidget {
  const SetPhPage({super.key});

  @override
  _SetPhPageState createState() => _SetPhPageState();
}

class _SetPhPageState extends State<SetPhPage> {
  double? lowerPHLevel;
  double? upperPHLevel;
  TextEditingController lowerPHTextController = TextEditingController();
  TextEditingController higherPHTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as UserScreenArguments;

    final lowerPHField = TextFormField(
        controller: lowerPHTextController,
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

    final nextButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();
            context
                .read<UserProvider>()
                .addPH(args.email, lowerPHLevel!, upperPHLevel!);
            Navigator.pushNamed(context, '/setTempPage',
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

            // birthDate,
            // location,
            lowerPHField,
            upperPHField,
            // invalidEmailMessage(context),
            nextButton,
            // backButton
          ],
        ),
      )),
    );
  }
}
