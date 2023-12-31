import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/user_screen_arguments.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? firstNameValue;
  String? lastNameValue;
  String? emailValue;
  String? passwordValue;

  Widget invalidEmailMessage(BuildContext context) {
    return Text(context.watch<AuthProvider>().signUpStatus,
        style: const TextStyle(color: Colors.red));
  }

  //shows the fields in a sign up page-first name, last name, username, email, password, birthday, and location-with each field having a validator
  @override
  Widget build(BuildContext context) {
    TextEditingController dateInput = TextEditingController();

    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    final firstName = TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "First Name",
          labelText: "First Name",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'First Name is Required!';
          }
          return null;
        },
        onSaved: ((String? value) {
          firstNameValue = value!;
        }));

    final lastName = TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Last Name",
          labelText: "Last Name",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Last Name is Required!';
          }
          return null;
        },
        onSaved: ((String? value) {
          lastNameValue = value!;
        }));

    final email = TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Email",
          labelText: "Email",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is Required!';
          } else {
            bool isValid = EmailValidator.validate(value);
            if (!isValid) {
              return 'Email format must be valid!';
            }
          }
          return null;
        },
        onSaved: ((String? value) {
          emailValue = value!;
        }));

    final password = TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Password",
          labelText: "Password",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          var regExp = RegExp(
              r'(?=[A-Za-z0-9@#$%^&+!=]+$)^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%^&+!=])(?=.{8,}).*$');
          if (value == null || value.isEmpty) {
            return 'Password is Required!';
          } else {
            if (!regExp.hasMatch(value)) {
              return 'Password must be at least 8 characters, includes a\nnumber and a special character, and contains both\nuppercase and lowercase letters';
            }
          }
          return null;
        },
        onSaved: ((String? value) {
          passwordValue = value!;
        }));

    final confirmPassword = TextFormField(
        controller: confirmPasswordController,
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Confirm Password",
          labelText: "Confirm Password",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          var regExp = RegExp(
              r'(?=[A-Za-z0-9@#$%^&+!=]+$)^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#$%^&+!=])(?=.{8,}).*$');
          if (value == null || value.isEmpty) {
            return 'Confirm Password is Required!';
          } else {
            if (passwordController.text != confirmPasswordController.text) {
              return 'Passwords do not match!';
            }
          }
          return null;
        },
        onSaved: ((String? value) {
          passwordValue = value!;
        }));

    final signUpButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          //call the auth provider here
          if (formKey.currentState!.validate()) {
            // Navigator.pushNamed(context, '/setPhPage');

            formKey.currentState?.save();

            DateTime currentDate = DateTime.now();
            String dateCreated = currentDate.toString().split(' ')[0];
            User user = User(
                email: emailValue!,
                firstName: firstNameValue!,
                lastName: lastNameValue!,
                dateCreated: dateCreated,
                password: passwordValue!,
                lowerPH: 0,
                upperPH: 0,
                lowerTemp: 0,
                upperTemp: 0,
                inFahrenheit: false,
                lowerDO: 0,
                upperDO: 0,
                isLoggedIn: false,
                fcmToken: "");
            bool success = await context.read<AuthProvider>().signUp(
                emailValue!,
                passwordValue!,
                firstNameValue!,
                lastNameValue!,
                dateCreated);

            if (success) {
              Navigator.pushNamed(context, '/setPhPage',
                  arguments: UserScreenArguments(emailValue!));
            } else {
              print("Failed signup");
            }
          }
        },
        child: const Text('Next', style: TextStyle(color: Colors.white)),
      ),
    );

    final backButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          context.read<AuthProvider>().resetSignUpMessage();
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
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: <Widget>[
            const Image(
              image: AssetImage('assets/images/aquatrack-logo-nobg.png'),
              width: 80,
              height: 104,
              // color: Colors.white,
            ),
            const Text(
              "AquaTrack",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              "Sign Up",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            Row(children: [
              Expanded(child: firstName),
              Expanded(child: lastName),
            ]),
            // userName,
            email,
            // birthDate,
            // location,
            password,
            confirmPassword,
            invalidEmailMessage(context),
            signUpButton,
            backButton
          ],
        ),
      )),
    );
  }
}
