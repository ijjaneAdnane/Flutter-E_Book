import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importez Supabase

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> livre;

  const BookDetailsPage({Key? key, required this.livre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vérifier si le livre est disponible
    final isAvailable = livre['disponible'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du livre'),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Retour à la page précédente (HomePage)
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo du livre
            Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                  width: 2,
                ),
                color: Colors.grey.shade200,
                image: livre['photo'] != null
                    ? DecorationImage(
                        image: NetworkImage(livre['photo']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: livre['photo'] == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 20),

            // Titre du livre
            Text(
              livre['titre'] ?? 'Titre inconnu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Auteur
            Text(
              'Auteur: ${livre['auteur'] ?? 'Auteur inconnu'}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Description
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              livre['description'] ?? 'Aucune description disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Résumé
            Text(
              'Résumé:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              livre['resume'] ?? 'Aucun résumé disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Bouton "Emprunter"
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      // Afficher la boîte de dialogue pour les dates
                      _showBorrowDialog(context, livre);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable
                    ? Colors.deepPurple
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isAvailable ? 'Emprunter' : 'Indisponible',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher la boîte de dialogue
  void _showBorrowDialog(BuildContext context, Map<String, dynamic> livre) {
    TextEditingController dateEmpruntController = TextEditingController();
    TextEditingController heureEmpruntController = TextEditingController();
    TextEditingController dateRetourController = TextEditingController();
    TextEditingController heureRetourController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emprunter le livre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date d'emprunt
                TextField(
                  controller: dateEmpruntController,
                  decoration: InputDecoration(
                    labelText: 'Date d\'emprunt',
                    hintText: 'JJ/MM/AAAA',
                  ),
                ),
                SizedBox(height: 10),
                // Heure d'emprunt
                TextField(
                  controller: heureEmpruntController,
                  decoration: InputDecoration(
                    labelText: 'Heure d\'emprunt',
                    hintText: 'HH:MM',
                  ),
                ),
                SizedBox(height: 10),
                // Date de retour
                TextField(
                  controller: dateRetourController,
                  decoration: InputDecoration(
                    labelText: 'Date de retour',
                    hintText: 'JJ/MM/AAAA',
                  ),
                ),
                SizedBox(height: 10),
                // Heure de retour
                TextField(
                  controller: heureRetourController,
                  decoration: InputDecoration(
                    labelText: 'Heure de retour',
                    hintText: 'HH:MM',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Récupérer les valeurs saisies
                final dateEmprunt = dateEmpruntController.text;
                final heureEmprunt = heureEmpruntController.text;
                final dateRetour = dateRetourController.text;
                final heureRetour = heureRetourController.text;

                // Valider les champs
                if (dateEmprunt.isNotEmpty &&
                    heureEmprunt.isNotEmpty &&
                    dateRetour.isNotEmpty &&
                    heureRetour.isNotEmpty) {
                  try {
                    // Insérer les données dans la table `emprunts`
                    await Supabase.instance.client.from('emprunts').insert({
                      'date_emprunt': dateEmprunt,
                      'heure_emprunt': heureEmprunt,
                      'date_retour': dateRetour,
                      'heure_retour': heureRetour,
                      'livre_id': livre['id'],
                      'user_id': Supabase.instance.client.auth.currentUser?.id,
                    });

                    // Afficher un message de succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emprunt enregistré avec succès !'),
                      ),
                    );

                    // Fermer la boîte de dialogue
                    Navigator.pop(context);
                  } catch (e) {
                    // Gérer les erreurs
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Une erreur s\'est produite : $e'),
                      ),
                    );
                  }
                } else {
                  // Afficher un message d'erreur si les champs sont vides
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez remplir tous les champs.'),
                    ),
                  );
                }
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }
}