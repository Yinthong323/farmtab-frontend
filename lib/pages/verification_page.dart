import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final codeController = TextEditingController();

  Timer? timer;

  int remainingSeconds = 60;

  bool isVerifying = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();

    startCountdown();
  }

  @override
  void dispose() {
    timer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  void startCountdown() {
    timer?.cancel();

    setState(() {
      remainingSeconds = 60;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds <= 1) {
          timer.cancel();

          if (mounted) {
            setState(() {
              remainingSeconds = 0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              remainingSeconds--;
            });
          }
        }
      },
    );
  }

  Future<void> handleVerify() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      showMessage('Please enter the 6-digit verification code.');
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      await AuthService.verifyEmail(
        email: widget.email,
        code: code,
      );

      if (!mounted) return;

      showMessage('Email verified successfully!');

      // Organisation page will be added later.
      // For now, go back to signup/login flow.
      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  Future<void> handleResend() async {
    if (remainingSeconds > 0 || isResending) {
      return;
    }

    setState(() {
      isResending = true;
    });

    try {
      await AuthService.resendCode(
        email: widget.email,
      );

      if (!mounted) return;

      showMessage(
        'A new verification code has been sent.',
      );

      startCountdown();
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = remainingSeconds == 0 && !isResending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
              ),

              const SizedBox(height: 25),

              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'We sent a 6-digit verification code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : handleVerify,
                  child: isVerifying
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Verify Email',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: canResend
                    ? handleResend
                    : null,
                child: isResending
                    ? const Text('Sending...')
                    : remainingSeconds > 0
                        ? Text(
                            'Resend Code (${remainingSeconds}s)',
                          )
                        : const Text(
                            'Resend Code',
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}