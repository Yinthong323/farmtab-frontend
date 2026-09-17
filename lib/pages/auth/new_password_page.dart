import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'login_page.dart';

class NewPasswordPage extends StatefulWidget {
  final String resetToken;

  const NewPasswordPage({super.key, required this.resetToken});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> handleSubmit() async {
    final password = passwordController.text;

    final confirmPassword = confirmPasswordController.text;

    if (password.length < 8) {
      showMessage('Password must contain at least 8 characters.');

      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.resetPassword(
        resetToken: widget.resetToken,
        newPassword: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset successfully. Please login with your new password.',
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (context) => const LoginPage()),

        (route) => false,
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
      appBar: AppBar(title: const Text('Create New Password')),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 40),

              const Icon(Icons.password_outlined, size: 80),

              const SizedBox(height: 25),

              const Text(
                'Create New Password',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              const Text(
                'Please create a new password for your FarmTab account.',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: passwordController,

                obscureText: obscurePassword,

                decoration: InputDecoration(
                  labelText: 'New Password',

                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),

                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: confirmPasswordController,

                obscureText: obscureConfirmPassword,

                decoration: InputDecoration(
                  labelText: 'Confirm New Password',

                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),

                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
