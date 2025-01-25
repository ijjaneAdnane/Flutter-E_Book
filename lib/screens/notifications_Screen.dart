import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/database_service.dart'; // Ajustez le chemin si nécessaire

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({required this.userId, super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DatabaseService dbService = DatabaseService();
  List<Map<String, dynamic>> emprunts = []; // Liste des livres empruntés
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmprunts(); // Récupérer les livres empruntés au chargement de la page
  }

  // Récupérer les livres empruntés de l'utilisateur
  Future<void> _fetchEmprunts() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await supabase
          .from('emprunts')
          .select('*, livres(titre, photo)') // Joindre la table livres
          .eq('user_id', user.id) // Filtrer par l'utilisateur connecté
          .execute();

      if (response.data != null) {
        setState(() {
          emprunts = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des emprunts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Calculer le temps restant avant la date et l'heure de retour
  String _calculateTimeLeft(String dateRetour, String heureRetour) {
    if (dateRetour.isEmpty || heureRetour.isEmpty) {
      return 'Date ou heure de retour invalide';
    }

    try {
      // Nettoyer la chaîne de date et d'heure
      final cleanedDateRetour = dateRetour.replaceFirst('T', ' ');
      final cleanedHeureRetour = heureRetour.replaceFirst('a ', '');

      // Assurez-vous que la date et l'heure sont dans le bon format
      final now = DateTime.now();
      final formattedDateTime = '$cleanedDateRetour $cleanedHeureRetour:00'; // Ajouter :00 pour les secondes
      final retourDateTime = DateTime.parse(formattedDateTime); // Format attendu : yyyy-MM-dd HH:mm:ss

      final difference = retourDateTime.difference(now);

      if (difference.isNegative) {
        return 'Retour en retard';
      }

      final days = difference.inDays;
      final hours = difference.inHours.remainder(24);
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      return '$days jours, $hours heures, $minutes minutes, $seconds secondes';
    } catch (e) {
      print('Erreur lors du calcul du temps restant: $e');
      return 'Erreur de calcul du temps restant';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Livres Empruntés',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : emprunts.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun livre emprunté pour le moment.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: emprunts.length,
                    itemBuilder: (context, index) {
                      final emprunt = emprunts[index];
                      final livre = emprunt['livres'] as Map<String, dynamic>?;
                      final titreLivre = livre?['titre'] ?? 'Titre inconnu';
                      final photoLivre = livre?['photo'];
                      final dateRetour = emprunt['date_retour'] ?? 'Date inconnue';
                      final heureRetour = emprunt['heure_retour'] ?? 'Heure inconnue';

                      // Calculer le temps restant
                      final timeLeft = _calculateTimeLeft(dateRetour, heureRetour);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            // Ajoutez une action ici si nécessaire
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                photoLivre != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          photoLivre,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.deepPurple,
                                          size: 30,
                                        ),
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titreLivre,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'À retourner le: $dateRetour à $heureRetour',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Temps restant: $timeLeft',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}