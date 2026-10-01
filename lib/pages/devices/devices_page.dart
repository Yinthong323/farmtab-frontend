// import 'package:flutter/material.dart';

// import 'device_detail_page.dart';
// import '../../services/device_service.dart';

// class DevicesPage extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic> organisation;

//   const DevicesPage({
//     super.key,
//     required this.user,
//     required this.organisation,
//   });

//   @override
//   State<DevicesPage> createState() => _DevicesPageState();
// }

// class _DevicesPageState extends State<DevicesPage> {
//   final DeviceService _deviceService = DeviceService();

//   List<Map<String, dynamic>> _devices = [];

//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadDevices();
//   }

//   Future<void> _loadDevices() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final organisationId = widget.organisation['id'];

//       final devices = await _deviceService.getDevices(
//         organisationId: organisationId,
//       );

//       if (!mounted) return;

//       setState(() {
//         _devices = devices;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Connected Devices')),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 60, color: Colors.red),
//               const SizedBox(height: 16),
//               const Text(
//                 'Unable to load devices',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(_errorMessage!, textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _loadDevices,
//                 child: const Text('Try Again'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_devices.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _loadDevices,
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           children: const [
//             SizedBox(height: 180),
//             Center(
//               child: Text(
//                 'No registered devices.',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadDevices,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: _devices.length,
//         itemBuilder: (context, index) {
//           final device = _devices[index];

//           return _buildDeviceCard(device);
//         },
//       ),
//     );
//   }

//   Widget _buildDeviceCard(Map<String, dynamic> device) {
//     final serialNumber =
//         device['device_serial_number']?.toString() ?? 'Unknown';

//     final siteName = device['site_name']?.toString() ?? 'Unknown Site';

//     final shelfName = device['shelf_name']?.toString() ?? 'Unknown Shelf';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 14),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => DeviceDetailPage(
//                 device: device,
//                 organisation: widget.organisation,
//               ),
//             ),
//           );

//           if (!mounted) return;

//           await _loadDevices();
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Colors.green.shade50,
//                     child: Icon(
//                       Icons.devices_outlined,
//                       color: Colors.green.shade700,
//                     ),
//                   ),

//                   const SizedBox(width: 14),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Connected Device',
//                           style: TextStyle(fontSize: 13, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           serialNumber,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 16,
//                     color: Colors.grey,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 18),

//               _buildInfoRow(
//                 icon: Icons.location_city_outlined,
//                 label: 'Site',
//                 value: siteName,
//               ),

//               const SizedBox(height: 10),

//               _buildInfoRow(
//                 icon: Icons.view_module_outlined,
//                 label: 'Shelf',
//                 value: shelfName,
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   Container(
//                     width: 9,
//                     height: 9,
//                     decoration: const BoxDecoration(
//                       color: Colors.grey,
//                       shape: BoxShape.circle,
//                     ),
//                   ),

//                   const SizedBox(width: 8),

//                   Text(
//                     'Connection Status',
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: Colors.grey.shade600),

//         const SizedBox(width: 10),

//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//           ),
//         ),

//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'device_detail_page.dart';
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
}

class DevicesPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> organisation;

  const DevicesPage({
    super.key,
    required this.user,
    required this.organisation,
  });

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final DeviceService _deviceService = DeviceService();

  List<Map<String, dynamic>> _devices = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredDevices {
    if (_searchQuery.trim().isEmpty) return _devices;

    final query = _searchQuery.trim().toLowerCase();

    return _devices.where((device) {
      final serial = (device['device_serial_number'] ?? '')
          .toString()
          .toLowerCase();
      final siteName = (device['site_name'] ?? '').toString().toLowerCase();
      final shelfName = (device['shelf_name'] ?? '').toString().toLowerCase();

      return serial.contains(query) ||
          siteName.contains(query) ||
          shelfName.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final organisationId = widget.organisation['id'];

      final devices = await _deviceService.getDevices(
        organisationId: organisationId,
      );

      if (!mounted) return;

      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────
  // Gradient header with the search box embedded directly into
  // it, matching the Sites page.

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(118),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FarmTabTheme.fern, Color.fromARGB(255, 112, 212, 167)],
          ),
          boxShadow: [
            BoxShadow(
              color: FarmTabTheme.grove.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Title row
                Text(
                  'Connected Devices',
                  style: FarmTabTheme.font(
                    size: 19,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.white,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Search box
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: FarmTabTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textH,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search devices…',
                      hintStyle: FarmTabTheme.font(
                        size: 14,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textM,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: FarmTabTheme.textM,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: FarmTabTheme.textM,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: FarmTabTheme.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: FarmTabTheme.grove,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: FarmTabTheme.alertRed.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: FarmTabTheme.alertRed,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Unable to load devices',
                style: FarmTabTheme.font(
                  size: 17,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textH,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _loadDevices,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                  'Try Again',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmTabTheme.grove,
                  foregroundColor: FarmTabTheme.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_devices.isEmpty) {
      return RefreshIndicator(
        color: FarmTabTheme.grove,
        onRefresh: _loadDevices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 140),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: FarmTabTheme.mist,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.devices_other_rounded,
                      size: 36,
                      color: FarmTabTheme.fern,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Registered Devices',
                    style: FarmTabTheme.font(
                      size: 18,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Devices connected to your shelves\nwill appear here.',
                    textAlign: TextAlign.center,
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: FarmTabTheme.grove,
      onRefresh: _loadDevices,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                '${_filteredDevices.length} device(s)',
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
          ),

          if (_filteredDevices.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 26,
                          color: FarmTabTheme.textM,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No matching devices',
                        style: FarmTabTheme.font(
                          size: 15,
                          weight: FontWeight.w600,
                          color: FarmTabTheme.textH,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Try a different keyword',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textM,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDeviceCard(_filteredDevices[index]),
                  ),
                  childCount: _filteredDevices.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final serialNumber =
        device['device_serial_number']?.toString() ?? 'Unknown';

    final siteName = device['site_name']?.toString() ?? 'Unknown Site';

    final shelfName = device['shelf_name']?.toString() ?? 'Unknown Shelf';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceDetailPage(
              device: device,
              organisation: widget.organisation,
            ),
          ),
        );

        if (!mounted) return;

        await _loadDevices();
      },
      child: Container(
        decoration: FarmTabTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [FarmTabTheme.fern, FarmTabTheme.grove],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FarmTabTheme.fern.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.devices_rounded,
                    size: 20,
                    color: FarmTabTheme.white,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Device',
                        style: FarmTabTheme.font(
                          size: 11.5,
                          weight: FontWeight.w500,
                          color: FarmTabTheme.textM,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        serialNumber,
                        style: FarmTabTheme.font(
                          size: 16.5,
                          weight: FontWeight.w700,
                          color: FarmTabTheme.textH,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status badge — sits where the chevron used to be.
                _buildConnectionStatusBadge(),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: FarmTabTheme.border, height: 1),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.location_city_rounded,
                    label: siteName,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.view_module_rounded,
                    label: shelfName,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Connection status — real telemetry isn't wired up yet, so
  // every device shows Offline in an attention colour. Swap the
  // colour/text here once live status is available.
  // ------------------------------------------------------------
  Widget _buildConnectionStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: FarmTabTheme.alertRed.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FarmTabTheme.alertRed.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: FarmTabTheme.alertRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: FarmTabTheme.font(
              size: 11.5,
              weight: FontWeight.w700,
              color: FarmTabTheme.alertRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: FarmTabTheme.grove),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmTabTheme.font(
                size: 12.5,
                weight: FontWeight.w600,
                color: FarmTabTheme.textH,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
