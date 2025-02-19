import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// COULEURS
import 'package:pontconnect/colors.dart';

class CapteursCarouselPage extends StatefulWidget {
  const CapteursCarouselPage({super.key});

  // CREER ETAT
  @override
  _CapteursCarouselPageState createState() => _CapteursCarouselPageState();
}

class _CapteursCarouselPageState extends State<CapteursCarouselPage> {
  List<dynamic> _capteurs = [];
  Timer? _refreshTimer;
  final Duration _refreshInterval = const Duration(seconds: 10);

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _fetchCapteurs();
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      _fetchCapteurs();
    });
  }

  // RECUPERER CAPTEURS
  Future<void> _fetchCapteurs() async {
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}getValuesCapteurs.php');
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _capteurs = data['capteurs'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "ERREUR DE RECUPERATION")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ERREUR: ${e.toString()}")));
    }
  }

  // LIBERER RESSOURCES
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // CONSTRUIRE SLIDE
  Widget _buildSlide(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Center(
              child: Text(
                (item['nom'] ?? "PONT INCONNU").toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: backgroundLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.only(top: 10, left: 12, right: 12)),


          // TEMPERATURE ET NIVEAU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // TEMPERATURE
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${item['temperature']}°C",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.thermostat, color: secondaryColor, size: 32),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // NIVEAU EAU
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${item['niveau_eau']} cm",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.water, color: secondaryColor, size: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // HUMIDITE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: secondaryColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "${item['humidite']} %",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.grain, color: secondaryColor, size: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CONSTRUIRE WIDGET PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _capteurs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(

        itemCount: _capteurs.length,
        controller: PageController(viewportFraction: 1.0),
        itemBuilder: (context, index) {
          return _buildSlide(_capteurs[index]);
        },
      ),
    );
  }
}