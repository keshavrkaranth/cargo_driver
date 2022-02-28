import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/screens/loginpage.dart';
import 'package:cargo_driver/screens/mainpage.dart';
import 'package:cargo_driver/screens/registrationpage.dart';
import 'package:cargo_driver/screens/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs',
      appId: '1:514277127247:android:c372f8a3262cf90266663a',
      messagingSenderId: '448618578101',
      projectId: 'cargo-tracking-815a8',
      databaseURL: 'https://cargo-tracking-815a8-default-rtdb.firebaseio.com',
      storageBucket: 'cargo-tracking-815a8.appspot.com',
    ),
  );
  currentUser = FirebaseAuth.instance.currentUser!;
  print(currentUser.uid);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: (currentUser == null) ? LoginPage.id : MainPage.id,
      routes: {
        MainPage.id :(context) =>const MainPage(),
        RegistrationPage.id : (context) => RegistrationPage(),
        VehicleInfoPage.id :(context) =>  VehicleInfoPage(),
        LoginPage.id :(context) => const LoginPage(),
      },
    );
  }
}

