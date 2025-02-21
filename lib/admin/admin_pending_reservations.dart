import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../user/user_session_storage.dart';
import 'package:pontconnect/colors.dart';

class AdminPendingReservations extends StatefulWidget {
  const AdminPendingReservations({super.key});

  @override
  _AdminReservationsState createState() => _AdminReservationsState();
}

class _AdminReservationsState extends State<AdminPendingReservations> {
  List<dynamic> _reservations = [];
  bool _isLoading = false;
  // Liste des statuts autorisés
  final List<String> _statuts = ["confirmé", "annulé", "en attente", "maintenance"];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminGetPendingReservations.php');
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _reservations = data['reservations'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "Erreur")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(int reservationId, String newStatut) async {
    if (UserSession.userId == null) return;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminUpdatePendingReservationStatus.php');
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
      if (data['success'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Statut mis à jour")));
        _fetchReservations();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "Erreur")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  // CONFIRMATION AVANT MODIF
  void _confirmStatusChange(int reservationId, String currentStatus, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la modification"),
        content: Text("Voulez-vous changer le statut de '$currentStatus' à '$newStatus' ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Annuler
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

  Widget _buildReservationItem(dynamic reservation) {
    final DateTime dateDebut = DateTime.parse(reservation['date_debut']);
    final DateTime dateFin = DateTime.parse(reservation['date_fin']);
    final String formattedDebut = DateFormat('dd/MM/yyyy HH:mm').format(dateDebut);
    final String formattedFin = DateFormat('dd/MM/yyyy HH:mm').format(dateFin);

    String currentStatus = reservation['statut'] ?? "en attente";
    final Color statusColor;
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

            // MENU DEROULANT
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
      appBar: AppBar(
        title: const Text(
          "Modifier Statut Réservation",
          style: TextStyle(fontWeight: FontWeight.bold, color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
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