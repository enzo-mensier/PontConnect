import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// COULEURS
import 'package:pontconnect/colors.dart';

class ReservationsSchedulePage extends StatefulWidget {
  const ReservationsSchedulePage({Key? key}) : super(key: key);

  // CREER ETAT
  @override
  _ReservationsSchedulePageState createState() => _ReservationsSchedulePageState();
}

class _ReservationsSchedulePageState extends State<ReservationsSchedulePage> {
  List<dynamic> _ponts = [];
  int? _selectedPontId;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedule = [];
  bool _isLoading = false;

  // INITIALISATION DE LA PAGE
  @override
  void initState() {
    super.initState();
    _fetchPonts();
  }

  // RECUPERER LES PONTS
  Future<void> _fetchPonts() async {
    try {
      // API REST URL
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}getPonts.php'));
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _ponts = data['ponts'];
          if (_ponts.isNotEmpty) {
            _selectedPontId = _ponts[0]['pont_id'];
          }
        });
      } else {
        _showMessage('ERREUR LORS DU CHARGEMENT DES PONTS.');
      }
    } catch (e) {
      _showMessage('ERREUR: ${e.toString()}');
    }
  }

  // RECHERCHER LES RÉSERVATIONS
  Future<void> _searchSchedule() async {
    if (_selectedPontId == null) return;
    setState(() {
      _isLoading = true;
      _schedule = [];
    });
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}schedule.php?pont_id=$_selectedPontId&date=$formattedDate');
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _schedule = data['schedule'];
        });
      } else {
        _showMessage('AUCUNE DONNÉE TROUVÉE POUR CETTE RECHERCHE.');
      }
    } catch (e) {
      _showMessage('ERREUR: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // CHOISIR LA DATE
  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // AFFICHER UN MESSAGE
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // CONSTRUIRE LA LISTE DES RÉSERVATIONS
  Widget _buildScheduleList() {
    if (_schedule.isEmpty) {
      return Center(
        child: Text(
          'PAS DE RECHERCHE EN COUR.',
          style: TextStyle(fontSize: 16, color: textPrimary),
        ),
      );
    }
    return ListView.separated(
      itemCount: _schedule.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = _schedule[index];
        final String status = slot['status'].toString().toLowerCase();
        final bool isAvailable = status == 'disponible' || status == 'pont ouvert';
        return Card(
          color: backgroundLight,
          surfaceTintColor: backgroundLight,
          shadowColor: Colors.grey.withOpacity(0.2),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundLight,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                left: BorderSide(
                  color: isAvailable ? accentColor : secondaryColor,
                  width: 5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // décalage de l'ombre
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AFFICHER L'HEURE ET LE STATUT
                Row(
                  children: [
                    Icon(Icons.access_time, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      slot['hour'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAvailable ? accentColor : secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        slot['status'],
                        style: const TextStyle(
                          color: backgroundLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // AFFICHER LES HORAIRES DE LA RÉSERVATION SI DISPONIBLE
                slot['reservation'] != null
                    ? Row(
                  children: [
                    Icon(Icons.play_circle_filled, size: 16, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      "DÉBUT : ${DateFormat('HH:mm').format(DateTime.parse(slot['reservation']['date_debut']))}",
                      style: TextStyle(fontSize: 14, color: textPrimary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.stop_circle, size: 16, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      "FIN : ${DateFormat('HH:mm').format(DateTime.parse(slot['reservation']['date_fin']))}",
                      style: TextStyle(fontSize: 14, color: textPrimary),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      "AUCUNE RÉSERVATION",
                      style: TextStyle(fontSize: 14, color: textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DEFINITION DE LA BORNE DES CHAMPS DE SAISIE
  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
    );
  }

  // CONSTRUIRE LE WIDGET PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'RECHERCHE DE RÉSERVATIONS',
          style: TextStyle(
            color: backgroundLight,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
        child: Column(
          children: [
            // CHAMPS DE FILTRE
            Row(
              children: [
                // SELECTIONNER UN PONT
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _selectedPontId,
                    hint: Text("Pont", style: TextStyle(color: textSecondary)),
                    items: _ponts.map<DropdownMenuItem<int>>((pont) {
                      return DropdownMenuItem<int>(
                        value: pont['pont_id'],
                        child: Text(pont['nom'], style: TextStyle(color: textPrimary)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPontId = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Pont",
                      labelStyle: TextStyle(color: textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: _inputBorder(),
                      focusedBorder: _inputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // CHOISIR LA DATE
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: _inputBorder(),
                        focusedBorder: _inputBorder(),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // BOUTON DE RECHERCHE
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _searchSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: textPrimary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Icon(Icons.search, size: 24, color: backgroundLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // AFFICHER LA LISTE DES RÉSERVATIONS
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }
}