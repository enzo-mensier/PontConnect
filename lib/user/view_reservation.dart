import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE DE RECHERCHE DE RESERVATIONS
class ReservationsSchedulePage extends StatefulWidget {
  const ReservationsSchedulePage({Key? key}) : super(key: key);
  @override
  _ReservationsSchedulePageState createState() => _ReservationsSchedulePageState();
}

// ETAT DE LA PAGE
class _ReservationsSchedulePageState extends State<ReservationsSchedulePage> {

  // VARIABLES
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
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}user/getPonts.php'));
      final data = json.decode(response.body);
      
      // VERIFIER LA REPONSE
      if (data['success']) {
        setState(() {
          _ponts = data['ponts'];
          if (_ponts.isNotEmpty) {
            _selectedPontId = _ponts[0]['pont_id'];
          }
        });
        
        // RECHERCHER LES RESERVATIONS AUTO
        if (_ponts.isNotEmpty) {
          _searchSchedule();
        }
      } else {
        _showMessage('ERREUR LORS DU CHARGEMENT DES PONTS.');
      }
    } catch (e) {
      _showMessage('ERREUR: ${e.toString()}');
    }
  }

  // RECHERCHER LES RÉSERVATIONS
  Future<void> _searchSchedule() async {

    // VERIFIER LE PONT SELECTIONNE
    if (_selectedPontId == null) return;
    setState(() {
      _isLoading = true;
      _schedule = [];
    });
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // RECUPERER LES RESERVATIONS
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}user/schedule.php?pont_id=$_selectedPontId&date=$formattedDate');
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

  // CHOISIR UNE DATE
  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),

      // PERSONNALISATION DU THEME
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: backgroundLight,
              onSurface: textPrimary,
            ),
            dialogBackgroundColor: backgroundLight,
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'DarumadropOne',
            ),
          ),
          child: child!,
        );
      },
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
        final String statusText = slot['status'].toString().toLowerCase();

        // COULEURS SELON LE STATUS
        Color chipColor;
        if (statusText == 'maintenance') {
          chipColor = accentColor2;
        } else if (statusText == 'pont ouvert') {
          chipColor = accentColor;
        } else {
          chipColor = secondaryColor;
        }

        // CONSTRUIRE LE WIDGET DE LA CARTE
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

          // CONTENU DE LA CARTE
          child: Container(
            decoration: BoxDecoration(
              color: backgroundLight,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                left: BorderSide(
                  color: chipColor,
                  width: 5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // AFFICHAGE DE L'HEURE
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
                        color: chipColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        // AFFICHAGE DU STATUS
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

                // AFFICHAGE DE LA RESERVATION
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

  // STYLE DU BORDURE DE CHAMP
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

      // BARRE DE NAVIGATION
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

      // CORPS DE LA PAGE
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
        child: Column(
          children: [
            // SELECTIONNER UN PONT + DATE + BOUTON DE RECHERCHE
            Row(
              children: [

                // SELECTIONNER UN PONT
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _selectedPontId,
                    hint: Text("Pont", style: TextStyle(color: textSecondary)),
                    dropdownColor: backgroundLight,
                    iconEnabledColor: textPrimary,
                    borderRadius: BorderRadius.circular(16),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'DarumadropOne',
                    ),

                    // LISTE DES PONTS
                    selectedItemBuilder: (BuildContext context) {
                      return _ponts.map<Widget>((pont) {
                        return Text(
                          pont['nom'],
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'DarumadropOne',
                          ),
                        );
                      }).toList();
                    },

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
                            style: TextStyle(color: textPrimary),
                          ),
                        ),
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

                // SELECTIONNER UNE DATE
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

            // AFFICHAGE DE LA LISTE DES RESERVATIONS
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