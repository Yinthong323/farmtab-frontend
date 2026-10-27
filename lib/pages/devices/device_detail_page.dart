// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../services/device_service.dart';

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

//   static InputDecoration fieldDecoration(String label, {String? hint}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: font(size: 13.5, weight: FontWeight.w500, color: textM),
//       hintStyle: font(size: 13.5, weight: FontWeight.w400, color: textM),
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
//     );
//   }
// }

// class DeviceDetailPage extends StatefulWidget {
//   final Map<String, dynamic> device;
//   final Map<String, dynamic> organisation;

//   const DeviceDetailPage({
//     super.key,
//     required this.device,
//     required this.organisation,
//   });

//   @override
//   State<DeviceDetailPage> createState() => _DeviceDetailPageState();
// }

// class _DeviceDetailPageState extends State<DeviceDetailPage> {
//   final DeviceService _deviceService = DeviceService();

//   late String _deviceSerialNumber;

//   bool _isUpdating = false;

//   @override
//   void initState() {
//     super.initState();

//     _deviceSerialNumber =
//         widget.device['device_serial_number']?.toString() ?? '';
//   }

//   bool get _isAdmin {
//     return widget.organisation['role'] == 'ADMIN';
//   }

//   Future<void> _editDevice() async {
//     final controller = TextEditingController(text: _deviceSerialNumber);

//     final newSerialNumber = await showDialog<String>(
//       context: context,
//       builder: (context) {
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
//                 'Edit Device',
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
//             decoration: FarmTabTheme.fieldDecoration(
//               'Device Serial Number',
//               hint: 'Enter device serial number',
//             ),
//             textInputAction: TextInputAction.done,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
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
//                 backgroundColor: FarmTabTheme.grove,
//                 foregroundColor: FarmTabTheme.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 final value = controller.text.trim();

//                 if (value.isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(context, value);
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

//     if (newSerialNumber == null ||
//         newSerialNumber.trim().isEmpty ||
//         newSerialNumber.trim() == _deviceSerialNumber) {
//       return;
//     }

//     await _saveDevice(newSerialNumber.trim());
//   }

//   Future<void> _saveDevice(String newSerialNumber) async {
//     setState(() {
//       _isUpdating = true;
//     });

//     try {
//       await _deviceService.updateDeviceSerialNumber(
//         siteId: widget.device['site_id'],
//         shelfId: widget.device['shelf_id'],
//         deviceSerialNumber: newSerialNumber,
//       );

//       if (!mounted) return;

//       setState(() {
//         _deviceSerialNumber = newSerialNumber;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Device updated successfully.')),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Unable to update device: $e')));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUpdating = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final siteName = widget.device['site_name']?.toString() ?? 'Unknown Site';

//     final shelfName =
//         widget.device['shelf_name']?.toString() ?? 'Unknown Shelf';

//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       appBar: _buildAppBar(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _sectionLabel('Device Information'),

//             const SizedBox(height: 12),

//             _buildInfoCard(
//               icon: Icons.qr_code_rounded,
//               title: 'Serial Number',
//               value: _deviceSerialNumber.isEmpty
//                   ? 'Unknown'
//                   : _deviceSerialNumber,
//             ),

//             const SizedBox(height: 10),

//             _buildInfoCard(
//               icon: Icons.location_city_rounded,
//               title: 'Site',
//               value: siteName,
//             ),

//             const SizedBox(height: 10),

//             _buildInfoCard(
//               icon: Icons.view_module_rounded,
//               title: 'Shelf',
//               value: shelfName,
//             ),

//             const SizedBox(height: 10),

//             _buildConnectionStatusCard(),

//             const SizedBox(height: 28),

