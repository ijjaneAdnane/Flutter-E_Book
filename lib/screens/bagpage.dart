import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BagPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  List<Map<String, dynamic>> _emprunts = []; // Liste des emprunts
  bool _isLoading = true; // Indicateur de chargement
  String _errorMessage = ''; // Message d'erreur

  @override
  void initState() {
    super.initState();
    _fetchEmprunts(); // Récupérer les emprunts au chargement de la page
  }

  // Fonction pour récupérer les emprunts depuis Supabase
  Future<void> _fetchEmprunts() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await Supabase.instance.client
          .from('emprunts')
          .select(
              '*, livres(titre, photo)') // Joindre la table livres pour récupérer le titre et la photo
          .eq('user_id', user.id) // Filtrer par l'utilisateur connecté
          .execute();

      if (response.data != null) {
        setState(() {
          _emprunts = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Aucun emprunt trouvé.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur s\'est produite: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Emprunts',
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
        automaticallyImplyLeading: false, // Désactive le bouton de retour
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _emprunts.length,
                            itemBuilder: (context, index) {
                              final emprunt = _emprunts[index];
                              final livre =
                                  emprunt['livres'] as Map<String, dynamic>?;
                              final titreLivre =
                                  livre?['titre'] ?? 'Titre inconnu';
                              final photoLivre = livre?['photo'];
                              final dateEmprunt =
                                  emprunt['date_emprunt'] ?? 'Date inconnue';
                              final heureEmprunt =
                                  emprunt['heure_emprunt'] ?? 'Heure inconnue';
                              final dateRetour =
                                  emprunt['date_retour'] ?? 'Date inconnue';
                              final heureRetour =
                                  emprunt['heure_retour'] ?? 'Heure inconnue';

                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                                  color: Colors
                                                      .deepPurple.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                'Emprunté le: $dateEmprunt à $heureEmprunt',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                'À retourner le: $dateRetour à $heureRetour',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.deepPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
