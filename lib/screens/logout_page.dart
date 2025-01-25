import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _logout(context); // Appeler la méthode de déconnexion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Couleur du bouton
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut(); // Déconnexion de l'utilisateur

      // Rediriger vers l'écran de connexion
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // Utilisez la route racine définie dans MaterialApp
        (route) => false, // Supprime tous les écrans de la pile
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have been logged out successfully.')),
      );
    } catch (e) {
      // Gérer les erreurs de déconnexion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }
}
