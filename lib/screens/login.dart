import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/screens/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Widget invalidCredentialsMessage(BuildContext context) {
    return Text(context.watch<AuthProvider>().loginStatus,
        style: TextStyle(color: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    String? emailValue;
    String? passwordValue;

    final email = TextField(
      key: const Key('emailField'),
      controller: emailController,
      decoration: const InputDecoration(
        hintText: "Email",
      ),
    );

    final emailField = TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Email",
          labelText: "Enter email address",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is Required!';
          }
        },
        onSaved: ((String? value) {
          emailValue = value!;
        }));

    final password = TextField(
      key: const Key('pwField'),
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Password',
      ),
    );

    final passwordField = TextFormField(
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Password",
          labelText: "Enter Password",
          contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is Required!';
          }
        },
        onSaved: ((String? value) {
          passwordValue = value!;
        }));

    final loginButton = Padding(
      key: const Key('loginButton'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState?.save();
          }
          print("i am here");
          await context
              .read<AuthProvider>()
              .signIn(emailValue!, passwordValue!);
          await context
              .read<UserProvider>()
              .getLoggedInUserDetails(emailValue!);
        },
        child: const Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final signUpButton = Padding(
      key: const Key('signUpButton'),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SignupPage(),
            ),
          );
        },
        child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
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
            Image(
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
            SizedBox(height: 90),
            const Text(
              "Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            emailField,
            passwordField,
            invalidCredentialsMessage(context),
            loginButton,
            signUpButton,
          ],
        ),
      )),
    );
  }
}
