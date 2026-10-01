// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../devices/devices_page.dart';
// import '../profile/profile_page.dart';
// import '../sites/sites_page.dart';

// import 'dart:async';

// import '../../services/global_alert_service.dart';
// import '../../services/shelf_service.dart';
// import '../shelves/shelf_detail_page.dart';

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

//   static TextStyle font({
//     required double size,
//     required FontWeight weight,
//     required Color color,
//     double? letterSpacing,
//   }) {
//     return GoogleFonts.plusJakartaSans(
//       fontSize: size,
//       fontWeight: weight,
//       color: color,
//       letterSpacing: letterSpacing,
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic> organisation;

//   const HomePage({super.key, required this.user, required this.organisation});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   late final List<Widget> _pages;

//   // ============================================================
//   // GLOBAL ALERT
//   // ============================================================

//   final GlobalAlertService _globalAlertService = GlobalAlertService();

//   StreamSubscription<Map<String, dynamic>>? _globalAlertSubscription;

//   Map<String, dynamic>? _currentFloatingAlert;

//   Timer? _floatingAlertTimer;

//   OverlayEntry? _floatingAlertOverlay;

//   @override
//   void initState() {
//     super.initState();

//     _pages = [
//       _buildHomePage(),
//       SitesPage(user: widget.user, organisation: widget.organisation),
//       DevicesPage(user: widget.user, organisation: widget.organisation),
//       ProfilePage(user: widget.user, organisation: widget.organisation),
//     ];

//     _connectGlobalAlert();
//   }

//   // ============================================================
//   // GLOBAL ALERT WEBSOCKET
//   // ============================================================

//   Future<void> _connectGlobalAlert() async {
//     _globalAlertSubscription = _globalAlertService.alerts.listen((alert) {
//       if (!mounted) return;

//       _showFloatingAlert(alert);
//     });

//     await _globalAlertService.connect();
//   }
//   // ============================================================
//   // SHOW FLOATING ALERT
//   // ============================================================

//   void _showFloatingAlert(Map<String, dynamic> alert) {
//     _floatingAlertTimer?.cancel();

//     // Remove an existing alert overlay first.
//     _floatingAlertOverlay?.remove();
//     _floatingAlertOverlay = null;

//     if (!mounted) return;

//     _currentFloatingAlert = alert;

//     final overlay = Navigator.of(context, rootNavigator: true).overlay;

//     if (overlay == null) {
//       return;
//     }

//     _floatingAlertOverlay = OverlayEntry(
//       builder: (context) {
//         return _buildFloatingAlert();
//       },
//     );

//     overlay.insert(_floatingAlertOverlay!);

//     _floatingAlertTimer = Timer(const Duration(seconds: 10), () {
//       _closeFloatingAlert();
//     });
//   }

//   // ============================================================
//   // CLOSE FLOATING ALERT
//   // ============================================================

//   void _closeFloatingAlert() {
//     _floatingAlertTimer?.cancel();
//     _floatingAlertTimer = null;

//     _floatingAlertOverlay?.remove();
//     _floatingAlertOverlay = null;

//     _currentFloatingAlert = null;
//   }

//   // ============================================================
//   // OPEN SHELF FROM ALERT
//   // ============================================================

//   Future<void> _openShelfFromAlert(Map<String, dynamic> alert) async {
//     final siteId = alert['site_id'];
//     final shelfId = alert['shelf_id'];

//     if (siteId == null || shelfId == null) {
//       _closeFloatingAlert();
//       return;
//     }

//     _floatingAlertTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         _currentFloatingAlert = null;
//       });
//     }

//     try {
//       final shelfService = ShelfService();

//       final shelf = await shelfService.getShelf(
//         siteId: int.parse(siteId.toString()),
//         shelfId: int.parse(shelfId.toString()),
//       );

//       if (!mounted) return;

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               ShelfDetailPage(shelf: shelf, organisation: widget.organisation),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   // ============================================================
//   // FLOATING ALERT UI
//   // ============================================================

//   Widget _buildFloatingAlert() {
//     final alert = _currentFloatingAlert;

//     if (alert == null) {
//       return const SizedBox.shrink();
//     }

//     final shelfName = alert['shelf_name']?.toString() ?? 'Shelf';

//     final sensorType = alert['sensor_type']?.toString() ?? '';

//     final alertType = alert['alert_type']?.toString() ?? '';

//     final value = alert['value']?.toString() ?? '';

//     final thresholdValue = alert['threshold_value']?.toString() ?? '';

//     final isHigh = alertType == 'HIGH';

