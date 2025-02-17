import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

class AddReservationPage extends StatefulWidget {
  const AddReservationPage({super.key});

  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  int? _currentUserId;
  List<dynamic> _ponts = [];
  int? _selectedPontId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  bool _isLoading = false;

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
      final response = await http.get(Uri.parse('http://192.168.145.118:8888/api/getPonts.php'));
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
      firstDate: DateTime(2020),
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
      final url = Uri.parse('http://192.168.145.118:8888/api/addReservation.php');
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
      decoration: const InputDecoration(
        labelText: "Choisir un pont",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      value: _selectedPontId,
      items: _ponts.map<DropdownMenuItem<int>>((pont) {
        return DropdownMenuItem<int>(
          value: pont['pont_id'],
          child: Text(pont['nom']),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedPontId = val;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une Réservation"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildPontDropdown(),
              const SizedBox(height: 10),
              // Choix de la date
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date de réservation",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Choix de l'heure de début
              GestureDetector(
                onTap: _pickStartTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Heure de début",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    "${_selectedStartTime.hour.toString().padLeft(2, '0')}:${_selectedStartTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Affichage dynamique de l'heure de fin
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Heure de fin (30 min après le début)",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _computeEndTime(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReservation,
                child: const Text("Ajouter la réservation"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}