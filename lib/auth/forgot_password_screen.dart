import 'package:flutter/material.dart';
import 'auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final auth = AuthService();

  void resetPassword() async {
    await auth.resetPassword(emailController.text.trim());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Password reset email sent")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Enter your email"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Send Reset Email"),
            ),
          ],
        ),
      ),
    );
  }
}
