import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pontconnect/colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  // Widget pour les icônes SVG (boat et car)
  Widget _buildSvgIconInfo({
    required String svgAsset,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          svgAsset,
          color: iconColor,
          width: 28,
          height: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  // Widget pour les icônes classiques
  Widget _buildIconInfo({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: textSecondary),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  // Widget pour construire une carte d'information
  Widget _buildCard({
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // Header de section pour une meilleure lisibilité
  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
            'AIDE & INFORMATIONS',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: backgroundLight),

        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Présentation'),
            const Text(
              'Cette application offre une vue d’ensemble moderne et épurée des ponts disponibles et de leurs réservations. '
                  'Chaque page est conçue pour rendre la navigation intuitive et agréable.',
              style: TextStyle(fontSize: 16, color: textSecondary),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: 'Page d\'Accueil - Informations sur les Ponts',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'La première partie de la page d’accueil présente un carrousel de différents ponts. '
                        'Chaque slide affiche plusieurs informations clés :',
                    style: TextStyle(fontSize: 16, color: textSecondary),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  _buildSvgIconInfo(
                    svgAsset: 'assets/images/boat.svg',
                    iconColor: primaryColor,
                    text:
                    'Le pont est ouvert pour le passage des bateaux et engins navigables.',
                  ),
                  const SizedBox(height: 12),
                  _buildSvgIconInfo(
                    svgAsset: 'assets/images/car.svg',
                    iconColor: secondaryColor,
                    text:
                    'Le pont est fermé pour le passage des bateaux, traversable par voie routière.',
                  ),
                  const SizedBox(height: 12),
                  _buildIconInfo(
                    icon: Icons.thermostat,
                    iconColor: accentColor,
                    text:
                    'La température est affichée pour informer sur l’environnement du pont.',
                  ),
                  const SizedBox(height: 12),
                  _buildIconInfo(
                    icon: Icons.water_damage,
                    iconColor: tertiaryColor,
                    text:
                    'Le taux d\'humidité est également indiqué.',
                  ),
                ],
              ),
            ),
            _buildCard(
              title: 'Page d\'Accueil - Disponibilités',
              content: const Text(
                'La seconde partie comporte une barre de recherche permettant de consulter '
                    'les disponibilités d\'un pont pour une date donnée. Sélectionnez le pont, choisissez la date, '
                    'puis lancez la recherche pour visualiser les créneaux disponibles durant la journée.',
                style: TextStyle(fontSize: 16, color: textSecondary),
                textAlign: TextAlign.justify,
              ),
            ),
            _buildCard(
              title: 'Réservation',
              content: const Text(
                'La section Réservation se divise en deux parties :\n\n'
                    '• Le widget d’ajout de réservation permet de planifier une réservation pour un jour à venir. '
                    'Choisissez la date, l’heure et le pont souhaité.\n\n'
                    '• Le widget de suivi vous permet de consulter vos réservations récentes et de les annuler si nécessaire.',
                style: TextStyle(fontSize: 16, color: textSecondary),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Merci d\'utiliser notre application !',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
