// import 'package:flutter/material.dart';

// import '../../services/device_service.dart';

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
//           title: const Text('Edit Device'),
//           content: TextField(
//             controller: controller,
//             decoration: const InputDecoration(
//               labelText: 'Device Serial Number',
//               hintText: 'Enter device serial number',
//               border: OutlineInputBorder(),
//             ),
//             textInputAction: TextInputAction.done,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final value = controller.text.trim();

//                 if (value.isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(context, value);
//               },
//               child: const Text('Save'),
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
//       appBar: AppBar(title: const Text('Connected Device')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 42,
//                 child: const Icon(Icons.devices, size: 42),
//               ),
//             ),

//             const SizedBox(height: 24),

//             const Text(
//               'Connected Device',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 16),

//             _buildInfoCard(
//               icon: Icons.qr_code,
//               title: 'Serial Number',
//               value: _deviceSerialNumber,
//             ),

//             const SizedBox(height: 12),

//             _buildInfoCard(icon: Icons.eco, title: 'Site', value: siteName),

//             const SizedBox(height: 12),

//             _buildInfoCard(
//               icon: Icons.view_module,
//               title: 'Shelf',
//               value: shelfName,
//             ),

//             const SizedBox(height: 12),

//             _buildInfoCard(
//               icon: Icons.circle,
//               title: 'Connection Status',
//               value: 'Not connected',
//             ),

//             const SizedBox(height: 28),

//             if (_isAdmin)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _isUpdating ? null : _editDevice,
//                   icon: _isUpdating
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.edit),
//                   label: Text(_isUpdating ? 'Updating...' : 'Change Device'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.green, size: 28),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
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
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  const DeviceDetailPage({
    super.key,
    required this.device,
    required this.organisation,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final DeviceService _deviceService = DeviceService();

  late String _deviceSerialNumber;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _deviceSerialNumber =
        widget.device['device_serial_number']?.toString() ?? '';
  }

  bool get _isAdmin {
    return widget.organisation['role'] == 'ADMIN';
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

            const SizedBox(height: 10),

            _buildConnectionStatusCard(),

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
  // Connection status — no live telemetry wired up yet, so this
  // shows as an attention-coloured "Offline" state. Swap the
  // colour/icon/text here once real device status is available.
  // ------------------------------------------------------------
  Widget _buildConnectionStatusCard() {
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
              color: FarmTabTheme.alertRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 19,
              color: FarmTabTheme.alertRed,
            ),
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
                  'Offline',
                  style: FarmTabTheme.font(
                    size: 15,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.alertRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
