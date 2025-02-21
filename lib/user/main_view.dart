import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pontconnect/user/user_reservation.dart';
import 'package:pontconnect/user/user_session_storage.dart';
import 'add_reservation.dart';
import 'help.dart';
import 'view_reservation.dart';
import 'get_values_capteurs.dart';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE UTILISATEUR
class UserPage extends StatefulWidget {
  const UserPage({super.key});
  @override
  _UserPageState createState() => _UserPageState();
}

// ETAT DE LA PAGE
class _UserPageState extends State<UserPage> {

  // RECUPERER LE NOM DE L'UTILISATEUR
  final String userName = UserSession.userName ?? "USER";
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
                UserSession.clear();
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
      backgroundColor: primaryColor,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/logo.svg",
            height: 55,
            color: backgroundLight,
          ),
          const SizedBox(width: 8),
          Text(
            ("| $userName").toUpperCase(),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: backgroundLight,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    );
  }

  // CONSTRUIRE LE CONTENU DU BODY
  Widget _getBodyContent() {

    // PREMIER ONGLET
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

    // DEUXIEME ONGLET    
    else if (_currentIndex == 1) {
      return Column(
        children: [

          // SECTION HAUTE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: backgroundLight,
              height: 280,
              child: const AddReservationPage(),
            ),
          ),
          const SizedBox(height: 16),

          // SECTION BASSE
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: backgroundLight,
                child: const UserReservationsPage(),
              ),
            ),
          ),
        ],
      );
    }

    // TROISIEME ONGLET
    else if (_currentIndex == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const HelpPage(),
        ),
      );
    }

    // AUTRES ONGLETS
    else {
      return Center(
        child: Text(
          'FONCTIONNALITÉ À VENIR',
          style: TextStyle(fontSize: 20, color: textPrimary),
        ),
      );
    }
  }

  // CONSTRUIRE LA BOTTOM NAVIGATION BAR
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: backgroundLight,
      selectedLabelStyle: const TextStyle(
        color: accentColor,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        color: primaryColor,
      ),
      elevation: 8,

      // DECONNEXION BUTTON
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