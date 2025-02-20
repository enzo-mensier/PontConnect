import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pontconnect/colors.dart';
import '../user/user_session_storage.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  _AdminUserManagementPageState createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagement> {
  List<dynamic> _users = [];
  bool _isLoading = false;

  final Map<int, String> userTypes = {1: "Habitan", 2: "Capitaine", 3: "Admin"};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (UserSession.userId == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminGetUsers.php?admin_id=${UserSession.userId}');
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _users = data['users'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"))
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateUserType(int targetUserId, int newTypeId) async {
    if (UserSession.userId == null) return;
    final TextEditingController _passwordController = TextEditingController();
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la modification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Veuillez saisir votre mot de passe admin pour confirmer :"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Annuler
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              if (_passwordController.text.trim().isNotEmpty) {
                confirmed = true;
                Navigator.pop(context);
              }
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (!confirmed) return;

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}admin/adminUpdateUserType.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "target_user_id": targetUserId,
          "new_type_id": newTypeId,
          "admin_id": UserSession.userId,
          "admin_password": _passwordController.text.trim(),
        }),
      );
      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Type d'utilisateur mis à jour")));
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "Erreur")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Widget _buildUserItem(dynamic user) {
    int currentType = user['type_user_id'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        title: Text(user['name'] ?? "Nom inconnu", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? "Email inconnu"),
            Row(
              children: [
                const Text("Type : "),
                DropdownButton<int>(
                  value: currentType,
                  items: userTypes.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    if (newVal != null && newVal != currentType) {
                      _updateUserType(user['id'], newVal);
                    }
                  },
                ),
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
      appBar: AppBar(
        title: const Text(
            "GESTION DES UTILISATEURS",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: backgroundLight),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchUsers,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 20),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            return _buildUserItem(_users[index]);
          },
        ),
      ),
    );
  }
}