//             if (_isAdmin)
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [FarmTabTheme.grove, FarmTabTheme.fern],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: FarmTabTheme.fern.withOpacity(0.35),
//                       blurRadius: 14,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   borderRadius: BorderRadius.circular(12),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(12),
//                     onTap: _isUpdating ? null : _editDevice,
//                     child: SizedBox(
//                       height: 52,
//                       child: Center(
//                         child: _isUpdating
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: FarmTabTheme.white,
//                                 ),
//                               )
//                             : Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.edit_rounded,
//                                     size: 18,
//                                     color: FarmTabTheme.white,
//                                   ),
//                                   const SizedBox(width: 9),
//                                   Text(
//                                     'Change Device',
//                                     style: FarmTabTheme.font(
//                                       size: 14.5,
//                                       weight: FontWeight.w600,
//                                       color: FarmTabTheme.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── APP BAR ────────────────────────────────────────────────

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 3,
//       shadowColor: FarmTabTheme.fern.withOpacity(0.35),
//       scrolledUnderElevation: 3,
//       centerTitle: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(22),
//           bottomRight: Radius.circular(22),
//         ),
//       ),
//       leading: IconButton(
//         onPressed: () => Navigator.of(context).maybePop(),
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//       ),
//       iconTheme: const IconThemeData(color: FarmTabTheme.white),
//       flexibleSpace: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(22),
//           bottomRight: Radius.circular(22),
//         ),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [FarmTabTheme.fern, Color(0xFF52B788)],
//             ),
//           ),
//         ),
//       ),
//       title: Text(
//         'Connected Device',
//         style: FarmTabTheme.font(
//           size: 17,
//           weight: FontWeight.w700,
//           color: FarmTabTheme.white,
//           letterSpacing: -0.2,
//         ),
//       ),
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

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: FarmTabTheme.mist,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             alignment: Alignment.center,
//             child: Icon(icon, size: 19, color: FarmTabTheme.grove),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   value,
//                   style: FarmTabTheme.font(
//                     size: 15,
//                     weight: FontWeight.w600,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // Connection status — no live telemetry wired up yet, so this
//   // shows as an attention-coloured "Offline" state. Swap the
//   // colour/icon/text here once real device status is available.
//   // ------------------------------------------------------------
//   Widget _buildConnectionStatusCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: FarmTabTheme.alertRed.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(11),
//             ),
//             alignment: Alignment.center,
//             child: const Icon(
//               Icons.wifi_off_rounded,
//               size: 19,
//               color: FarmTabTheme.alertRed,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Connection Status',
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   'Offline',
//                   style: FarmTabTheme.font(
//                     size: 15,
//                     weight: FontWeight.w700,
//                     color: FarmTabTheme.alertRed,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'device_status.dart';
import '../../services/device_service.dart';

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
    );
  }
}

class DeviceDetailPage extends StatefulWidget {
  final Map<String, dynamic> device;
  final Map<String, dynamic> organisation;

  // The status the device list already knows, so this page is not blank
  // while it asks the server again
  final DeviceStatus? initialStatus;

