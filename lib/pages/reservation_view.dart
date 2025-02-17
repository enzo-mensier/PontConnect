import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationsSchedulePage extends StatefulWidget {
  const ReservationsSchedulePage({Key? key}) : super(key: key);

  @override
  _ReservationsSchedulePageState createState() => _ReservationsSchedulePageState();
}

class _ReservationsSchedulePageState extends State<ReservationsSchedulePage> {
  List<dynamic> _ponts = [];
  int? _selectedPontId;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedule = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPonts();
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
        _showMessage('Erreur lors du chargement des ponts.');
      }
    } catch (e) {
      _showMessage('Erreur: ${e.toString()}');
    }
  }

  Future<void> _searchSchedule() async {
    if (_selectedPontId == null) return;
    setState(() {
      _isLoading = true;
      _schedule = [];
    });
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      final url = Uri.parse(
          'http://192.168.145.118:8888/api/schedule.php?pont_id=$_selectedPontId&date=$formattedDate');
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _schedule = data['schedule'];
        });
      } else {
        _showMessage('Aucune donnée trouvée pour cette recherche.');
      }
    } catch (e) {
      _showMessage('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildScheduleList() {
    if (_schedule.isEmpty) {
      return const Center(child: Text('Aucune donnée pour cette recherche.'));
    }
    return ListView.builder(
      itemCount: _schedule.length,
      itemBuilder: (context, index) {
        final slot = _schedule[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 3,
          child: ListTile(
            leading: Text(slot['hour'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            title: Text(slot['status']),
            subtitle: slot['reservation'] != null
                ? Text(
              "Début: ${DateFormat('HH:mm').format(DateTime.parse(slot['reservation']['date_debut']))}\nFin: ${DateFormat('HH:mm').format(DateTime.parse(slot['reservation']['date_fin']))}",
            )
                : const Text("Aucune réservation"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar modernisée avec la palette turquoise
      appBar: AppBar(
        title: const Text('Recherche de Réservations'),
        backgroundColor: const Color(0xFF0083B0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Choix du pont
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedPontId,
                    hint: const Text("Sélectionner un pont"),
                    items: _ponts.map<DropdownMenuItem<int>>((pont) {
                      return DropdownMenuItem<int>(
                        value: pont['pont_id'],
                        child: Text(pont['nom']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPontId = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Choix de la date et bouton de recherche
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Sélectionner la date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0083B0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Rechercher"),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Affichage de l'emploi du temps
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildScheduleList(),
            )
          ],
        ),
      ),
    );
  }
}