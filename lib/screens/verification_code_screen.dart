import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package

import '../services/supabase_service.dart';

class VerificationCodeScreen extends StatelessWidget {
  final TextEditingController emailController =
      TextEditingController(); // To capture the email
  final TextEditingController codeController =
      TextEditingController(); // To capture the OTP code

  VerificationCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and the verification code sent to your inbox.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Email Field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // OTP Code Field
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter the code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Verify Button
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final otp = codeController.text.trim();

                if (email.isEmpty || otp.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required.')),
                  );
                  return;
                }

                try {
                  final service = SupabaseService();
                  await service.verifyOTP(email, otp, OtpType.recovery);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification Successful!')),
                  );

                  // Utilisez un `unique NavigatorKey` pour naviguer
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/reset-password',
                    (route) => false, // Supprime tous les écrans de la pile
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
