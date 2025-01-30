import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Enlève la bannière de debug
      theme: ThemeData(
        fontFamily: 'SmoochSans', // Applique la police par défaut
      ),

      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              SvgPicture.asset(
                "assets/images/logo.svg",
                height: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 20), // Espace entre le logo et le texte

              // Titre principal
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 60), // Marge gauche et droite
                child: const Text(
                  "Bienvenue sur le pont connecté ! Réservez un créneau et consultez son état en temps réel.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(height: 18), // Espace avant le bouton

              // Bouton
              ElevatedButton(
                onPressed: () {
                  // logique du bouton
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5, // Ombre pour un effet 3D
                ),
                child: const Text(
                  "Commencer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}