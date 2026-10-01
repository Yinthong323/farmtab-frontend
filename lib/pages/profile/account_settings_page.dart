import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color alertRed = Color(0xFFE63946);
  static const Color amber = Color(0xFFF4A261);

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

  static InputDecoration fieldDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
      errorText: errorText,
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
        borderSide: const BorderSide(color: alertRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: alertRed, width: 1.5),
      ),
    );
  }
}

class AccountSettingsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AccountSettingsPage({super.key, required this.user});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isChangingPassword = false;
  bool _isDeletingAccount = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // NOTE FOR WHOEVER WIRES UP THE BACKEND LATER:
  // There is no AuthService.changePassword(...) endpoint yet.
  // This validates the form client-side, then shows a clear
  // placeholder message instead of silently pretending to work.
  // A real implementation should call something like:
  //   AuthService.changePassword(
  //     currentPassword: ...,
  //     newPassword: ...,
  //   )
  // and should NOT reuse the forgot-password reset-token flow,
  // since the user is already authenticated here.
  // ------------------------------------------------------------
  Future<void> _handleChangePassword() async {
    final current = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      _showMessage('Please enter your current password.');
      return;
    }

    if (newPassword.length < 8) {
      _showMessage('New password must be at least 8 characters.');
      return;
    }

    if (newPassword != confirm) {
      _showMessage('New password and confirmation do not match.');
      return;
    }

    if (newPassword == current) {
      _showMessage('New password must be different from the current one.');
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    // Simulate a brief delay so the loading state is visible,
    // since there's no real request to await yet.
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isChangingPassword = false;
    });

    _showMessage(
      'Change password isn\'t connected to the backend yet — '
      'no changes were saved.',
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FarmTabTheme.alertRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_rounded,
                  size: 18,
                  color: FarmTabTheme.alertRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Account?',
                  style: FarmTabTheme.font(
                    size: 16.5,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'This will permanently delete your account and remove your '
            'access to all organisations. This action cannot be undone.',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmTabTheme.alertRed,
                foregroundColor: FarmTabTheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete Account',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeletingAccount = true;
    });

    // ------------------------------------------------------------
    // NOTE FOR WHOEVER WIRES UP THE BACKEND LATER:
    // There is no AuthService.deleteAccount() endpoint yet. A real
    // implementation should call it here, then clear the stored
    // access token (SharedPreferences) before navigating to
    // LoginPage — similar to the confirmed-delete flow below.
    // ------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isDeletingAccount = false;
    });

    _showMessage(
      'Delete account isn\'t connected to the backend yet — '
      'your account was not deleted.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
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
          'Account Settings',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Change Password'),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: FarmTabTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    obscure: _obscureCurrent,
                    onToggle: () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    },
                  ),

                  const SizedBox(height: 14),

                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscure: _obscureNew,
                    onToggle: () {
                      setState(() => _obscureNew = !_obscureNew);
                    },
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Must be at least 8 characters.',
                    style: FarmTabTheme.font(
                      size: 11.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    obscure: _obscureConfirm,
                    onToggle: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isChangingPassword
                            ? null
                            : _handleChangePassword,
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: _isChangingPassword
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: FarmTabTheme.white,
                                    ),
                                  )
                                : Text(
                                    'Update Password',
                                    style: FarmTabTheme.font(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: FarmTabTheme.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionLabel('Danger Zone'),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: FarmTabTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FarmTabTheme.alertRed.withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: FarmTabTheme.alertRed.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          size: 19,
                          color: FarmTabTheme.alertRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Delete Account',
                          style: FarmTabTheme.font(
                            size: 15,
                            weight: FontWeight.w700,
                            color: FarmTabTheme.textH,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Permanently delete your account and all associated '
                    'data. This action cannot be undone.',
                    style: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isDeletingAccount
                          ? null
                          : _showDeleteAccountConfirmation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FarmTabTheme.alertRed,
                        side: const BorderSide(color: Color(0xFFF4B9BE)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isDeletingAccount
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmTabTheme.alertRed,
                              ),
                            )
                          : Text(
                              'Delete My Account',
                              style: FarmTabTheme.font(
                                size: 13.5,
                                weight: FontWeight.w600,
                                color: FarmTabTheme.alertRed,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: FarmTabTheme.font(
        size: 14,
        weight: FontWeight.w500,
        color: FarmTabTheme.textH,
      ),
      decoration: FarmTabTheme.fieldDecoration(label).copyWith(
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 19,
            color: FarmTabTheme.textM,
          ),
        ),
      ),
    );
  }
}
