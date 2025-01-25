import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final response =
          await Supabase.instance.client.from('livres').select('*').execute();

      if (response.data != null) {
        setState(() {
          _books = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception('Aucune donnée trouvée');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des livres: $e')),
      );
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await Supabase.instance.client.from('livres').delete().eq('id', bookId);
      _fetchBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livre supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du livre: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des Livres',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Naviguer vers AddBookPage et attendre le résultat
          final result = await Navigator.pushNamed(context, '/addBook');

          // Si le résultat est `true`, rafraîchir la liste des livres
          if (result == true) {
            _fetchBooks();
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : _books.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun livre trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          // Ajoutez une action au clic sur la carte si nécessaire
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Image du livre
                              if (book['photo'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book['photo'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Titre et auteur
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['titre'] ?? 'Titre inconnu',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book['auteur'] ?? 'Auteur inconnu',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Boutons d'édition et de suppression
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.pushNamed(
                                        context,
                                        '/editBook',
                                        arguments: book,
                                      );

                                      if (result == true) {
                                        _fetchBooks();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _deleteBook(book['id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}