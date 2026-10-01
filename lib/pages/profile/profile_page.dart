// // // import 'package:flutter/material.dart';

// // // import 'organisation_management_page.dart';
// // // import '../auth/login_page.dart';

// // // class ProfilePage extends StatelessWidget {
// // //   final Map<String, dynamic> user;
// // //   final Map<String, dynamic> organisation;

// // //   const ProfilePage({
// // //     super.key,
// // //     required this.user,
// // //     required this.organisation,
// // //   });

// // //   Future<void> _confirmLogout(BuildContext context) async {
// // //     final confirmed = await showDialog<bool>(
// // //       context: context,
// // //       builder: (context) {
// // //         return AlertDialog(
// // //           title: const Text('Logout'),
// // //           content: const Text('Are you sure you want to logout?'),
// // //           actions: [
// // //             TextButton(
// // //               onPressed: () {
// // //                 Navigator.pop(context, false);
// // //               },
// // //               child: const Text('Cancel'),
// // //             ),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 Navigator.pop(context, true);
// // //               },
// // //               child: const Text('Logout'),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );

// // //     if (confirmed != true) {
// // //       return;
// // //     }

// // //     if (!context.mounted) return;

// // //     Navigator.pushAndRemoveUntil(
// // //       context,
// // //       MaterialPageRoute(builder: (_) => const LoginPage()),
// // //       (route) => false,
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final username = user['username'] ?? 'User';
// // //     final email = user['email'] ?? '';
// // //     final organisationName = organisation['name'] ?? 'Organisation';
// // //     final role = organisation['role'] ?? 'STAFF';

// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Profile')),

// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             const SizedBox(height: 10),

// // //             // Profile header
// // //             const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),

// // //             const SizedBox(height: 16),

// // //             Text(
// // //               username,
// // //               textAlign: TextAlign.center,
// // //               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // //             ),

// // //             const SizedBox(height: 6),

// // //             Text(
// // //               email,
// // //               textAlign: TextAlign.center,
// // //               style: const TextStyle(color: Colors.grey, fontSize: 15),
// // //             ),

// // //             const SizedBox(height: 30),

// // //             // Organisation section
// // //             const Text(
// // //               'Organisation',
// // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //             ),

// // //             const SizedBox(height: 12),

// // //             Card(
// // //               child: ListTile(
// // //                 leading: const CircleAvatar(child: Icon(Icons.business)),
// // //                 title: Text(
// // //                   organisationName,
// // //                   style: const TextStyle(fontWeight: FontWeight.bold),
// // //                 ),
// // //                 subtitle: Text('Role: $role'),
// // //                 trailing: const Icon(Icons.arrow_forward_ios, size: 18),
// // //                 onTap: () {
// // //                   Navigator.push(
// // //                     context,
// // //                     MaterialPageRoute(
// // //                       builder: (_) => OrganisationManagementPage(
// // //                         user: user,
// // //                         organisation: organisation,
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),

// // //             const SizedBox(height: 30),

// // //             // Account section
// // //             const Text(
// // //               'Account',
// // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //             ),

// // //             const SizedBox(height: 12),

// // //             Card(
// // //               child: ListTile(
// // //                 leading: const Icon(Icons.settings),
// // //                 title: const Text('Account Settings'),
// // //                 trailing: const Icon(Icons.arrow_forward_ios, size: 18),
// // //                 onTap: () {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text(
// // //                         'Account settings will be implemented later.',
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),

// // //             const SizedBox(height: 12),

// // //             Card(
// // //               child: ListTile(
// // //                 leading: const Icon(Icons.logout),
// // //                 title: const Text('Logout'),
// // //                 onTap: () => _confirmLogout(context),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'dart:io';

// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';

// // import 'organisation_management_page.dart';
// // import 'account_settings_page.dart';
// // import '../auth/login_page.dart';

// // // ─────────────────────────────────────────────────────────────
// // // FARMTAB DESIGN TOKENS (same system used across the app)
// // // ─────────────────────────────────────────────────────────────
// // class FarmTabTheme {
// //   static const Color forest = Color(0xFF1B4332);
// //   static const Color grove = Color(0xFF2D6A4F);
// //   static const Color fern = Color(0xFF40916C);
// //   static const Color mint = Color(0xFF95D5B2);
// //   static const Color mist = Color(0xFFD8F3DC);
// //   static const Color white = Color(0xFFFFFFFF);
// //   static const Color border = Color(0xFFE8E8E8);
// //   static const Color textH = Color(0xFF111111);
// //   static const Color textB = Color(0xFF444444);
// //   static const Color textM = Color(0xFF888888);
// //   static const Color alertRed = Color(0xFFE63946);

