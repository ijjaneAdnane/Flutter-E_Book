import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<int> totalBooksFuture;
  late Future<int> totalUsersFuture;
  late Future<int> totalEmpruntsFuture;
  late String username = 'Admin'; // Par défaut, afficher "Admin"
  bool _isLoadingUser = true; // Indicateur de chargement pour les infos utilisateur

  @override
  void initState() {
    super.initState();
    totalBooksFuture = getTotalBooks();
    totalUsersFuture = getTotalUsers();
    totalEmpruntsFuture = getTotalEmprunts();
    _fetchUserInfo(); // Récupérer les informations de l'utilisateur
  }

  // Récupérer les informations de l'utilisateur connecté
  Future<void> _fetchUserInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('username')
            .eq('id', user.id)
            .single()
            .execute();

        if (response.data != null) {
          setState(() {
            username = response.data['username'] ?? 'Admin';
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des informations utilisateur: $e')),
      );
    }
  }

  Future<int> getTotalBooks() async {
    try {
      final response =
          await Supabase.instance.client.from('livres').select('id').execute();
      if (response.data != null) {
        return response.data.length;
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  Future<int> getTotalUsers() async {
    try {
      final response =
          await Supabase.instance.client.from('users').select('id').execute();
      if (response.data != null) {
        return response.data.length;
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<int> getTotalEmprunts() async {
    try {
      final response = await Supabase.instance.client
          .from('emprunts')
          .select('id')
          .execute();
      if (response.data != null) {
        return response.data.length;
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Failed to fetch emprunts: $e');
    }
  }

  Future<int> getRecentUsers() async {
    try {
      // Récupérer la date d'il y a 7 jours
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7)).toIso8601String();

      // Récupérer les utilisateurs enregistrés dans les 7 derniers jours
      final response = await Supabase.instance.client
          .from('users')
          .select('id')
          .gte('created_at', sevenDaysAgo) // "gte" signifie "greater than or equal to"
          .execute();

      if (response.data != null) {
        return response.data.length; // Retourner le nombre d'utilisateurs récents
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Failed to fetch recent users: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacementNamed(context, '/sign-in');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoadingUser
                  ? const CircularProgressIndicator()
                  : Text(
                      'Welcome, $username!', // Afficher le nom d'utilisateur
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
              const SizedBox(height: 20),
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<int>(
                    future: totalBooksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard('Total Books', 'Loading...');
                      } else if (snapshot.hasError) {
                        return _buildStatCard('Total Books', 'Error');
                      } else {
                        return _buildStatCard('Total Books', '${snapshot.data}');
                      }
                    },
                  ),
                  FutureBuilder<int>(
                    future: totalUsersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard('Users', 'Loading...');
                      } else if (snapshot.hasError) {
                        return _buildStatCard('Users', 'Error');
                      } else {
                        return _buildStatCard('Users', '${snapshot.data}');
                      }
                    },
                  ),
                  FutureBuilder<int>(
                    future: totalEmpruntsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard('Emprunts', 'Loading...');
                      } else if (snapshot.hasError) {
                        return _buildStatCard('Emprunts', 'Error');
                      } else {
                        return _buildStatCard('Emprunts', '${snapshot.data}');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.add, 'Add Book', () {
                    Navigator.pushNamed(context, '/addBookPage');
                  }),
                  _buildActionButton(Icons.edit, 'Edit Book', () {
                    Navigator.pushNamed(context, '/bookList');
                  }),
                  _buildActionButton(Icons.person, 'Users', () {
                    Navigator.pushNamed(context, '/users');
                  }),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildNotificationCard(
                      icon: Icons.person_add,
                      title: '14 new users registered',
                      subtitle: 'In the last 7 days',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    _buildNotificationCard(
                      icon: Icons.system_update,
                      title: 'System update available',
                      subtitle: '5 hours ago',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    _buildNotificationCard(
                      icon: Icons.backup,
                      title: 'Database backup completed',
                      subtitle: '1 day ago',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14, // Taille réduite pour le titre
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center, // Centrer le texte
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18, // Taille réduite pour la valeur
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}