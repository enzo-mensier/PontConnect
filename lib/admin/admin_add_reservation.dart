import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user/user_session_storage.dart';

// COULEURS
import 'package:pontconnect/colors.dart';

class AdminAddReservation extends StatefulWidget {
  const AdminAddReservation({super.key});

  @override
  _AdminAddReservationState createState() => _AdminAddReservationState();
}

class _AdminAddReservationState extends State<AdminAddReservation> {
  int? _currentUserId;
  List<dynamic> _ponts = [];
  int? _selectedPontId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  bool _isLoading = false;
  // Valeur par défaut pour le statut admin
  String _selectedStatut = "maintenance";
  // Liste des statuts autorisés
  final List<String> _statuts = ["en attente", "confirmé", "annulé", "maintenance"];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchPonts();
    _selectedStartTime = TimeOfDay.now();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUserId = UserSession.userId;
    });
  }

  Future<void> _fetchPonts() async {
    try {
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
        _showMessage("Erreur lors du chargement des ponts.");
      }
    } catch (e) {
      _showMessage("Erreur: ${e.toString()}");
    }
  }

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

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitReservation() async {
    if (_selectedPontId == null || _currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

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
      final url = Uri.parse('${ApiConstants.baseUrl}adminAddReservation.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": _currentUserId,
          "pont_id": _selectedPontId,
          "date": dateStr,
          "start_time": startTimeStr,
          "statut": _selectedStatut, // Envoi du statut choisi
        }),
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        _showMessage("Réservation ajoutée avec succès");
      } else {
        _showMessage("Erreur : ${data['message']}");
      }
    } catch (e) {
      _showMessage("Erreur: ${e.toString()}");
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildPontDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Choisir un pont",
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textSecondary),
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
      items: _ponts.map<DropdownMenuItem<int>>((pont) {
        return DropdownMenuItem<int>(
          value: pont['pont_id'],
          child: Text(
            pont['nom'],
            style: const TextStyle(fontSize: 16, color: textPrimary),
          ),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedPontId = val;
        });
      },
    );
  }

  Widget _buildStatutDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Choisir le statut",
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textSecondary),
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
      value: _selectedStatut,
      items: _statuts.map<DropdownMenuItem<String>>((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            status,
            style: const TextStyle(fontSize: 16, color: textPrimary),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedStatut = val;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AJOUTER UNE RÉSERVATION",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: backgroundLight,
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              // PREMIÈRE LIGNE: Dropdown Pont et Date
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
              // DEUXIÈME LIGNE: Heure de début et d'affichage de l'heure de fin
              Row(
                children: [
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
              const SizedBox(height: 16),
              // TROISIÈME LIGNE: Dropdown pour le statut
              _buildStatutDropdown(),
              const SizedBox(height: 24),
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