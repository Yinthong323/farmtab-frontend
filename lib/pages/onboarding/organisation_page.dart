// import 'package:flutter/material.dart';

// import '../auth/login_page.dart';
// import '../../services/organisation_service.dart';

// class OrganisationPage extends StatefulWidget {
//   final String setupToken;

//   const OrganisationPage({super.key, required this.setupToken});

//   @override
//   State<OrganisationPage> createState() => _OrganisationPageState();
// }

// class _OrganisationPageState extends State<OrganisationPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _websiteController = TextEditingController();
//   final _phoneController = TextEditingController();

//   String _organisationType = 'PERSONAL';

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _websiteController.dispose();
//     _phoneController.dispose();

//     super.dispose();
//   }

//   Future<void> _createOrganisation() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final result = await OrganisationService().createOrganisation(
//         setupToken: widget.setupToken,
//         name: _nameController.text.trim(),
//         description: _descriptionController.text.trim(),
//         website: _websiteController.text.trim().isEmpty
//             ? null
//             : _websiteController.text.trim(),
//         phoneNumber: _phoneController.text.trim().isEmpty
//             ? null
//             : _phoneController.text.trim(),
//         organisationType: _organisationType,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             result['message'] ?? 'Organisation created successfully.',
//           ),
//         ),
//       );

//       await Future.delayed(const Duration(seconds: 1));

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Organisation Setup')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 20),

//                 const Text(
//                   'Set Up Your Organisation',
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 10),

//                 const Text(
//                   'Create an organisation to continue using FarmTab.',
//                   style: TextStyle(fontSize: 16),
//                 ),

//                 const SizedBox(height: 30),

//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Organisation Name *',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Organisation name is required.';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 TextFormField(
//                   controller: _descriptionController,
//                   maxLines: 4,
//                   decoration: const InputDecoration(
//                     labelText: 'Description *',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Description is required.';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 TextFormField(
//                   controller: _websiteController,
//                   decoration: const InputDecoration(
//                     labelText: 'Website (Optional)',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 TextFormField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: const InputDecoration(
//                     labelText: 'Phone Number (Optional)',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 const Text(
//                   'Organisation Type *',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),

//                 RadioListTile<String>(
//                   title: const Text('Personal'),
//                   subtitle: const Text(
//                     'Only you can belong to this organisation.',
//                   ),
//                   value: 'PERSONAL',
//                   groupValue: _organisationType,
//                   onChanged: (value) {
//                     setState(() {
//                       _organisationType = value!;
//                     });
//                   },
//                 ),

//                 RadioListTile<String>(
//                   title: const Text('Shared'),
//                   subtitle: const Text('Other users can request to join.'),
//                   value: 'SHARED',
//                   groupValue: _organisationType,
//                   onChanged: (value) {
//                     setState(() {
//                       _organisationType = value!;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 25),

//                 SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _createOrganisation,
//                     child: _isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text(
//                             'Create Organisation',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_page.dart';
import '../../services/organisation_service.dart';

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

  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static InputDecoration fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: font(size: 13.5, weight: FontWeight.w500, color: textM),
      hintStyle: font(size: 13.5, weight: FontWeight.w400, color: textM),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: fern, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.5),
      ),
    );
  }
}

class OrganisationPage extends StatefulWidget {
  final String setupToken;

  const OrganisationPage({super.key, required this.setupToken});

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();

  String _organisationType = 'PERSONAL';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _createOrganisation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OrganisationService().createOrganisation(
        setupToken: widget.setupToken,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        organisationType: _organisationType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Organisation created successfully.',
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        shadowColor: FarmTabTheme.fern.withOpacity(0.35),
        centerTitle: false,
        iconTheme: const IconThemeData(color: FarmTabTheme.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [FarmTabTheme.fern, Color(0xFF52B788)],
            ),
          ),
        ),
        title: Text(
          'Organisation Setup',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Text(
                  'Set Up Your Organisation',
                  style: FarmTabTheme.font(
                    size: 24,
                    weight: FontWeight.w800,
                    color: FarmTabTheme.textH,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Create an organisation to continue using FarmTab.',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),

                const SizedBox(height: 28),

                _sectionLabel('Organisation Details'),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: FarmTabTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w500,
                          color: FarmTabTheme.textH,
                        ),
                        decoration: FarmTabTheme.fieldDecoration(
                          'Organisation Name *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Organisation name is required.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textH,
                        ),
                        decoration: FarmTabTheme.fieldDecoration(
                          'Description *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _websiteController,
                        style: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textH,
                        ),
                        decoration: FarmTabTheme.fieldDecoration(
                          'Website (Optional)',
                          hint: 'https://example.com',
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textH,
                        ),
                        decoration: FarmTabTheme.fieldDecoration(
                          'Phone Number (Optional)',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionLabel('Organisation Type *'),

                const SizedBox(height: 12),

                _buildTypeOption(
                  value: 'PERSONAL',
                  icon: Icons.person_rounded,
                  title: 'Personal',
                  subtitle: 'Only you can belong to this organisation.',
                ),

                const SizedBox(height: 10),

                _buildTypeOption(
                  value: 'SHARED',
                  icon: Icons.groups_rounded,
                  title: 'Shared',
                  subtitle: 'Other users can request to join.',
                ),

                const SizedBox(height: 28),

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
                        color: FarmTabTheme.fern.withOpacity(0.3),
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
                      onTap: _isLoading ? null : _createOrganisation,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: FarmTabTheme.white,
                                ),
                              )
                            : Text(
                                'Create Organisation',
                                style: FarmTabTheme.font(
                                  size: 14.5,
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
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 15,
        weight: FontWeight.w700,
        color: FarmTabTheme.textH,
        letterSpacing: -0.2,
      ),
    );
  }

  // ============================================================
  // ORGANISATION TYPE OPTION CARD
  // ============================================================

  Widget _buildTypeOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _organisationType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _organisationType = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? FarmTabTheme.mist.withOpacity(0.5)
              : FarmTabTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? FarmTabTheme.fern : FarmTabTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? FarmTabTheme.mint.withOpacity(0.4)
                    : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? FarmTabTheme.grove : FarmTabTheme.textM,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FarmTabTheme.font(
                      size: 14.5,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? FarmTabTheme.grove : Colors.transparent,
                border: Border.all(
                  color: isSelected ? FarmTabTheme.grove : FarmTabTheme.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: FarmTabTheme.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
