// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../onboarding/organisation_selection_page.dart';
// import '../../services/auth_service.dart';

// class VerificationPage extends StatefulWidget {
//   final String email;

//   const VerificationPage({super.key, required this.email});

//   @override
//   State<VerificationPage> createState() => _VerificationPageState();
// }

// class _VerificationPageState extends State<VerificationPage> {
//   final codeController = TextEditingController();

//   Timer? timer;

//   int remainingSeconds = 60;

//   bool isVerifying = false;
//   bool isResending = false;

//   @override
//   void initState() {
//     super.initState();

//     startCountdown();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     codeController.dispose();
//     super.dispose();
//   }

//   void startCountdown() {
//     timer?.cancel();

//     setState(() {
//       remainingSeconds = 60;
//     });

//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingSeconds <= 1) {
//         timer.cancel();

//         if (mounted) {
//           setState(() {
//             remainingSeconds = 0;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             remainingSeconds--;
//           });
//         }
//       }
//     });
//   }

//   Future<void> handleVerify() async {
//     final code = codeController.text.trim();

//     if (code.length != 6) {
//       showMessage('Please enter the 6-digit verification code.');
//       return;
//     }

//     setState(() {
//       isVerifying = true;
//     });

//     try {
//       final result = await AuthService.verifyEmail(
//         email: widget.email,
//         code: code,
//       );

//       final setupToken = result['setup_token'];

//       if (!mounted) return;

//       showMessage('Email verified successfully!');

//       await Future.delayed(const Duration(seconds: 1));

//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               OrganisationSelectionPage(accessToken: setupToken),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           isVerifying = false;
//         });
//       }
//     }
//   }

//   Future<void> handleResend() async {
//     if (remainingSeconds > 0 || isResending) {
//       return;
//     }

//     setState(() {
//       isResending = true;
//     });

//     try {
//       await AuthService.resendCode(email: widget.email);

//       if (!mounted) return;

//       showMessage('A new verification code has been sent.');

//       startCountdown();
//     } catch (e) {
//       if (!mounted) return;

//       showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           isResending = false;
//         });
//       }
//     }
//   }

//   void showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final canResend = remainingSeconds == 0 && !isResending;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 40),

//               const Icon(Icons.mark_email_unread_outlined, size: 80),

//               const SizedBox(height: 25),

//               const Text(
//                 'Verify Your Email',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               Text(
//                 'We sent a 6-digit verification code to\n${widget.email}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),

//               const SizedBox(height: 35),

//               TextField(
//                 controller: codeController,
//                 keyboardType: TextInputType.number,
//                 maxLength: 6,
//                 textAlign: TextAlign.center,
//                 decoration: const InputDecoration(
//                   labelText: 'Verification Code',
//                   border: OutlineInputBorder(),
//                   counterText: '',
//                 ),
//               ),

//               const SizedBox(height: 20),

//               SizedBox(
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: isVerifying ? null : handleVerify,
//                   child: isVerifying
//                       ? const CircularProgressIndicator()
//                       : const Text(
//                           'Verify Email',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               TextButton(
//                 onPressed: canResend ? handleResend : null,
//                 child: isResending
//                     ? const Text('Sending...')
//                     : remainingSeconds > 0
//                     ? Text('Resend Code (${remainingSeconds}s)')
//                     : const Text('Resend Code'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding/organisation_selection_page.dart';
import '../../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────
// FARMTAB DESIGN TOKENS (same system used across the app)
// ─────────────────────────────────────────────────────────────
class FarmTabTheme {
  static const Color forest = Color(0xFF1B4332);
  static const Color grove = Color(0xFF2D6A4F);
  static const Color fern = Color(0xFF40916C);
  static const Color mint = Color(0xFF95D5B2);
  static const Color mist = Color(0xFFD8F3DC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E8E8);
  static const Color textH = Color(0xFF111111);
  static const Color textB = Color(0xFF444444);
  static const Color textM = Color(0xFF888888);

  static TextStyle font({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

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

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    });
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
      final result = await AuthService.verifyEmail(
        email: widget.email,
        code: code,
      );

      final setupToken = result['setup_token'];

      if (!mounted) return;

      showMessage('Email verified successfully!');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OrganisationSelectionPage(accessToken: setupToken),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
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
      await AuthService.resendCode(email: widget.email);

      if (!mounted) return;

      showMessage('A new verification code has been sent.');

      startCountdown();
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
    final canResend = remainingSeconds == 0 && !isResending;

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: FarmTabTheme.textH,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FarmTabTheme.fern, FarmTabTheme.grove],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: FarmTabTheme.fern.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 38,
                    color: FarmTabTheme.white,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 24,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 10),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'We sent a 6-digit verification code to\n',
                      style: FarmTabTheme.font(
                        size: 14,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textM,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: widget.email,
                      style: FarmTabTheme.font(
                        size: 14,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textH,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── 6-digit code field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FarmTabTheme.border),
                ),
                child: TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: FarmTabTheme.font(
                    size: 26,
                    weight: FontWeight.w800,
                    color: FarmTabTheme.textH,
                    letterSpacing: 14,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '------',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FarmTabTheme.fern.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: isVerifying ? null : handleVerify,
                    child: Center(
                      child: isVerifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmTabTheme.white,
                              ),
                            )
                          : Text(
                              'Verify Email',
                              style: FarmTabTheme.font(
                                size: 15,
                                weight: FontWeight.w600,
                                color: FarmTabTheme.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: canResend ? handleResend : null,
                  child: isResending
                      ? Text(
                          'Sending...',
                          style: FarmTabTheme.font(
                            size: 13.5,
                            weight: FontWeight.w500,
                            color: FarmTabTheme.textM,
                          ),
                        )
                      : remainingSeconds > 0
                      ? Text(
                          'Resend Code (${remainingSeconds}s)',
                          style: FarmTabTheme.font(
                            size: 13.5,
                            weight: FontWeight.w500,
                            color: FarmTabTheme.textM,
                          ),
                        )
                      : Text(
                          'Resend Code',
                          style: FarmTabTheme.font(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: FarmTabTheme.grove,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
