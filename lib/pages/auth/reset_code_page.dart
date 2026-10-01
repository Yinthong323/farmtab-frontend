// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';
// import 'new_password_page.dart';

// class ResetCodePage extends StatefulWidget {
//   final String email;

//   const ResetCodePage({super.key, required this.email});

//   @override
//   State<ResetCodePage> createState() => _ResetCodePageState();
// }

// class _ResetCodePageState extends State<ResetCodePage> {
//   final codeController = TextEditingController();

//   bool isLoading = false;
//   bool isResending = false;

//   int resendCountdown = 0;
//   Timer? resendTimer;

//   @override
//   void initState() {
//     super.initState();

//     // The first reset code was already sent from Forgot Password.
//     // Prevent the user from immediately requesting another one.
//     startResendCountdown();
//   }

//   @override
//   void dispose() {
//     codeController.dispose();
//     resendTimer?.cancel();
//     super.dispose();
//   }

//   void startResendCountdown() {
//     resendTimer?.cancel();

//     setState(() {
//       resendCountdown = 60;
//     });

//     resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       if (resendCountdown <= 1) {
//         timer.cancel();

//         setState(() {
//           resendCountdown = 0;
//         });
//       } else {
//         setState(() {
//           resendCountdown--;
//         });
//       }
//     });
//   }

//   Future<void> handleVerify() async {
//     final code = codeController.text.trim();

//     if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
//       showMessage('Please enter the 6-digit reset code.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final result = await AuthService.verifyResetCode(
//         email: widget.email,
//         code: code,
//       );

//       final resetToken = result['reset_token'];

//       if (resetToken == null) {
//         throw Exception('Invalid reset session.');
//       }

//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => NewPasswordPage(resetToken: resetToken),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> handleResendCode() async {
//     if (resendCountdown > 0 || isResending) {
//       return;
//     }

//     setState(() {
//       isResending = true;
//     });

//     try {
//       await AuthService.resendResetCode(email: widget.email);

//       if (!mounted) return;

//       codeController.clear();

//       showMessage('A new reset code has been sent to your email.');

//       startResendCountdown();
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
//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Reset Code')),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,

//             children: [
//               const SizedBox(height: 40),

//               const Icon(Icons.mark_email_read_outlined, size: 80),

//               const SizedBox(height: 25),

//               const Text(
//                 'Enter Reset Code',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               Text(
//                 'We sent a 6-digit code to\n${widget.email}',
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
//                   labelText: '6-Digit Code',
//                   border: OutlineInputBorder(),
//                   counterText: '',
//                 ),
//               ),

//               const SizedBox(height: 25),

//               SizedBox(
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : handleVerify,
//                   child: isLoading
//                       ? const SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(),
//                         )
//                       : const Text(
//                           'Verify Code',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               TextButton(
//                 onPressed: (resendCountdown > 0 || isResending)
//                     ? null
//                     : handleResendCode,
//                 child: isResending
//                     ? const Text('Sending new code...')
//                     : resendCountdown > 0
//                     ? Text('Resend Code in ${resendCountdown}s')
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

import '../../services/auth_service.dart';
import 'new_password_page.dart';

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
                    Icons.mark_email_read_rounded,
                    size: 38,
                    color: FarmTabTheme.white,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Enter Reset Code',
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
                      text: 'We sent a 6-digit code to\n',
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
                    onTap: isLoading ? null : handleVerify,
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmTabTheme.white,
                              ),
                            )
                          : Text(
                              'Verify Code',
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
                  onPressed: (resendCountdown > 0 || isResending)
                      ? null
                      : handleResendCode,
                  child: isResending
                      ? Text(
                          'Sending new code...',
                          style: FarmTabTheme.font(
                            size: 13.5,
                            weight: FontWeight.w500,
                            color: FarmTabTheme.textM,
                          ),
                        )
                      : resendCountdown > 0
                      ? Text(
                          'Resend Code in ${resendCountdown}s',
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