//     return Positioned(
//       top: 0,
//       left: 16,
//       right: 16,
//       child: SafeArea(
//         bottom: false,
//         child: Material(
//           color: Colors.transparent,
//           child: GestureDetector(
//             onTap: () {
//               _openShelfFromAlert(alert);
//             },
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.18),
//                     blurRadius: 12,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//                 border: Border.all(color: Colors.red.shade300, width: 1.2),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.warning_amber_rounded,
//                       color: Colors.red.shade700,
//                       size: 25,
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'Sensor Alert',
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 7,
//                                 vertical: 3,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isHigh
//                                     ? Colors.red.shade50
//                                     : Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 alertType,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: isHigh
//                                       ? Colors.red.shade700
//                                       : Colors.orange.shade700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           '$shelfName • $sensorType',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey.shade800,
//                           ),
//                         ),

//                         const SizedBox(height: 3),

//                         Text(
//                           'Value: $value   Threshold: $thresholdValue',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   IconButton(
//                     tooltip: 'Dismiss',
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: _closeFloatingAlert,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _floatingAlertTimer?.cancel();
//     _floatingAlertOverlay?.remove();
//     _floatingAlertOverlay = null;

//     _globalAlertSubscription?.cancel();
//     _globalAlertService.dispose();

//     super.dispose();
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     backgroundColor: FarmTabTheme.white,
//   //     // Change the content when a tab is selected — using a
//   //     // layered fade instead of an instant swap, so switching
//   //     // tabs feels smooth. All pages stay mounted (same as
//   //     // IndexedStack) so state/scroll position is preserved.
//   //     body: Stack(
//   //       children: List.generate(_pages.length, (index) {
//   //         final isActive = _currentIndex == index;

//   //         return IgnorePointer(
//   //           ignoring: !isActive,
//   //           child: AnimatedOpacity(
//   //             opacity: isActive ? 1 : 0,
//   //             duration: const Duration(milliseconds: 220),
//   //             curve: Curves.easeOut,
//   //             child: _pages[index],
//   //           ),
//   //         );
//   //       }),
//   //     ),

//   //     // This stays permanently at the bottom.
//   //     bottomNavigationBar: _buildBottomNavBar(),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       body: Stack(
//         children: [
//           ...List.generate(_pages.length, (index) {
//             final isActive = _currentIndex == index;

//             return IgnorePointer(
//               ignoring: !isActive,
//               child: AnimatedOpacity(
//                 opacity: isActive ? 1 : 0,
//                 duration: const Duration(milliseconds: 220),
//                 curve: Curves.easeOut,
//                 child: _pages[index],
//               ),
//             );
//           }),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }

//   // ── BOTTOM NAVIGATION BAR ────────────────────────────────────
//   // Custom-built nav bar (instead of the stock BottomNavigationBar)
//   // so the selected tab gets a soft mint pill highlight, matching
//   // the rest of the app's design system.

//   Widget _buildBottomNavBar() {
//     final items = [
//       (icon: Icons.home_rounded, label: 'Home'),
//       (icon: Icons.eco_rounded, label: 'Sites'),
//       (icon: Icons.devices_rounded, label: 'Devices'),
//       (icon: Icons.person_rounded, label: 'Profile'),
//     ];

//     return SafeArea(
//       top: false,
//       minimum: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Container(
//           height: 62,
//           decoration: BoxDecoration(
//             color: FarmTabTheme.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.10),
//                 blurRadius: 18,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Row(
//             children: List.generate(items.length, (index) {
//               final selected = _currentIndex == index;
//               final item = items[index];

