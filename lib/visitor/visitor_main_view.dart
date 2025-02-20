import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pontconnect/user/user_reservation.dart';
import 'package:pontconnect/user/user_session_storage.dart';


// COULEURS
import 'package:pontconnect/colors.dart';

import '../user/get_values_capteurs.dart';
import '../user/help.dart';
import '../user/view_reservation.dart';

class VisitorMainView extends StatefulWidget {
  const VisitorMainView({super.key});

  // CRÉER L'ÉTAT
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<VisitorMainView> {

  final String userName = UserSession.userName ?? "VISITEUR";
  int _currentIndex = 0;

  // CONSTRUIRE L'INTERFACE PRINCIPALE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getBodyContent(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // METHODE DECONNEXION
  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login_screen', (route) => false);
              },
              child: const Text('Déconnecter'),
            ),
          ],
        );
      },
    );
  }

  // CONSTRUIRE APP BAR
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundLight,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/logo.svg",
            height: 55,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            ("| $userName").toUpperCase(),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    );
  }

  // CONSTRUIRE LE CONTENU DU BODY
  Widget _getBodyContent() {
    if (_currentIndex == 0) {
      return Column(
        children: [
          // SECTION HAUTE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: backgroundLight,
              height: 250,
              child: const CapteursCarouselPage(),
            ),
          ),
          const SizedBox(height: 16),
          // SECTION BASSE
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: backgroundLight,
                child: const ReservationsSchedulePage(),
              ),
            ),
          ),
        ],
      );
    }
    else if (_currentIndex == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const HelpPage(),
        ),
      );
    }

    else {
      return Center(
        child: Text(
          'VOUS ETES VISITEUR',
          style: TextStyle(fontSize: 20, color: textPrimary),
        ),
      );
    }
  }

  // CONSTRUIRE LA BOTTOM NAVIGATION BAR
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      backgroundColor: backgroundLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      elevation: 8,
      onTap: (index) {
        if (index == 3) {
          // DECONNEXION
          _logout();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Réservation',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline_sharp),
          label: 'Aide',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Déco',
        ),

      ],
    );
  }
}