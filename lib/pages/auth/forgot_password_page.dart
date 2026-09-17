import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'reset_code_page.dart';
import 'signup_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage('Please enter your registered email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.forgotPassword(email: email);

      if (!mounted) return;

      showMessage('A password reset code has been sent to your email.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResetCodePage(email: email)),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 40),

              const Icon(Icons.lock_reset_outlined, size: 80),

              const SizedBox(height: 25),

              const Text(
                'Reset Your Password',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text(
                'Enter the email address registered with your FarmTab account. We will send you a 6-digit code to reset your password.',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: const InputDecoration(
                  labelText: 'Registered Email',
                  border: OutlineInputBorder(),

                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,

                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSubmit,

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,

                          child: CircularProgressIndicator(),
                        )
                      : const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text("Don't have an account?"),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },

                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
