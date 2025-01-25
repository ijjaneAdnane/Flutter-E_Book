import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  /// Sign-Up: Create a new user with email, password, and additional user data
  Future<AuthResponse> signUp(
    String username,
    String email,
    String password,
    String confirmPassword, {
    required String role, // Ajoutez le paramètre role
  }) async {
    if (password != confirmPassword) {
      throw Exception("Passwords do not match");
    }

    try {
      // Vérifier si l'email existe déjà dans la table "users"
      final userResponse =
          await client.from('users').select().eq('email', email);

      if (userResponse.isNotEmpty) {
        throw Exception("An account with this email already exists.");
      }

      // Étape 1 : Inscrire l'utilisateur avec Supabase Auth
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'role': role, // Ajoutez le rôle dans les metadata
        },
      );

      if (authResponse.user == null) {
        throw Exception("Failed to create user.");
      }

      // Étape 2 : Ajouter les informations supplémentaires dans la table "users"
      await client.from('users').insert({
        'id': authResponse.user!.id, // ID de l'utilisateur créé
        'username': username,
        'email': email,
        'role': role, // Ajoutez le rôle dans la table users
      });

      return authResponse;
    } catch (e) {
      throw Exception('Sign-Up failed: $e');
    }
  }

  /// Sign-In: Authenticate an existing user with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Étape 1 : Authentifier l'utilisateur
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Sign-In failed: User not found");
      }

      // Étape 2 : Récupérer le rôle de l'utilisateur depuis la table "users"
      final userResponse = await client
          .from('users')
          .select('role')
          .eq('id', authResponse.user!.id)
          .single();

      if (userResponse.isEmpty) {
        throw Exception("User role not found");
      }

      // Retourner l'ID de l'utilisateur et son rôle
      return {
        'id': authResponse.user!.id,
        'role': userResponse['role'],
      };
    } catch (e) {
      throw Exception('Sign-In failed: $e');
    }
  }

  /// Reset Password: Send a password reset email
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Verify OTP: Verify a one-time password (OTP) for email confirmation or password recovery
  Future<AuthResponse> verifyOTP(String email, String otp, OtpType type) async {
    try {
      final response = await client.auth.verifyOTP(
        email: email,
        token: otp,
        type: type == OtpType.recovery ? OtpType.recovery : OtpType.signup,
      );
      return response;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Log Out: Sign out the currently authenticated user
  Future<void> logOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Log out failed: $e');
    }
  }

  /// Get Current User: Retrieve the currently authenticated user's details
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Update User Password: Change the password of the currently authenticated user
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }
}