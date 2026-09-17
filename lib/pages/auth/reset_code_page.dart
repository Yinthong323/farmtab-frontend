import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'new_password_page.dart';

class ResetCodePage extends StatefulWidget {
  final String email;

  const ResetCodePage({super.key, required this.email});

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final codeController = TextEditingController();

  bool isLoading = false;
  bool isResending = false;

  int resendCountdown = 0;
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();

    // The first reset code was already sent from Forgot Password.
    // Prevent the user from immediately requesting another one.
    startResendCountdown();
  }

  @override
  void dispose() {
    codeController.dispose();
    resendTimer?.cancel();
    super.dispose();
  }

  void startResendCountdown() {
    resendTimer?.cancel();

    setState(() {
      resendCountdown = 60;
    });

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (resendCountdown <= 1) {
        timer.cancel();

        setState(() {
          resendCountdown = 0;
        });
      } else {
        setState(() {
          resendCountdown--;
        });
      }
    });
  }

  Future<void> handleVerify() async {
    final code = codeController.text.trim();

    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      showMessage('Please enter the 6-digit reset code.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await AuthService.verifyResetCode(
        email: widget.email,
        code: code,
      );

      final resetToken = result['reset_token'];

      if (resetToken == null) {
        throw Exception('Invalid reset session.');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordPage(resetToken: resetToken),
        ),
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

  Future<void> handleResendCode() async {
    if (resendCountdown > 0 || isResending) {
      return;
    }

    setState(() {
      isResending = true;
    });

    try {
      await AuthService.resendResetCode(email: widget.email);

      if (!mounted) return;

      codeController.clear();

      showMessage('A new reset code has been sent to your email.');

      startResendCountdown();
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
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
      appBar: AppBar(title: const Text('Verify Reset Code')),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: 40),

              const Icon(Icons.mark_email_read_outlined, size: 80),

              const SizedBox(height: 25),

              const Text(
                'Enter Reset Code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Text(
                'We sent a 6-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: '6-Digit Code',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleVerify,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'Verify Code',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: (resendCountdown > 0 || isResending)
                    ? null
                    : handleResendCode,
                child: isResending
                    ? const Text('Sending new code...')
                    : resendCountdown > 0
                    ? Text('Resend Code in ${resendCountdown}s')
                    : const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