  const DeviceDetailPage({
    super.key,
    required this.device,
    required this.organisation,
    this.initialStatus,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final DeviceService _deviceService = DeviceService();

  late String _deviceSerialNumber;

  bool _isUpdating = false;

  // The live connection status, refreshed every few seconds
  late DeviceStatus _status;
  bool _statusFailed = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    _deviceSerialNumber =
        widget.device['device_serial_number']?.toString() ?? '';

    _status = widget.initialStatus ?? DeviceStatus.unknown;

    _loadStatus();

    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadStatus(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  bool get _isAdmin {
    return widget.organisation['role'] == 'ADMIN';
  }

  int? get _shelfId {
    final value = widget.device['shelf_id'];

    if (value is int) return value;

    return int.tryParse('$value');
  }

  Future<void> _loadStatus() async {
    final shelfId = _shelfId;

    if (shelfId == null) return;

    try {
      final raw = await _deviceService.getDeviceStatuses(shelfIds: [shelfId]);

      if (!mounted) return;

      final json = raw[shelfId];

      setState(() {
        if (json != null) _status = DeviceStatus.fromJson(json);
        _statusFailed = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _statusFailed = true;
      });
    }
  }

  Future<void> _editDevice() async {
    final controller = TextEditingController(text: _deviceSerialNumber);

    final newSerialNumber = await showDialog<String>(
      context: context,
      builder: (context) {
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
                'Edit Device',
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
            decoration: FarmTabTheme.fieldDecoration(
              'Device Serial Number',
              hint: 'Enter device serial number',
            ),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
                backgroundColor: FarmTabTheme.grove,
                foregroundColor: FarmTabTheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(context, value);
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

    if (newSerialNumber == null ||
        newSerialNumber.trim().isEmpty ||
        newSerialNumber.trim() == _deviceSerialNumber) {
      return;
    }

    await _saveDevice(newSerialNumber.trim());
  }

  Future<void> _saveDevice(String newSerialNumber) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _deviceService.updateDeviceSerialNumber(
        siteId: widget.device['site_id'],
        shelfId: widget.device['shelf_id'],
        deviceSerialNumber: newSerialNumber,
      );

      if (!mounted) return;

      setState(() {
        _deviceSerialNumber = newSerialNumber;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to update device: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteName = widget.device['site_name']?.toString() ?? 'Unknown Site';

    final shelfName =
        widget.device['shelf_name']?.toString() ?? 'Unknown Shelf';

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Connection'),

            const SizedBox(height: 12),

            _buildConnectionStatusCard(),

            if (_hasLatestReading) ...[
              const SizedBox(height: 22),

              _sectionLabel('Latest Sensor Reading'),

              const SizedBox(height: 12),

              _buildLatestReadingCard(),
            ],

            const SizedBox(height: 26),

            _sectionLabel('Device Information'),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.qr_code_rounded,
              title: 'Serial Number',
              value: _deviceSerialNumber.isEmpty
                  ? 'Unknown'
                  : _deviceSerialNumber,
            ),

            const SizedBox(height: 10),

            _buildInfoCard(
              icon: Icons.location_city_rounded,
              title: 'Site',
              value: siteName,
            ),

            const SizedBox(height: 10),

            _buildInfoCard(
              icon: Icons.view_module_rounded,
              title: 'Shelf',
              value: shelfName,
            ),

            const SizedBox(height: 28),

            if (_isAdmin)
              Container(
                width: double.infinity,
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
                    onTap: _isUpdating ? null : _editDevice,
                    child: SizedBox(
                      height: 52,
                      child: Center(
                        child: _isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: FarmTabTheme.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                    color: FarmTabTheme.white,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Change Device',
                                    style: FarmTabTheme.font(
                                      size: 14.5,
                                      weight: FontWeight.w600,
                                      color: FarmTabTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      scrolledUnderElevation: 3,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      iconTheme: const IconThemeData(color: FarmTabTheme.white),
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [FarmTabTheme.fern, Color(0xFF52B788)],
            ),
          ),
        ),
      ),
      title: Text(
        'Connected Device',
        style: FarmTabTheme.font(
          size: 17,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: FarmTabTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FarmTabTheme.mist,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: FarmTabTheme.grove),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: FarmTabTheme.font(
                    size: 15,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Connection status. Online = the device is sending sensor readings
  // right now. It is worked out by the server from the readings it
  // receives, and refreshed every few seconds while this page is open.
  // ------------------------------------------------------------
  Widget _buildConnectionStatusCard() {
    // If the check itself failed, do not claim Online or Offline
    final status = _statusFailed ? DeviceStatus.unknown : _status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(status.icon, size: 19, color: status.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: FarmTabTheme.font(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: FarmTabTheme.textM,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _statusFailed ? 'Not available' : status.label,
                      style: FarmTabTheme.font(
                        size: 15,
                        weight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
              DeviceStatusBadge(status: status),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _statusFailed
                ? 'Could not check the connection. It will try again in a few seconds.'
                : status.description,
            style: FarmTabTheme.font(
              size: 12.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
              height: 1.4,
            ),
          ),

          if (!_statusFailed && status.state != DeviceState.unknown) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 15,
                  color: FarmTabTheme.textM,
                ),
                const SizedBox(width: 6),
                Text(
                  '${status.readingsLastHour} readings in the last hour',
                  style: FarmTabTheme.font(
                    size: 12,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasLatestReading => !_statusFailed && _status.latest != null;

  // The newest values the device sent
  Widget _buildLatestReadingCard() {
    final latest = _status.latest ?? const <String, dynamic>{};

    String show(dynamic value, int decimals) {
      final number = value is num ? value : num.tryParse('$value');

      return number == null ? '--' : number.toStringAsFixed(decimals);
    }

    Widget tile(IconData icon, String label, String value, String unit) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: FarmTabTheme.grove),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: FarmTabTheme.font(
                      size: 11,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: FarmTabTheme.font(
                    size: 10.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              tile(Icons.science_rounded, 'pH', show(latest['ph'], 2), ''),
              const SizedBox(width: 8),
              tile(
                Icons.water_drop_rounded,
                'EC',
                show(latest['ec'], 0),
                '\u00B5S/cm',
              ),
              const SizedBox(width: 8),
              tile(
                Icons.thermostat_rounded,
                'Temp',
                show(latest['temperature'], 1),
                '\u00B0C',
              ),
              const SizedBox(width: 8),
              tile(Icons.bolt_rounded, 'ORP', show(latest['orp'], 0), 'mV'),
            ],
          ),

          if (_status.lastReadingAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Received ${_formatTime(_status.lastReadingAt!)}',
              style: FarmTabTheme.font(
                size: 11.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
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

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '${time.day} ${months[time.month - 1]}, $hour:$minute:$second $period';
  }
}
