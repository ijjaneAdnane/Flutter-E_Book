import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importez Supabase

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> _users = []; // Liste des utilisateurs
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Récupérer les utilisateurs au chargement de la page
  }

  // Méthode pour récupérer les utilisateurs depuis Supabase
  Future<void> _fetchUsers() async {
    try {
      final response =
          await Supabase.instance.client.from('users').select('*').execute();

      // Vérifiez si la réponse contient des données
      if (response.data != null) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false; // Fin du chargement
        });
      } else {
        throw Exception('Aucune donnée trouvée');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Fin du chargement même en cas d'erreur
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de la récupération des utilisateurs: $e')),
      );
    }
  }

  // Méthode pour supprimer un utilisateur
  Future<void> _deleteUser(String userId) async {
    try {
      await Supabase.instance.client.from('users').delete().eq('id', userId);
      // Rafraîchir la liste des utilisateurs après la suppression
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de la suppression de l\'utilisateur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des Utilisateurs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          user['email'] ?? 'Email inconnu',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          user['role'] ?? 'Rôle inconnu',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Supprimer l'utilisateur
                            _deleteUser(user['id']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}