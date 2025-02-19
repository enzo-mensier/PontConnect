import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pontconnect/connexion/login.dart'; // Import de la page de connexion

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Création de l'AnimationController pour gérer la durée de l'animation de mise à l'échelle
    _scaleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Animation pour le scale (de 0.8 à 1.4)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // Animation pour l'opacité (de 0 à 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeIn),
    );

    // Création de l'AnimationController pour gérer la durée de l'animation de déplacement
    _slideController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Animation pour la translation (de 0 à -50 pixels)
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0, -1.5)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Création de l'AnimationController pour gérer la durée de l'animation de couleur
    _colorController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Animation pour la couleur (de blanc à une autre couleur)
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.red).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    // Démarrage de l'animation de mise à l'échelle
    _scaleController.forward().then((_) {
      // Démarrage de l'animation de déplacement après l'animation de mise à l'échelle
      _slideController.forward().then((_) {
        // Démarrage de l'animation de couleur après l'animation de déplacement
        _colorController.forward();
      });
    });

    // Navigation vers l'écran de connexion après 5 secondes
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _scaleController.dispose(); // Toujours disposer l'animation controller
    _slideController.dispose(); // Toujours disposer l'animation controller
    _colorController.dispose(); // Toujours disposer l'animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFFDA22FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) => SvgPicture.asset(
                    'assets/images/logo.svg', // Chemin vers ton logo SVG
                    width: 150,
                    color: _colorAnimation.value, // Appliquer la couleur animée au SVG
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}