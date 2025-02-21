import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'user_session_storage.dart';

// COULEURS
import 'package:pontconnect/colors.dart';

class UserReservationsPage extends StatefulWidget {
  const UserReservationsPage({super.key});

  // CREATION D'ETAT
  @override
  _UserReservationsPageState createState() => _UserReservationsPageState();
}

class _UserReservationsPageState extends State<UserReservationsPage> {
  List<dynamic> _reservations = [];
  bool _isLoading = false;

  // INITIALISATION
  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // RECUPERER RESERVATIONS
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

  // METTRE A JOUR LE STATUT
  Future<void> _updateStatus(int reservationId, String newStatut) async {
    if (UserSession.userId == null) return;
    try {
      // API REST URL
      final url = Uri.parse('${ApiConstants.baseUrl}user/userUpdateReservationStatus.php');
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

  // CONSTRUIRE UN ITEM DE RESERVATION
  Widget _buildReservationItem(dynamic reservation) {
    final dateDebut = DateTime.parse(reservation['date_debut']);
    final dateFin = DateTime.parse(reservation['date_fin']);
    final formattedDateDebut =
    DateFormat('dd/MM/yyyy HH:mm').format(dateDebut);
    final formattedDateFin =
    DateFormat('dd/MM/yyyy HH:mm').format(dateFin);

    String currentStatus = reservation['statut'];
    if (!["en attente", "annulé", "confirmé"].contains(currentStatus)) {
      currentStatus = "en attente";
    }

    final Color statusColor;
    if (currentStatus == "annulé") {
      statusColor = textSecondary;
    } else if (currentStatus == "confirmé") {
      statusColor = accentColor;
    } else {
      statusColor = secondaryColor;
    }

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
          color: backgroundLight, // Changer la couleur de fond en noir
          border: Border(
            left: BorderSide(color: statusColor, width: 5),

          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
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
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENTETE DE L'ITEM
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

                // MENU DEROULANT
                Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DropdownButton<String>(
                    value: currentStatus == "confirmé" ? null : currentStatus,

                    hint: Text(
                      "confirmé",
                      style: const TextStyle(fontSize: 14, color: backgroundLight,fontFamily: 'DarumadropOne'),
                    ),

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
                    underline: Container(),
                    isDense: true,
                    iconSize: 16,
                    selectedItemBuilder: (BuildContext context) {
                      if (currentStatus == "confirmé") {
                        return <Widget>[
                          Text(
                            "confirmé",
                            style: const TextStyle(fontSize: 14, color: textPrimary),
                          )
                        ];
                      } else {
                        return ["en attente", "annulé"].map((status) {
                          return Text(
                            status,
                            style: const TextStyle(fontSize: 14, color: backgroundLight),
                          );
                        }).toList();
                      }
                    },
                    items: currentStatus == "confirmé"
                        ? <String>["annulé"].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList()
                        : <String>["en attente", "annulé"].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 14),
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

            // INFORMATIONS DE DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DÉBUT: $formattedDateDebut",
                  style: const TextStyle(
                      fontSize: 14, color: textPrimary),
                ),
                Text(
                  "FIN: $formattedDateFin",
                  style: const TextStyle(
                      fontSize: 14, color: textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // CONSTRUIRE LA PAGE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MES RÉSERVATIONS",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: backgroundLight),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),

      body: Container(
        color: backgroundLight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reservations.isEmpty
            ? RefreshIndicator(
          onRefresh: _fetchReservations,
          child: ListView(
            padding: const EdgeInsets.only(top: 25),
            children: [
              const SizedBox(height: 50),
              Center(
                child: Text(
                  "VOUS N'AVEZ PAS DE RÉSERVATION",
                  style: TextStyle(fontSize: 16, color: textPrimary),
                ),
              ),
            ],
          ),
        )
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