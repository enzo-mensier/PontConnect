import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../user/get_values_capteurs.dart';
import '../user/view_reservation.dart';
import 'admin_pending_reservations.dart';
import 'admin_add_reservation.dart';
import 'admin_reservation.dart';


// COULEURS
import 'package:pontconnect/colors.dart';


class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  // CRÉER L'ÉTAT
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<AdminMainView> {
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
        setState(() {
          _currentIndex = index;
        });
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
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}