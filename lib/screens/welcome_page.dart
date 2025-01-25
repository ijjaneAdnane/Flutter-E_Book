import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Book Store Logo
            // Chargez l'image correctement
            Image.asset(
              'assets/book.PNG', // Assurez-vous que le chemin est correct
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'E - Book Store',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'Here you can find the best books for you, read or Borrow to them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            // Continue Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home'); // Navigate to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 96, 211),
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
