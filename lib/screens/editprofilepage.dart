import 'dart:typed_data'; // Pour utiliser Uint8List

import 'package:file_picker/file_picker.dart'; // Pour sélectionner une image depuis la machine
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour sélectionner une image depuis la galerie
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? photoUrl; // URL de la photo actuelle
  Uint8List? _selectedImageBytes; // Bytes de l'image sélectionnée

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Charger les informations de l'utilisateur au démarrage
  }

  // Récupérer les informations de l'utilisateur
  Future<void> _fetchUserInfo() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select(
                'username, email, profile_image_url') // Sélectionner les champs nécessaires
            .eq('id', userId)
            .single();

        if (response != null) {
          setState(() {
            _usernameController.text = response['username'] ?? '';
            _emailController.text = response['email'] ?? '';
            photoUrl =
                response['profile_image_url']; // Récupérer l'URL de l'image
          });
        }
      }
    } catch (e) {
      print(
          'Erreur lors de la récupération des informations de l\'utilisateur: $e');
    }
  }

  // Sélectionner une photo depuis la galerie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  // Sélectionner une photo depuis la machine
  Future<void> _pickImageFromMachine() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        if (file.bytes != null) {
          setState(() {
            _selectedImageBytes = file.bytes;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
    }
  }

  // Uploader l'image dans Supabase Storage et mettre à jour la table users
  Future<void> _uploadImage() async {
    if (_selectedImageBytes != null) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          // Générer un chemin unique pour le fichier dans le dossier de l'utilisateur
          final filePath = '$userId/${DateTime.now().toIso8601String()}.jpg';

          // Uploader l'image dans le bucket en utilisant les bytes
          await Supabase.instance.client.storage
              .from('profile_images')
              .uploadBinary(filePath, _selectedImageBytes!);

          // Récupérer l'URL publique de l'image
          final publicUrl = Supabase.instance.client.storage
              .from('profile_images')
              .getPublicUrl(filePath);

          // Mettre à jour l'URL de l'image dans la table users
          await Supabase.instance.client
              .from('users')
              .update({'profile_image_url': publicUrl}).eq('id', userId);

          setState(() {
            photoUrl =
                publicUrl; // Mettre à jour l'URL de l'image dans l'interface
          });
        }
      } catch (e) {
        print('Erreur lors de l\'upload de l\'image: $e');
      }
    }
  }

  // Méthode pour mettre à jour le profil
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          // Uploader l'image si une nouvelle image est sélectionnée
          if (_selectedImageBytes != null) {
            await _uploadImage();
          }

          // Mettre à jour les informations dans la table "users"
          await Supabase.instance.client.from('users').update({
            'username': _usernameController.text,
            'email': _emailController.text,
          }).eq('id', userId);

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès !')),
          );

          // Retourner un résultat à la page précédente
          Navigator.pop(context,
              true); // Retourne "true" pour indiquer une mise à jour réussie
        }
      } catch (e) {
        // Gérer les erreurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour du profil : $e')),
        );
        print('Erreur : $e'); // Log pour déboguer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le Profil',
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Section pour la photo de profil
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImageBytes != null
                              ? MemoryImage(
                                  _selectedImageBytes!) // Afficher l'image sélectionnée
                              : (photoUrl != null
                                  ? NetworkImage(
                                      photoUrl!) // Afficher l'image depuis l'URL
                                  : null),
                          child: _selectedImageBytes == null && photoUrl == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImageFromMachine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Charger photo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Champ pour le nom d'utilisateur
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom d\'utilisateur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Champ pour l'e-mail
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un e-mail valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Bouton pour enregistrer les modifications
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
