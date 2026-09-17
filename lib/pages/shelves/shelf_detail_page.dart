// import 'package:flutter/material.dart';

// import 'edit_shelf_page.dart';

// class ShelfDetailPage extends StatefulWidget {
//   final Map<String, dynamic> shelf;
//   final Map<String, dynamic> organisation;

//   const ShelfDetailPage({
//     super.key,
//     required this.shelf,
//     required this.organisation,
//   });

//   @override
//   State<ShelfDetailPage> createState() => _ShelfDetailPageState();
// }

// class _ShelfDetailPageState extends State<ShelfDetailPage> {
//   static const String baseUrl = 'http://98.88.222.75:8000';

//   @override
//   Widget build(BuildContext context) {
//     final shelf = widget.shelf;
//     final organisation = widget.organisation;

//     final imagePath = shelf['image'];

//     return Scaffold(
//       appBar: AppBar(title: Text(shelf['name'] ?? 'Shelf Details')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =========================
//             // Shelf Image
//             // =========================

//             if (imagePath != null && imagePath.toString().isNotEmpty)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   '$baseUrl$imagePath',
//                   width: double.infinity,
//                   height: 220,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 220,
//                       width: double.infinity,
//                       color: Colors.grey.shade200,
//                       child: const Icon(Icons.image_not_supported, size: 60),
//                     );
//                   },
//                 ),
//               ),

//             const SizedBox(height: 20),

//             // =========================
//             // Shelf Name
//             // =========================
//             Text(
//               shelf['name'] ?? 'Unnamed Shelf',
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 6),

//             // =========================
//             // Crop Type
//             // =========================
//             Text(
//               shelf['crop_type'] ?? '',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.green,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             const SizedBox(height: 20),

