import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_reservation_page.dart';
import 'reservation_view.dart'; // Assurez-vous que le chemin est correct

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/images/logo.svg",
              height: 40,
              color: Colors.blueAccent,
            ),
            const SizedBox(width: 8),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getBodyContent(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Si "Accueil" est sélectionné, on affiche ReservationsSchedulePage.
  // Sinon, un simple placeholder.
  Widget _getBodyContent() {
    if (_currentIndex == 0) {
      return const ReservationsSchedulePage();
    }
    else if (_currentIndex == 1) {
      return AddReservationPage();
    }
    else {
      return Center(
        child: Text(
          'Fonctionnalité à venir',
          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
        ),
      );
    }
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
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