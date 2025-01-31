import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupération de l'email passé via les arguments de navigation
    final String email = ModalRoute.of(context)?.settings.arguments as String? ?? 'Utilisateur';

    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: Text('Bienvenue, $email !', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
