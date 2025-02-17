import 'package:flutter/material.dart';
import 'package:pontconnect/pages/add_reservation_page.dart';
import 'package:pontconnect/pages/login_screen.dart';
import 'package:pontconnect/pages/registe.dart';
import 'package:pontconnect/pages/reservation_view.dart';
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
      initialRoute: '/login_screen',
      routes: {
        '/login_screen': (context) => LoginPage(), // PAGE DE CONNEXION
        '/register' : (context) => RegisterPage(), // PAGE D'INSCRIPTION
        '/user': (context) => UserPage(), // PAGE USER
        '/Reservation_view': (context) => ReservationsSchedulePage(), // PAGE DE VIEW RESERVATION
        '/AddReservation': (context) => AddReservationPage(), // PAGE DE RESERVATION
      },

    );
  }
}