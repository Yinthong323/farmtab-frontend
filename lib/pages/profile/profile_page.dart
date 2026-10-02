import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'organisation_management_page.dart';
import 'account_settings_page.dart';
import '../auth/login_page.dart';
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
  static const Color alertRed = Color(0xFFE63946);

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

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: grove,
    foregroundColor: white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const ProfilePage({
    super.key,
    required this.user,
    required this.organisation,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

  // Local-only preview of a newly picked profile picture. There is
  // no backend endpoint yet to actually upload/store this — see
  // _pickProfileImage() for details on what's needed.
  XFile? _pendingProfileImage;

  // ------------------------------------------------------------
  // NOTE FOR WHOEVER WIRES UP THE BACKEND LATER:
  // The `users` table currently has no column to store a profile
  // picture (no `profile_image` / `avatar_url`), and there is no
  // `AuthService.updateProfile(...)` method yet either. Until
  // those exist on the backend, picking an image only previews it
  // locally — it is not actually saved anywhere.
  // ------------------------------------------------------------
  Future<void> _pickProfileImage() async {
    debugPrint('CAMERA BUTTON CLICKED');

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Camera button clicked')));

    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final updatedUser = await AuthService.uploadProfileImage(image.path);

      debugPrint('UPDATED USER: $updatedUser');

      final userData = updatedUser['user'];

      debugPrint('PROFILE IMAGE: ${userData['profile_image']}');

      if (!mounted) return;

      setState(() {
        widget.user['profile_image'] = userData['profile_image'];
        _pendingProfileImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  bool _isLoadingProfile = false;

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(
      text: widget.user['username']?.toString() ?? '',
    );

    final newName = await showDialog<String>(
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
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit_rounded,
                  size: 17,
                  color: FarmTabTheme.grove,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Name',
                style: FarmTabTheme.font(
                  size: 16.5,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: FarmTabTheme.font(
              size: 14,
              weight: FontWeight.w500,
              color: FarmTabTheme.textH,
            ),
            decoration: FarmTabTheme.fieldDecoration('Username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
              style: FarmTabTheme.primaryButton,
              onPressed: () async {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: Text(
                'Save',
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

    controller.dispose();

    if (newName == null || !mounted) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final result = await AuthService.updateProfile(username: newName);

      if (!mounted) return;

      final updatedUser = result['user'];

      setState(() {
        widget.user['username'] = updatedUser['username'];
        widget.user['email'] = updatedUser['email'];
        widget.user['created_at'] = updatedUser['created_at'];
        widget.user['profile_image'] = updatedUser['profile_image'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profile = await AuthService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        widget.user['id'] = profile['id'];
        widget.user['username'] = profile['username'];
        widget.user['email'] = profile['email'];
        widget.user['is_verified'] = profile['is_verified'];
        widget.user['created_at'] = profile['created_at'];
        widget.user['profile_image'] = profile['profile_image'];
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
                  Icons.logout_rounded,
                  size: 17,
                  color: FarmTabTheme.alertRed,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: FarmTabTheme.font(
                  size: 16.5,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
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
                'Logout',
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

    if (confirmed != true) return;

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _formatMemberSince(dynamic createdAt) {
    if (createdAt == null) return '--';

    final parsed = DateTime.tryParse(createdAt.toString());
    if (parsed == null) return '--';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final username = widget.user['username']?.toString() ?? 'User';
    final email = widget.user['email']?.toString() ?? '';
    final organisationName =
        widget.organisation['name']?.toString() ?? 'Organisation';
    final role = widget.organisation['role']?.toString() ?? 'STAFF';
    final memberSince = _formatMemberSince(widget.user['created_at']);

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover header with overlapping avatar
            _buildCoverHeader(username),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              username,
                              style: FarmTabTheme.font(
                                size: 21,
                                weight: FontWeight.w800,
                                color: FarmTabTheme.textH,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _showEditNameDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: FarmTabTheme.textM,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          email,
                          style: FarmTabTheme.font(
                            size: 13.5,
                            weight: FontWeight.w400,
                            color: FarmTabTheme.textM,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: FarmTabTheme.textM,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Member since $memberSince',
                                style: FarmTabTheme.font(
                                  size: 11.5,
                                  weight: FontWeight.w500,
                                  color: FarmTabTheme.textM,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── Organisation
                  _sectionLabel('Organisation'),

                  const SizedBox(height: 12),

                  Container(
                    decoration: FarmTabTheme.cardDecoration,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrganisationManagementPage(
                                user: widget.user,
                                organisation: widget.organisation,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: FarmTabTheme.mist,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.business_rounded,
                                  size: 21,
                                  color: FarmTabTheme.grove,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      organisationName,
                                      style: FarmTabTheme.font(
                                        size: 15,
                                        weight: FontWeight.w700,
                                        color: FarmTabTheme.textH,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Role: $role',
                                      style: FarmTabTheme.font(
                                        size: 12.5,
                                        weight: FontWeight.w400,
                                        color: FarmTabTheme.textM,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: FarmTabTheme.textM,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── Account
                  _sectionLabel('Account'),

                  const SizedBox(height: 12),

                  Container(
                    decoration: FarmTabTheme.cardDecoration,
                    child: Column(
                      children: [
                        _buildAccountTile(
                          icon: Icons.settings_rounded,
                          title: 'Account Settings',
                          subtitle: 'Password & account management',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountSettingsPage(user: widget.user),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: FarmTabTheme.border,
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        _buildAccountTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          iconColor: FarmTabTheme.alertRed,
                          titleColor: FarmTabTheme.alertRed,
                          showChevron: false,
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── COVER HEADER ─────────────────────────────────────────────
  // A taller decorative gradient "cover" with soft circular
  // accents, and the avatar overlapping its bottom edge — same
  // pattern used by most modern profile screens.

  Widget _buildCoverHeader(String username) {
    return SizedBox(
      height: 195,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FarmTabTheme.fern,
                    Color.fromARGB(255, 112, 212, 167),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative soft circles for visual depth.
                  Positioned(
                    right: -34,
                    top: -34,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 30,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -26,
                    bottom: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),

                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Text(
                        'Profile',
                        style: FarmTabTheme.font(
                          size: 19,
                          weight: FontWeight.w700,
                          color: FarmTabTheme.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Avatar, overlapping the boundary between the cover
          // and the white content below.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(child: _buildAvatar(username)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String username) {
    final profileImage = widget.user['profile_image']?.toString();

    String? imageUrl;

    if (profileImage != null && profileImage.isNotEmpty) {
      if (profileImage.startsWith('http://') ||
          profileImage.startsWith('https://')) {
        imageUrl = profileImage;
      } else {
        imageUrl = '${AuthService.baseUrl}$profileImage';
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: FarmTabTheme.mist,
            border: Border.all(color: FarmTabTheme.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialAvatar(username);
                    },
                  )
                : _buildInitialAvatar(username),
          ),
        ),

        Positioned(
          right: 2,
          bottom: 2,
          child: Material(
            color: FarmTabTheme.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _pickProfileImage,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FarmTabTheme.grove,
                  border: Border.all(color: FarmTabTheme.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAvatar(String username) {
    final initial = username.isNotEmpty
        ? username.substring(0, 1).toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initial,
        style: FarmTabTheme.font(
          size: 44,
          weight: FontWeight.w800,
          color: FarmTabTheme.grove,
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

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? FarmTabTheme.grove).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 19,
                  color: iconColor ?? FarmTabTheme.grove,
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
                        weight: FontWeight.w600,
                        color: titleColor ?? FarmTabTheme.textH,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: FarmTabTheme.font(
                          size: 12,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textM,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: FarmTabTheme.textM,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
