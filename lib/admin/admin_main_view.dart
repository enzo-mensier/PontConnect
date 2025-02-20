import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../user/get_values_capteurs.dart';
import '../user/view_reservation.dart';
import 'admin_pending_reservations.dart';
import 'admin_add_reservation.dart';
import 'admin_pont_management.dart';
import 'admin_reservation.dart';
import 'admin_user_management.dart';


// COULEURS
import 'package:pontconnect/colors.dart';


class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  // CRÉER L'ÉTAT
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<AdminMainView> {

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

  int _currentIndex = 0;

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
          const Text(
            "| ADMIN",
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
    } else if (_currentIndex == 1) {
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
    else if (_currentIndex == 2){
      return const AdminPendingReservations();
    }
    else if (_currentIndex == 3){
      return const AdminUserManagement();
    }
    else if (_currentIndex == 4){
      return const AdminPontManagement();
    }
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
      currentIndex: _currentIndex,
      backgroundColor: backgroundLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      elevation: 8,
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