import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';

class SetDissolvedOxygenPage extends StatefulWidget {
  const SetDissolvedOxygenPage({super.key});

  @override
  _SetDissolvedOxygenPageState createState() => _SetDissolvedOxygenPageState();
}

class _SetDissolvedOxygenPageState extends State<SetDissolvedOxygenPage> {
  double? lowerDO;
  double? upperDO;

  @override
  Widget build(BuildContext context) {
    TextEditingController lowerDOController = TextEditingController();
    TextEditingController upperDOController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    final args =
        ModalRoute.of(context)!.settings.arguments as UserScreenArguments;

    var lowerDOField = TextFormField(
        controller: lowerDOController,
        decoration: InputDecoration(
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
            double DO = double.parse(value!);
            try {
              double upperDOValue = double.parse(upperDOController.text);
              if (DO > upperDOValue) {
                return 'This value should be less than the higher DO field';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Dissolved Oxygen should be a number';
          }
        },
        onSaved: ((String? value) {
          lowerDO = double.parse(value!)!;
        }));

    final upperDOField = TextFormField(
        controller: upperDOController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Upper DO Threshold",
          labelText: "Upper DO Threshold",
          suffixText: "mg/L",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Higher DO is required';
          }

          try {
            double DO = double.parse(value!);
            try {
              double lowerDOValue = double.parse(lowerDOController.text);
              if (DO < lowerDOValue) {
                return 'Thie value should be higher than the lower DO field';
              }
            } catch (e) {
              print("The other field is not a floating point");
            }
          } catch (e) {
            return 'Dissolved Oxygen should be a number';
          }
        },
        onSaved: ((String? value) {
          upperDO = double.parse(value!)!;
        }));

    final SignUpButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          //call the auth provider here
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();
            await context
                .read<UserProvider>()
                .addDissolvedOxygen(args.email, lowerDO!, upperDO!);
            await context
                .read<UserProvider>()
                .getLoggedInUserDetails(args.email);

            Navigator.pushNamed(context, '/');
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
              "Set Dissolved Oxygen Threshold",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            lowerDOField,
            upperDOField,
            //change the sign up button of set temp to "next" button
            SignUpButton,
            // backButton
          ],
        ),
      )),
    );
  }
}
