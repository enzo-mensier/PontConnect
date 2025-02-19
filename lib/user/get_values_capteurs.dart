import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// COULEURS
import 'package:pontconnect/colors.dart';

class CapteursCarouselPage extends StatefulWidget {
  const CapteursCarouselPage({Key? key}) : super(key: key);

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

  // RECUPERATION DES CAPTEURS
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
        SnackBar(content: Text("ERREUR: ${e.toString()}")),
      );
    }
  }

  // LIBERER RESSOURCES
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // CARTE DU CAPTEUR
  Widget buildSensorCard({
    required String value,
    required IconData icon,
    required String unit,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "$value $unit",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: secondaryColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  // CONSTRUCTION DE LA SLIDE POUR UN CAPTEUR
  Widget _buildSlide(Map<String, dynamic> item) {
    // Si niveau_eau > 7, on considère que le pont est ouvert (bateau)
    bool showBoat = (item['niveau_eau'] is num && item['niveau_eau'] > 7);

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
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                )
              ],
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

          // TEMPERATURE ET NIVEAU D'EAU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                buildSensorCard(
                  value: "${item['temperature']}",
                  icon: Icons.thermostat,
                  unit: "°C",
                ),
                buildSensorCard(
                  value: "${item['niveau_eau']}",
                  icon: Icons.water,
                  unit: "cm",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // HUMIDITE ET ANIMATION SVG
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedBridgeSVG(isBoat: showBoat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CONSTRUCTION DU WIDGET PRINCIPAL
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

// ANIMATION SVG (BATEAU / VOITURE)
class AnimatedBridgeSVG extends StatefulWidget {
  final bool isBoat;
  const AnimatedBridgeSVG({Key? key, required this.isBoat}) : super(key: key);

  @override
  _AnimatedBridgeSVGState createState() => _AnimatedBridgeSVGState();
}

class _AnimatedBridgeSVGState extends State<AnimatedBridgeSVG>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translationAnimation;
  late Animation<double> _boatTiltAnimation;
  late Animation<double> _carFlipAnimation;

  // INITIALISATION DE L'ANIMATION
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _translationAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isBoat) {
      _boatTiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _carFlipAnimation = AlwaysStoppedAnimation(0.0);
    } else {
      _carFlipAnimation = Tween<double>(begin: 0, end: 3.14).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
        ),
      );
      _boatTiltAnimation = AlwaysStoppedAnimation(0.0);
    }
  }

  // LIBERATION DE L'ANIMATION
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // CONSTRUCTION DU WIDGET ANIMÉ
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.isBoat) {
          return Transform.translate(
            offset: Offset(0, _translationAnimation.value),
            child: Transform.rotate(
              angle: _boatTiltAnimation.value,
              child: child,
            ),
          );
        } else {
          return Transform.translate(
            offset: Offset(_translationAnimation.value, 0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(_carFlipAnimation.value),
              child: child,
            ),
          );
        }
      },
      child: widget.isBoat
          ? SvgPicture.asset(
        'assets/images/boat.svg',
        width: 54,
        height: 54,
        color: secondaryColor,
      )
          : SvgPicture.asset(
        'assets/images/car.svg',
        width: 54,
        height: 54,
        color: secondaryColor,
      ),
    );
  }
}