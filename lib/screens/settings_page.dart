import 'package:flutter/material.dart';
import 'package:gestion_biblio/screens/editprofilepage.dart';
import 'package:gestion_biblio/screens/logout_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importez Supabase

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Bouton pour modifier le profil
            _buildSettingTile(
              context,
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                _navigateToEditProfile(context);
              },
            ),
            // Bouton pour réinitialiser le mot de passe
            _buildSettingTile(
              context,
              icon: Icons.lock_reset,
              title: 'Reset Password',
              onTap: () {
                _showResetPasswordDialog(context);
              },
            ),
            // Bouton de déconnexion
            _buildSettingTile(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                _navigateToLogoutPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour naviguer vers la page de modification du profil
  void _navigateToEditProfile(BuildContext context) {
    print('Navigating to EditProfilePage'); // Débogage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  // Méthode pour naviguer vers la page de déconnexion
  void _navigateToLogoutPage(BuildContext context) {
    print('Navigating to LogoutPage'); // Débogage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LogoutPage(),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue de réinitialisation de mot de passe
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs.'),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les mots de passe ne correspondent pas.'),
                    ),
                  );
                  return;
                }

                try {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(password: newPassword),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mot de passe mis à jour avec succès.'),
                      ),
                    );
                    Navigator.pop(context); // Fermer la boîte de dialogue
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aucun utilisateur connecté.'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la mise à jour du mot de passe: $e'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );
  }

  // Widget pour construire une tuile de paramètre stylisée
  Widget _buildSettingTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}