// //   static TextStyle font({
// //     required double size,
// //     required FontWeight weight,
// //     required Color color,
// //     double? letterSpacing,
// //     double? height,
// //   }) {
// //     return GoogleFonts.plusJakartaSans(
// //       fontSize: size,
// //       fontWeight: weight,
// //       color: color,
// //       letterSpacing: letterSpacing,
// //       height: height,
// //     );
// //   }

// //   static BoxDecoration cardDecoration = BoxDecoration(
// //     color: white,
// //     borderRadius: BorderRadius.circular(16),
// //     border: Border.all(color: border, width: 1),
// //     boxShadow: [
// //       BoxShadow(
// //         color: Colors.black.withOpacity(0.05),
// //         blurRadius: 10,
// //         offset: const Offset(0, 2),
// //       ),
// //     ],
// //   );

// //   static ButtonStyle primaryButton = ElevatedButton.styleFrom(
// //     backgroundColor: grove,
// //     foregroundColor: white,
// //     elevation: 0,
// //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //   );

// //   static InputDecoration fieldDecoration(String label) {
// //     return InputDecoration(
// //       labelText: label,
// //       labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
// //       filled: true,
// //       fillColor: const Color(0xFFF7F7F7),
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
// //       border: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide.none,
// //       ),
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide.none,
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: const BorderSide(color: fern, width: 1.5),
// //       ),
// //       disabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(10),
// //         borderSide: BorderSide.none,
// //       ),
// //     );
// //   }
// // }

// // class ProfilePage extends StatefulWidget {
// //   final Map<String, dynamic> user;
// //   final Map<String, dynamic> organisation;

// //   const ProfilePage({
// //     super.key,
// //     required this.user,
// //     required this.organisation,
// //   });

// //   @override
// //   State<ProfilePage> createState() => _ProfilePageState();
// // }

// // class _ProfilePageState extends State<ProfilePage> {
// //   final ImagePicker _imagePicker = ImagePicker();

// //   // Local-only preview of a newly picked profile picture. There is
// //   // no backend endpoint yet to actually upload/store this — see
// //   // _pickProfileImage() for details on what's needed.
// //   XFile? _pendingProfileImage;

// //   // ------------------------------------------------------------
// //   // NOTE FOR WHOEVER WIRES UP THE BACKEND LATER:
// //   // The `users` table currently has no column to store a profile
// //   // picture (no `profile_image` / `avatar_url`), and there is no
// //   // `AuthService.updateProfile(...)` method yet either. Until
// //   // those exist on the backend, picking an image only previews it
// //   // locally — it is not actually saved anywhere.
// //   // ------------------------------------------------------------
// //   Future<void> _pickProfileImage() async {
// //     final image = await _imagePicker.pickImage(source: ImageSource.gallery);

// //     if (image == null) return;

// //     setState(() {
// //       _pendingProfileImage = image;
// //     });

// //     _showComingSoon(
// //       'Profile picture upload isn\'t connected to the backend yet — '
// //       'this is just a preview for now.',
// //     );
// //   }

// //   Future<void> _showEditNameDialog() async {
// //     final controller = TextEditingController(
// //       text: widget.user['username']?.toString() ?? '',
// //     );

