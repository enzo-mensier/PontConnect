import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../user/user_session_storage.dart';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE DE GESTION DES RESERVATIONS
class AdminReservations extends StatefulWidget {
  const AdminReservations({super.key});
  @override
  _AdminReservationsState createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminReservations> {
  
  // VARIABLES
  List<dynamic> _reservations = [];
  bool _isLoading = false;

  // STATUTS DE RESERVATION
  final List<String> _statuts = ["en attente", "confirmé", "annulé", "maintenance"];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // RECUPERATION DES RESERVATIONS
  Future<void> _fetchReservations() async {
    if (UserSession.userId == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}user/getUserReservations.php?user_id=${UserSession.userId}');
      final response = await http.get(url);
      final data = json.decode(response.body);

      // VERIFICATION DE LA REPONSE
      if (data['success'] == true) {
        setState(() {
          _reservations = data['reservations'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "ERREUR")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ERREUR: $e")));
    }
    setState(() {
      _isLoading = false;
    });
  }

  // MISE A JOUR DU STATUT DE RESERVATION
  Future<void> _updateStatus(int reservationId, String newStatut) async {
    if (UserSession.userId == null) return;
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminUpdateReservationStatus.php');
      
      // ENVOI DE LA REQUETE
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "reservation_id": reservationId,
          "user_id": UserSession.userId,
          "statut": newStatut,
        }),
      );
      final data = json.decode(response.body);

      // VERIFICATION DE LA REPONSE
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("MISE À JOUR EFFECTUÉE")));
        _fetchReservations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "ERREUR")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ERREUR: $e")));
    }
  }

  // CONSTRUCTION DES CARTES DE RESERVATIONS
  Widget _buildReservationItem(dynamic reservation) {

    // FORMATTAGE DES DATES
    final dateDebut = DateTime.parse(reservation['date_debut']);
    final dateFin = DateTime.parse(reservation['date_fin']);
    final formattedDateDebut = DateFormat('dd/MM/yyyy HH:mm').format(dateDebut);
    final formattedDateFin = DateFormat('dd/MM/yyyy HH:mm').format(dateFin);

    // STATUT DE RESERVATION
    String currentStatus = reservation['statut'];
    if (!["en attente", "annulé", "confirmé", "maintenance"].contains(currentStatus)) {
      currentStatus = "en attente";
    }

    // COULEUR DE STATUT
    final Color statusColor;
    if (currentStatus == "annulé") {
      statusColor = textSecondary;
    } else if (currentStatus == "confirmé") {
      statusColor = accentColor;
    } else if (currentStatus == "maintenance") {
      statusColor = accentColor2;
    } else {
      statusColor = secondaryColor;
    }

    // CARTE DE RESERVATION
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
          border: Border(
            left: BorderSide(color: statusColor, width: 5),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NOM DU PONT
            Row(
              children: [
                Expanded(
                  child: Text(
                    reservation['nom'] ?? "PONT INCONNU",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),

                // MENU DEROULANT DE STATUT
                Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                  child: DropdownButton<String>(
                    value: currentStatus,
                    underline: Container(),
                    isDense: true,

                    // MENU DEROULANT STYLE
                    dropdownColor: backgroundLight,
                    iconEnabledColor: textPrimary,
                    borderRadius: BorderRadius.circular(16) ,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'DarumadropOne',
                    ),

                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: backgroundLight,
                      size: 25,
                    ),
                    iconSize: 16,

                    selectedItemBuilder: (BuildContext context) {
                      return _statuts.map((String status) {
                        return Text(
                          status,
                          style: const TextStyle(fontSize: 14, color: backgroundLight, fontFamily: 'DarumadropOne'),
                        );
                      }).toList();
                    },

                    // MENU DEROULANT ITEMS
                    items: _statuts.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 14, color: textPrimary, fontFamily: 'DarumadropOne'),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null && newValue != currentStatus) {
                        _updateStatus(reservation['reservation_id'], newValue);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Padding(padding: const EdgeInsets.only(bottom: 5, top: 5)),
            
            // DATES DE RESERVATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("DÉBUT: $formattedDateDebut", style: const TextStyle(fontSize: 14, color: textPrimary)),
                Text("FIN: $formattedDateFin", style: const TextStyle(fontSize: 14, color: textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // BARRE DE NAVIGATION
      appBar: AppBar(
        title: const Text(
          "MES RÉSERVATIONS",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),

      // CORPS DE LA PAGE
      body: Container(
        color: backgroundLight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchReservations,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 25),
            itemCount: _reservations.length,
            itemBuilder: (context, index) {
              return _buildReservationItem(_reservations[index]);
            },
          ),
        ),
      ),
    );
  }
}