//             // =========================
//             // Shelf Information
//             // =========================
//             _buildInfoCard(
//               title: 'Shelf Information',
//               children: [
//                 _buildInfoRow('Description', shelf['description'] ?? '-'),
//                 _buildInfoRow(
//                   'Device Serial Number',
//                   shelf['device_serial_number'] ?? '-',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // =========================
//             // Current Sensor Data
//             // =========================
//             _buildInfoCard(
//               title: 'Current Sensor Data',
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildSensorCard(
//                         icon: Icons.water_drop,
//                         label: 'pH',
//                         value: '--',
//                         unit: '',
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildSensorCard(
//                         icon: Icons.science,
//                         label: 'EC',
//                         value: '--',
//                         unit: 'mS/cm',
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildSensorCard(
//                         icon: Icons.bolt,
//                         label: 'ORP',
//                         value: '--',
//                         unit: 'mV',
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildSensorCard(
//                         icon: Icons.thermostat,
//                         label: 'Temperature',
//                         value: '--',
//                         unit: '°C',
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // =========================
//             // Thresholds
//             // =========================
//             _buildInfoCard(
//               title: 'Thresholds',
//               children: [
//                 _buildInfoRow(
//                   'pH',
//                   '${shelf['ph_min'] ?? '--'} - ${shelf['ph_max'] ?? '--'}',
//                 ),
//                 _buildInfoRow(
//                   'EC',
//                   '${shelf['ec_min'] ?? '--'} - ${shelf['ec_max'] ?? '--'} mS/cm',
//                 ),
//                 _buildInfoRow(
//                   'ORP',
//                   '${shelf['orp_min'] ?? '--'} - ${shelf['orp_max'] ?? '--'} mV',
//                 ),
//                 _buildInfoRow(
//                   'Temperature',
//                   '${shelf['temperature_min'] ?? '--'} - ${shelf['temperature_max'] ?? '--'} °C',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // =========================
//             // Admin Controls
//             // =========================
//             if (organisation['role'] == 'ADMIN')
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditShelfPage(
//                           shelf: shelf,
//                           organisation: organisation,
//                         ),
//                       ),
//                     );

//                     if (!mounted) return;

//                     // Rebuild the page using the
//                     // updated shelf Map.
//                     setState(() {});
//                   },
//                   icon: const Icon(Icons.edit),
//                   label: const Text('Edit Shelf'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================================================
//   // Information Card
//   // =========================================================

//   Widget _buildInfoCard({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================================================
//   // Information Row
//   // =========================================================

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 150,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   // =========================================================
//   // Sensor Card
//   // =========================================================

//   Widget _buildSensorCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required String unit,
//   }) {
//     return Card(
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Icon(icon, size: 30),
//             const SizedBox(height: 8),
//             Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             if (unit.isNotEmpty)
//               Text(unit, style: const TextStyle(fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../services/shelf_service.dart';
import 'edit_shelf_page.dart';

class ShelfDetailPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;

  const ShelfDetailPage({
    super.key,
    required this.shelf,
    required this.organisation,
  });

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  final ShelfService _shelfService = ShelfService();

  static const String baseUrl = 'http://98.88.222.75:8000';

  Map<String, dynamic>? _latestSensorReading;

  bool _isLoadingSensor = true;
  String? _sensorError;

  @override
  void initState() {
    super.initState();

    _loadLatestSensorReading();
  }

  // =========================================================
  // Load Latest Sensor Reading
  // =========================================================

  Future<void> _loadLatestSensorReading() async {
    try {
      final reading = await _shelfService.getLatestSensorReading(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      setState(() {
        _latestSensorReading = reading;
        _isLoadingSensor = false;
        _sensorError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSensor = false;
        _sensorError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // =========================================================
  // Refresh Sensor Reading
  // =========================================================

  Future<void> _refreshSensorReading() async {
    setState(() {
      _isLoadingSensor = true;
    });

    await _loadLatestSensorReading();
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.shelf['image'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.shelf['name'] ?? 'Shelf Details')),

      body: RefreshIndicator(
        onRefresh: _refreshSensorReading,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // Shelf Image
              // =================================================

              if (imagePath != null && imagePath.toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    '$baseUrl$imagePath',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 60),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // =================================================
              // Shelf Name
              // =================================================
              Text(
                widget.shelf['name'] ?? 'Unnamed Shelf',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // =================================================
              // Crop Type
              // =================================================
              Text(
                widget.shelf['crop_type'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // Shelf Information
              // =================================================
              _buildInfoCard(
                title: 'Shelf Information',
                children: [
                  _buildInfoRow(
                    'Description',
                    widget.shelf['description'] ?? '-',
                  ),
                  _buildInfoRow(
                    'Device Serial Number',
                    widget.shelf['device_serial_number'] ?? '-',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // Current Sensor Data
              // =================================================
              _buildInfoCard(
                title: 'Current Sensor Data',
                children: [
                  if (_isLoadingSensor)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_sensorError != null)
                    _buildSensorError()
                  else
                    _buildSensorData(),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // Thresholds
              // =================================================
              _buildInfoCard(
                title: 'Thresholds',
                children: [
                  _buildInfoRow(
                    'pH',
                    '${widget.shelf['ph_min'] ?? '--'} - ${widget.shelf['ph_max'] ?? '--'}',
                  ),
                  _buildInfoRow(
                    'EC',
                    '${widget.shelf['ec_min'] ?? '--'} - ${widget.shelf['ec_max'] ?? '--'} mS/cm',
                  ),
                  _buildInfoRow(
                    'ORP',
                    '${widget.shelf['orp_min'] ?? '--'} - ${widget.shelf['orp_max'] ?? '--'} mV',
                  ),
                  _buildInfoRow(
                    'Temperature',
                    '${widget.shelf['temperature_min'] ?? '--'} - ${widget.shelf['temperature_max'] ?? '--'} °C',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // Edit Shelf
              // =================================================
              if (widget.organisation['role'] == 'ADMIN')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditShelfPage(
                            shelf: widget.shelf,
                            organisation: widget.organisation,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      // Rebuild the page using the updated
                      // widget.shelf Map.
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Shelf'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Sensor Data
  // =========================================================

  Widget _buildSensorData() {
    final reading = _latestSensorReading;

    // No reading has been recorded yet.
    if (reading == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'No sensor data available yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                icon: Icons.water_drop,
                label: 'pH',
                value: _formatValue(reading['ph']),
                unit: '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                icon: Icons.science,
                label: 'EC',
                value: _formatValue(reading['ec']),
                unit: 'mS/cm',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                icon: Icons.bolt,
                label: 'ORP',
                value: _formatValue(reading['orp']),
                unit: 'mV',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: _formatValue(reading['temperature']),
                unit: '°C',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (reading['recorded_at'] != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Last updated: ${_formatDateTime(reading['recorded_at'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // Sensor Error
  // =========================================================

  Widget _buildSensorError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 40, color: Colors.red),
        const SizedBox(height: 8),
        Text(
          _sensorError ?? 'Unable to load sensor data.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _refreshSensorReading,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  // =========================================================
  // Format Sensor Value
  // =========================================================

  String _formatValue(dynamic value) {
    if (value == null) {
      return '--';
    }

    if (value is num) {
      return value.toString();
    }

    return value.toString();
  }

  // =========================================================
  // Format Date Time
  // =========================================================

  String _formatDateTime(dynamic value) {
    if (value == null) {
      return '--';
    }

    final dateTime = DateTime.tryParse(value.toString());

    if (dateTime == null) {
      return value.toString();
    }

    final localTime = dateTime.toLocal();

    final year = localTime.year.toString();
    final month = localTime.month.toString().padLeft(2, '0');
    final day = localTime.day.toString().padLeft(2, '0');

    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  // =========================================================
  // Info Card
  // =========================================================

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...children,
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Info Row
  // =========================================================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // =========================================================
  // Sensor Card
  // =========================================================

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
