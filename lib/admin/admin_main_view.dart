import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../user/get_values_capteurs.dart';
import '../user/user_session_storage.dart';
import '../user/view_reservation.dart';
import 'admin_pending_reservations.dart';
import 'admin_add_reservation.dart';
import 'admin_pont_management.dart';
import 'admin_reservation.dart';
import 'admin_user_management.dart';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE PRINCIPALE DE L'ADMINISTRATEUR
class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<AdminMainView> {

  // VARIABLES
  final String userName = UserSession.userName ?? "ADMIN";
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

  // CONSTRUIRE LE CONTENU
  Widget _getBodyContent() {

    // PAGES PRINCIPALES
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
    
    // DEUXIEME PAGE RESERVATION
    else if (_currentIndex == 1) {
      return Column(
        children: [

          // SECTION HAUTE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: backgroundLight,
              height: 340,
              child: const AdminAddReservation(),
            ),
          ),
          const SizedBox(height: 16),

          // SECTION BASSE
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: backgroundLight,
                child: const AdminReservations(),
              ),
            ),
          ),
        ],
      );
    }

    // TROISIEME PAGE MANAGEMENT RESERVATION
    else if (_currentIndex == 2){
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const AdminPendingReservations(),
        ),
      );
    }

    // QUATRIEME PAGE GESTION UTILISATEUR
    else if (_currentIndex == 3){
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const AdminUserManagement(),
        ),
      );
    }

    // CINQUIEME PAGE GESTION PONTS
    else if (_currentIndex == 4){
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: backgroundLight,
          child: const AdminPontManagement(),
        ),
      );
    }

    // AUTRES PAGE
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

      // DECONNEXION & CHANGEMENT D'ONGLET
      onTap: (index) {
        if (index == 5) {
          // DECONNEXION
          _logout();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },

      // ICONES & LABELS
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
          icon: Icon(Icons.check_circle_outlined),
          label: 'Confirm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_moderator_outlined),
          label: 'Admin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_boat_outlined),
          label: 'Ponts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Déco',
        ),
      ],
    );
  }
}