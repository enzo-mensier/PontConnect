import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../user/user_session_storage.dart';

// CENTRALISATION COULEURS & API
import 'package:pontconnect/constants.dart';

// PAGE DE GESTION DES RESERVATIONS EN ATTENTE
class AdminPendingReservations extends StatefulWidget {
  const AdminPendingReservations({super.key});
  @override
  _AdminReservationsState createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminPendingReservations> {
  
  // VARIABLES
  List<dynamic> _reservations = [];
  bool _isLoading = false;

  // STATUTS DE RESERVATION
  final List<String> _statuts = ["confirmé", "annulé", "en attente", "maintenance"];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // RECUPERATION DES RESERVATIONS
  Future<void> _fetchReservations() async {
    setState(() => _isLoading = true);
    try {

      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminGetPendingReservations.php');
      final response = await http.get(url);
      final data = json.decode(response.body);

      // VERIFICATION DE LA REPONSE
      if (data['success'] == true) {
        setState(() {
          _reservations = data['reservations'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "ERREUR")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ERREUR: $e")));
    }
    setState(() => _isLoading = false);
  }

  // MISE A JOUR DU STATUT DE RESERVATION
  Future<void> _updateStatus(int reservationId, String newStatut) async {
    if (UserSession.userId == null) return;
    try {

      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminUpdatePendingReservationStatus.php');
      
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Statut mis à jour")));
        _fetchReservations();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "ERREUR")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ERREUR: $e")));
    }
  }

  // CONFIRMATION DE CHANGEMENT DE STATUT
  void _confirmStatusChange(int reservationId, String currentStatus, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la modification"),
        content: Text("Voulez-vous changer le statut de '$currentStatus' à '$newStatus' ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(reservationId, newStatus);
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  // CONSTRUCTION DES CARTES DE RESERVATIONS
  Widget _buildReservationItem(dynamic reservation) {
    // FORMATTAGE DES DATES
    final DateTime dateDebut = DateTime.parse(reservation['date_debut']);
    final DateTime dateFin = DateTime.parse(reservation['date_fin']);
    final String formattedDebut = DateFormat('dd/MM/yyyy HH:mm').format(dateDebut);
    final String formattedFin = DateFormat('dd/MM/yyyy HH:mm').format(dateFin);

    String currentStatus = reservation['statut'] ?? "en attente";
    final Color statusColor;
    
    // COULEUR DE STATUT
    switch (currentStatus) {
      case "annulé":
        statusColor = textSecondary;
        break;
      case "confirmé":
        statusColor = accentColor;
        break;
      case "maintenance":
        statusColor = accentColor2;
        break;
      default:
        statusColor = secondaryColor;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 3,
      child: ListTile(

        // INFORMATIONS DE RESERVATION
        title: Text(
          "${reservation['user_name'] ?? 'Utilisateur inconnu'} - ${reservation['pont_name'] ?? 'Pont inconnu'}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email : ${reservation['user_email']}", style: const TextStyle(color: textSecondary)),
            Text("Début : $formattedDebut", style: const TextStyle(color: textSecondary)),
            Text("Fin : $formattedFin", style: const TextStyle(color: textSecondary)),
          ],
        ),

        // MENU DEROULANT DE STATUT
        trailing: Container(
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

          child: DropdownButton<String>(
            value: currentStatus,
            underline: Container(),
            isDense: true,

            // QUAND LE MENU EST OUVERT
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

            // QUAND UN ELEMENT EST SELECTIONNE
            selectedItemBuilder: (BuildContext context) {
              return _statuts.map((String status) {
                return Text(
                  status,
                  style: const TextStyle(fontSize: 14, color: backgroundLight, fontFamily: 'DarumadropOne'),
                );
              }).toList();
            },
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
                _confirmStatusChange(reservation['reservation_id'], currentStatus, newValue);
              }
            },
          ),
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
          "Modifier Statut Réservation",
          style: TextStyle(fontWeight: FontWeight.bold, color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),

      // CORPS DE LA PAGE
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchReservations,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 20),
          itemCount: _reservations.length,
          itemBuilder: (context, index) {
            return _buildReservationItem(_reservations[index]);
          },
        ),
      ),
    );
  }
}