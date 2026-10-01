// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';
// import 'reset_code_page.dart';
// import 'signup_page.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final emailController = TextEditingController();

//   bool isLoading = false;

//   @override
//   void dispose() {
//     emailController.dispose();
//     super.dispose();
//   }

//   Future<void> handleSubmit() async {
//     final email = emailController.text.trim();

//     if (email.isEmpty) {
//       showMessage('Please enter your registered email address.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await AuthService.forgotPassword(email: email);

//       if (!mounted) return;

//       showMessage('A password reset code has been sent to your email.');

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ResetCodePage(email: email)),
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

//   void showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Forgot Password')),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,

//             children: [
//               const SizedBox(height: 40),

//               const Icon(Icons.lock_reset_outlined, size: 80),

//               const SizedBox(height: 25),

//               const Text(
//                 'Reset Your Password',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               const Text(
//                 'Enter the email address registered with your FarmTab account. We will send you a 6-digit code to reset your password.',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(fontSize: 16),
//               ),

//               const SizedBox(height: 35),

//               TextField(
//                 controller: emailController,

//                 keyboardType: TextInputType.emailAddress,

//                 decoration: const InputDecoration(
//                   labelText: 'Registered Email',
//                   border: OutlineInputBorder(),

//                   prefixIcon: Icon(Icons.email_outlined),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               SizedBox(
//                 height: 52,

//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : handleSubmit,

//                   child: isLoading
//                       ? const SizedBox(
//                           height: 24,
//                           width: 24,

//                           child: CircularProgressIndicator(),
//                         )
//                       : const Text('Submit', style: TextStyle(fontSize: 16)),
//                 ),
//               ),

//               const Spacer(),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,

//                 children: [
//                   const Text("Don't have an account?"),

//                   TextButton(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const SignupPage(),
//                               ),
//                             );
//                           },

//                     child: const Text('Sign Up'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import 'reset_code_page.dart';
import 'signup_page.dart';

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

  static InputDecoration fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: font(size: 13.5, weight: FontWeight.w500, color: textM),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: textM) : null,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: fern, width: 1.5),
      ),
    );
  }
}

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
                    Icons.lock_reset_rounded,
                    size: 40,
                    color: FarmTabTheme.white,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Reset Your Password',
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 24,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter the email address registered with your FarmTab '
                'account. We will send you a 6-digit code to reset your '
                'password.',
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: FarmTabTheme.font(
                  size: 14.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textH,
                ),
                decoration: FarmTabTheme.fieldDecoration(
                  'Registered Email',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 30),

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
                    onTap: isLoading ? null : handleSubmit,
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
                              'Submit',
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

              const SizedBox(height: 150),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: FarmTabTheme.font(
                      size: 13.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
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
                    child: Text(
                      'Sign Up',
                      style: FarmTabTheme.font(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.grove,
                      ),
                    ),
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