//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _currentIndex = index;
//                     });
//                   },
//                   behavior: HitTestBehavior.opaque,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         curve: Curves.easeOut,
//                         width: 44,
//                         height: 24,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: selected
//                               ? FarmTabTheme.mist
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Icon(
//                           item.icon,
//                           size: 18,
//                           color: selected
//                               ? FarmTabTheme.grove
//                               : FarmTabTheme.textM,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         item.label,
//                         style: FarmTabTheme.font(
//                           size: 10,
//                           weight: selected ? FontWeight.w700 : FontWeight.w500,
//                           color: selected
//                               ? FarmTabTheme.grove
//                               : FarmTabTheme.textM,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HOME PAGE CONTENT
//   // ============================================================

//   Widget _buildHomePage() {
//     final username = widget.user['username'] ?? 'User';
//     final organisationName = widget.organisation['name'] ?? 'Organisation';
//     final role = widget.organisation['role'] ?? 'STAFF';

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Welcome
//           Text(
//             'Welcome, $username! 👋',
//             style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 8),

//           const Text(
//             'Here\'s your farm overview.',
//             style: TextStyle(fontSize: 15, color: Colors.grey),
//           ),

//           const SizedBox(height: 24),

//           // Organisation
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(18),
//               child: Row(
//                 children: [
//                   const CircleAvatar(radius: 28, child: Icon(Icons.business)),

//                   const SizedBox(width: 16),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Organisation',
//                           style: TextStyle(fontSize: 13, color: Colors.grey),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           organisationName,
//                           style: const TextStyle(
//                             fontSize: 19,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           'Role: $role',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 28),

//           // Farm Overview
//           const Text(
//             'Farm Overview',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _buildSummaryCard(
//                   icon: Icons.eco,
//                   title: 'Sites',
//                   value: '2',
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: _buildSummaryCard(
//                   icon: Icons.view_module,
//                   title: 'Shelves',
//                   value: '8',
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 28),

//           // Recent Shelves
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Recent Shelves',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _currentIndex = 1;
//                   });
//                 },
//                 child: const Text('See all'),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           _buildRecentShelfCard(
//             icon: Icons.eco,
//             shelfName: 'Lettuce Shelf 01',
//             details: 'Site A • Lettuce',
//           ),

//           _buildRecentShelfCard(
//             icon: Icons.eco,
//             shelfName: 'Lettuce Shelf 03',
//             details: 'Site B • Lettuce',
//           ),

//           _buildRecentShelfCard(
//             icon: Icons.local_florist,
//             shelfName: 'Tomato Shelf 02',
//             details: 'Site A • Tomato',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, size: 30, color: Colors.green),

//             const SizedBox(height: 12),

//             Text(
//               title,
//               style: const TextStyle(fontSize: 15, color: Colors.grey),
//             ),

//             const SizedBox(height: 4),

//             Text(
//               value,
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentShelfCard({
//     required IconData icon,
//     required String shelfName,
//     required String details,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

//         leading: CircleAvatar(child: Icon(icon)),

//         title: Text(
//           shelfName,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),

//         subtitle: Text(details),

//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),

//         onTap: () {
//           // Shelf details will be implemented later.
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../devices/devices_page.dart';
import '../profile/profile_page.dart';
import '../sites/sites_page.dart';

import 'dart:async';

import '../../services/global_alert_service.dart';
import '../../services/shelf_service.dart';
import '../shelves/shelf_detail_page.dart';

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
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const HomePage({super.key, required this.user, required this.organisation});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  // ============================================================
  // GLOBAL ALERT
  // ============================================================

  final GlobalAlertService _globalAlertService = GlobalAlertService();

  StreamSubscription<Map<String, dynamic>>? _globalAlertSubscription;

  Map<String, dynamic>? _currentFloatingAlert;

  Timer? _floatingAlertTimer;

  OverlayEntry? _floatingAlertOverlay;

  @override
  void initState() {
    super.initState();

    _pages = [
      _buildHomePage(),
      SitesPage(user: widget.user, organisation: widget.organisation),
      DevicesPage(user: widget.user, organisation: widget.organisation),
      ProfilePage(user: widget.user, organisation: widget.organisation),
    ];

    _connectGlobalAlert();
  }

  // ============================================================
  // GLOBAL ALERT WEBSOCKET
  // ============================================================

  Future<void> _connectGlobalAlert() async {
    _globalAlertSubscription = _globalAlertService.alerts.listen((alert) {
      if (!mounted) return;

      _showFloatingAlert(alert);
    });

    await _globalAlertService.connect();
  }
  // ============================================================
  // SHOW FLOATING ALERT
  // ============================================================

  void _showFloatingAlert(Map<String, dynamic> alert) {
    _floatingAlertTimer?.cancel();

    // Remove an existing alert overlay first.
    _floatingAlertOverlay?.remove();
    _floatingAlertOverlay = null;

    if (!mounted) return;

    _currentFloatingAlert = alert;

    final overlay = Navigator.of(context, rootNavigator: true).overlay;

    if (overlay == null) {
      return;
    }

    _floatingAlertOverlay = OverlayEntry(
      builder: (context) {
        return _buildFloatingAlert();
      },
    );

    overlay.insert(_floatingAlertOverlay!);

    _floatingAlertTimer = Timer(const Duration(seconds: 10), () {
      _closeFloatingAlert();
    });
  }

  // ============================================================
  // CLOSE FLOATING ALERT
  // ============================================================

  void _closeFloatingAlert() {
    _floatingAlertTimer?.cancel();
    _floatingAlertTimer = null;

    _floatingAlertOverlay?.remove();
    _floatingAlertOverlay = null;

    _currentFloatingAlert = null;
  }

  // ============================================================
  // OPEN SHELF FROM ALERT
  // ============================================================

  Future<void> _openShelfFromAlert(Map<String, dynamic> alert) async {
    final siteId = alert['site_id'];
    final shelfId = alert['shelf_id'];

    if (siteId == null || shelfId == null) {
      _closeFloatingAlert();
      return;
    }

    _floatingAlertTimer?.cancel();

    if (mounted) {
      setState(() {
        _currentFloatingAlert = null;
      });
    }

    try {
      final shelfService = ShelfService();

      final shelf = await shelfService.getShelf(
        siteId: int.parse(siteId.toString()),
        shelfId: int.parse(shelfId.toString()),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ShelfDetailPage(shelf: shelf, organisation: widget.organisation),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // ============================================================
  // FLOATING ALERT UI
  // ============================================================

  Widget _buildFloatingAlert() {
    final alert = _currentFloatingAlert;

    if (alert == null) {
      return const SizedBox.shrink();
    }

    final shelfName = alert['shelf_name']?.toString() ?? 'Shelf';

    final sensorType = alert['sensor_type']?.toString() ?? '';

    final alertType = alert['alert_type']?.toString() ?? '';

    final value = alert['value']?.toString() ?? '';

    final thresholdValue = alert['threshold_value']?.toString() ?? '';

    final isHigh = alertType == 'HIGH';

    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        // SafeArea alone only adds padding to avoid a phone's
        // notch/status bar — on desktop (no notch) that's 0, which
        // is why the card was sitting flush against the very top
        // edge. `minimum` guarantees a real gap everywhere.
        minimum: const EdgeInsets.only(top: 14),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _openShelfFromAlert(alert);
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.red.shade300, width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sensor Alert',
                                style: FarmTabTheme.font(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: FarmTabTheme.textH,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isHigh
                                    ? Colors.red.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                alertType,
                                style: FarmTabTheme.font(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: isHigh
                                      ? Colors.red.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '$shelfName • $sensorType',
                          style: FarmTabTheme.font(
                            size: 12,
                            weight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Value: $value   Threshold: $thresholdValue',
                          style: FarmTabTheme.font(
                            size: 10,
                            weight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Dismiss',
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _closeFloatingAlert,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _floatingAlertTimer?.cancel();
    _floatingAlertOverlay?.remove();
    _floatingAlertOverlay = null;

    _globalAlertSubscription?.cancel();
    _globalAlertService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      body: Stack(
        children: [
          ...List.generate(_pages.length, (index) {
            final isActive = _currentIndex == index;

            return IgnorePointer(
              ignoring: !isActive,
              child: AnimatedOpacity(
                opacity: isActive ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: _pages[index],
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── BOTTOM NAVIGATION BAR ────────────────────────────────────
  // Custom-built nav bar (instead of the stock BottomNavigationBar)
  // so the selected tab gets a soft mint pill highlight, matching
  // the rest of the app's design system.

  Widget _buildBottomNavBar() {
    final items = [
      (icon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.eco_rounded, label: 'Sites'),
      (icon: Icons.devices_rounded, label: 'Devices'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: FarmTabTheme.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _currentIndex == index;
              final item = items[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: 44,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? FarmTabTheme.mist
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: selected
                              ? FarmTabTheme.grove
                              : FarmTabTheme.textM,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: FarmTabTheme.font(
                          size: 10,
                          weight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? FarmTabTheme.grove
                              : FarmTabTheme.textM,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HOME PAGE CONTENT
  // ============================================================

  Widget _buildHomePage() {
    final username = widget.user['username'] ?? 'User';
    final organisationName = widget.organisation['name'] ?? 'Organisation';
    final role = widget.organisation['role'] ?? 'STAFF';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            'Welcome, $username! 👋',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Here\'s your farm overview.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Organisation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.business)),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Organisation',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          organisationName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Role: $role',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Farm Overview
          const Text(
            'Farm Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.eco,
                  title: 'Sites',
                  value: '2',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.view_module,
                  title: 'Shelves',
                  value: '8',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Recent Shelves
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Shelves',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: const Text('See all'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildRecentShelfCard(
            icon: Icons.eco,
            shelfName: 'Lettuce Shelf 01',
            details: 'Site A • Lettuce',
          ),

          _buildRecentShelfCard(
            icon: Icons.eco,
            shelfName: 'Lettuce Shelf 03',
            details: 'Site B • Lettuce',
          ),

          _buildRecentShelfCard(
            icon: Icons.local_florist,
            shelfName: 'Tomato Shelf 02',
            details: 'Site A • Tomato',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.green),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentShelfCard({
    required IconData icon,
    required String shelfName,
    required String details,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        leading: CircleAvatar(child: Icon(icon)),

        title: Text(
          shelfName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(details),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: () {
          // Shelf details will be implemented later.
        },
      ),
    );
  }
}
