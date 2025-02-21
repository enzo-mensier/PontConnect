import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session_storage.dart';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE D'AJOUT DE RÉSERVATION
class AddReservationPage extends StatefulWidget {
  const AddReservationPage({super.key});
  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  
  // VARIABLES
  int? _currentUserId;
  List<dynamic> _ponts = [];
  int? _selectedPontId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  bool _isLoading = false;

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchPonts();
    _selectedStartTime = TimeOfDay.now();
  }

  // RECUPERATION DE L'UTILISATEUR
  void _loadCurrentUser() {
    setState(() {
      _currentUserId = UserSession.userId;
    });
  }

  // RÉCUPÉRER LES PONTS
  Future<void> _fetchPonts() async {
    try {
      // API REST URL
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}user/getPonts.php'));
      final data = json.decode(response.body);

      // VÉRIFIER LA RÉPONSE
      if (data['success']) {
        setState(() {
          _ponts = data['ponts'];
          if (_ponts.isNotEmpty) {
            _selectedPontId = _ponts[0]['pont_id'];
          }
        });
      } else {
        _showMessage("ERREUR LORS DU CHARGEMENT DES PONTS");
      }
    } catch (e) {
      _showMessage("ERREUR: ${e.toString()}");
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

  // CHOIX L'HEURE DE DÉBUT
  Future<void> _pickStartTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (time != null) {
      setState(() {
        _selectedStartTime = time;
      });
    }
  }

  // CALCULER L'HEURE DE FIN (30 MINUTES PLUS TARD)
  String _computeEndTime() {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    final endDateTime = startDateTime.add(const Duration(minutes: 30));
    return DateFormat('HH:mm').format(endDateTime);
  }

  // AFFICHER UN MESSAGE
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // SOUMETTRE LA RÉSERVATION
  Future<void> _submitReservation() async {
    if (_selectedPontId == null || _currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    // FORMATER LA DATE ET L'HEURE
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    String startTimeStr = DateFormat('HH:mm').format(startDateTime);

    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}user/addReservation.php');
      
      // ENVOYER LA REQUÊTE
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": _currentUserId,
          "pont_id": _selectedPontId,
          "date": dateStr,
          "start_time": startTimeStr
        }),
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        _showMessage("RESERVATION AJOUTÉE AVEC SUCCÈS");
      } else {
        _showMessage("ERREUR : ${data['message']}");
      }
    } catch (e) {
      _showMessage("ERREUR: ${e.toString()}");
    }
    setState(() {
      _isLoading = false;
    });
  }

  // CONSTRUIRE LA LISTE DÉROULANTE DES PONTS
  Widget _buildPontDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Choisir un pont",
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true,
      value: _selectedPontId,

      // LORSQUE LE MENU EST OUVERT
      items: _ponts.map<DropdownMenuItem<int>>((pont) {
        bool isSelected = pont['pont_id'] == _selectedPontId;
        return DropdownMenuItem<int>(
          value: pont['pont_id'],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: isSelected
                ? BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            )
                : null,
            child: Text(
              pont['nom'],
              style: TextStyle(
                fontSize: 16,
                color: textPrimary,
                fontFamily: 'DarumadropOne',
              ),
            ),
          ),
        );
      }).toList(),

      // LORSQUE LE MENU EST FERMÉ
      selectedItemBuilder: (BuildContext context) {
        return _ponts.map<Widget>((pont) {
          return Text(
            pont['nom'],
            style: TextStyle(
              fontSize: 16,
              color: textPrimary,
              fontWeight: FontWeight.w500,
              fontFamily: 'DarumadropOne',
            ),
          );
        }).toList();
      },
      onChanged: (val) {
        setState(() {
          _selectedPontId = val;
        });
      },

      // STYLES DU MENU DÉROULANT
      dropdownColor: backgroundLight,
      iconEnabledColor: textPrimary,
      borderRadius: BorderRadius.circular(16),
      style: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'DarumadropOne',
      ),
    );
  }

  // CONSTRUIRE LE WIDGET PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // BARRE DE NAVIGATION
      appBar: AppBar(
        title: const Text(
          "AJOUTER UNE RÉSERVATION",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: backgroundLight,

      // CORPS DE LA PAGE
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: 
          Column(
            children: [
              // CHAMP DE SÉLECTION DU PONT & DATE
              Row(
                children: [
                  Expanded(
                    child: _buildPontDropdown(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Date de réservation",
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontSize: 16, color: textPrimary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  
                  // CHAMP DE SÉLECTION DE L'HEURE DE DÉBUT
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Heure de début",
                          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          "${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 16, color: textPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // CHAMP DE L'HEURE DE FIN
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Heure de fin",
                        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        _computeEndTime(),
                        style: const TextStyle(fontSize: 16, color: textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // BOUTON DE SOUMISSION
              ElevatedButton(
                onPressed: _submitReservation,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: secondaryColor,
                ),
                child: const Text(
                  "Ajouter la réservation",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: backgroundLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}