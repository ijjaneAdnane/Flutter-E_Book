import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gestion_biblio/services/database_service.dart'; // Importez DatabaseService
import 'package:image_picker/image_picker.dart';

class EditBookPage extends StatefulWidget {
  final Map<String, dynamic> book; // Données du livre à modifier

  const EditBookPage({super.key, required this.book});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    // Préremplir les champs avec les données du livre
    _titleController.text = widget.book['titre'];
    _authorController.text = widget.book['auteur'];
    _descriptionController.text = widget.book['description'];
    _resumeController.text = widget.book['resume'];
    _imageUrl = widget.book['photo']; // URL de l'image existante
  }

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

  Future<void> _updateBook() async {
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
      // Mettre à jour le livre dans Supabase
      await DatabaseService().updateBook(widget.book['id'], bookData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livre mis à jour avec succès')),
      );

      // Retourner un résultat à BookListPage pour indiquer que la mise à jour a été effectuée
      Navigator.pop(context,
          true); // Retourne `true` pour indiquer une mise à jour réussie
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du livre: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le Livre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ Titre
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre',
                labelStyle: const TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ Auteur
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Auteur',
                labelStyle: const TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Champ Résumé
            TextField(
              controller: _resumeController,
              decoration: InputDecoration(
                labelText: 'Résumé',
                labelStyle: const TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Bouton pour sélectionner une image
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sélectionner une Image',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Aperçu de l'image
            if (_imageFile != null)
              kIsWeb
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _imageFile!.path,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageFile!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    )
            else if (_imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _imageUrl!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            // Bouton pour mettre à jour le livre
            ElevatedButton(
              onPressed: _updateBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Mettre à jour le Livre',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
