import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// HOME PAGE
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // LOGO
            SvgPicture.asset(
              "assets/images/logo.svg",
              height: 100,
              color: Colors.blue,
            ),

            const SizedBox(height: 20), // MARGIN

            // PARAGRAPHE
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 60), // MARGIN RIGHT LEFT
              child: const Text(
                "Bienvenue sur le pont connecté ! Réservez un créneau et consultez son état en temps réel.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'SmoochSans',
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 18), // MARGIN

            // BOUTON
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login_screen');
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5, // OMBRE
              ),

              child: const Text(
                "Commencer",
                style: TextStyle(
                  fontFamily: 'SmoochSans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}