import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/Authentification/login_screen.dart';
import 'package:users_app/Authentification/signUp_screen.dart';
import 'package:users_app/pages/home_page.dart';

Future <void>  main() async
{
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
    {
    if(valueOfPermission)
      {
        Permission.locationWhenInUse.request();

      }
    });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FirebaseAuth.instance.currentUser == null? LoginScreen(): HomePage(),
    );
  }
}

