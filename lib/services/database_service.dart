import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // ---------------- USERS ----------------

  /// Fetch all users
  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await client.from('users').select('*');
      if (response.isEmpty) {
        throw Exception('Error fetching users: No data returned');
      }
      return response;
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  /// Add a new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await client.from('users').insert(userData);
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  /// Update a user
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await client.from('users').update(userData).eq('id', userId);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await client.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // ---------------- LIVRES ----------------

  /// Fetch all books
  Future<List<dynamic>> fetchBooks() async {
    try {
      final response = await client
          .from('livre')
          .select('*, auteur(*), image(*)'); // Fetch books with relations
      if (response.isEmpty) {
        throw Exception('Error fetching books: No data returned');
      }
      return response;
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<void> addBook(Map<String, dynamic> bookData) async {
    try {
      // Assurez-vous que l'utilisateur est authentifié
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ajoutez l'user_id aux données du livre
      bookData['user_id'] = user.id;

      // Insérez le livre et récupérez les données insérées
      final response = await Supabase.instance.client
          .from('livres')
          .insert(bookData)
          .select(); // Ajoutez .select() pour récupérer les données insérées

      if (response.isEmpty) {
        throw Exception('Error adding book: No data returned');
      }

      print('Livre ajouté avec succès: ${response}');
    } catch (e) {
      throw Exception('Error adding book: $e');
    }
  }

  /// Update a book
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateBook(String id, Map<String, dynamic> bookData) async {
    await _supabase
        .from('livres') // Nom de la table dans Supabase
        .update(bookData)
        .eq('id', id); // Utiliser l'ID comme entier
  }

  /// Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      await client.from('livre').delete().eq('id', bookId);
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }

  // ---------------- EMPRUNT ----------------

  /// Fetch all borrow records
  Future<List<dynamic>> fetchBorrows() async {
    try {
      final response = await client.from('emprunt').select(
          '*, users(*), livre(*)'); // Fetch borrow records with relations
      if (response.isEmpty) {
        throw Exception('Error fetching borrow records: No data returned');
      }
      return response;
    } catch (e) {
      throw Exception('Error fetching borrow records: $e');
    }
  }

  /// Add a new borrow record
  Future<void> addBorrow(Map<String, dynamic> borrowData) async {
    try {
      await client.from('emprunt').insert(borrowData);
    } catch (e) {
      throw Exception('Error adding borrow record: $e');
    }
  }

  /// Update a borrow record
  Future<void> updateBorrow(
      String borrowId, Map<String, dynamic> borrowData) async {
    try {
      await client.from('emprunt').update(borrowData).eq('id', borrowId);
    } catch (e) {
      throw Exception('Error updating borrow record: $e');
    }
  }

  /// Delete a borrow record
  Future<void> deleteBorrow(String borrowId) async {
    try {
      await client.from('emprunt').delete().eq('id', borrowId);
    } catch (e) {
      throw Exception('Error deleting borrow record: $e');
    }
  }

  Future<void> emprunterLivreEtNotifier(
      String userId, String livreId, DateTime dateRetour) async {
    final supabase = Supabase.instance.client;

    try {
      // 1. Insérer l'emprunt dans la table `emprunts`
      final empruntResponse = await supabase
          .from('emprunts')
          .insert({
            'user_id': userId,
            'livre_id': livreId,
            'date_retour': dateRetour.toIso8601String(),
          })
          .select()
          .single();

      final empruntId = empruntResponse['id'] as String;

      // 2. Créer une notification dans la table `notifications`
      await supabase.from('notifications').insert({
        'user_id': userId,
        'livre_id': livreId,
        'emprunt_id': empruntId,
        'message':
            'Vous avez emprunté un livre. Date de retour: ${dateRetour.toLocal()}',
      });

      print('Emprunt et notification créés avec succès.');
    } catch (e) {
      print(
          'Erreur lors de l\'emprunt ou de la création de la notification: $e');
    }
  }

  // ---------------- NOTIFICATIONS ----------------

  /// Fetch all notifications
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    try {
      final response = await client
          .from('notifications')
          .select(
              '*, livres(*), emprunts(*)') // Inclure les détails du livre et de l'emprunt
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        throw Exception('Error fetching notifications: No data returned');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'lue': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Add a new notification
  Future<void> addNotification(Map<String, dynamic> notificationData) async {
    try {
      await client.from('notifications').insert(notificationData);
    } catch (e) {
      throw Exception('Error adding notification: $e');
    }
  }

  /// Update a notification
  Future<void> updateNotification(
      String notificationId, Map<String, dynamic> notificationData) async {
    try {
      await client
          .from('notifications')
          .update(notificationData)
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Error updating notification: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await client.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}
