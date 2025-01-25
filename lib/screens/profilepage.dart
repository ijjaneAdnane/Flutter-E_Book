import 'package:flutter/material.dart';
import 'package:gestion_biblio/screens/editprofilepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _username;
  String? _email;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Charger les informations de l'utilisateur
  }

  /// Méthode pour récupérer les informations de l'utilisateur
  Future<void> _fetchUserInfo() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        final response = await _supabase
            .from('users')
            .select('username, email, profile_image_url')
            .eq('id', user.id)
            .single();

        if (response != null) {
          // Générer une URL signée si nécessaire
          String? signedUrl;
          if (response['profile_image_url'] != null) {
            signedUrl = await _generateSignedUrl(response['profile_image_url']);
          }

          // Mettre à jour l'état avec les données récupérées
          setState(() {
            _username = response['username'];
            _email = response['email'];
            photoUrl = signedUrl ?? response['profile_image_url'];
          });

          print(
              'Données utilisateur récupérées : $_username, $_email, $photoUrl');
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur : $e');
    }
  }

  /// Générer une URL signée pour le fichier
  Future<String?> _generateSignedUrl(String path) async {
    try {
      // Nettoyer le chemin pour éviter les erreurs
      final sanitizedPath = path.replaceAll(' ', '%20');

      final response = await _supabase.storage
          .from('profile_images') // Nom du bucket
          .createSignedUrl(sanitizedPath, 60 * 60); // URL valide 1h

      print('URL signée générée : $response');
      return response;
    } catch (e) {
      print('Erreur lors de la génération de l\'URL signée : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Affichage de la photo de profil avec une ombre portée
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                onBackgroundImageError: photoUrl != null
                    ? (exception, stackTrace) {
                        print('Erreur de chargement de l\'image : $exception');
                        setState(() {
                          photoUrl = null;
                        });
                      }
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Section des informations personnelles avec un dégradé de fond
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations Personnelles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Username', _username ?? 'Loading...'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Email', _email ?? 'Loading...'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton pour modifier le profil avec une animation
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );

                if (result == true) {
                  await _fetchUserInfo(); // Recharger les informations
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                shadowColor: Colors.blue.withOpacity(0.3),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}