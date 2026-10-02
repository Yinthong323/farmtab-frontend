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

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: grove,
    foregroundColor: white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: grove,
    side: const BorderSide(color: fern),
    padding: const EdgeInsets.symmetric(vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        borderSide: const BorderSide(color: alertRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: alertRed, width: 1.5),
      ),
    );
  }
}

class DeviceManagementPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;

  const DeviceManagementPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = false,
  });

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final DeviceService _deviceService = DeviceService();

  bool _isChangingDevice = false;

  bool get _isAdmin => widget.organisation['role'] == 'ADMIN';

  String get _deviceSerialNumber {
    final serial = widget.shelf['device_serial_number']?.toString().trim();

    if (serial == null || serial.isEmpty) {
      return 'Not available';
    }

    return serial;
  }

  Future<void> _showChangeDeviceDialog() async {
    final controller = TextEditingController(
      text: widget.shelf['device_serial_number']?.toString() ?? '',
    );

    final newSerialNumber = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final serialNumber = controller.text.trim();

              if (serialNumber.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Device serial number is required.';
                });
                return;
              }

              setDialogState(() {
                isSaving = true;
                errorMessage = null;
              });

              try {
                final siteId = widget.shelf['site_id'];
                final shelfId = widget.shelf['id'];

                await _deviceService.updateDeviceSerialNumber(
                  siteId: siteId,
                  shelfId: shelfId,
                  deviceSerialNumber: serialNumber,
                );

                if (!context.mounted) return;

                Navigator.pop(dialogContext, serialNumber);
              } catch (e) {
                if (!context.mounted) return;

                setDialogState(() {
                  isSaving = false;
                  errorMessage = e.toString().replaceFirst('Exception: ', '');
                });
              }
            }

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
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: FarmTabTheme.grove,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Device',
                    style: FarmTabTheme.font(
                      size: 16.5,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the serial number of the new physical device connected to this shelf.',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textB,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    enabled: !isSaving,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!isSaving) {
                        save();
                      }
                    },
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textH,
                    ),
                    decoration: FarmTabTheme.fieldDecoration(
                      'Device Serial Number',
                      hint: 'e.g. FARM-DEVICE-001',
                    ).copyWith(errorText: errorMessage),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
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
                  style: FarmTabTheme.primaryButton,
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: FarmTabTheme.white,
                          ),
                        )
                      : Text(
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
      },
    );

    controller.dispose();

    if (newSerialNumber == null || !mounted) {
      return;
    }

    setState(() {
      _isChangingDevice = true;

      // Update the same shelf map used by ShelfDetailPage.
      widget.shelf['device_serial_number'] = newSerialNumber;
    });

    setState(() {
      _isChangingDevice = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device changed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (widget.embedded) {
      return Container(color: FarmTabTheme.white, child: content);
    }

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
          'Device Management',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: content,
    );
  }

  Widget _buildContent() {
    final shelfName = widget.shelf['name']?.toString() ?? 'Shelf';
    final cropType = widget.shelf['crop_type']?.toString() ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectedDeviceCard(),
          const SizedBox(height: 18),
          _buildShelfInformation(shelfName: shelfName, cropType: cropType),
          const SizedBox(height: 24),
          if (_isAdmin) _buildAdminActions(),
        ],
      ),
    );
  }

  Widget _buildConnectedDeviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.devices_rounded,
                  size: 22,
                  color: FarmTabTheme.grove,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Connected Device',
                  style: FarmTabTheme.font(
                    size: 16,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Device Serial Number',
                  textAlign: TextAlign.center,
                  style: FarmTabTheme.font(
                    size: 12,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _deviceSerialNumber,
                  textAlign: TextAlign.center,
                  style: FarmTabTheme.font(
                    size: 19,
                    weight: FontWeight.w700,
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

  Widget _buildShelfInformation({
    required String shelfName,
    required String cropType,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shelf Information',
            style: FarmTabTheme.font(
              size: 15.5,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.view_module_rounded,
            label: 'Shelf',
            value: shelfName,
          ),

          const SizedBox(height: 4),
          const Divider(color: FarmTabTheme.border, height: 20),

          _buildInfoRow(
            icon: Icons.eco_rounded,
            label: 'Crop',
            value: cropType,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FarmTabTheme.mist.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmTabTheme.mint.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Management',
            style: FarmTabTheme.font(
              size: 15.5,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Changing the device replaces the physical device currently connected to this shelf.',
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isChangingDevice ? null : _showChangeDeviceDialog,
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text(
                'Change Device',
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.grove,
                ),
              ),
              style: FarmTabTheme.outlinedButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: FarmTabTheme.textM),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w500,
              color: FarmTabTheme.textM,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: FarmTabTheme.font(
              size: 14,
              weight: FontWeight.w600,
              color: FarmTabTheme.textH,
            ),
          ),
        ),
      ],
    );
  }
}