// //     final newName = await showDialog<String>(
// //       context: context,
// //       builder: (dialogContext) {
// //         return AlertDialog(
// //           backgroundColor: FarmTabTheme.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: Row(
// //             children: [
// //               Container(
// //                 width: 36,
// //                 height: 36,
// //                 decoration: BoxDecoration(
// //                   color: FarmTabTheme.mist,
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 alignment: Alignment.center,
// //                 child: const Icon(
// //                   Icons.edit_rounded,
// //                   size: 17,
// //                   color: FarmTabTheme.grove,
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Text(
// //                 'Edit Name',
// //                 style: FarmTabTheme.font(
// //                   size: 16.5,
// //                   weight: FontWeight.w700,
// //                   color: FarmTabTheme.textH,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           content: TextField(
// //             controller: controller,
// //             autofocus: true,
// //             style: FarmTabTheme.font(
// //               size: 14,
// //               weight: FontWeight.w500,
// //               color: FarmTabTheme.textH,
// //             ),
// //             decoration: FarmTabTheme.fieldDecoration('Username'),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(dialogContext),
// //               child: Text(
// //                 'Cancel',
// //                 style: FarmTabTheme.font(
// //                   size: 13.5,
// //                   weight: FontWeight.w600,
// //                   color: FarmTabTheme.textM,
// //                 ),
// //               ),
// //             ),
// //             ElevatedButton(
// //               style: FarmTabTheme.primaryButton,
// //               onPressed: () {
// //                 final value = controller.text.trim();
// //                 if (value.isEmpty) return;
// //                 Navigator.pop(dialogContext, value);
// //               },
// //               child: Text(
// //                 'Save',
// //                 style: FarmTabTheme.font(
// //                   size: 13.5,
// //                   weight: FontWeight.w600,
// //                   color: FarmTabTheme.white,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );

// //     controller.dispose();

// //     if (newName == null || !mounted) return;

// //     // No AuthService.updateProfile(...) exists yet — nothing is
// //     // actually saved to the backend here.
// //     _showComingSoon('Editing your name isn\'t connected to the backend yet.');
// //   }

// //   void _showComingSoon(String message) {
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(SnackBar(content: Text(message)));
// //   }

// //   Future<void> _confirmLogout(BuildContext context) async {
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (dialogContext) {
// //         return AlertDialog(
// //           backgroundColor: FarmTabTheme.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: Row(
// //             children: [
// //               Container(
// //                 width: 36,
// //                 height: 36,
// //                 decoration: BoxDecoration(
// //                   color: FarmTabTheme.alertRed.withOpacity(0.10),
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 alignment: Alignment.center,
// //                 child: const Icon(
// //                   Icons.logout_rounded,
// //                   size: 17,
// //                   color: FarmTabTheme.alertRed,
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Text(
// //                 'Logout',
// //                 style: FarmTabTheme.font(
// //                   size: 16.5,
// //                   weight: FontWeight.w700,
// //                   color: FarmTabTheme.textH,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           content: Text(
// //             'Are you sure you want to logout?',
// //             style: FarmTabTheme.font(
// //               size: 13.5,
// //               weight: FontWeight.w400,
// //               color: FarmTabTheme.textB,
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(dialogContext, false),
// //               child: Text(
// //                 'Cancel',
// //                 style: FarmTabTheme.font(
// //                   size: 13.5,
// //                   weight: FontWeight.w600,
// //                   color: FarmTabTheme.textM,
// //                 ),
// //               ),
// //             ),
// //             ElevatedButton(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: FarmTabTheme.alertRed,
// //                 foregroundColor: FarmTabTheme.white,
// //                 elevation: 0,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //               onPressed: () => Navigator.pop(dialogContext, true),
// //               child: Text(
// //                 'Logout',
// //                 style: FarmTabTheme.font(
// //                   size: 13.5,
// //                   weight: FontWeight.w600,
// //                   color: FarmTabTheme.white,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );

// //     if (confirmed != true) return;

// //     if (!context.mounted) return;

// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (_) => const LoginPage()),
// //       (route) => false,
// //     );
// //   }

// //   String _formatMemberSince(dynamic createdAt) {
// //     if (createdAt == null) return '--';

// //     final parsed = DateTime.tryParse(createdAt.toString());
// //     if (parsed == null) return '--';

// //     const months = [
// //       'Jan',
// //       'Feb',
// //       'Mar',
// //       'Apr',
// //       'May',
// //       'Jun',
// //       'Jul',
// //       'Aug',
// //       'Sep',
// //       'Oct',
// //       'Nov',
// //       'Dec',
// //     ];

// //     return '${months[parsed.month - 1]} ${parsed.year}';
// //   }

// //   // ============================================================
// //   // BUILD
// //   // ============================================================

// //   @override
// //   Widget build(BuildContext context) {
// //     final username = widget.user['username']?.toString() ?? 'User';
// //     final email = widget.user['email']?.toString() ?? '';
// //     final organisationName =
// //         widget.organisation['name']?.toString() ?? 'Organisation';
// //     final role = widget.organisation['role']?.toString() ?? 'STAFF';
// //     final memberSince = _formatMemberSince(widget.user['created_at']);

// //     return Scaffold(
// //       backgroundColor: FarmTabTheme.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 3,
// //         shadowColor: FarmTabTheme.fern.withOpacity(0.35),
// //         scrolledUnderElevation: 3,
// //         centerTitle: false,
// //         titleSpacing: 20,
// //         shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.only(
// //             bottomLeft: Radius.circular(22),
// //             bottomRight: Radius.circular(22),
// //           ),
// //         ),
// //         flexibleSpace: ClipRRect(
// //           borderRadius: const BorderRadius.only(
// //             bottomLeft: Radius.circular(22),
// //             bottomRight: Radius.circular(22),
// //           ),
// //           child: Container(
// //             decoration: const BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [FarmTabTheme.fern, Color(0xFF52B788)],
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           'Profile',
// //           style: FarmTabTheme.font(
// //             size: 18,
// //             weight: FontWeight.w700,
// //             color: FarmTabTheme.white,
// //             letterSpacing: -0.2,
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ── Profile hero
// //             Center(
// //               child: Column(
// //                 children: [
// //                   Stack(
// //                     clipBehavior: Clip.none,
// //                     children: [
// //                       Container(
// //                         width: 96,
// //                         height: 96,
// //                         decoration: BoxDecoration(
// //                           gradient: const LinearGradient(
// //                             begin: Alignment.topLeft,
// //                             end: Alignment.bottomRight,
// //                             colors: [FarmTabTheme.fern, FarmTabTheme.grove],
// //                           ),
// //                           shape: BoxShape.circle,
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: FarmTabTheme.fern.withOpacity(0.3),
// //                               blurRadius: 18,
// //                               offset: const Offset(0, 8),
// //                             ),
// //                           ],
// //                         ),
// //                         alignment: Alignment.center,
// //                         child: _pendingProfileImage != null
// //                             ? ClipOval(
// //                                 child: Image.file(
// //                                   File(_pendingProfileImage!.path),
// //                                   width: 96,
// //                                   height: 96,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               )
// //                             : Text(
// //                                 username.isNotEmpty
// //                                     ? username[0].toUpperCase()
// //                                     : '?',
// //                                 style: FarmTabTheme.font(
// //                                   size: 36,
// //                                   weight: FontWeight.w800,
// //                                   color: FarmTabTheme.white,
// //                                 ),
// //                               ),
// //                       ),
// //                       Positioned(
// //                         right: -2,
// //                         bottom: -2,
// //                         child: Material(
// //                           color: Colors.transparent,
// //                           child: InkWell(
// //                             borderRadius: BorderRadius.circular(20),
// //                             onTap: _pickProfileImage,
// //                             child: Container(
// //                               width: 32,
// //                               height: 32,
// //                               decoration: BoxDecoration(
// //                                 color: FarmTabTheme.white,
// //                                 shape: BoxShape.circle,
// //                                 border: Border.all(
// //                                   color: FarmTabTheme.border,
// //                                   width: 1.5,
// //                                 ),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: Colors.black.withOpacity(0.10),
// //                                     blurRadius: 6,
// //                                     offset: const Offset(0, 2),
// //                                   ),
// //                                 ],
// //                               ),
// //                               alignment: Alignment.center,
// //                               child: const Icon(
// //                                 Icons.camera_alt_rounded,
// //                                 size: 15,
// //                                 color: FarmTabTheme.grove,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 16),

// //                   Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Text(
// //                         username,
// //                         style: FarmTabTheme.font(
// //                           size: 21,
// //                           weight: FontWeight.w800,
// //                           color: FarmTabTheme.textH,
// //                           letterSpacing: -0.3,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Material(
// //                         color: Colors.transparent,
// //                         child: InkWell(
// //                           borderRadius: BorderRadius.circular(8),
// //                           onTap: _showEditNameDialog,
// //                           child: Container(
// //                             padding: const EdgeInsets.all(4),
// //                             child: const Icon(
// //                               Icons.edit_rounded,
// //                               size: 15,
// //                               color: FarmTabTheme.textM,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 4),

// //                   Text(
// //                     email,
// //                     style: FarmTabTheme.font(
// //                       size: 13.5,
// //                       weight: FontWeight.w400,
// //                       color: FarmTabTheme.textM,
// //                     ),
// //                   ),

// //                   const SizedBox(height: 8),

// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 10,
// //                       vertical: 5,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFF2F2F2),
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         const Icon(
// //                           Icons.calendar_today_rounded,
// //                           size: 11,
// //                           color: FarmTabTheme.textM,
// //                         ),
// //                         const SizedBox(width: 5),
// //                         Text(
// //                           'Member since $memberSince',
// //                           style: FarmTabTheme.font(
// //                             size: 11.5,
// //                             weight: FontWeight.w500,
// //                             color: FarmTabTheme.textM,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 30),

// //             // ── Organisation
// //             _sectionLabel('Organisation'),

// //             const SizedBox(height: 12),

// //             Container(
// //               decoration: FarmTabTheme.cardDecoration,
// //               child: Material(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.circular(16),
// //                 child: InkWell(
// //                   borderRadius: BorderRadius.circular(16),
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (_) => OrganisationManagementPage(
// //                           user: widget.user,
// //                           organisation: widget.organisation,
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16),
// //                     child: Row(
// //                       children: [
// //                         Container(
// //                           width: 44,
// //                           height: 44,
// //                           decoration: BoxDecoration(
// //                             color: FarmTabTheme.mist,
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           alignment: Alignment.center,
// //                           child: const Icon(
// //                             Icons.business_rounded,
// //                             size: 21,
// //                             color: FarmTabTheme.grove,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 14),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 organisationName,
// //                                 style: FarmTabTheme.font(
// //                                   size: 15,
// //                                   weight: FontWeight.w700,
// //                                   color: FarmTabTheme.textH,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 2),
// //                               Text(
// //                                 'Role: $role',
// //                                 style: FarmTabTheme.font(
// //                                   size: 12.5,
// //                                   weight: FontWeight.w400,
// //                                   color: FarmTabTheme.textM,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         const Icon(
// //                           Icons.chevron_right_rounded,
// //                           size: 20,
// //                           color: FarmTabTheme.textM,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(height: 26),

// //             // ── Account
// //             _sectionLabel('Account'),

// //             const SizedBox(height: 12),

// //             Container(
// //               decoration: FarmTabTheme.cardDecoration,
// //               child: Column(
// //                 children: [
// //                   _buildAccountTile(
// //                     icon: Icons.settings_rounded,
// //                     title: 'Account Settings',
// //                     subtitle: 'Password & account management',
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) =>
// //                               AccountSettingsPage(user: widget.user),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   const Divider(
// //                     color: FarmTabTheme.border,
// //                     height: 1,
// //                     indent: 16,
// //                     endIndent: 16,
// //                   ),
// //                   _buildAccountTile(
// //                     icon: Icons.logout_rounded,
// //                     title: 'Logout',
// //                     iconColor: FarmTabTheme.alertRed,
// //                     titleColor: FarmTabTheme.alertRed,
// //                     showChevron: false,
// //                     onTap: () => _confirmLogout(context),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 10),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _sectionLabel(String text) {
// //     return Text(
// //       text,
// //       style: FarmTabTheme.font(
// //         size: 15,
// //         weight: FontWeight.w700,
// //         color: FarmTabTheme.textH,
// //         letterSpacing: -0.2,
// //       ),
// //     );
// //   }

// //   Widget _buildAccountTile({
// //     required IconData icon,
// //     required String title,
// //     String? subtitle,
// //     Color? iconColor,
// //     Color? titleColor,
// //     bool showChevron = true,
// //     required VoidCallback onTap,
// //   }) {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: onTap,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Row(
// //             children: [
// //               Container(
// //                 width: 40,
// //                 height: 40,
// //                 decoration: BoxDecoration(
// //                   color: (iconColor ?? FarmTabTheme.grove).withOpacity(0.10),
// //                   borderRadius: BorderRadius.circular(11),
// //                 ),
// //                 alignment: Alignment.center,
// //                 child: Icon(
// //                   icon,
// //                   size: 19,
// //                   color: iconColor ?? FarmTabTheme.grove,
// //                 ),
// //               ),
// //               const SizedBox(width: 14),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       title,
// //                       style: FarmTabTheme.font(
// //                         size: 14.5,
// //                         weight: FontWeight.w600,
// //                         color: titleColor ?? FarmTabTheme.textH,
// //                       ),
// //                     ),
// //                     if (subtitle != null) ...[
// //                       const SizedBox(height: 2),
// //                       Text(
// //                         subtitle,
// //                         style: FarmTabTheme.font(
// //                           size: 12,
// //                           weight: FontWeight.w400,
// //                           color: FarmTabTheme.textM,
// //                         ),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //               if (showChevron)
// //                 const Icon(
// //                   Icons.chevron_right_rounded,
// //                   size: 20,
// //                   color: FarmTabTheme.textM,
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';

// import 'organisation_management_page.dart';
// import 'account_settings_page.dart';
// import '../auth/login_page.dart';

// // ─────────────────────────────────────────────────────────────
// // FARMTAB DESIGN TOKENS (same system used across the app)
// // ─────────────────────────────────────────────────────────────
// class FarmTabTheme {
//   static const Color forest = Color(0xFF1B4332);
//   static const Color grove = Color(0xFF2D6A4F);
//   static const Color fern = Color(0xFF40916C);
//   static const Color mint = Color(0xFF95D5B2);
//   static const Color mist = Color(0xFFD8F3DC);
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color border = Color(0xFFE8E8E8);
//   static const Color textH = Color(0xFF111111);
//   static const Color textB = Color(0xFF444444);
//   static const Color textM = Color(0xFF888888);
//   static const Color alertRed = Color(0xFFE63946);

//   static TextStyle font({
//     required double size,
//     required FontWeight weight,
//     required Color color,
//     double? letterSpacing,
//     double? height,
//   }) {
//     return GoogleFonts.plusJakartaSans(
//       fontSize: size,
//       fontWeight: weight,
//       color: color,
//       letterSpacing: letterSpacing,
//       height: height,
//     );
//   }

//   static BoxDecoration cardDecoration = BoxDecoration(
//     color: white,
//     borderRadius: BorderRadius.circular(16),
//     border: Border.all(color: border, width: 1),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.05),
//         blurRadius: 10,
//         offset: const Offset(0, 2),
//       ),
//     ],
//   );

//   static ButtonStyle primaryButton = ElevatedButton.styleFrom(
//     backgroundColor: grove,
//     foregroundColor: white,
//     elevation: 0,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   );

//   static InputDecoration fieldDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
//       filled: true,
//       fillColor: const Color(0xFFF7F7F7),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: fern, width: 1.5),
//       ),
//       disabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
// }

// class ProfilePage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic> organisation;

//   const ProfilePage({
//     super.key,
//     required this.user,
//     required this.organisation,
//   });

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final ImagePicker _imagePicker = ImagePicker();

//   // Local-only preview of a newly picked profile picture. There is
//   // no backend endpoint yet to actually upload/store this — see
//   // _pickProfileImage() for details on what's needed.
//   XFile? _pendingProfileImage;

//   // ------------------------------------------------------------
//   // NOTE FOR WHOEVER WIRES UP THE BACKEND LATER:
//   // The `users` table currently has no column to store a profile
//   // picture (no `profile_image` / `avatar_url`), and there is no
//   // `AuthService.updateProfile(...)` method yet either. Until
//   // those exist on the backend, picking an image only previews it
//   // locally — it is not actually saved anywhere.
//   // ------------------------------------------------------------
//   Future<void> _pickProfileImage() async {
//     final image = await _imagePicker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;

//     setState(() {
//       _pendingProfileImage = image;
//     });

//     _showComingSoon(
//       'Profile picture upload isn\'t connected to the backend yet — '
//       'this is just a preview for now.',
//     );
//   }

//   Future<void> _showEditNameDialog() async {
//     final controller = TextEditingController(
//       text: widget.user['username']?.toString() ?? '',
//     );

//     final newName = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: FarmTabTheme.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: FarmTabTheme.mist,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(
//                   Icons.edit_rounded,
//                   size: 17,
//                   color: FarmTabTheme.grove,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Edit Name',
//                 style: FarmTabTheme.font(
//                   size: 16.5,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//             ],
//           ),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             style: FarmTabTheme.font(
//               size: 14,
//               weight: FontWeight.w500,
//               color: FarmTabTheme.textH,
//             ),
//             decoration: FarmTabTheme.fieldDecoration('Username'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: Text(
//                 'Cancel',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: FarmTabTheme.primaryButton,
//               onPressed: () {
//                 final value = controller.text.trim();
//                 if (value.isEmpty) return;
//                 Navigator.pop(dialogContext, value);
//               },
//               child: Text(
//                 'Save',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.white,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     controller.dispose();

//     if (newName == null || !mounted) return;

//     // No AuthService.updateProfile(...) exists yet — nothing is
//     // actually saved to the backend here.
//     _showComingSoon('Editing your name isn\'t connected to the backend yet.');
//   }

//   void _showComingSoon(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   Future<void> _confirmLogout(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: FarmTabTheme.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: FarmTabTheme.alertRed.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(
//                   Icons.logout_rounded,
//                   size: 17,
//                   color: FarmTabTheme.alertRed,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Logout',
//                 style: FarmTabTheme.font(
//                   size: 16.5,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'Are you sure you want to logout?',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: Text(
//                 'Cancel',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: FarmTabTheme.alertRed,
//                 foregroundColor: FarmTabTheme.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: Text(
//                 'Logout',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.white,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) return;

//     if (!context.mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   String _formatMemberSince(dynamic createdAt) {
//     if (createdAt == null) return '--';

//     final parsed = DateTime.tryParse(createdAt.toString());
//     if (parsed == null) return '--';

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return '${months[parsed.month - 1]} ${parsed.year}';
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final username = widget.user['username']?.toString() ?? 'User';
//     final email = widget.user['email']?.toString() ?? '';
//     final organisationName =
//         widget.organisation['name']?.toString() ?? 'Organisation';
//     final role = widget.organisation['role']?.toString() ?? 'STAFF';
//     final memberSince = _formatMemberSince(widget.user['created_at']);

//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Cover header with overlapping avatar
//             _buildCoverHeader(username),

//             const SizedBox(height: 58),

//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               username,
//                               style: FarmTabTheme.font(
//                                 size: 21,
//                                 weight: FontWeight.w800,
//                                 color: FarmTabTheme.textH,
//                                 letterSpacing: -0.3,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(8),
//                                 onTap: _showEditNameDialog,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   child: const Icon(
//                                     Icons.edit_rounded,
//                                     size: 15,
//                                     color: FarmTabTheme.textM,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           email,
//                           style: FarmTabTheme.font(
//                             size: 13.5,
//                             weight: FontWeight.w400,
//                             color: FarmTabTheme.textM,
//                           ),
//                         ),

//                         const SizedBox(height: 8),

//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF2F2F2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.calendar_today_rounded,
//                                 size: 11,
//                                 color: FarmTabTheme.textM,
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 'Member since $memberSince',
//                                 style: FarmTabTheme.font(
//                                   size: 11.5,
//                                   weight: FontWeight.w500,
//                                   color: FarmTabTheme.textM,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // ── Organisation
//                   _sectionLabel('Organisation'),

//                   const SizedBox(height: 12),

//                   Container(
//                     decoration: FarmTabTheme.cardDecoration,
//                     child: Material(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.circular(16),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(16),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => OrganisationManagementPage(
//                                 user: widget.user,
//                                 organisation: widget.organisation,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 44,
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   color: FarmTabTheme.mist,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: const Icon(
//                                   Icons.business_rounded,
//                                   size: 21,
//                                   color: FarmTabTheme.grove,
//                                 ),
//                               ),
//                               const SizedBox(width: 14),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       organisationName,
//                                       style: FarmTabTheme.font(
//                                         size: 15,
//                                         weight: FontWeight.w700,
//                                         color: FarmTabTheme.textH,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       'Role: $role',
//                                       style: FarmTabTheme.font(
//                                         size: 12.5,
//                                         weight: FontWeight.w400,
//                                         color: FarmTabTheme.textM,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Icon(
//                                 Icons.chevron_right_rounded,
//                                 size: 20,
//                                 color: FarmTabTheme.textM,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 26),

//                   // ── Account
//                   _sectionLabel('Account'),

//                   const SizedBox(height: 12),

//                   Container(
//                     decoration: FarmTabTheme.cardDecoration,
//                     child: Column(
//                       children: [
//                         _buildAccountTile(
//                           icon: Icons.settings_rounded,
//                           title: 'Account Settings',
//                           subtitle: 'Password & account management',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     AccountSettingsPage(user: widget.user),
//                               ),
//                             );
//                           },
//                         ),
//                         const Divider(
//                           color: FarmTabTheme.border,
//                           height: 1,
//                           indent: 16,
//                           endIndent: 16,
//                         ),
//                         _buildAccountTile(
//                           icon: Icons.logout_rounded,
//                           title: 'Logout',
//                           iconColor: FarmTabTheme.alertRed,
//                           titleColor: FarmTabTheme.alertRed,
//                           showChevron: false,
//                           onTap: () => _confirmLogout(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── COVER HEADER ─────────────────────────────────────────────
//   // A taller decorative gradient "cover" with soft circular
//   // accents, and the avatar overlapping its bottom edge — same
//   // pattern used by most modern profile screens.

//   Widget _buildCoverHeader(String username) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         ClipRRect(
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(32),
//             bottomRight: Radius.circular(32),
//           ),
//           child: Container(
//             height: 176,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [FarmTabTheme.forest, FarmTabTheme.fern],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Decorative soft circles for visual depth.
//                 Positioned(
//                   right: -34,
//                   top: -34,
//                   child: Container(
//                     width: 130,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.08),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 30,
//                   top: 30,
//                   child: Container(
//                     width: 46,
//                     height: 46,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.06),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: -26,
//                   bottom: -20,
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.07),
//                     ),
//                   ),
//                 ),

//                 SafeArea(
//                   bottom: false,
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
//                     child: Text(
//                       'Profile',
//                       style: FarmTabTheme.font(
//                         size: 20,
//                         weight: FontWeight.w700,
//                         color: FarmTabTheme.white,
//                         letterSpacing: -0.2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // ── Avatar, overlapping the boundary between the cover
//         // and the white content below.
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: -50,
//           child: Center(child: _buildAvatar(username)),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvatar(String username) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         // White ring so the avatar reads cleanly against both the
//         // gradient cover and the white content beneath it.
//         Container(
//           width: 116,
//           height: 116,
//           padding: const EdgeInsets.all(5),
//           decoration: BoxDecoration(
//             color: FarmTabTheme.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.14),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [FarmTabTheme.mint, FarmTabTheme.fern],
//               ),
//               shape: BoxShape.circle,
//             ),
//             padding: const EdgeInsets.all(2.5),
//             child: ClipOval(
//               child: Container(
//                 color: FarmTabTheme.grove,
//                 child: _pendingProfileImage != null
//                     ? Image.file(
//                         File(_pendingProfileImage!.path),
//                         fit: BoxFit.cover,
//                       )
//                     : Center(
//                         child: Text(
//                           username.isNotEmpty ? username[0].toUpperCase() : '?',
//                           style: FarmTabTheme.font(
//                             size: 38,
//                             weight: FontWeight.w800,
//                             color: FarmTabTheme.white,
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ),

//         // ── Edit-photo button — a filled circle with a soft
//         // shadow and a white ring, sitting on the avatar's edge.
//         Positioned(
//           right: -2,
//           bottom: 2,
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: _pickProfileImage,
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [FarmTabTheme.grove, FarmTabTheme.fern],
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: FarmTabTheme.white, width: 3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.18),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(
//                   Icons.camera_alt_rounded,
//                   size: 16,
//                   color: FarmTabTheme.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _sectionLabel(String text) {
//     return Text(
//       text,
//       style: FarmTabTheme.font(
//         size: 15,
//         weight: FontWeight.w700,
//         color: FarmTabTheme.textH,
//         letterSpacing: -0.2,
//       ),
//     );
//   }

//   Widget _buildAccountTile({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Color? iconColor,
//     Color? titleColor,
//     bool showChevron = true,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: (iconColor ?? FarmTabTheme.grove).withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(11),
//                 ),
//                 alignment: Alignment.center,
//                 child: Icon(
//                   icon,
//                   size: 19,
//                   color: iconColor ?? FarmTabTheme.grove,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: FarmTabTheme.font(
//                         size: 14.5,
//                         weight: FontWeight.w600,
//                         color: titleColor ?? FarmTabTheme.textH,
//                       ),
//                     ),
//                     if (subtitle != null) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: FarmTabTheme.font(
//                           size: 12,
//                           weight: FontWeight.w400,
//                           color: FarmTabTheme.textM,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               if (showChevron)
//                 const Icon(
//                   Icons.chevron_right_rounded,
//                   size: 20,
//                   color: FarmTabTheme.textM,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _pendingProfileImage = image;
    });

    _showComingSoon(
      'Profile picture upload isn\'t connected to the backend yet — '
      'this is just a preview for now.',
    );
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

            const SizedBox(height: 58),

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
    return Stack(
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
                colors: [FarmTabTheme.fern, Color.fromARGB(255, 112, 212, 167)],
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
          bottom: -50,
          child: Center(child: _buildAvatar(username)),
        ),
      ],
    );
  }

  Widget _buildAvatar(String username) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // White ring so the avatar reads cleanly against both the
        // gradient cover and the white content beneath it.
        Container(
          width: 116,
          height: 116,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: FarmTabTheme.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [FarmTabTheme.mint, FarmTabTheme.fern],
              ),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: Container(
                color: FarmTabTheme.grove,
                child: _pendingProfileImage != null
                    ? Image.file(
                        File(_pendingProfileImage!.path),
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: FarmTabTheme.font(
                            size: 38,
                            weight: FontWeight.w800,
                            color: FarmTabTheme.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),

        // ── Edit-photo button — a filled circle with a soft
        // shadow and a white ring, sitting on the avatar's edge.
        Positioned(
          right: -2,
          bottom: 2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _pickProfileImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FarmTabTheme.grove, FarmTabTheme.fern],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: FarmTabTheme.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ),
        ),
      ],
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
