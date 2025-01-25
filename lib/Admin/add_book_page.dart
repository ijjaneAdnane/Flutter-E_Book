import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gestion_biblio/services/database_service.dart'; // Importez DatabaseService
import 'package:image_picker/image_picker.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _imageUrl = pickedFile.path;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _addBook() async {
    final title = _titleController.text;
    final author = _authorController.text;
    final description = _descriptionController.text;
    final resume = _resumeController.text;

    if (title.isEmpty ||
        author.isEmpty ||
        description.isEmpty ||
        resume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final bookData = {
      'titre': title,
      'auteur': author,
      'description': description,
      'resume': resume,
      'photo': kIsWeb ? _imageUrl : _imageFile?.path,
    };

    try {
      // Ajouter le livre à Supabase
      await DatabaseService().addBook(bookData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livre ajouté avec succès')),
      );

      // Réinitialiser les champs
      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _resumeController.clear();
      setState(() {
        _imageFile = null;
        _imageUrl = null;
      });

      // Retourner un résultat à l'écran précédent
      Navigator.pop(context, true); // Retourne `true` pour indiquer un succès
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du livre: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Book',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.description, color: Colors.deepPurple),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _resumeController,
                decoration: InputDecoration(
                  labelText: 'Résumé',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.article, color: Colors.deepPurple),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                ),
                child: const Text(
                  'Select Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_imageFile != null || _imageUrl != null)
                kIsWeb
                    ? Image.network(
                        _imageUrl!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _imageFile!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                ),
                child: const Text(
                  'Add Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}