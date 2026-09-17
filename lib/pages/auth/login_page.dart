import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';
import '../home/home_page.dart';
import '../onboarding/organisation_selection_page.dart';
import '../onboarding/pending_request_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> handleLogin() async {
    final login = loginController.text.trim();
    final password = passwordController.text;

    if (login.isEmpty) {
      showMessage('Please enter your username or email.');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter your password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await AuthService.login(login: login, password: password);

      if (!mounted) return;

      final status = result['organisation_status'];
      final user = result['user'];
      final organisation = result['organisation'];
      final accessToken = result['access_token'];

      if (status == 'APPROVED') {
        final Map<String, dynamic> userWithToken = {
          ...user,
          'access_token': accessToken,
        };

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(user: userWithToken, organisation: organisation),
          ),
        );
      } else if (status == 'PENDING') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PendingRequestPage(
              user: {...user, 'access_token': accessToken},
              organisation: organisation,
            ),
          ),
        );
      } else if (status == 'NONE') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrganisationSelectionPage(accessToken: accessToken),
          ),
        );
      } else {
        showMessage('Unknown organisation status.');
      }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const Spacer(),

              const Text(
                'FarmTab',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Farm Management System',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 45),

              TextField(
                controller: loginController,

                decoration: const InputDecoration(
                  labelText: 'Username or Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,

                obscureText: obscurePassword,

                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),

                  prefixIcon: const Icon(Icons.lock_outline),

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

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,

                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },

                  child: const Text('Forgot Password?'),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 52,

                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,

                          child: CircularProgressIndicator(),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,

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

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
