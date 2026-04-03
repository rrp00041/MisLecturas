import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login privado', style: TextStyle(fontSize: 24)),
            SizedBox(height: 12),
            Text(
              'Pendiente integrar Firebase Auth (email/password).',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
