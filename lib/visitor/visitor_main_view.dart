import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pontconnect/user/user_reservation.dart';
import 'package:pontconnect/user/user_session_storage.dart';
import '../user/get_values_capteurs.dart';
import '../user/help.dart';
import '../user/view_reservation.dart';


// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE PRINCIPALE DU VISITEUR
class VisitorMainView extends StatefulWidget {
  const VisitorMainView({super.key});
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<VisitorMainView> {

  // VARIABLES
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
      builder: (BuildContext context) {
        return Theme(

          // THEME DE LA BOITE DE DIALOGUE
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: backgroundLight,
              onSurface: textPrimary,
            ),
            dialogBackgroundColor: backgroundLight,
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'DarumadropOne',
            ),
          ),

          // BOITE DE DIALOGUE
          child: AlertDialog(
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login_screen',
                        (route) => false,
                  );
                },
                child: const Text('Déconnecter'),
              ),
            ],
          ),
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

    // PREMIERE PAGE (ACCUEIL)
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

    // TROISIEME PAGE (AIDE)
    else if (_currentIndex == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const HelpPage(),
        ),
      );
    }

    // PAGES PAR DEFAUT
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

      // DECONNEXION & REDIRECTION
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