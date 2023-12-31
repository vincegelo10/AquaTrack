import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/providers/todo_provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/providers/water_parameter_annotation_provider.dart';
import 'package:week7_networking_discussion/screens/do_annotation_page.dart';
import 'package:week7_networking_discussion/screens/do_page.dart';
import 'package:week7_networking_discussion/screens/editDO.dart';
import 'package:week7_networking_discussion/screens/ph_annotation_page.dart';
import 'package:week7_networking_discussion/screens/setDO.dart';
import 'package:week7_networking_discussion/screens/setPH.dart';
import 'package:week7_networking_discussion/screens/setTemp.dart';
import 'package:week7_networking_discussion/screens/home_page.dart';
import 'package:week7_networking_discussion/screens/editPH.dart';
import 'package:week7_networking_discussion/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:week7_networking_discussion/screens/water_temperature_annotation_page.dart';
import 'firebase_options.dart';
import 'package:week7_networking_discussion/screens/PH_Page.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';
import 'package:week7_networking_discussion/screens/water_temperature_page.dart';
import 'package:week7_networking_discussion/screens/edit_page.dart';
import 'package:week7_networking_discussion/screens/editTemp.dart';
import 'package:week7_networking_discussion/api/firebase_messaging_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => TodoListProvider())),
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
        ChangeNotifierProvider(create: ((context) => UserProvider())),
        ChangeNotifierProvider(create: ((context) => SensorDataProvider())),
        ChangeNotifierProvider(
            create: ((context) => WaterParameterAnnotationProvider())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleTodo',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => FutureBuilder<void>(
              // Initialize providers from Firestore when the app is opened
              future: context.read<UserProvider>().initializeFromFirestore(),
              builder: (context, snapshot) {
                return const AuthWrapper();
              },
            ),
        '/setPhPage': (context) => const SetPhPage(),
        '/setTempPage': (context) => const SetTempPage(),
        '/setDissolvedOxygenPage': (context) => const SetDissolvedOxygenPage(),
        '/phPage': (context) => const PH_Page(),
        '/tempPage': (context) => const WaterTemperaturePage(),
        '/doPage': (context) => const DO_Page(),
        '/editPage': (context) => const EditPage(),
        '/editPhPage': (context) => const EditPhPage(),
        '/editTempPage': (context) => const EditTempPage(),
        '/editDissolvedOxygenPage': (context) =>
            const EditDissolvedOxygenPage(),
        '/PhAnnotationPage': (context) => const PhAnnotationPage(),
        '/WaterTemperatureAnnotationPage': (context) =>
            const WaterTemperatureAnnotationPage(),
        '/DissolvedOxygenAnnotationPage': (context) => const DoAnnotationPage()
      },
      theme: ThemeData(primarySwatch: Colors.cyan),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseMessagingAPI().initNotifications(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final token = snapshot.data;
          context.read<UserProvider>().changeFcmToken(token!);
          return context.watch<AuthProvider>().isAuthenticated
              ? const HomePage()
              : const LoginPage();
        } else {
          // Return a loading indicator or an empty container while waiting
          return CircularProgressIndicator();
        }
      },
    );
  }
}
