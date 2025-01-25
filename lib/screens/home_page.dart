import 'package:flutter/material.dart';
import 'package:gestion_biblio/screens/bookdetailspage.dart';
import 'package:gestion_biblio/screens/notifications_Screen.dart';
import 'package:gestion_biblio/screens/profilepage.dart';
import 'package:gestion_biblio/screens/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestion_biblio/screens/bagpage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> livres = [];
  bool isLoading = true;
  String errorMessage = '';

  // Déclarez _pages comme une variable d'instance
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    fetchLivres();

    // Initialisez _pages dans initState
    _pages = [
      HomeContent(onRefresh: fetchLivres), // Utilisez fetchLivres ici
      NotificationsScreen(userId: ''),
      ProfilePage(),
      SettingsPage(),
      BagPage(),
    ];
  }

  Future<void> fetchLivres() async {
    try {
      final data = await Supabase.instance.client
          .from('livres')
          .select()
          .order('titre', ascending: true);

      if (data != null) {
        setState(() {
          livres = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Aucun livre trouvé.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Une erreur s\'est produite: $e';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            ),
          ),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.deepPurple,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.deepPurple.shade200,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications, size: 24),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 24),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 24),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag, size: 24),
                label: 'Bag',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final VoidCallback onRefresh; // Callback pour rafraîchir la liste des livres

  HomeContent({required this.onRefresh}); // Constructeur

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('livres')
          .select()
          .order('titre', ascending: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Une erreur s\'est produite: ${snapshot.error}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          );
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(
            child: Text(
              'Aucun livre trouvé.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          );
        } else {
          final livres = List<Map<String, dynamic>>.from(snapshot.data as List);

          return Scrollbar(
            thumbVisibility: true,
            radius: Radius.circular(4),
            thickness: 8,
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: livres.length,
                itemBuilder: (context, index) {
                  final livre = livres[index];
                  final isAvailable = livre['disponible'] == true;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailsPage(livre: livre),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(height: 4),
                            Text(
                              livre['titre'] ?? 'Titre inconnu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              livre['auteur'] ?? 'Auteur inconnu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            ElevatedButton(
                              onPressed: isAvailable
                                  ? () {
                                      _showBorrowDialog(context, livre).then((_) {
                                        onRefresh(); // Rafraîchir la liste des livres après l'emprunt
                                      });
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAvailable
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isAvailable ? 'Emprunter' : 'Indisponible',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
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
      },
    );
  }

  Future<void> _showBorrowDialog(BuildContext context, Map<String, dynamic> livre) async {
    TextEditingController dateEmpruntController = TextEditingController();
    TextEditingController heureEmpruntController = TextEditingController();
    TextEditingController dateRetourController = TextEditingController();
    TextEditingController heureRetourController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emprunter le livre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateEmpruntController,
                  decoration: InputDecoration(
                    labelText: 'Date d\'emprunt',
                    hintText: 'JJ/MM/AAAA',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: heureEmpruntController,
                  decoration: InputDecoration(
                    labelText: 'Heure d\'emprunt',
                    hintText: 'HH:MM',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: dateRetourController,
                  decoration: InputDecoration(
                    labelText: 'Date de retour',
                    hintText: 'JJ/MM/AAAA',
                  ),
                ),
                SizedBox(height: 10),
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
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dateEmprunt = dateEmpruntController.text;
                final heureEmprunt = heureEmpruntController.text;
                final dateRetour = dateRetourController.text;
                final heureRetour = heureRetourController.text;

                if (dateEmprunt.isNotEmpty &&
                    heureEmprunt.isNotEmpty &&
                    dateRetour.isNotEmpty &&
                    heureRetour.isNotEmpty) {
                  try {
                    // Insérer l'emprunt dans la table 'emprunts'
                    await Supabase.instance.client.from('emprunts').insert({
                      'date_emprunt': dateEmprunt,
                      'heure_emprunt': heureEmprunt,
                      'date_retour': dateRetour,
                      'heure_retour': heureRetour,
                      'livre_id': livre['id'],
                      'user_id': Supabase.instance.client.auth.currentUser?.id,
                    });

                    // Mettre à jour le champ 'disponible' du livre dans la table 'livres'
                    await Supabase.instance.client
                        .from('livres')
                        .update({'disponible': false})
                        .eq('id', livre['id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emprunt enregistré avec succès !'),
                      ),
                    );

                    Navigator.pop(context); // Fermer la boîte de dialogue
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Une erreur s\'est produite : $e'),
                      ),
                    );
                  }
                } else {
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