// import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';
// import 'login_page.dart';

// class NewPasswordPage extends StatefulWidget {
//   final String resetToken;

//   const NewPasswordPage({super.key, required this.resetToken});

//   @override
//   State<NewPasswordPage> createState() => _NewPasswordPageState();
// }

// class _NewPasswordPageState extends State<NewPasswordPage> {
//   final passwordController = TextEditingController();

//   final confirmPasswordController = TextEditingController();

//   bool isLoading = false;

//   bool obscurePassword = true;
//   bool obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     passwordController.dispose();
//     confirmPasswordController.dispose();

//     super.dispose();
//   }

//   Future<void> handleSubmit() async {
//     final password = passwordController.text;

//     final confirmPassword = confirmPasswordController.text;

//     if (password.length < 8) {
//       showMessage('Password must contain at least 8 characters.');

//       return;
//     }

//     if (password != confirmPassword) {
//       showMessage('Passwords do not match.');

//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await AuthService.resetPassword(
//         resetToken: widget.resetToken,
//         newPassword: password,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Password reset successfully. Please login with your new password.',
//           ),
//         ),
//       );

//       await Future.delayed(const Duration(seconds: 1));

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,

//         MaterialPageRoute(builder: (context) => const LoginPage()),

//         (route) => false,
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
//       appBar: AppBar(title: const Text('Create New Password')),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,

//             children: [
//               const SizedBox(height: 40),

//               const Icon(Icons.password_outlined, size: 80),

//               const SizedBox(height: 25),

//               const Text(
//                 'Create New Password',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 15),

//               const Text(
//                 'Please create a new password for your FarmTab account.',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(fontSize: 16),
//               ),

//               const SizedBox(height: 35),

//               TextField(
//                 controller: passwordController,

//                 obscureText: obscurePassword,

//                 decoration: InputDecoration(
//                   labelText: 'New Password',

//                   border: const OutlineInputBorder(),

//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscurePassword
//                           ? Icons.visibility_outlined
//                           : Icons.visibility_off_outlined,
//                     ),

//                     onPressed: () {
//                       setState(() {
//                         obscurePassword = !obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               TextField(
//                 controller: confirmPasswordController,

//                 obscureText: obscureConfirmPassword,

//                 decoration: InputDecoration(
//                   labelText: 'Confirm New Password',

//                   border: const OutlineInputBorder(),

//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscureConfirmPassword
//                           ? Icons.visibility_outlined
//                           : Icons.visibility_off_outlined,
//                     ),

//                     onPressed: () {
//                       setState(() {
//                         obscureConfirmPassword = !obscureConfirmPassword;
//                       });
//                     },
//                   ),
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
import 'login_page.dart';

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

              Text(
                'Create New Password',
                style: FarmTabTheme.font(
                  size: 24,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                  letterSpacing: -0.4,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Please create a new password for your FarmTab account.',
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: FarmTabTheme.font(
                  size: 14.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textH,
                ),
                decoration:
                    FarmTabTheme.fieldDecoration(
                      'New Password',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                          color: FarmTabTheme.textM,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Must be at least 8 characters.',
                  style: FarmTabTheme.font(
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                style: FarmTabTheme.font(
                  size: 14.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textH,
                ),
                decoration:
                    FarmTabTheme.fieldDecoration(
                      'Confirm New Password',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                          color: FarmTabTheme.textM,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
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

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
