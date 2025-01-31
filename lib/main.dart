import 'package:flutter/material.dart';
import 'package:pontconnect/pages/home_page.dart';
import 'package:pontconnect/pages/login_screen.dart';
import 'package:pontconnect/pages/registe.dart';
import 'package:pontconnect/pages/user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Enlève la bannière de debug

      // THEME PAR DEFAUT
      theme: ThemeData(
        fontFamily: 'SmoochSans',
      ),

      // DEFINITIONS DES ROUTES
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(), // PAGE D'ACCUEIL
        '/login_screen': (context) => LoginPage(), // PAGE DE CONNEXION
        '/registe' : (context) => RegisterPage(), // PAGE D'INSCRIPTION
        '/user': (context) => UserPage(), // PAGE USER
      },
    );
  }
}