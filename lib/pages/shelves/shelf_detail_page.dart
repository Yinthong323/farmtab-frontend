// import 'dart:convert';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:fl_chart/fl_chart.dart';

// import 'device_management_page.dart';
// import 'threshold_settings_page.dart';
// import 'shelf_settings_page.dart';
// import 'ai_assistant_page.dart';
// import '../../services/growing_cycle_service.dart';
// import '../../services/shelf_service.dart';
// import '../notifications/shelf_notifications_page.dart';
// import '../../services/notification_service.dart';

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
//   static const Color amber = Color(0xFFF4A261);
//   static const Color skyBlue = Color(0xFF457B9D);

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
//     padding: const EdgeInsets.symmetric(vertical: 13),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   );

//   static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
//     foregroundColor: grove,
//     side: const BorderSide(color: fern),
//     padding: const EdgeInsets.symmetric(vertical: 13),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   );

//   static ButtonStyle dangerOutlinedButton = OutlinedButton.styleFrom(
//     foregroundColor: alertRed,
//     side: const BorderSide(color: Color(0xFFF4B9BE)),
//     padding: const EdgeInsets.symmetric(vertical: 13),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   );
// }

// enum ShelfFunction {
//   sensorMonitoring,
//   thresholdSettings,
//   shelfSettings,
//   growthMonitoring,
//   simulation,
//   aiAssistant,
//   deviceManagement,
// }

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

// class _ShelfDetailPageState extends State<ShelfDetailPage>
//     with SingleTickerProviderStateMixin {
//   final ShelfService _shelfService = ShelfService();
//   final GrowingCycleService _growingCycleService = GrowingCycleService();

//   static const String baseUrl = 'http://98.88.222.75:8000';

//   WebSocketChannel? _sensorChannel;

//   Map<String, dynamic>? _latestSensorReading;
//   Map<String, dynamic>? _activeGrowingCycle;

//   bool _isLoadingGrowingCycle = true;
//   String? _growingCycleError;

//   bool _isLoadingSensor = true;
//   bool _isSensorLive = false;
//   bool _isConnectingSensor = true;
//   DateTime _historyStartDate = DateTime.now();
//   DateTime _historyEndDate = DateTime.now();

//   int _historyIntervalMinutes = 60;

//   bool _isLoadingHistory = false;
//   String? _historyError;

//   List<Map<String, dynamic>> _sensorHistory = [];

//   int _selectedHistorySensor = 0;

//   String? _sensorError;

//   final NotificationService _notificationService = NotificationService();

//   bool _hasUnreadNotifications = false;

//   late TabController _sensorTabController;

//   Map<String, dynamic>? _shelfThresholds;

//   // ------------------------------------------------------------
//   // Shelf function navigation
//   // ------------------------------------------------------------

//   ShelfFunction _selectedFunction = ShelfFunction.sensorMonitoring;

//   // ------------------------------------------------------------
//   // Calibration state
//   // ------------------------------------------------------------

//   bool _isCalibrationOpen = false;
//   bool _isCalibrationRunning = false;

//   String? _calibrationSensor;
//   double? _calibrationReferenceValue;

//   final TextEditingController _referenceController = TextEditingController();

//   // ------------------------------------------------------------
//   // Lifecycle
//   // ------------------------------------------------------------

//   @override
//   void initState() {
//     super.initState();

//     _sensorTabController = TabController(length: 2, vsync: this);

//     _sensorTabController.addListener(() {
//       if (_sensorTabController.index == 1 &&
//           !_isLoadingHistory &&
//           _sensorHistory.isEmpty &&
//           _historyError == null) {
//         _loadSensorHistory();
//       }
//     });

//     _loadLatestSensorReading();
//     _loadActiveGrowingCycle();
//     _loadShelfThresholdsForStatus();
//     _connectSensorWebSocket();
//     _loadUnreadNotificationStatus();
//   }

//   @override
//   void dispose() {
//     _sensorTabController.dispose();
//     _sensorChannel?.sink.close();
//     _referenceController.dispose();

//     super.dispose();
//   }

//   Future<void> _loadUnreadNotificationStatus() async {
//     try {
//       final notifications = await _notificationService.getShelfNotifications(
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       final hasUnread = notifications.any(
//         (notification) => notification['is_read'] == false,
//       );

//       setState(() {
//         _hasUnreadNotifications = hasUnread;
//       });
//     } catch (_) {
//       // Do not interrupt the Shelf Detail page
//       // if notification loading fails.
//     }
//   }

//   // ------------------------------------------------------------
//   // Sensor data
//   // ------------------------------------------------------------

//   Future<void> _loadLatestSensorReading() async {
//     try {
//       final reading = await _shelfService.getLatestSensorReading(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _latestSensorReading = reading;
//         _isLoadingSensor = false;
//         _sensorError = null;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoadingSensor = false;
//         _sensorError = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   // ------------------------------------------------------------
//   // Loads this shelf's threshold min/max values so the sensor
//   // cards can show a "Too High / Too Low / Normal" badge. This is
//   // the same data the Start Growing Cycle flow already fetches —
//   // we just also grab it here, right when the page opens, so the
//   // badges have something to compare against immediately.
//   // ------------------------------------------------------------
//   Future<void> _loadShelfThresholdsForStatus() async {
//     try {
//       final shelf = await _shelfService.getShelf(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _shelfThresholds = shelf;
//       });
//     } catch (e) {
//       // Quietly skip — if thresholds can't be loaded, the sensor
//       // cards simply won't show a status badge (no crash).
//       debugPrint('Unable to load shelf thresholds: $e');
//     }
//   }

//   // ------------------------------------------------------------
//   // Compares a live sensor value against this shelf's threshold
//   // min/max, and returns the badge to show — or null if either
//   // the reading or the threshold isn't available.
//   // ------------------------------------------------------------
//   ({String label, Color color})? _getSensorStatus({
//     required num? value,
//     required String minKey,
//     required String maxKey,
//   }) {
//     if (value == null || _shelfThresholds == null) return null;

//     final min = _shelfThresholds![minKey];
//     final max = _shelfThresholds![maxKey];

//     final minValue = min is num ? min.toDouble() : double.tryParse('$min');
//     final maxValue = max is num ? max.toDouble() : double.tryParse('$max');

//     if (minValue == null || maxValue == null) return null;

//     if (value > maxValue) {
//       return (label: 'Too High', color: FarmTabTheme.alertRed);
//     }

//     if (value < minValue) {
//       return (label: 'Too Low', color: FarmTabTheme.alertRed);
//     }

//     return (label: 'Normal', color: FarmTabTheme.grove);
//   }

//   Future<void> _loadSensorHistory() async {
//     setState(() {
//       _isLoadingHistory = true;
//       _historyError = null;
//     });

//     try {
//       final history = await _shelfService.getSensorHistory(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//         startDate: _historyStartDate,
//         endDate: _historyEndDate,
//         intervalMinutes: _historyIntervalMinutes,
//       );
//       if (!mounted) return;

//       setState(() {
//         _sensorHistory = history;
//         _isLoadingHistory = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoadingHistory = false;
//         _historyError = e.toString();
//         _sensorHistory = [];
//       });
//     }
//   }

//   Future<void> _refreshSensorReading() async {
//     // Keep the current sensor values visible while refreshing.
//     await _loadLatestSensorReading();
//   }

//   Future<void> _loadActiveGrowingCycle() async {
//     try {
//       final cycle = await _growingCycleService.getActiveGrowingCycle(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _activeGrowingCycle = cycle;
//         _isLoadingGrowingCycle = false;
//         _growingCycleError = null;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoadingGrowingCycle = false;
//         _growingCycleError = e.toString().replaceFirst('Exception: ', '');
//       });
//     }
//   }

//   // ------------------------------------------------------------
//   // WebSocket
//   // ------------------------------------------------------------

//   Future<void> _connectSensorWebSocket() async {
//     try {
//       setState(() {
//         _isConnectingSensor = true;
//       });

//       final prefs = await SharedPreferences.getInstance();

//       final token = prefs.getString('access_token');

//       if (token == null || token.isEmpty) {
//         throw Exception('Access token not found. Please login again.');
//       }

//       final siteId = widget.shelf['site_id'];
//       final shelfId = widget.shelf['id'];

//       final uri = Uri.parse(
//         'ws://98.88.222.75:8000/ws/sites/$siteId/shelves/$shelfId/sensor',
//       );

//       final channel = WebSocketChannel.connect(uri);

//       _sensorChannel = channel;

//       channel.stream.listen(
//         (message) {
//           try {
//             final data = jsonDecode(message.toString());

//             if (!mounted) return;

//             setState(() {
//               _latestSensorReading = Map<String, dynamic>.from(data);

//               _isLoadingSensor = false;
//               _sensorError = null;
//               _isSensorLive = true;
//               _isConnectingSensor = false;
//             });
//           } catch (e) {
//             debugPrint('Invalid WebSocket message: $e');
//           }
//         },
//         onError: (error) {
//           debugPrint('Sensor WebSocket error: $error');

//           if (!mounted) return;

//           setState(() {
//             _isSensorLive = false;
//             _isConnectingSensor = false;
//           });
//         },
//         onDone: () {
//           debugPrint('Sensor WebSocket connection closed.');

//           if (!mounted) return;

//           setState(() {
//             _isSensorLive = false;
//             _isConnectingSensor = false;
//           });
//         },
//       );
//     } catch (e) {
//       debugPrint('Failed to connect to sensor WebSocket: $e');

//       if (!mounted) return;

//       setState(() {
//         _isSensorLive = false;
//         _isConnectingSensor = false;
//       });
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final shelfName = widget.shelf['name']?.toString() ?? 'Shelf';

//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       appBar: _buildAppBar(shelfName),
//       body: Column(
//         children: [
//           _buildFunctionHeader(),
//           Expanded(child: _buildSelectedFunction()),
//         ],
//       ),
//     );
//   }

//   // ── APP BAR ────────────────────────────────────────────────
//   // Gradient header with rounded bottom corners (top stays square),
//   // matching the rest of the app's design system.

//   PreferredSizeWidget _buildAppBar(String shelfName) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 3,
//       shadowColor: FarmTabTheme.fern.withOpacity(0.35),
//       scrolledUnderElevation: 3,
//       centerTitle: false,
//       titleSpacing: 0,
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
//         shelfName,
//         style: FarmTabTheme.font(
//           size: 17,
//           weight: FontWeight.w700,
//           color: FarmTabTheme.white,
//           letterSpacing: -0.2,
//         ),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       actions: [
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(10),
//                 onTap: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ShelfNotificationsPage(
//                         shelfId: widget.shelf['id'],
//                         shelfName: widget.shelf['name'],
//                       ),
//                     ),
//                   );

//                   // Refresh unread status after returning
//                   _loadUnreadNotificationStatus();
//                 },
//                 child: Container(
//                   width: 38,
//                   height: 38,
//                   margin: const EdgeInsets.only(right: 6),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.16),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.white.withOpacity(0.25)),
//                   ),
//                   child: const Icon(
//                     Icons.notifications_none_rounded,
//                     size: 19,
//                     color: FarmTabTheme.white,
//                   ),
//                 ),
//               ),
//             ),

//             if (_hasUnreadNotifications)
//               Positioned(
//                 right: 1,
//                 top: -2,
//                 child: Container(
//                   width: 9,
//                   height: 9,
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: FarmTabTheme.white, width: 1.5),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: _showMoreMenu,
//             child: Container(
//               width: 38,
//               height: 38,
//               margin: const EdgeInsets.only(right: 14),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.16),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.white.withOpacity(0.25)),
//               ),
//               child: const Icon(
//                 Icons.apps_rounded,
//                 size: 19,
//                 color: FarmTabTheme.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFunctionHeader() {
//     String title;
//     IconData icon;

//     switch (_selectedFunction) {
//       case ShelfFunction.sensorMonitoring:
//         title = 'Sensor Monitoring';
//         icon = Icons.sensors_rounded;
//         break;

//       case ShelfFunction.thresholdSettings:
//         title = 'Threshold Settings';
//         icon = Icons.tune_rounded;
//         break;

//       case ShelfFunction.shelfSettings:
//         title = 'Shelf Settings';
//         icon = Icons.settings_rounded;
//         break;

//       case ShelfFunction.growthMonitoring:
//         title = 'Growth Monitoring';
//         icon = Icons.eco_rounded;
//         break;

//       case ShelfFunction.simulation:
//         title = 'Simulation';
//         icon = Icons.science_rounded;
//         break;

//       case ShelfFunction.aiAssistant:
//         title = 'AI Assistant';
//         icon = Icons.smart_toy_rounded;
//         break;

//       case ShelfFunction.deviceManagement:
//         title = 'Device Management';
//         icon = Icons.devices_rounded;
//         break;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//       decoration: const BoxDecoration(
//         color: FarmTabTheme.white,
//         border: Border(bottom: BorderSide(color: FarmTabTheme.border)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: FarmTabTheme.mist,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             alignment: Alignment.center,
//             child: Icon(icon, size: 18, color: FarmTabTheme.grove),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: FarmTabTheme.font(
//               size: 16,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // ============================================================
//   // SHELF FUNCTION NAVIGATION
//   // ============================================================

//   Widget _buildSelectedFunction() {
//     switch (_selectedFunction) {
//       case ShelfFunction.sensorMonitoring:
//         return _buildSensorMonitoring();

//       case ShelfFunction.thresholdSettings:
//         return ThresholdSettingsPage(
//           shelf: widget.shelf,
//           organisation: widget.organisation,
//           embedded: true,
//         );

//       case ShelfFunction.shelfSettings:
//         return ShelfSettingsPage(
//           shelf: widget.shelf,
//           organisation: widget.organisation,
//           embedded: true,
//         );

//       case ShelfFunction.growthMonitoring:
//         return _buildComingSoonPage(
//           title: 'Growth Monitoring',
//           icon: Icons.eco_rounded,
//         );

//       case ShelfFunction.simulation:
//         return _buildComingSoonPage(
//           title: 'Simulation',
//           icon: Icons.science_rounded,
//         );

//       case ShelfFunction.aiAssistant:
//         return AiAssistantPage(
//           shelf: widget.shelf,
//           organisation: widget.organisation,
//           embedded: true,
//         );

//       case ShelfFunction.deviceManagement:
//         return DeviceManagementPage(
//           shelf: widget.shelf,
//           organisation: widget.organisation,
//           embedded: true,
//         );
//     }
//   }

//   Widget _buildSensorMonitoring() {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
//           height: 44,
//           padding: const EdgeInsets.all(3),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF2F2F2),
//             borderRadius: BorderRadius.circular(11),
//           ),
//           child: TabBar(
//             controller: _sensorTabController,
//             indicator: BoxDecoration(
//               color: FarmTabTheme.grove,
//               borderRadius: BorderRadius.circular(9),
//             ),
//             indicatorSize: TabBarIndicatorSize.tab,
//             dividerColor: Colors.transparent,
//             labelColor: FarmTabTheme.white,
//             unselectedLabelColor: FarmTabTheme.textM,
//             labelStyle: FarmTabTheme.font(
//               size: 13,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.white,
//             ),
//             unselectedLabelStyle: FarmTabTheme.font(
//               size: 13,
//               weight: FontWeight.w500,
//               color: FarmTabTheme.textM,
//             ),
//             tabs: const [
//               Tab(text: 'Monitor'),
//               Tab(text: 'Trends'),
//             ],
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _sensorTabController,
//             children: [_buildCurrentSensorTab(), _buildHistoryTab()],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildComingSoonPage({required String title, required IconData icon}) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 84,
//               height: 84,
//               decoration: BoxDecoration(
//                 color: FarmTabTheme.mist,
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               child: Icon(icon, size: 38, color: FarmTabTheme.fern),
//             ),
//             const SizedBox(height: 18),
//             Text(
//               title,
//               style: FarmTabTheme.font(
//                 size: 19,
//                 weight: FontWeight.w700,
//                 color: FarmTabTheme.textH,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'This feature will be implemented later.',
//               textAlign: TextAlign.center,
//               style: FarmTabTheme.font(
//                 size: 13,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textM,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CURRENT SENSOR TAB
//   // ============================================================

//   Widget _buildCurrentSensorTab() {
//     return RefreshIndicator(
//       color: FarmTabTheme.grove,
//       onRefresh: _refreshSensorReading,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ----------------------------------------------------
//             // 1. Growing Cycle
//             // ----------------------------------------------------
//             _sectionLabel('Growing Cycle'),

//             const SizedBox(height: 12),

//             _buildGrowingCycleCard(),

//             const SizedBox(height: 24),

//             // ----------------------------------------------------
//             // 2. Current Conditions
//             // ----------------------------------------------------
//             _sectionLabel('Current Conditions'),

//             const SizedBox(height: 12),

//             if (_sensorError != null && _latestSensorReading == null)
//               _buildSensorError()
//             else if (_latestSensorReading != null)
//               _buildSensorData()
//             else
//               _buildSensorLoading(),

//             const SizedBox(height: 24),

//             // ----------------------------------------------------
//             // 3. Device Status
//             // ----------------------------------------------------
//             _buildDeviceStatusCard(),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(String text) {
//     return Text(
//       text,
//       style: FarmTabTheme.font(
//         size: 17,
//         weight: FontWeight.w700,
//         color: FarmTabTheme.textH,
//         letterSpacing: -0.2,
//       ),
//     );
//   }

//   Widget _buildSensorLoading() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 28),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Column(
//         children: [
//           const SizedBox(
//             width: 22,
//             height: 22,
//             child: CircularProgressIndicator(
//               strokeWidth: 2.5,
//               color: FarmTabTheme.grove,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Loading sensor data...',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textM,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // ============================================================
//   // GROWING CYCLE
//   // ============================================================

//   Widget _buildGrowingCycleCard() {
//     if (_isLoadingGrowingCycle) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(18),
//         decoration: FarmTabTheme.cardDecoration,
//         child: Row(
//           children: [
//             const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 color: FarmTabTheme.grove,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Loading growing cycle...',
//               style: FarmTabTheme.font(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textM,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     if (_growingCycleError != null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(18),
//         decoration: FarmTabTheme.cardDecoration,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _growingCycleError!,
//               style: FarmTabTheme.font(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textB,
//               ),
//             ),
//             const SizedBox(height: 14),
//             OutlinedButton(
//               onPressed: _loadActiveGrowingCycle,
//               style: FarmTabTheme.outlinedButton,
//               child: Text(
//                 'Retry',
//                 style: FarmTabTheme.font(
//                   size: 13,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.grove,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final cycle = _activeGrowingCycle;

//     // ------------------------------------------------------------
//     // No active cycle
//     // ------------------------------------------------------------

//     if (cycle == null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: FarmTabTheme.cardDecoration,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     color: FarmTabTheme.mist,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   alignment: Alignment.center,
//                   child: const Icon(
//                     Icons.eco_rounded,
//                     size: 26,
//                     color: FarmTabTheme.fern,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Text(
//                     'No active cycle',
//                     style: FarmTabTheme.font(
//                       size: 15.5,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.textH,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _showCalibrationDialog,
//                     style: FarmTabTheme.outlinedButton,
//                     child: Text(
//                       'Calibration',
//                       style: FarmTabTheme.font(
//                         size: 13,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.grove,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _showStartCycleCalibrationCheck,
//                     style: FarmTabTheme.primaryButton,
//                     child: Text(
//                       'Start Cycle',
//                       style: FarmTabTheme.font(
//                         size: 13,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }

//     // ------------------------------------------------------------
//     // Active cycle
//     // ------------------------------------------------------------

//     final cropType = cycle['crop_type']?.toString() ?? '--';

//     final startDate = cycle['start_date']?.toString() ?? '--';

//     final targetDays = cycle['target_harvest_days'];

//     final targetHarvestDate = cycle['target_harvest_date']?.toString() ?? '--';

//     final parsedStartDate = DateTime.tryParse(startDate);

//     final today = DateTime.now();

//     int growthDay = 1;

//     if (parsedStartDate != null) {
//       final start = DateTime(
//         parsedStartDate.year,
//         parsedStartDate.month,
//         parsedStartDate.day,
//       );

//       final current = DateTime(today.year, today.month, today.day);

//       growthDay = current.difference(start).inDays + 1;

//       if (growthDay < 1) {
//         growthDay = 1;
//       }
//     }

//     double progress = 0;
//     final targetDaysInt = targetDays is int
//         ? targetDays
//         : int.tryParse(targetDays?.toString() ?? '');

//     if (targetDaysInt != null && targetDaysInt > 0) {
//       progress = (growthDay / targetDaysInt).clamp(0.0, 1.0);
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // ── Progress ring
//               _GrowthProgressRing(progress: progress, growthDay: growthDay),

//               const SizedBox(width: 18),

//               // ── Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: FarmTabTheme.mist,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         cropType,
//                         style: FarmTabTheme.font(
//                           size: 11.5,
//                           weight: FontWeight.w700,
//                           color: FarmTabTheme.grove,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Text(
//                       'Day $growthDay of ${targetDaysInt ?? '--'}',
//                       style: FarmTabTheme.font(
//                         size: 16,
//                         weight: FontWeight.w700,
//                         color: FarmTabTheme.textH,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _cycleDateRow(
//                       Icons.play_circle_outline_rounded,
//                       'Started',
//                       _formatCycleDate(startDate),
//                     ),

//                     const SizedBox(height: 4),

//                     _cycleDateRow(
//                       Icons.flag_outlined,
//                       'Target',
//                       _formatCycleDate(targetHarvestDate),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     _showComingSoon('Harvest');
//                   },
//                   style: FarmTabTheme.outlinedButton,
//                   child: Text(
//                     'Harvest',
//                     style: FarmTabTheme.font(
//                       size: 13,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.grove,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => _showStopCycleConfirmation(),
//                   style: FarmTabTheme.dangerOutlinedButton,
//                   child: Text(
//                     'Stop Cycle',
//                     style: FarmTabTheme.font(
//                       size: 13,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.alertRed,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _cycleDateRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 13, color: FarmTabTheme.textM),
//         const SizedBox(width: 6),
//         Text(
//           '$label ',
//           style: FarmTabTheme.font(
//             size: 12.5,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textM,
//           ),
//         ),
//         Text(
//           value,
//           style: FarmTabTheme.font(
//             size: 12.5,
//             weight: FontWeight.w600,
//             color: FarmTabTheme.textB,
//           ),
//         ),
//       ],
//     );
//   }

//   void _showStopCycleConfirmation() {
//     if (_activeGrowingCycle == null) return;

//     final cycleId = _activeGrowingCycle!['id'];

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: FarmTabTheme.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             'Stop Growing Cycle?',
//             style: FarmTabTheme.font(
//               size: 16,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to stop this growing cycle?',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
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
//               style: FarmTabTheme.primaryButton,
//               onPressed: () async {
//                 Navigator.pop(dialogContext);

//                 try {
//                   await _growingCycleService.stopGrowingCycle(
//                     siteId: widget.shelf['site_id'],
//                     shelfId: widget.shelf['id'],
//                     cycleId: cycleId,
//                   );

//                   await _loadActiveGrowingCycle();

//                   if (!mounted) return;

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Growing cycle stopped.')),
//                   );
//                 } catch (e) {
//                   if (!mounted) return;

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to stop cycle: $e')),
//                   );
//                 }
//               },
//               child: Text(
//                 'Stop Cycle',
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
//   }
//   // ============================================================
//   // CURRENT SENSOR DATA
//   // ============================================================

//   Widget _buildSensorData() {
//     final reading = _latestSensorReading;

//     if (reading == null) {
//       return _buildNoSensorData();
//     }

//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildSensorCard(
//                 title: 'pH',
//                 value: _formatSensorValue(reading['ph']),
//                 rawValue: _asNum(reading['ph']),
//                 minKey: 'ph_min',
//                 maxKey: 'ph_max',
//                 unit: '',
//                 icon: Icons.science_rounded,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildSensorCard(
//                 title: 'EC',
//                 value: _formatSensorValue(reading['ec']),
//                 rawValue: _asNum(reading['ec']),
//                 minKey: 'ec_min',
//                 maxKey: 'ec_max',
//                 unit: 'µS/cm',
//                 icon: Icons.water_drop_rounded,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 12),

//         Row(
//           children: [
//             Expanded(
//               child: _buildSensorCard(
//                 title: 'Temperature',
//                 value: _formatSensorValue(reading['temperature']),
//                 rawValue: _asNum(reading['temperature']),
//                 minKey: 'temperature_min',
//                 maxKey: 'temperature_max',
//                 unit: '°C',
//                 icon: Icons.thermostat_rounded,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildSensorCard(
//                 title: 'ORP',
//                 value: _formatSensorValue(reading['orp']),
//                 rawValue: _asNum(reading['orp']),
//                 minKey: 'orp_min',
//                 maxKey: 'orp_max',
//                 unit: 'mV',
//                 icon: Icons.bolt_rounded,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Helper: safely reads a sensor value as a num for comparison,
//   // regardless of whether the backend sent it as a number or a
//   // string.
//   num? _asNum(dynamic value) {
//     if (value == null) return null;
//     if (value is num) return value;
//     return num.tryParse(value.toString());
//   }

//   Widget _buildSensorCard({
//     required String title,
//     required String value,
//     required num? rawValue,
//     required String minKey,
//     required String maxKey,
//     required String unit,
//     required IconData icon,
//   }) {
//     final status = _getSensorStatus(
//       value: rawValue,
//       minKey: minKey,
//       maxKey: maxKey,
//     );

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: FarmTabTheme.mist,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 alignment: Alignment.center,
//                 child: Icon(icon, size: 18, color: FarmTabTheme.grove),
//               ),

//               const Spacer(),

//               // ── Status badge — top-right corner of the card.
//               if (status != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: status.color.withOpacity(0.10),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: status.color.withOpacity(0.25)),
//                   ),
//                   child: Text(
//                     status.label,
//                     style: FarmTabTheme.font(
//                       size: 10.5,
//                       weight: FontWeight.w700,
//                       color: status.color,
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           // ── Title + unit together, so the value below never
//           // has to wrap onto a second line.
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: title,
//                   style: FarmTabTheme.font(
//                     size: 13,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//                 if (unit.isNotEmpty)
//                   TextSpan(
//                     text: ' ($unit)',
//                     style: FarmTabTheme.font(
//                       size: 11.5,
//                       weight: FontWeight.w400,
//                       color: FarmTabTheme.textM,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 4),

//           Text(
//             value,
//             style: FarmTabTheme.font(
//               size: 19,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatSensorValue(dynamic value) {
//     if (value == null) {
//       return '--';
//     }

//     if (value is num) {
//       return value.toStringAsFixed(2);
//     }

//     final parsed = double.tryParse(value.toString());

//     if (parsed != null) {
//       return parsed.toStringAsFixed(2);
//     }

//     return value.toString();
//   }

//   Widget _buildNoSensorData() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: const Color(0xFFF7F7F7),
//       ),
//       child: Center(
//         child: Text(
//           'No sensor data available.',
//           style: FarmTabTheme.font(
//             size: 13.5,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textM,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSensorError() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: const Color(0xFFF7F7F7),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.error_outline_rounded,
//             size: 30,
//             color: FarmTabTheme.alertRed,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             _sensorError ?? 'Unable to load sensor data.',
//             textAlign: TextAlign.center,
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//           const SizedBox(height: 12),
//           OutlinedButton(
//             onPressed: _refreshSensorReading,
//             style: FarmTabTheme.outlinedButton,
//             child: Text(
//               'Retry',
//               style: FarmTabTheme.font(
//                 size: 13,
//                 weight: FontWeight.w600,
//                 color: FarmTabTheme.grove,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // DEVICE STATUS
//   // ============================================================

//   Widget _buildDeviceStatusCard() {
//     String statusText;
//     IconData statusIcon;
//     Color statusColor;

//     if (_isConnectingSensor) {
//       statusText = 'Connecting...';
//       statusIcon = Icons.sync_rounded;
//       statusColor = FarmTabTheme.amber;
//     } else if (_isSensorLive) {
//       statusText = 'Device Online';
//       statusIcon = Icons.wifi_rounded;
//       statusColor = FarmTabTheme.grove;
//     } else {
//       statusText = 'Device Offline';
//       statusIcon = Icons.wifi_off_rounded;
//       statusColor = FarmTabTheme.alertRed;
//     }

//     final recordedAt = _latestSensorReading?['recorded_at'];

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             alignment: Alignment.center,
//             child: Icon(statusIcon, size: 21, color: statusColor),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Device Status',
//                   style: FarmTabTheme.font(
//                     size: 14.5,
//                     weight: FontWeight.w600,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   statusText,
//                   style: FarmTabTheme.font(
//                     size: 13,
//                     weight: FontWeight.w400,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),

//                 if (recordedAt != null) ...[
//                   const SizedBox(height: 3),
//                   Text(
//                     'Last updated: ${_formatRecordedTime(recordedAt)}',
//                     style: FarmTabTheme.font(
//                       size: 11.5,
//                       weight: FontWeight.w400,
//                       color: FarmTabTheme.textM,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatRecordedTime(dynamic recordedAt) {
//     if (recordedAt == null) {
//       return '--';
//     }

//     try {
//       final dateTime = DateTime.parse(recordedAt.toString()).toLocal();

//       final hour = dateTime.hour > 12
//           ? dateTime.hour - 12
//           : dateTime.hour == 0
//           ? 12
//           : dateTime.hour;

//       final minute = dateTime.minute.toString().padLeft(2, '0');

//       final second = dateTime.second.toString().padLeft(2, '0');

//       final period = dateTime.hour >= 12 ? 'PM' : 'AM';

//       return '$hour:$minute:$second $period';
//     } catch (_) {
//       return recordedAt.toString();
//     }
//   }

//   String _formatCycleDate(String date) {
//     final parsed = DateTime.tryParse(date);

//     if (parsed == null) {
//       return date;
//     }

//     return '${parsed.day.toString().padLeft(2, '0')} '
//         '${_monthName(parsed.month)} ${parsed.year}';
//   }

//   String _monthName(int month) {
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

//     return months[month - 1];
//   }
//   // ============================================================
//   // HISTORY
//   // ============================================================

//   Widget _buildHistoryTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionLabel('Date Range'),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _buildHistoryDateButton(
//                   label: 'Start Date',
//                   date: _historyStartDate,
//                   onTap: () => _selectHistoryStartDate(),
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: _buildHistoryDateButton(
//                   label: 'End Date',
//                   date: _historyEndDate,
//                   onTap: () => _selectHistoryEndDate(),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 22),

//           _sectionLabel('Time Interval'),

//           const SizedBox(height: 12),

//           _buildHistoryIntervalDropdown(),

//           const SizedBox(height: 24),

//           _buildHistorySensorTabs(),

//           const SizedBox(height: 16),

//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: FarmTabTheme.cardDecoration,
//             child: _buildHistoryChart(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHistoryDateButton({
//     required String label,
//     required DateTime date,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF7F7F7),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: FarmTabTheme.font(
//                 size: 11.5,
//                 weight: FontWeight.w500,
//                 color: FarmTabTheme.textM,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Row(
//               children: [
//                 const Icon(
//                   Icons.calendar_today_rounded,
//                   size: 15,
//                   color: FarmTabTheme.grove,
//                 ),

//                 const SizedBox(width: 8),

//                 Expanded(
//                   child: Text(
//                     '${date.day.toString().padLeft(2, '0')}/'
//                     '${date.month.toString().padLeft(2, '0')}/'
//                     '${date.year}',
//                     style: FarmTabTheme.font(
//                       size: 14,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.textH,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectHistoryStartDate() async {
//     final selectedDate = await showDatePicker(
//       context: context,
//       initialDate: _historyStartDate,
//       firstDate: DateTime(2020),
//       lastDate: _historyEndDate,
//     );

//     if (selectedDate == null) return;

//     setState(() {
//       _historyStartDate = selectedDate;
//     });

//     await _loadSensorHistory();
//   }

//   Future<void> _selectHistoryEndDate() async {
//     final selectedDate = await showDatePicker(
//       context: context,
//       initialDate: _historyEndDate,
//       firstDate: _historyStartDate,
//       lastDate: DateTime.now(),
//     );

//     if (selectedDate == null) return;

//     setState(() {
//       _historyEndDate = selectedDate;
//     });

//     await _loadSensorHistory();
//   }

//   Widget _buildHistoryIntervalDropdown() {
//     const intervals = [60, 360, 1440];

//     String intervalLabel(int minutes) {
//       if (minutes < 60) {
//         return '$minutes minutes';
//       }

//       if (minutes == 60) {
//         return '1 hour';
//       }

//       if (minutes % 60 == 0) {
//         return '${minutes ~/ 60} hours';
//       }

//       return '$minutes minutes';
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F7F7),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<int>(
//           value: _historyIntervalMinutes,
//           isExpanded: true,
//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: FarmTabTheme.textM,
//           ),
//           style: FarmTabTheme.font(
//             size: 14,
//             weight: FontWeight.w500,
//             color: FarmTabTheme.textH,
//           ),
//           items: intervals.map((interval) {
//             return DropdownMenuItem<int>(
//               value: interval,
//               child: Text(intervalLabel(interval)),
//             );
//           }).toList(),
//           onChanged: (value) async {
//             if (value == null) return;

//             setState(() {
//               _historyIntervalMinutes = value;
//             });

//             await _loadSensorHistory();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHistorySensorTabs() {
//     const sensors = ['pH', 'EC', 'Temp', 'ORP'];

//     return Container(
//       height: 46,
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF2F2F2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: List.generate(sensors.length, (index) {
//           final selected = _selectedHistorySensor == index;

//           return Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedHistorySensor = index;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 margin: const EdgeInsets.symmetric(horizontal: 2),
//                 decoration: BoxDecoration(
//                   color: selected ? FarmTabTheme.grove : Colors.transparent,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   sensors[index],
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w600,
//                     color: selected ? FarmTabTheme.white : FarmTabTheme.textM,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // Picks a "nice" axis interval (in milliseconds) based on the
//   // total selected range, so labels are evenly spaced and never
//   // overlap — independent of how many raw readings came back.
//   // ------------------------------------------------------------
//   double _niceAxisIntervalMs(Duration totalRange) {
//     final hours = totalRange.inMinutes / 60.0;

//     if (hours <= 6) {
//       return const Duration(hours: 1).inMilliseconds.toDouble();
//     } else if (hours <= 24) {
//       return const Duration(hours: 3).inMilliseconds.toDouble();
//     } else if (hours <= 24 * 3) {
//       return const Duration(hours: 12).inMilliseconds.toDouble();
//     } else if (hours <= 24 * 10) {
//       return const Duration(days: 1).inMilliseconds.toDouble();
//     } else if (hours <= 24 * 30) {
//       return const Duration(days: 3).inMilliseconds.toDouble();
//     } else {
//       return const Duration(days: 7).inMilliseconds.toDouble();
//     }
//   }

//   Widget _buildHistoryChart() {
//     if (_isLoadingHistory) {
//       return const SizedBox(
//         height: 300,
//         child: Center(
//           child: CircularProgressIndicator(color: FarmTabTheme.grove),
//         ),
//       );
//     }

//     if (_historyError != null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         child: Text(
//           _historyError!,
//           textAlign: TextAlign.center,
//           style: FarmTabTheme.font(
//             size: 13,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textB,
//           ),
//         ),
//       );
//     }

//     if (_sensorHistory.isEmpty) {
//       return Container(
//         width: double.infinity,
//         height: 250,
//         alignment: Alignment.center,
//         child: Text(
//           'No sensor data available for this date range.',
//           style: FarmTabTheme.font(
//             size: 13,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textM,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       );
//     }

//     final sensorKey = switch (_selectedHistorySensor) {
//       0 => 'ph',
//       1 => 'ec',
//       2 => 'temperature',
//       3 => 'orp',
//       _ => 'ph',
//     };

//     final sensorName = switch (_selectedHistorySensor) {
//       0 => 'pH',
//       1 => 'EC',
//       2 => 'Temperature',
//       3 => 'ORP',
//       _ => 'pH',
//     };

//     final sensorUnit = switch (_selectedHistorySensor) {
//       0 => '',
//       1 => 'µS/cm',
//       2 => '°C',
//       3 => 'mV',
//       _ => '',
//     };

//     final spots = <FlSpot>[];

//     for (int i = 0; i < _sensorHistory.length; i++) {
//       final reading = _sensorHistory[i];

//       final recordedAt = DateTime.tryParse(
//         reading['recorded_at']?.toString() ?? '',
//       );

//       final value = double.tryParse(reading[sensorKey]?.toString() ?? '');

//       if (recordedAt == null || value == null) {
//         continue;
//       }

//       spots.add(FlSpot(recordedAt.millisecondsSinceEpoch.toDouble(), value));
//     }

//     if (spots.isEmpty) {
//       return Container(
//         width: double.infinity,
//         height: 250,
//         alignment: Alignment.center,
//         child: Text(
//           'No valid sensor data available.',
//           style: FarmTabTheme.font(
//             size: 13,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textM,
//           ),
//         ),
//       );
//     }

//     final values = spots.map((spot) => spot.y).toList();

//     double minY = values.reduce((a, b) => a < b ? a : b);
//     double maxY = values.reduce((a, b) => a > b ? a : b);

//     if (minY == maxY) {
//       minY -= 1;
//       maxY += 1;
//     } else {
//       final padding = (maxY - minY) * 0.22;
//       minY -= padding;
//       maxY += padding;
//     }

//     // ------------------------------------------------------------
//     // Axis range: always spans exactly the selected date range,
//     // starting at 00:00 of the start date, so the first tick the
//     // user sees on the left is midnight of the start date.
//     // ------------------------------------------------------------
//     final rangeStart = DateTime(
//       _historyStartDate.year,
//       _historyStartDate.month,
//       _historyStartDate.day,
//     );
//     final rangeEnd = DateTime(
//       _historyEndDate.year,
//       _historyEndDate.month,
//       _historyEndDate.day,
//       23,
//       59,
//       59,
//     );
//     final totalRange = rangeEnd.difference(rangeStart);

//     final minX = rangeStart.millisecondsSinceEpoch.toDouble();
//     final maxX = rangeEnd.millisecondsSinceEpoch.toDouble();

//     final axisIntervalMs = _niceAxisIntervalMs(totalRange);

//     // ------------------------------------------------------------
//     // Chart width scales with how many ticks the range will need,
//     // so short ranges fit the screen and long ranges scroll
//     // horizontally instead of squeezing labels on top of each
//     // other.
//     // ------------------------------------------------------------
//     final tickCount = (totalRange.inMilliseconds / axisIntervalMs).ceil();
//     const pixelsPerTick = 110.0;
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final availableWidth = screenWidth - 100; // card padding + axis labels
//     final chartWidth = math.max(availableWidth, tickCount * pixelsPerTick);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               sensorName,
//               style: FarmTabTheme.font(
//                 size: 15,
//                 weight: FontWeight.w700,
//                 color: FarmTabTheme.textH,
//               ),
//             ),
//             if (sensorUnit.isNotEmpty) ...[
//               const SizedBox(width: 5),
//               Text(
//                 '($sensorUnit)',
//                 style: FarmTabTheme.font(
//                   size: 12,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ],
//             const Spacer(),
//             if (chartWidth > availableWidth)
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.swipe_rounded,
//                     size: 14,
//                     color: FarmTabTheme.textM,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Scroll to explore',
//                     style: FarmTabTheme.font(
//                       size: 11,
//                       weight: FontWeight.w500,
//                       color: FarmTabTheme.textM,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),

//         const SizedBox(height: 14),

//         SizedBox(
//           height: 340,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SizedBox(
//               width: chartWidth,
//               height: 340,
//               child: LineChart(
//                 LineChartData(
//                   minX: minX,
//                   maxX: maxX,
//                   minY: minY,
//                   maxY: maxY,

//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: true,
//                     verticalInterval: axisIntervalMs,
//                     horizontalInterval: (maxY - minY) / 4,
//                     getDrawingHorizontalLine: (value) =>
//                         FlLine(color: FarmTabTheme.border, strokeWidth: 1),
//                     getDrawingVerticalLine: (value) =>
//                         FlLine(color: FarmTabTheme.border, strokeWidth: 1),
//                   ),

//                   borderData: FlBorderData(
//                     show: true,
//                     border: const Border(
//                       left: BorderSide(color: FarmTabTheme.border),
//                       bottom: BorderSide(color: FarmTabTheme.border),
//                     ),
//                   ),

//                   titlesData: FlTitlesData(
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),

//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 54,
//                         interval: (maxY - minY) / 4,
//                         getTitlesWidget: (value, meta) {
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 6),
//                             child: Text(
//                               value.toStringAsFixed(1),
//                               style: FarmTabTheme.font(
//                                 size: 10.5,
//                                 weight: FontWeight.w400,
//                                 color: FarmTabTheme.textM,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                         interval: axisIntervalMs,
//                         getTitlesWidget: (value, meta) {
//                           final dateTime = DateTime.fromMillisecondsSinceEpoch(
//                             value.toInt(),
//                           ).toLocal();

//                           return SideTitleWidget(
//                             meta: meta,
//                             child: Text(
//                               _formatHistoryXAxisLabel(dateTime),
//                               style: FarmTabTheme.font(
//                                 size: 10,
//                                 weight: FontWeight.w400,
//                                 color: FarmTabTheme.textM,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   lineTouchData: LineTouchData(
//                     enabled: true,
//                     touchTooltipData: LineTouchTooltipData(
//                       // Keeps the tooltip fully inside the chart's
//                       // drawing area, nudging it down/sideways when
//                       // the touched point is close to an edge —
//                       // this is what stops the tooltip from getting
//                       // clipped off when a point is near the top.
//                       fitInsideVertically: true,
//                       fitInsideHorizontally: true,
//                       getTooltipItems: (touchedSpots) {
//                         return touchedSpots.map((spot) {
//                           final dateTime = DateTime.fromMillisecondsSinceEpoch(
//                             spot.x.toInt(),
//                           ).toLocal();

//                           return LineTooltipItem(
//                             '${_formatHistoryTooltipDate(dateTime)}\n'
//                             '${spot.y.toStringAsFixed(2)}'
//                             '${sensorUnit.isNotEmpty ? ' $sensorUnit' : ''}',
//                             FarmTabTheme.font(
//                               size: 12,
//                               weight: FontWeight.w600,
//                               color: FarmTabTheme.white,
//                             ),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),

//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: spots,
//                       isCurved: true,
//                       curveSmoothness: 0.2,
//                       color: FarmTabTheme.grove,
//                       barWidth: 2.5,
//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (spot, percent, bar, index) {
//                           return FlDotCirclePainter(
//                             radius: 3,
//                             color: FarmTabTheme.grove,
//                             strokeWidth: 1.5,
//                             strokeColor: FarmTabTheme.white,
//                           );
//                         },
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             FarmTabTheme.mint.withOpacity(0.35),
//                             FarmTabTheme.mint.withOpacity(0.0),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatHistoryXAxisLabel(DateTime dateTime) {
//     final sameDay =
//         _historyStartDate.year == _historyEndDate.year &&
//         _historyStartDate.month == _historyEndDate.month &&
//         _historyStartDate.day == _historyEndDate.day;

//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');

//     if (sameDay) {
//       // Single-day range: just the time.
//       return '$hour:$minute';
//     }

//     // Multi-day range: always a single, compact line — never two
//     // lines, since a wrapped label is what was overflowing into
//     // its neighbour and causing the overlap you saw.
//     final dateLabel =
//         '${dateTime.day.toString().padLeft(2, '0')}/'
//         '${dateTime.month.toString().padLeft(2, '0')}';

//     final isMidnight = dateTime.hour == 0 && dateTime.minute == 0;

//     if (isMidnight) {
//       return dateLabel;
//     }

//     return '$dateLabel $hour:$minute';
//   }

//   String _formatHistoryTooltipDate(DateTime dateTime) {
//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');

//     return '${dateTime.day.toString().padLeft(2, '0')}/'
//         '${dateTime.month.toString().padLeft(2, '0')} '
//         '$hour:$minute';
//   }
//   // ============================================================
//   // MORE MENU
//   // ============================================================

//   void _showMoreMenu() {
//     showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       isScrollControlled: true,
//       backgroundColor: FarmTabTheme.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (bottomSheetContext) {
//         return SafeArea(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.75,
//             ),
//             child: ListView(
//               shrinkWrap: true,
//               padding: const EdgeInsets.only(bottom: 8),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Shelf Functions',
//                       style: FarmTabTheme.font(
//                         size: 19,
//                         weight: FontWeight.w700,
//                         color: FarmTabTheme.textH,
//                       ),
//                     ),
//                   ),
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.sensors_rounded,
//                   title: 'Sensor Monitoring',
//                   function: ShelfFunction.sensorMonitoring,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.tune_rounded,
//                   title: 'Threshold Settings',
//                   function: ShelfFunction.thresholdSettings,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.settings_rounded,
//                   title: 'Shelf Settings',
//                   function: ShelfFunction.shelfSettings,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.eco_rounded,
//                   title: 'Growth Monitoring',
//                   function: ShelfFunction.growthMonitoring,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.science_rounded,
//                   title: 'Simulation',
//                   function: ShelfFunction.simulation,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.smart_toy_rounded,
//                   title: 'AI Assistant',
//                   function: ShelfFunction.aiAssistant,
//                 ),

//                 _buildFunctionTile(
//                   bottomSheetContext: bottomSheetContext,
//                   icon: Icons.devices_rounded,
//                   title: 'Device Management',
//                   function: ShelfFunction.deviceManagement,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFunctionTile({
//     required BuildContext bottomSheetContext,
//     required IconData icon,
//     required String title,
//     required ShelfFunction function,
//   }) {
//     final isSelected = _selectedFunction == function;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
//       child: Material(
//         color: isSelected ? FarmTabTheme.mist : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () {
//             Navigator.pop(bottomSheetContext);

//             if (!mounted) return;

//             setState(() {
//               _selectedFunction = function;
//             });

//             // Coming back to Sensor Monitoring — refresh thresholds
//             // so the Too High/Too Low/Normal badges always compare
//             // against the latest saved values, not a stale copy
//             // fetched when the page first opened.
//             if (function == ShelfFunction.sensorMonitoring) {
//               _loadShelfThresholdsForStatus();
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   size: 20,
//                   color: isSelected ? FarmTabTheme.grove : FarmTabTheme.textM,
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: FarmTabTheme.font(
//                       size: 14.5,
//                       weight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                       color: isSelected
//                           ? FarmTabTheme.grove
//                           : FarmTabTheme.textB,
//                     ),
//                   ),
//                 ),
//                 if (isSelected)
//                   const Icon(
//                     Icons.check_rounded,
//                     size: 18,
//                     color: FarmTabTheme.grove,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showComingSoon(String feature) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$feature will be implemented later.')),
//     );
//   }

//   void _showStartCycleCalibrationCheck() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: FarmTabTheme.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             'Before Starting the Growing Cycle',
//             style: FarmTabTheme.font(
//               size: 16,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//           content: Text(
//             'Have you completed sensor calibration?',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textB,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);

//                 // Open the existing calibration dialog.
//                 _showCalibrationDialog();
//               },
//               child: Text(
//                 'Calibrate Now',
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
//                 Navigator.pop(dialogContext);

//                 _openThresholdSetup();
//               },
//               child: Text(
//                 'Yes, Continue',
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
//   }

//   Future<void> _openThresholdSetup() async {
//     try {
//       final shelf = await _shelfService.getShelf(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//       );

//       if (!mounted) return;

//       setState(() {
//         _shelfThresholds = shelf;
//       });

//       _showThresholdSetupDialog();
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }

//   void _showThresholdSetupDialog() {
//     if (_shelfThresholds == null) {
//       return;
//     }

//     // ------------------------------------------------------------
//     // Threshold controllers
//     // These stay alive throughout the entire Start Cycle flow.
//     // ------------------------------------------------------------

//     final phMinController = TextEditingController(
//       text: _shelfThresholds!['ph_min']?.toString() ?? '',
//     );

//     final phMaxController = TextEditingController(
//       text: _shelfThresholds!['ph_max']?.toString() ?? '',
//     );

//     final ecMinController = TextEditingController(
//       text: _shelfThresholds!['ec_min']?.toString() ?? '',
//     );

//     final ecMaxController = TextEditingController(
//       text: _shelfThresholds!['ec_max']?.toString() ?? '',
//     );

//     final temperatureMinController = TextEditingController(
//       text: _shelfThresholds!['temperature_min']?.toString() ?? '',
//     );

//     final temperatureMaxController = TextEditingController(
//       text: _shelfThresholds!['temperature_max']?.toString() ?? '',
//     );

//     final orpMinController = TextEditingController(
//       text: _shelfThresholds!['orp_min']?.toString() ?? '',
//     );

//     final orpMaxController = TextEditingController(
//       text: _shelfThresholds!['orp_max']?.toString() ?? '',
//     );

//     // ------------------------------------------------------------
//     // Cycle setup state
//     // ------------------------------------------------------------

//     DateTime selectedStartDate = DateTime.now();

//     final targetDaysController = TextEditingController(text: '30');

//     int currentStep = 0;

//     // 0 = Threshold Setup
//     // 1 = Cycle Setup
//     // 2 = Review

//     bool isSavingThresholds = false;

//     // ------------------------------------------------------------
//     // ONE dialog for the entire flow
//     // ------------------------------------------------------------

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             // ------------------------------------------------------
//             // Calculate target harvest date
//             // ------------------------------------------------------

//             final targetDays = int.tryParse(targetDaysController.text.trim());

//             DateTime? targetHarvestDate;

//             if (targetDays != null && targetDays > 0) {
//               targetHarvestDate = selectedStartDate.add(
//                 Duration(days: targetDays),
//               );
//             }

//             // ------------------------------------------------------
//             // STEP 0 — THRESHOLD SETUP
//             // ------------------------------------------------------

//             if (currentStep == 0) {
//               return AlertDialog(
//                 backgroundColor: FarmTabTheme.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 title: Text(
//                   'Monitoring Thresholds',
//                   style: FarmTabTheme.font(
//                     size: 16,
//                     weight: FontWeight.w700,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),

//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Review or update the monitoring thresholds '
//                         'before starting the growing cycle.',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w400,
//                           color: FarmTabTheme.textB,
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       _buildThresholdRow(
//                         label: 'pH',
//                         icon: Icons.science_rounded,
//                         minController: phMinController,
//                         maxController: phMaxController,
//                       ),

//                       const SizedBox(height: 18),

//                       _buildThresholdRow(
//                         label: 'EC',
//                         icon: Icons.water_drop_rounded,
//                         unit: 'µS/cm',
//                         minController: ecMinController,
//                         maxController: ecMaxController,
//                       ),

//                       const SizedBox(height: 18),

//                       _buildThresholdRow(
//                         label: 'Temperature',
//                         icon: Icons.thermostat_rounded,
//                         unit: '°C',
//                         minController: temperatureMinController,
//                         maxController: temperatureMaxController,
//                       ),

//                       const SizedBox(height: 18),

//                       _buildThresholdRow(
//                         label: 'ORP',
//                         icon: Icons.bolt_rounded,
//                         unit: 'mV',
//                         minController: orpMinController,
//                         maxController: orpMaxController,
//                       ),
//                     ],
//                   ),
//                 ),

//                 actions: [
//                   TextButton(
//                     onPressed: isSavingThresholds
//                         ? null
//                         : () {
//                             Navigator.pop(dialogContext);
//                           },
//                     child: Text(
//                       'Cancel',
//                       style: FarmTabTheme.font(
//                         size: 13.5,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.textM,
//                       ),
//                     ),
//                   ),

//                   ElevatedButton(
//                     style: FarmTabTheme.primaryButton,
//                     onPressed: isSavingThresholds
//                         ? null
//                         : () async {
//                             // ----------------------------------------
//                             // Read threshold values
//                             // ----------------------------------------

//                             final phMin = double.tryParse(
//                               phMinController.text.trim(),
//                             );

//                             final phMax = double.tryParse(
//                               phMaxController.text.trim(),
//                             );

//                             final ecMin = double.tryParse(
//                               ecMinController.text.trim(),
//                             );

//                             final ecMax = double.tryParse(
//                               ecMaxController.text.trim(),
//                             );

//                             final temperatureMin = double.tryParse(
//                               temperatureMinController.text.trim(),
//                             );

//                             final temperatureMax = double.tryParse(
//                               temperatureMaxController.text.trim(),
//                             );

//                             final orpMin = double.tryParse(
//                               orpMinController.text.trim(),
//                             );

//                             final orpMax = double.tryParse(
//                               orpMaxController.text.trim(),
//                             );

//                             // ----------------------------------------
//                             // Validate values
//                             // ----------------------------------------

//                             if (phMin == null ||
//                                 phMax == null ||
//                                 ecMin == null ||
//                                 ecMax == null ||
//                                 temperatureMin == null ||
//                                 temperatureMax == null ||
//                                 orpMin == null ||
//                                 orpMax == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                     'Please enter valid values for all thresholds.',
//                                   ),
//                                 ),
//                               );
//                               return;
//                             }

//                             if (phMin >= phMax ||
//                                 ecMin >= ecMax ||
//                                 temperatureMin >= temperatureMax ||
//                                 orpMin >= orpMax) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                     'Minimum values must be lower than maximum values.',
//                                   ),
//                                 ),
//                               );
//                               return;
//                             }

//                             // ----------------------------------------
//                             // Save to backend
//                             // ----------------------------------------

//                             setDialogState(() {
//                               isSavingThresholds = true;
//                             });

//                             try {
//                               await _shelfService.updateShelfThresholds(
//                                 siteId: widget.shelf['site_id'],
//                                 shelfId: widget.shelf['id'],
//                                 phMin: phMin,
//                                 phMax: phMax,
//                                 ecMin: ecMin,
//                                 ecMax: ecMax,
//                                 temperatureMin: temperatureMin,
//                                 temperatureMax: temperatureMax,
//                                 orpMin: orpMin,
//                                 orpMax: orpMax,
//                               );

//                               // --------------------------------------
//                               // Immediately update local values
//                               // --------------------------------------

//                               _shelfThresholds = {
//                                 ...?_shelfThresholds,
//                                 'ph_min': phMin,
//                                 'ph_max': phMax,
//                                 'ec_min': ecMin,
//                                 'ec_max': ecMax,
//                                 'temperature_min': temperatureMin,
//                                 'temperature_max': temperatureMax,
//                                 'orp_min': orpMin,
//                                 'orp_max': orpMax,
//                               };

//                               if (!mounted) return;

//                               // --------------------------------------
//                               // Move to Cycle Setup
//                               //
//                               // IMPORTANT:
//                               // We do NOT close the dialog.
//                               // --------------------------------------

//                               setDialogState(() {
//                                 isSavingThresholds = false;
//                                 currentStep = 1;
//                               });
//                             } catch (e) {
//                               if (!mounted) return;

//                               setDialogState(() {
//                                 isSavingThresholds = false;
//                               });

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     e.toString().replaceFirst(
//                                       'Exception: ',
//                                       '',
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                     child: isSavingThresholds
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: FarmTabTheme.white,
//                             ),
//                           )
//                         : Text(
//                             'Continue',
//                             style: FarmTabTheme.font(
//                               size: 13.5,
//                               weight: FontWeight.w600,
//                               color: FarmTabTheme.white,
//                             ),
//                           ),
//                   ),
//                 ],
//               );
//             }

//             // ------------------------------------------------------
//             // STEP 1 — CYCLE SETUP
//             // ------------------------------------------------------

//             if (currentStep == 1) {
//               final cropType =
//                   widget.shelf['crop_type']?.toString() ?? 'Unknown';

//               return AlertDialog(
//                 backgroundColor: FarmTabTheme.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 title: Text(
//                   'Cycle Setup',
//                   style: FarmTabTheme.font(
//                     size: 16,
//                     weight: FontWeight.w700,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),

//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Crop Type',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: FarmTabTheme.textH,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 14,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: const Color(0xFFF7F7F7),
//                         ),
//                         child: Text(
//                           cropType,
//                           style: FarmTabTheme.font(
//                             size: 14.5,
//                             weight: FontWeight.w500,
//                             color: FarmTabTheme.textH,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Text(
//                         'Start Date',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: FarmTabTheme.textH,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () async {
//                           final pickedDate = await showDatePicker(
//                             context: context,
//                             initialDate: selectedStartDate,
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2100),
//                           );

//                           if (pickedDate != null) {
//                             setDialogState(() {
//                               selectedStartDate = pickedDate;
//                             });
//                           }
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: FarmTabTheme.border),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.calendar_today_rounded,
//                                 size: 18,
//                                 color: FarmTabTheme.grove,
//                               ),

//                               const SizedBox(width: 10),

//                               Text(
//                                 _formatCycleDate(
//                                   selectedStartDate.toIso8601String(),
//                                 ),
//                                 style: FarmTabTheme.font(
//                                   size: 14.5,
//                                   weight: FontWeight.w500,
//                                   color: FarmTabTheme.textH,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Text(
//                         'Target Harvest Days',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: FarmTabTheme.textH,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       TextField(
//                         controller: targetDaysController,
//                         keyboardType: TextInputType.number,
//                         style: FarmTabTheme.font(
//                           size: 14,
//                           weight: FontWeight.w400,
//                           color: FarmTabTheme.textH,
//                         ),
//                         onChanged: (_) {
//                           setDialogState(() {});
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'e.g. 30',
//                           suffixText: 'days',
//                           filled: true,
//                           fillColor: const Color(0xFFF7F7F7),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: const BorderSide(
//                               color: FarmTabTheme.fern,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Text(
//                         'Target Harvest Date',
//                         style: FarmTabTheme.font(
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: FarmTabTheme.textH,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 14,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: const Color(0xFFF7F7F7),
//                         ),
//                         child: Text(
//                           targetHarvestDate == null
//                               ? '--'
//                               : _formatCycleDate(
//                                   targetHarvestDate.toIso8601String(),
//                                 ),
//                           style: FarmTabTheme.font(
//                             size: 14.5,
//                             weight: FontWeight.w500,
//                             color: FarmTabTheme.textH,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(dialogContext);
//                     },
//                     child: Text(
//                       'Cancel',
//                       style: FarmTabTheme.font(
//                         size: 13.5,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.textM,
//                       ),
//                     ),
//                   ),

//                   ElevatedButton(
//                     style: FarmTabTheme.primaryButton,
//                     onPressed: () {
//                       if (targetDays == null || targetDays <= 0) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Please enter a valid number of harvest days.',
//                             ),
//                           ),
//                         );
//                         return;
//                       }

//                       // ----------------------------------------------
//                       // Same dialog → Review
//                       // ----------------------------------------------

//                       setDialogState(() {
//                         currentStep = 2;
//                       });
//                     },
//                     child: Text(
//                       'Continue',
//                       style: FarmTabTheme.font(
//                         size: 13.5,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }

//             // ------------------------------------------------------
//             // STEP 2 — REVIEW
//             // ------------------------------------------------------

//             final cropType = widget.shelf['crop_type']?.toString() ?? 'Unknown';

//             return AlertDialog(
//               backgroundColor: FarmTabTheme.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               title: Text(
//                 'Review Growing Cycle',
//                 style: FarmTabTheme.font(
//                   size: 16,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),

//               content: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Please review the cycle details before starting.',
//                       style: FarmTabTheme.font(
//                         size: 13,
//                         weight: FontWeight.w400,
//                         color: FarmTabTheme.textB,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     _buildReviewItem('Crop Type', cropType),

//                     _buildReviewItem(
//                       'Start Date',
//                       _formatCycleDate(selectedStartDate.toIso8601String()),
//                     ),

//                     _buildReviewItem(
//                       'Target Harvest Days',
//                       targetDays == null ? '--' : '$targetDays days',
//                     ),

//                     _buildReviewItem(
//                       'Target Harvest Date',
//                       targetHarvestDate == null
//                           ? '--'
//                           : _formatCycleDate(
//                               targetHarvestDate.toIso8601String(),
//                             ),
//                     ),

//                     const SizedBox(height: 12),

//                     const Divider(color: FarmTabTheme.border),

//                     const SizedBox(height: 12),

//                     Text(
//                       'Monitoring Thresholds',
//                       style: FarmTabTheme.font(
//                         size: 14,
//                         weight: FontWeight.w700,
//                         color: FarmTabTheme.textH,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _buildThresholdReviewItem(
//                       'pH',
//                       _shelfThresholds?['ph_min'],
//                       _shelfThresholds?['ph_max'],
//                     ),

//                     _buildThresholdReviewItem(
//                       'EC',
//                       _shelfThresholds?['ec_min'],
//                       _shelfThresholds?['ec_max'],
//                       unit: 'µS/cm',
//                     ),

//                     _buildThresholdReviewItem(
//                       'Temperature',
//                       _shelfThresholds?['temperature_min'],
//                       _shelfThresholds?['temperature_max'],
//                       unit: '°C',
//                     ),

//                     _buildThresholdReviewItem(
//                       'ORP',
//                       _shelfThresholds?['orp_min'],
//                       _shelfThresholds?['orp_max'],
//                       unit: 'mV',
//                     ),
//                   ],
//                 ),
//               ),

//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     // Cancel the entire Start Cycle process.
//                     Navigator.pop(dialogContext);
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: FarmTabTheme.font(
//                       size: 13.5,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.textM,
//                     ),
//                   ),
//                 ),

//                 ElevatedButton(
//                   style: FarmTabTheme.primaryButton,
//                   onPressed: () async {
//                     if (targetDays == null || targetDays <= 0) {
//                       return;
//                     }

//                     await _startGrowingCycle(
//                       dialogContext: dialogContext,
//                       startDate: selectedStartDate,
//                       targetHarvestDays: targetDays,
//                     );
//                   },
//                   child: Text(
//                     'Start Cycle',
//                     style: FarmTabTheme.font(
//                       size: 13.5,
//                       weight: FontWeight.w600,
//                       color: FarmTabTheme.white,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     ).then((_) {
//       // The whole dialog is now closed.
//       // Safe place to dispose the controllers.
//       phMinController.dispose();
//       phMaxController.dispose();
//       ecMinController.dispose();
//       ecMaxController.dispose();
//       temperatureMinController.dispose();
//       temperatureMaxController.dispose();
//       orpMinController.dispose();
//       orpMaxController.dispose();
//       targetDaysController.dispose();
//     });
//   }

//   Widget _buildThresholdRow({
//     required String label,
//     required IconData icon,
//     required TextEditingController minController,
//     required TextEditingController maxController,
//     String? unit,
//   }) {
//     InputDecoration fieldDecoration() {
//       return InputDecoration(
//         filled: true,
//         fillColor: const Color(0xFFF7F7F7),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 13,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: FarmTabTheme.fern, width: 1.5),
//         ),
//       );
//     }

//     // Small label shown ABOVE each field — "Min" / "Max" plus the
//     // unit in muted text, e.g. "Min · µS/cm". Keeping the unit out
//     // of the field itself means long values are never cut off.
//     Widget fieldLabel(String prefix) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 6, left: 2),
//         child: RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: prefix,
//                 style: FarmTabTheme.font(
//                   size: 12,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.textB,
//                 ),
//               ),
//               if (unit != null)
//                 TextSpan(
//                   text: '  ·  $unit',
//                   style: FarmTabTheme.font(
//                     size: 11.5,
//                     weight: FontWeight.w400,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: FarmTabTheme.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: FarmTabTheme.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: FarmTabTheme.mist,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 alignment: Alignment.center,
//                 child: Icon(icon, size: 15, color: FarmTabTheme.grove),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 label,
//                 style: FarmTabTheme.font(
//                   size: 14.5,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     fieldLabel('Min'),
//                     TextField(
//                       controller: minController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       style: FarmTabTheme.font(
//                         size: 14.5,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.textH,
//                       ),
//                       decoration: fieldDecoration(),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     fieldLabel('Max'),
//                     TextField(
//                       controller: maxController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       style: FarmTabTheme.font(
//                         size: 14.5,
//                         weight: FontWeight.w600,
//                         color: FarmTabTheme.textH,
//                       ),
//                       decoration: fieldDecoration(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReviewItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: FarmTabTheme.font(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textM,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: FarmTabTheme.font(
//                 size: 13.5,
//                 weight: FontWeight.w600,
//                 color: FarmTabTheme.textH,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildThresholdReviewItem(
//     String label,
//     dynamic min,
//     dynamic max, {
//     String unit = '',
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: FarmTabTheme.font(
//                 size: 13.5,
//                 weight: FontWeight.w400,
//                 color: FarmTabTheme.textB,
//               ),
//             ),
//           ),
//           Text(
//             '${_formatSensorValue(min)} - '
//             '${_formatSensorValue(max)}'
//             '${unit.isEmpty ? '' : ' $unit'}',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w600,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _startGrowingCycle({
//     required BuildContext dialogContext,
//     required DateTime startDate,
//     required int targetHarvestDays,
//   }) async {
//     try {
//       final startDateString =
//           '${startDate.year.toString().padLeft(4, '0')}-'
//           '${startDate.month.toString().padLeft(2, '0')}-'
//           '${startDate.day.toString().padLeft(2, '0')}';

//       await _growingCycleService.createGrowingCycle(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//         startDate: startDateString,
//         targetHarvestDays: targetHarvestDays,
//       );

//       if (!mounted) return;

//       Navigator.pop(dialogContext);

//       await _loadActiveGrowingCycle();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Growing cycle started successfully.')),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
//       );
//     }
//   }
//   // ============================================================
//   // CALIBRATION
//   // ============================================================

//   void _showCalibrationDialog() {
//     _referenceController.clear();

//     setState(() {
//       _isCalibrationOpen = true;
//       _isCalibrationRunning = false;
//       _calibrationSensor = null;
//       _calibrationReferenceValue = null;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: FarmTabTheme.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               title: Text(
//                 'Calibration',
//                 style: FarmTabTheme.font(
//                   size: 16,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: SizedBox(
//                   width: 400,
//                   child: _isCalibrationRunning
//                       ? _buildCalibrationMonitoring(context, setDialogState)
//                       : _buildCalibrationSetup(context, setDialogState),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     ).then((_) {
//       if (!mounted) return;

//       setState(() {
//         _isCalibrationOpen = false;
//         _isCalibrationRunning = false;
//         _calibrationSensor = null;
//         _calibrationReferenceValue = null;
//       });

//       _referenceController.clear();
//     });
//   }

//   // ============================================================
//   // CALIBRATION SETUP
//   // ============================================================

//   Widget _buildCalibrationSetup(
//     BuildContext context,
//     StateSetter setDialogState,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Sensor',
//           style: FarmTabTheme.font(
//             size: 14,
//             weight: FontWeight.w600,
//             color: FarmTabTheme.textH,
//           ),
//         ),

//         const SizedBox(height: 8),

//         Row(
//           children: [
//             Expanded(
//               child: RadioListTile<String>(
//                 activeColor: FarmTabTheme.grove,
//                 contentPadding: EdgeInsets.zero,
//                 title: Text(
//                   'EC',
//                   style: FarmTabTheme.font(
//                     size: 14,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),
//                 value: 'ec',
//                 groupValue: _calibrationSensor,
//                 onChanged: (value) {
//                   setDialogState(() {
//                     _calibrationSensor = value;
//                   });
//                 },
//               ),
//             ),
//             Expanded(
//               child: RadioListTile<String>(
//                 activeColor: FarmTabTheme.grove,
//                 contentPadding: EdgeInsets.zero,
//                 title: Text(
//                   'pH',
//                   style: FarmTabTheme.font(
//                     size: 14,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textH,
//                   ),
//                 ),
//                 value: 'ph',
//                 groupValue: _calibrationSensor,
//                 onChanged: (value) {
//                   setDialogState(() {
//                     _calibrationSensor = value;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 8),

//         Text(
//           'Reference Value',
//           style: FarmTabTheme.font(
//             size: 14,
//             weight: FontWeight.w600,
//             color: FarmTabTheme.textH,
//           ),
//         ),

//         const SizedBox(height: 8),

//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 130,
//               child: TextField(
//                 controller: _referenceController,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 style: FarmTabTheme.font(
//                   size: 14,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textH,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: _calibrationSensor == 'ec'
//                       ? 'e.g. 1413'
//                       : _calibrationSensor == 'ph'
//                       ? 'e.g. 7.00'
//                       : 'Value',
//                   filled: true,
//                   fillColor: const Color(0xFFF7F7F7),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ),

//             if (_calibrationSensor == 'ec') ...[
//               const SizedBox(width: 10),
//               Text(
//                 'µS/cm',
//                 style: FarmTabTheme.font(
//                   size: 14,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textB,
//                 ),
//               ),
//             ],
//           ],
//         ),
//         const SizedBox(height: 24),

//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
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

//             const SizedBox(width: 8),

//             ElevatedButton(
//               style: FarmTabTheme.primaryButton,
//               onPressed: () {
//                 _startCalibration(setDialogState);
//               },
//               child: Text(
//                 'Calibrate',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w600,
//                   color: FarmTabTheme.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // START CALIBRATION
//   // ============================================================

//   void _startCalibration(StateSetter setDialogState) {
//     if (_calibrationSensor == null) {
//       _showCalibrationError(setDialogState, 'Please select EC or pH.');
//       return;
//     }

//     final reference = double.tryParse(_referenceController.text.trim());

//     if (reference == null) {
//       _showCalibrationError(
//         setDialogState,
//         'Please enter a valid reference value.',
//       );
//       return;
//     }

//     if (reference < 0) {
//       _showCalibrationError(
//         setDialogState,
//         'Reference value cannot be negative.',
//       );
//       return;
//     }

//     setState(() {
//       _calibrationReferenceValue = reference;
//       _isCalibrationRunning = true;
//     });

//     setDialogState(() {});
//   }

//   void _showCalibrationError(StateSetter setDialogState, String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));

//     setDialogState(() {});
//   }

//   // ============================================================
//   // CALIBRATION MONITORING
//   // ============================================================

//   Widget _buildCalibrationMonitoring(
//     BuildContext context,
//     StateSetter setDialogState,
//   ) {
//     final currentValue = _getCalibrationCurrentValue();

//     final recordedAt = _latestSensorReading?['recorded_at'];

//     final sensorName = _calibrationSensor == 'ec' ? 'EC' : 'pH';

//     final unit = _calibrationSensor == 'ec' ? 'µS/cm' : 'pH';

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$sensorName Calibration',
//           style: FarmTabTheme.font(
//             size: 17,
//             weight: FontWeight.w700,
//             color: FarmTabTheme.textH,
//           ),
//         ),

//         const SizedBox(height: 20),

//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             color: FarmTabTheme.mist,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Reference Value',
//                 style: FarmTabTheme.font(
//                   size: 12.5,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.grove,
//                 ),
//               ),

//               const SizedBox(height: 6),

//               Text(
//                 '${_formatSensorValue(_calibrationReferenceValue)} $unit',
//                 style: FarmTabTheme.font(
//                   size: 23,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 16),

//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: FarmTabTheme.cardDecoration,
//           child: Column(
//             children: [
//               Text(
//                 'Current $sensorName',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               Text(
//                 currentValue == null
//                     ? '--'
//                     : '${_formatSensorValue(currentValue)} $unit',
//                 style: FarmTabTheme.font(
//                   size: 29,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     _isSensorLive
//                         ? Icons.circle_rounded
//                         : Icons.circle_outlined,
//                     size: 10,
//                     color: _isSensorLive
//                         ? FarmTabTheme.grove
//                         : FarmTabTheme.textM,
//                   ),

//                   const SizedBox(width: 6),

//                   Text(
//                     _isSensorLive ? 'Live' : 'Offline',
//                     style: FarmTabTheme.font(
//                       size: 12.5,
//                       weight: FontWeight.w500,
//                       color: FarmTabTheme.textB,
//                     ),
//                   ),
//                 ],
//               ),

//               if (recordedAt != null) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   'Last updated: ${_formatRecordedTime(recordedAt)}',
//                   style: FarmTabTheme.font(
//                     size: 11.5,
//                     weight: FontWeight.w400,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),

//         const SizedBox(height: 18),

//         Text(
//           'Perform the calibration on the physical device. '
//           'When you are finished, press Done.',
//           style: FarmTabTheme.font(
//             size: 13,
//             weight: FontWeight.w400,
//             color: FarmTabTheme.textB,
//             height: 1.4,
//           ),
//         ),

//         const SizedBox(height: 24),

//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             style: FarmTabTheme.primaryButton,
//             onPressed: () {
//               _finishCalibration(context, setDialogState);
//             },
//             child: Text(
//               'Done',
//               style: FarmTabTheme.font(
//                 size: 14,
//                 weight: FontWeight.w600,
//                 color: FarmTabTheme.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // CURRENT CALIBRATION VALUE
//   // ============================================================

//   double? _getCalibrationCurrentValue() {
//     if (_latestSensorReading == null) {
//       return null;
//     }

//     final key = _calibrationSensor == 'ec' ? 'ec' : 'ph';

//     final value = _latestSensorReading![key];

//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(value?.toString() ?? '');
//   }

//   // ============================================================
//   // FINISH CALIBRATION
//   // ============================================================

//   void _finishCalibration(
//     BuildContext dialogContext,
//     StateSetter setDialogState,
//   ) {
//     final currentValue = _getCalibrationCurrentValue();

//     final reference = _calibrationReferenceValue;

//     // If no current reading is available,
//     // let the user decide what to do.
//     if (currentValue == null || reference == null) {
//       _showCalibrationWarning(
//         dialogContext,
//         setDialogState,
//         currentValue,
//         reference,
//       );

//       return;
//     }

//     final difference = (currentValue - reference).abs();

//     // Current tolerance:
//     // reference ± 5
//     if (difference > 5) {
//       _showCalibrationWarning(
//         dialogContext,
//         setDialogState,
//         currentValue,
//         reference,
//       );

//       return;
//     }

//     // Within tolerance.
//     Navigator.pop(dialogContext);
//   }

//   // ============================================================
//   // OUTSIDE TOLERANCE WARNING
//   // ============================================================

//   void _showCalibrationWarning(
//     BuildContext parentContext,
//     StateSetter setDialogState,
//     double? currentValue,
//     double? reference,
//   ) {
//     showDialog(
//       context: parentContext,
//       barrierDismissible: false,
//       builder: (warningContext) {
//         final sensorName = _calibrationSensor == 'ec' ? 'EC' : 'pH';

//         final unit = _calibrationSensor == 'ec' ? 'µS/cm' : 'pH';

//         return AlertDialog(
//           backgroundColor: FarmTabTheme.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             'Calibration Value Check',
//             style: FarmTabTheme.font(
//               size: 16,
//               weight: FontWeight.w700,
//               color: FarmTabTheme.textH,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'The current value is outside the expected tolerance.',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textB,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Text(
//                 'Reference: '
//                 '${_formatSensorValue(reference)} $unit',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),

//               const SizedBox(height: 6),

//               Text(
//                 'Current: '
//                 '${currentValue == null ? '--' : _formatSensorValue(currentValue)} $unit',
//                 style: FarmTabTheme.font(
//                   size: 13.5,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Text(
//                 'Please check the physical device. '
//                 'You can retry the calibration or confirm to finish anyway.',
//                 style: FarmTabTheme.font(
//                   size: 13,
//                   weight: FontWeight.w400,
//                   color: FarmTabTheme.textB,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(warningContext);

//                 // Stay in the calibration screen.
//                 // User can continue working with the physical device.
//                 setDialogState(() {});
//               },
//               child: Text(
//                 'Retry',
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
//                 Navigator.pop(warningContext);
//                 Navigator.pop(parentContext);
//               },
//               child: Text(
//                 'Confirm',
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
//   }

//   // ============================================================
//   // END
//   // ============================================================
// }

// // ─────────────────────────────────────────────────────────────
// // GROWTH PROGRESS RING — circular indicator for Growing Cycle
// // ─────────────────────────────────────────────────────────────
// class _GrowthProgressRing extends StatelessWidget {
//   final double progress;
//   final int growthDay;

//   const _GrowthProgressRing({required this.progress, required this.growthDay});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 92,
//       height: 92,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CustomPaint(
//             size: const Size(92, 92),
//             painter: _RingPainter(progress: progress),
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '${(progress * 100).round()}%',
//                 style: FarmTabTheme.font(
//                   size: 17,
//                   weight: FontWeight.w800,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),
//               Text(
//                 'Day $growthDay',
//                 style: FarmTabTheme.font(
//                   size: 9.5,
//                   weight: FontWeight.w500,
//                   color: FarmTabTheme.textM,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RingPainter extends CustomPainter {
//   final double progress;

//   _RingPainter({required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//     const strokeWidth = 9.0;

//     // Track (background ring)
//     final trackPaint = Paint()
//       ..color = FarmTabTheme.mist
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;

//     canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

//     // Progress arc
//     final progressPaint = Paint()
//       ..shader = const LinearGradient(
//         colors: [FarmTabTheme.fern, FarmTabTheme.grove],
//       ).createShader(Rect.fromCircle(center: center, radius: radius))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;

//     final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
//       -math.pi / 2,
//       sweep,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _RingPainter oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

import 'device_management_page.dart';
import 'threshold_settings_page.dart';
import 'shelf_settings_page.dart';
import 'ai_assistant_page.dart';
import '../../services/growing_cycle_service.dart';
import '../../services/shelf_service.dart';
import '../notifications/shelf_notifications_page.dart';
import '../../services/notification_service.dart';

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
  static const Color skyBlue = Color(0xFF457B9D);

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

  static ButtonStyle dangerOutlinedButton = OutlinedButton.styleFrom(
    foregroundColor: alertRed,
    side: const BorderSide(color: Color(0xFFF4B9BE)),
    padding: const EdgeInsets.symmetric(vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

enum ShelfFunction {
  sensorMonitoring,
  thresholdSettings,
  shelfSettings,
  growthMonitoring,
  simulation,
  aiAssistant,
  deviceManagement,
}

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

class _ShelfDetailPageState extends State<ShelfDetailPage>
    with SingleTickerProviderStateMixin {
  final ShelfService _shelfService = ShelfService();
  final GrowingCycleService _growingCycleService = GrowingCycleService();

  static const String baseUrl = 'http://98.88.222.75:8000';

  WebSocketChannel? _sensorChannel;

  Map<String, dynamic>? _latestSensorReading;
  Map<String, dynamic>? _activeGrowingCycle;

  bool _isLoadingGrowingCycle = true;
  String? _growingCycleError;

  bool _isLoadingSensor = true;
  bool _isSensorLive = false;
  bool _isConnectingSensor = true;
  DateTime _historyStartDate = DateTime.now();
  DateTime _historyEndDate = DateTime.now();

  int _historyIntervalMinutes = 60;

  bool _isLoadingHistory = false;
  String? _historyError;

  List<Map<String, dynamic>> _sensorHistory = [];

  int _selectedHistorySensor = 0;

  String? _sensorError;

  final NotificationService _notificationService = NotificationService();

  bool _hasUnreadNotifications = false;

  late TabController _sensorTabController;

  Map<String, dynamic>? _shelfThresholds;

  // ------------------------------------------------------------
  // Shelf function navigation
  // ------------------------------------------------------------

  ShelfFunction _selectedFunction = ShelfFunction.sensorMonitoring;

  // ------------------------------------------------------------
  // Calibration state
  // ------------------------------------------------------------

  bool _isCalibrationOpen = false;
  bool _isCalibrationRunning = false;

  String? _calibrationSensor;
  double? _calibrationReferenceValue;

  final TextEditingController _referenceController = TextEditingController();

  // ------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _sensorTabController = TabController(length: 2, vsync: this);

    _sensorTabController.addListener(() {
      if (_sensorTabController.index == 1 &&
          !_isLoadingHistory &&
          _sensorHistory.isEmpty &&
          _historyError == null) {
        _loadSensorHistory();
      }
    });

    _loadLatestSensorReading();
    _loadActiveGrowingCycle();
    _loadShelfThresholdsForStatus();
    _connectSensorWebSocket();
    _loadUnreadNotificationStatus();
  }

  @override
  void dispose() {
    _sensorTabController.dispose();
    _sensorChannel?.sink.close();
    _referenceController.dispose();

    super.dispose();
  }

  Future<void> _loadUnreadNotificationStatus() async {
    try {
      final notifications = await _notificationService.getShelfNotifications(
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      final hasUnread = notifications.any(
        (notification) => notification['is_read'] == false,
      );

      setState(() {
        _hasUnreadNotifications = hasUnread;
      });
    } catch (_) {
      // Do not interrupt the Shelf Detail page
      // if notification loading fails.
    }
  }

  // ------------------------------------------------------------
  // Sensor data
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // Loads this shelf's threshold min/max values so the sensor
  // cards can show a "Too High / Too Low / Normal" badge. This is
  // the same data the Start Growing Cycle flow already fetches —
  // we just also grab it here, right when the page opens, so the
  // badges have something to compare against immediately.
  // ------------------------------------------------------------
  Future<void> _loadShelfThresholdsForStatus() async {
    try {
      final shelf = await _shelfService.getShelf(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      setState(() {
        _shelfThresholds = shelf;
      });
    } catch (e) {
      // Quietly skip — if thresholds can't be loaded, the sensor
      // cards simply won't show a status badge (no crash).
      debugPrint('Unable to load shelf thresholds: $e');
    }
  }

  // ------------------------------------------------------------
  // Compares a live sensor value against this shelf's threshold
  // min/max, and returns the badge to show — or null if either
  // the reading or the threshold isn't available.
  // ------------------------------------------------------------
  ({String label, Color color})? _getSensorStatus({
    required num? value,
    required String minKey,
    required String maxKey,
  }) {
    if (value == null || _shelfThresholds == null) return null;

    final min = _shelfThresholds![minKey];
    final max = _shelfThresholds![maxKey];

    final minValue = min is num ? min.toDouble() : double.tryParse('$min');
    final maxValue = max is num ? max.toDouble() : double.tryParse('$max');

    if (minValue == null || maxValue == null) return null;

    if (value > maxValue) {
      return (label: 'Too High', color: FarmTabTheme.alertRed);
    }

    if (value < minValue) {
      return (label: 'Too Low', color: FarmTabTheme.alertRed);
    }

    return (label: 'Normal', color: FarmTabTheme.grove);
  }

  Future<void> _loadSensorHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final history = await _shelfService.getSensorHistory(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        startDate: _historyStartDate,
        endDate: _historyEndDate,
        intervalMinutes: _historyIntervalMinutes,
      );
      if (!mounted) return;

      setState(() {
        _sensorHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
        _historyError = e.toString();
        _sensorHistory = [];
      });
    }
  }

  Future<void> _refreshSensorReading() async {
    // Keep the current sensor values visible while refreshing.
    await _loadLatestSensorReading();
  }

  Future<void> _loadActiveGrowingCycle() async {
    try {
      final cycle = await _growingCycleService.getActiveGrowingCycle(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      setState(() {
        _activeGrowingCycle = cycle;
        _isLoadingGrowingCycle = false;
        _growingCycleError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingGrowingCycle = false;
        _growingCycleError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ------------------------------------------------------------
  // WebSocket
  // ------------------------------------------------------------

  Future<void> _connectSensorWebSocket() async {
    try {
      setState(() {
        _isConnectingSensor = true;
      });

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found. Please login again.');
      }

      final siteId = widget.shelf['site_id'];
      final shelfId = widget.shelf['id'];

      final uri = Uri.parse(
        'ws://98.88.222.75:8000/ws/sites/$siteId/shelves/$shelfId/sensor',
      );

      final channel = WebSocketChannel.connect(uri);

      _sensorChannel = channel;

      channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message.toString());

            if (!mounted) return;

            setState(() {
              _latestSensorReading = Map<String, dynamic>.from(data);

              _isLoadingSensor = false;
              _sensorError = null;
              _isSensorLive = true;
              _isConnectingSensor = false;
            });

            // A new live reading is exactly the moment a new alert
            // notification might have just been created server-side
            // — so re-check unread status right now instead of
            // waiting for the user to leave and reopen this page.
            _loadUnreadNotificationStatus();
          } catch (e) {
            debugPrint('Invalid WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('Sensor WebSocket error: $error');

          if (!mounted) return;

          setState(() {
            _isSensorLive = false;
            _isConnectingSensor = false;
          });
        },
        onDone: () {
          debugPrint('Sensor WebSocket connection closed.');

          if (!mounted) return;

          setState(() {
            _isSensorLive = false;
            _isConnectingSensor = false;
          });
        },
      );
    } catch (e) {
      debugPrint('Failed to connect to sensor WebSocket: $e');

      if (!mounted) return;

      setState(() {
        _isSensorLive = false;
        _isConnectingSensor = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final shelfName = widget.shelf['name']?.toString() ?? 'Shelf';

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(shelfName),
      body: Column(
        children: [
          _buildFunctionHeader(),
          Expanded(child: _buildSelectedFunction()),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────
  // Gradient header with rounded bottom corners (top stays square),
  // matching the rest of the app's design system.

  PreferredSizeWidget _buildAppBar(String shelfName) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleSpacing: 0,
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
        shelfName,
        style: FarmTabTheme.font(
          size: 17,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShelfNotificationsPage(
                        shelfId: widget.shelf['id'],
                        shelfName: widget.shelf['name'],
                      ),
                    ),
                  );

                  // Refresh unread status after returning
                  _loadUnreadNotificationStatus();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 19,
                    color: FarmTabTheme.white,
                  ),
                ),
              ),
            ),

            if (_hasUnreadNotifications)
              Positioned(
                right: 1,
                top: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: FarmTabTheme.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _showMoreMenu,
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(
                Icons.apps_rounded,
                size: 19,
                color: FarmTabTheme.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionHeader() {
    String title;
    IconData icon;

    switch (_selectedFunction) {
      case ShelfFunction.sensorMonitoring:
        title = 'Sensor Monitoring';
        icon = Icons.sensors_rounded;
        break;

      case ShelfFunction.thresholdSettings:
        title = 'Threshold Settings';
        icon = Icons.tune_rounded;
        break;

      case ShelfFunction.shelfSettings:
        title = 'Shelf Settings';
        icon = Icons.settings_rounded;
        break;

      case ShelfFunction.growthMonitoring:
        title = 'Growth Monitoring';
        icon = Icons.eco_rounded;
        break;

      case ShelfFunction.simulation:
        title = 'Simulation';
        icon = Icons.science_rounded;
        break;

      case ShelfFunction.aiAssistant:
        title = 'AI Assistant';
        icon = Icons.smart_toy_rounded;
        break;

      case ShelfFunction.deviceManagement:
        title = 'Device Management';
        icon = Icons.devices_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: FarmTabTheme.white,
        border: Border(bottom: BorderSide(color: FarmTabTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FarmTabTheme.mist,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: FarmTabTheme.grove),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SHELF FUNCTION NAVIGATION
  // ============================================================

  Widget _buildSelectedFunction() {
    switch (_selectedFunction) {
      case ShelfFunction.sensorMonitoring:
        return _buildSensorMonitoring();

      case ShelfFunction.thresholdSettings:
        return ThresholdSettingsPage(
          shelf: widget.shelf,
          organisation: widget.organisation,
          embedded: true,
        );

      case ShelfFunction.shelfSettings:
        return ShelfSettingsPage(
          shelf: widget.shelf,
          organisation: widget.organisation,
          embedded: true,
        );

      case ShelfFunction.growthMonitoring:
        return _buildComingSoonPage(
          title: 'Growth Monitoring',
          icon: Icons.eco_rounded,
        );

      case ShelfFunction.simulation:
        return _buildComingSoonPage(
          title: 'Simulation',
          icon: Icons.science_rounded,
        );

      case ShelfFunction.aiAssistant:
        return AiAssistantPage(
          shelf: widget.shelf,
          organisation: widget.organisation,
          embedded: true,
        );

      case ShelfFunction.deviceManagement:
        return DeviceManagementPage(
          shelf: widget.shelf,
          organisation: widget.organisation,
          embedded: true,
        );
    }
  }

  Widget _buildSensorMonitoring() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(11),
          ),
          child: TabBar(
            controller: _sensorTabController,
            indicator: BoxDecoration(
              color: FarmTabTheme.grove,
              borderRadius: BorderRadius.circular(9),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: FarmTabTheme.white,
            unselectedLabelColor: FarmTabTheme.textM,
            labelStyle: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w600,
              color: FarmTabTheme.white,
            ),
            unselectedLabelStyle: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w500,
              color: FarmTabTheme.textM,
            ),
            tabs: const [
              Tab(text: 'Monitor'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _sensorTabController,
            children: [_buildCurrentSensorTab(), _buildHistoryTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonPage({required String title, required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: FarmTabTheme.mist,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 38, color: FarmTabTheme.fern),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: FarmTabTheme.font(
                size: 19,
                weight: FontWeight.w700,
                color: FarmTabTheme.textH,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This feature will be implemented later.',
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
    );
  }

  // ============================================================
  // CURRENT SENSOR TAB
  // ============================================================

  Widget _buildCurrentSensorTab() {
    return RefreshIndicator(
      color: FarmTabTheme.grove,
      onRefresh: _refreshSensorReading,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // 1. Growing Cycle
            // ----------------------------------------------------
            _sectionLabel('Growing Cycle'),

            const SizedBox(height: 12),

            _buildGrowingCycleCard(),

            const SizedBox(height: 24),

            // ----------------------------------------------------
            // 2. Current Conditions
            // ----------------------------------------------------
            _sectionLabel('Current Conditions'),

            const SizedBox(height: 12),

            if (_sensorError != null && _latestSensorReading == null)
              _buildSensorError()
            else if (_latestSensorReading != null)
              _buildSensorData()
            else
              _buildSensorLoading(),

            const SizedBox(height: 24),

            // ----------------------------------------------------
            // 3. Device Status
            // ----------------------------------------------------
            _buildDeviceStatusCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: FarmTabTheme.font(
        size: 17,
        weight: FontWeight.w700,
        color: FarmTabTheme.textH,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildSensorLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: FarmTabTheme.grove,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading sensor data...',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // GROWING CYCLE
  // ============================================================

  Widget _buildGrowingCycleCard() {
    if (_isLoadingGrowingCycle) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: FarmTabTheme.cardDecoration,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: FarmTabTheme.grove,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading growing cycle...',
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
            ),
          ],
        ),
      );
    }
    if (_growingCycleError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: FarmTabTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _growingCycleError!,
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textB,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadActiveGrowingCycle,
              style: FarmTabTheme.outlinedButton,
              child: Text(
                'Retry',
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.grove,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final cycle = _activeGrowingCycle;

    // ------------------------------------------------------------
    // No active cycle
    // ------------------------------------------------------------

    if (cycle == null) {
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: FarmTabTheme.mist,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 26,
                    color: FarmTabTheme.fern,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No active cycle',
                    style: FarmTabTheme.font(
                      size: 15.5,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showCalibrationDialog,
                    style: FarmTabTheme.outlinedButton,
                    child: Text(
                      'Calibration',
                      style: FarmTabTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.grove,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showStartCycleCalibrationCheck,
                    style: FarmTabTheme.primaryButton,
                    child: Text(
                      'Start Cycle',
                      style: FarmTabTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------
    // Active cycle
    // ------------------------------------------------------------

    final cropType = cycle['crop_type']?.toString() ?? '--';

    final startDate = cycle['start_date']?.toString() ?? '--';

    final targetDays = cycle['target_harvest_days'];

    final targetHarvestDate = cycle['target_harvest_date']?.toString() ?? '--';

    final parsedStartDate = DateTime.tryParse(startDate);

    final today = DateTime.now();

    int growthDay = 1;

    if (parsedStartDate != null) {
      final start = DateTime(
        parsedStartDate.year,
        parsedStartDate.month,
        parsedStartDate.day,
      );

      final current = DateTime(today.year, today.month, today.day);

      growthDay = current.difference(start).inDays + 1;

      if (growthDay < 1) {
        growthDay = 1;
      }
    }

    double progress = 0;
    final targetDaysInt = targetDays is int
        ? targetDays
        : int.tryParse(targetDays?.toString() ?? '');

    if (targetDaysInt != null && targetDaysInt > 0) {
      progress = (growthDay / targetDaysInt).clamp(0.0, 1.0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Progress ring
              _GrowthProgressRing(progress: progress, growthDay: growthDay),

              const SizedBox(width: 18),

              // ── Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FarmTabTheme.mist,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cropType,
                        style: FarmTabTheme.font(
                          size: 11.5,
                          weight: FontWeight.w700,
                          color: FarmTabTheme.grove,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Day $growthDay of ${targetDaysInt ?? '--'}',
                      style: FarmTabTheme.font(
                        size: 16,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textH,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _cycleDateRow(
                      Icons.play_circle_outline_rounded,
                      'Started',
                      _formatCycleDate(startDate),
                    ),

                    const SizedBox(height: 4),

                    _cycleDateRow(
                      Icons.flag_outlined,
                      'Target',
                      _formatCycleDate(targetHarvestDate),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showComingSoon('Harvest');
                  },
                  style: FarmTabTheme.outlinedButton,
                  child: Text(
                    'Harvest',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.grove,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showStopCycleConfirmation(),
                  style: FarmTabTheme.dangerOutlinedButton,
                  child: Text(
                    'Stop Cycle',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.alertRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cycleDateRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: FarmTabTheme.textM),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: FarmTabTheme.font(
            size: 12.5,
            weight: FontWeight.w400,
            color: FarmTabTheme.textM,
          ),
        ),
        Text(
          value,
          style: FarmTabTheme.font(
            size: 12.5,
            weight: FontWeight.w600,
            color: FarmTabTheme.textB,
          ),
        ),
      ],
    );
  }

  void _showStopCycleConfirmation() {
    if (_activeGrowingCycle == null) return;

    final cycleId = _activeGrowingCycle!['id'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Stop Growing Cycle?',
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          content: Text(
            'Are you sure you want to stop this growing cycle?',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
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
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _growingCycleService.stopGrowingCycle(
                    siteId: widget.shelf['site_id'],
                    shelfId: widget.shelf['id'],
                    cycleId: cycleId,
                  );

                  await _loadActiveGrowingCycle();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Growing cycle stopped.')),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to stop cycle: $e')),
                  );
                }
              },
              child: Text(
                'Stop Cycle',
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
  }
  // ============================================================
  // CURRENT SENSOR DATA
  // ============================================================

  Widget _buildSensorData() {
    final reading = _latestSensorReading;

    if (reading == null) {
      return _buildNoSensorData();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                title: 'pH',
                value: _formatSensorValue(reading['ph']),
                rawValue: _asNum(reading['ph']),
                minKey: 'ph_min',
                maxKey: 'ph_max',
                unit: '',
                icon: Icons.science_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                title: 'EC',
                value: _formatSensorValue(reading['ec']),
                rawValue: _asNum(reading['ec']),
                minKey: 'ec_min',
                maxKey: 'ec_max',
                unit: 'µS/cm',
                icon: Icons.water_drop_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                title: 'Temperature',
                value: _formatSensorValue(reading['temperature']),
                rawValue: _asNum(reading['temperature']),
                minKey: 'temperature_min',
                maxKey: 'temperature_max',
                unit: '°C',
                icon: Icons.thermostat_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                title: 'ORP',
                value: _formatSensorValue(reading['orp']),
                rawValue: _asNum(reading['orp']),
                minKey: 'orp_min',
                maxKey: 'orp_max',
                unit: 'mV',
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: safely reads a sensor value as a num for comparison,
  // regardless of whether the backend sent it as a number or a
  // string.
  num? _asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required num? rawValue,
    required String minKey,
    required String maxKey,
    required String unit,
    required IconData icon,
  }) {
    final status = _getSensorStatus(
      value: rawValue,
      minKey: minKey,
      maxKey: maxKey,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: FarmTabTheme.grove),
              ),

              const Spacer(),

              // ── Status badge — top-right corner of the card.
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: status.color.withOpacity(0.25)),
                  ),
                  child: Text(
                    status.label,
                    style: FarmTabTheme.font(
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: status.color,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Title + unit together, so the value below never
          // has to wrap onto a second line.
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: FarmTabTheme.font(
                    size: 13,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' ($unit)',
                    style: FarmTabTheme.font(
                      size: 11.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: FarmTabTheme.font(
              size: 19,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSensorValue(dynamic value) {
    if (value == null) {
      return '--';
    }

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    final parsed = double.tryParse(value.toString());

    if (parsed != null) {
      return parsed.toStringAsFixed(2);
    }

    return value.toString();
  }

  Widget _buildNoSensorData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F7F7),
      ),
      child: Center(
        child: Text(
          'No sensor data available.',
          style: FarmTabTheme.font(
            size: 13.5,
            weight: FontWeight.w400,
            color: FarmTabTheme.textM,
          ),
        ),
      ),
    );
  }

  Widget _buildSensorError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F7F7),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 30,
            color: FarmTabTheme.alertRed,
          ),
          const SizedBox(height: 10),
          Text(
            _sensorError ?? 'Unable to load sensor data.',
            textAlign: TextAlign.center,
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _refreshSensorReading,
            style: FarmTabTheme.outlinedButton,
            child: Text(
              'Retry',
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w600,
                color: FarmTabTheme.grove,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEVICE STATUS
  // ============================================================

  Widget _buildDeviceStatusCard() {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (_isConnectingSensor) {
      statusText = 'Connecting...';
      statusIcon = Icons.sync_rounded;
      statusColor = FarmTabTheme.amber;
    } else if (_isSensorLive) {
      statusText = 'Device Online';
      statusIcon = Icons.wifi_rounded;
      statusColor = FarmTabTheme.grove;
    } else {
      statusText = 'Device Offline';
      statusIcon = Icons.wifi_off_rounded;
      statusColor = FarmTabTheme.alertRed;
    }

    final recordedAt = _latestSensorReading?['recorded_at'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: FarmTabTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(statusIcon, size: 21, color: statusColor),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Status',
                  style: FarmTabTheme.font(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.textH,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  statusText,
                  style: FarmTabTheme.font(
                    size: 13,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),

                if (recordedAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Last updated: ${_formatRecordedTime(recordedAt)}',
                    style: FarmTabTheme.font(
                      size: 11.5,
                      weight: FontWeight.w400,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRecordedTime(dynamic recordedAt) {
    if (recordedAt == null) {
      return '--';
    }

    try {
      final dateTime = DateTime.parse(recordedAt.toString()).toLocal();

      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : dateTime.hour == 0
          ? 12
          : dateTime.hour;

      final minute = dateTime.minute.toString().padLeft(2, '0');

      final second = dateTime.second.toString().padLeft(2, '0');

      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute:$second $period';
    } catch (_) {
      return recordedAt.toString();
    }
  }

  String _formatCycleDate(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return date;
    }

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} ${parsed.year}';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }
  // ============================================================
  // HISTORY
  // ============================================================

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Date Range'),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildHistoryDateButton(
                  label: 'Start Date',
                  date: _historyStartDate,
                  onTap: () => _selectHistoryStartDate(),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildHistoryDateButton(
                  label: 'End Date',
                  date: _historyEndDate,
                  onTap: () => _selectHistoryEndDate(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _sectionLabel('Time Interval'),

          const SizedBox(height: 12),

          _buildHistoryIntervalDropdown(),

          const SizedBox(height: 24),

          _buildHistorySensorTabs(),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: FarmTabTheme.cardDecoration,
            child: _buildHistoryChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: FarmTabTheme.font(
                size: 11.5,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: FarmTabTheme.grove,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year}',
                    style: FarmTabTheme.font(
                      size: 14,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectHistoryStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _historyStartDate,
      firstDate: DateTime(2020),
      lastDate: _historyEndDate,
    );

    if (selectedDate == null) return;

    setState(() {
      _historyStartDate = selectedDate;
    });

    await _loadSensorHistory();
  }

  Future<void> _selectHistoryEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _historyEndDate,
      firstDate: _historyStartDate,
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      _historyEndDate = selectedDate;
    });

    await _loadSensorHistory();
  }

  Widget _buildHistoryIntervalDropdown() {
    const intervals = [60, 360, 1440];

    String intervalLabel(int minutes) {
      if (minutes < 60) {
        return '$minutes minutes';
      }

      if (minutes == 60) {
        return '1 hour';
      }

      if (minutes % 60 == 0) {
        return '${minutes ~/ 60} hours';
      }

      return '$minutes minutes';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _historyIntervalMinutes,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FarmTabTheme.textM,
          ),
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w500,
            color: FarmTabTheme.textH,
          ),
          items: intervals.map((interval) {
            return DropdownMenuItem<int>(
              value: interval,
              child: Text(intervalLabel(interval)),
            );
          }).toList(),
          onChanged: (value) async {
            if (value == null) return;

            setState(() {
              _historyIntervalMinutes = value;
            });

            await _loadSensorHistory();
          },
        ),
      ),
    );
  }

  Widget _buildHistorySensorTabs() {
    const sensors = ['pH', 'EC', 'Temp', 'ORP'];

    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(sensors.length, (index) {
          final selected = _selectedHistorySensor == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHistorySensor = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? FarmTabTheme.grove : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  sensors[index],
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: selected ? FarmTabTheme.white : FarmTabTheme.textM,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ------------------------------------------------------------
  // Picks a "nice" axis interval (in milliseconds) based on the
  // total selected range, so labels are evenly spaced and never
  // overlap — independent of how many raw readings came back.
  // ------------------------------------------------------------
  double _niceAxisIntervalMs(Duration totalRange) {
    final hours = totalRange.inMinutes / 60.0;

    if (hours <= 6) {
      return const Duration(hours: 1).inMilliseconds.toDouble();
    } else if (hours <= 24) {
      return const Duration(hours: 3).inMilliseconds.toDouble();
    } else if (hours <= 24 * 3) {
      return const Duration(hours: 12).inMilliseconds.toDouble();
    } else if (hours <= 24 * 10) {
      return const Duration(days: 1).inMilliseconds.toDouble();
    } else if (hours <= 24 * 30) {
      return const Duration(days: 3).inMilliseconds.toDouble();
    } else {
      return const Duration(days: 7).inMilliseconds.toDouble();
    }
  }

  Widget _buildHistoryChart() {
    if (_isLoadingHistory) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: FarmTabTheme.grove),
        ),
      );
    }

    if (_historyError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Text(
          _historyError!,
          textAlign: TextAlign.center,
          style: FarmTabTheme.font(
            size: 13,
            weight: FontWeight.w400,
            color: FarmTabTheme.textB,
          ),
        ),
      );
    }

    if (_sensorHistory.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        alignment: Alignment.center,
        child: Text(
          'No sensor data available for this date range.',
          style: FarmTabTheme.font(
            size: 13,
            weight: FontWeight.w400,
            color: FarmTabTheme.textM,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sensorKey = switch (_selectedHistorySensor) {
      0 => 'ph',
      1 => 'ec',
      2 => 'temperature',
      3 => 'orp',
      _ => 'ph',
    };

    final sensorName = switch (_selectedHistorySensor) {
      0 => 'pH',
      1 => 'EC',
      2 => 'Temperature',
      3 => 'ORP',
      _ => 'pH',
    };

    final sensorUnit = switch (_selectedHistorySensor) {
      0 => '',
      1 => 'µS/cm',
      2 => '°C',
      3 => 'mV',
      _ => '',
    };

    final spots = <FlSpot>[];

    for (int i = 0; i < _sensorHistory.length; i++) {
      final reading = _sensorHistory[i];

      final recordedAt = DateTime.tryParse(
        reading['recorded_at']?.toString() ?? '',
      );

      final value = double.tryParse(reading[sensorKey]?.toString() ?? '');

      if (recordedAt == null || value == null) {
        continue;
      }

      spots.add(FlSpot(recordedAt.millisecondsSinceEpoch.toDouble(), value));
    }

    if (spots.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        alignment: Alignment.center,
        child: Text(
          'No valid sensor data available.',
          style: FarmTabTheme.font(
            size: 13,
            weight: FontWeight.w400,
            color: FarmTabTheme.textM,
          ),
        ),
      );
    }

    final values = spots.map((spot) => spot.y).toList();

    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    } else {
      final padding = (maxY - minY) * 0.22;
      minY -= padding;
      maxY += padding;
    }

    // ------------------------------------------------------------
    // Axis range: always spans exactly the selected date range,
    // starting at 00:00 of the start date, so the first tick the
    // user sees on the left is midnight of the start date.
    // ------------------------------------------------------------
    final rangeStart = DateTime(
      _historyStartDate.year,
      _historyStartDate.month,
      _historyStartDate.day,
    );
    final rangeEnd = DateTime(
      _historyEndDate.year,
      _historyEndDate.month,
      _historyEndDate.day,
      23,
      59,
      59,
    );
    final totalRange = rangeEnd.difference(rangeStart);

    final minX = rangeStart.millisecondsSinceEpoch.toDouble();
    final maxX = rangeEnd.millisecondsSinceEpoch.toDouble();

    final axisIntervalMs = _niceAxisIntervalMs(totalRange);

    // ------------------------------------------------------------
    // Chart width scales with how many ticks the range will need,
    // so short ranges fit the screen and long ranges scroll
    // horizontally instead of squeezing labels on top of each
    // other.
    // ------------------------------------------------------------
    final tickCount = (totalRange.inMilliseconds / axisIntervalMs).ceil();
    const pixelsPerTick = 110.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - 100; // card padding + axis labels
    final chartWidth = math.max(availableWidth, tickCount * pixelsPerTick);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              sensorName,
              style: FarmTabTheme.font(
                size: 15,
                weight: FontWeight.w700,
                color: FarmTabTheme.textH,
              ),
            ),
            if (sensorUnit.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                '($sensorUnit)',
                style: FarmTabTheme.font(
                  size: 12,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
              ),
            ],
            const Spacer(),
            if (chartWidth > availableWidth)
              Row(
                children: [
                  const Icon(
                    Icons.swipe_rounded,
                    size: 14,
                    color: FarmTabTheme.textM,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Scroll to explore',
                    style: FarmTabTheme.font(
                      size: 11,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textM,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 340,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: 340,
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval: axisIntervalMs,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: FarmTabTheme.border, strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: FarmTabTheme.border, strokeWidth: 1),
                  ),

                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: FarmTabTheme.border),
                      bottom: BorderSide(color: FarmTabTheme.border),
                    ),
                  ),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 54,
                        interval: (maxY - minY) / 4,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              value.toStringAsFixed(1),
                              style: FarmTabTheme.font(
                                size: 10.5,
                                weight: FontWeight.w400,
                                color: FarmTabTheme.textM,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: axisIntervalMs,
                        getTitlesWidget: (value, meta) {
                          final dateTime = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          ).toLocal();

                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _formatHistoryXAxisLabel(dateTime),
                              style: FarmTabTheme.font(
                                size: 10,
                                weight: FontWeight.w400,
                                color: FarmTabTheme.textM,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      // Keeps the tooltip fully inside the chart's
                      // drawing area, nudging it down/sideways when
                      // the touched point is close to an edge —
                      // this is what stops the tooltip from getting
                      // clipped off when a point is near the top.
                      fitInsideVertically: true,
                      fitInsideHorizontally: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dateTime = DateTime.fromMillisecondsSinceEpoch(
                            spot.x.toInt(),
                          ).toLocal();

                          return LineTooltipItem(
                            '${_formatHistoryTooltipDate(dateTime)}\n'
                            '${spot.y.toStringAsFixed(2)}'
                            '${sensorUnit.isNotEmpty ? ' $sensorUnit' : ''}',
                            FarmTabTheme.font(
                              size: 12,
                              weight: FontWeight.w600,
                              color: FarmTabTheme.white,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: FarmTabTheme.grove,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: FarmTabTheme.grove,
                            strokeWidth: 1.5,
                            strokeColor: FarmTabTheme.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            FarmTabTheme.mint.withOpacity(0.35),
                            FarmTabTheme.mint.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatHistoryXAxisLabel(DateTime dateTime) {
    final sameDay =
        _historyStartDate.year == _historyEndDate.year &&
        _historyStartDate.month == _historyEndDate.month &&
        _historyStartDate.day == _historyEndDate.day;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (sameDay) {
      // Single-day range: just the time.
      return '$hour:$minute';
    }

    // Multi-day range: always a single, compact line — never two
    // lines, since a wrapped label is what was overflowing into
    // its neighbour and causing the overlap you saw.
    final dateLabel =
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}';

    final isMidnight = dateTime.hour == 0 && dateTime.minute == 0;

    if (isMidnight) {
      return dateLabel;
    }

    return '$dateLabel $hour:$minute';
  }

  String _formatHistoryTooltipDate(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')} '
        '$hour:$minute';
  }
  // ============================================================
  // MORE MENU
  // ============================================================

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: FarmTabTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Shelf Functions',
                      style: FarmTabTheme.font(
                        size: 19,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textH,
                      ),
                    ),
                  ),
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.sensors_rounded,
                  title: 'Sensor Monitoring',
                  function: ShelfFunction.sensorMonitoring,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.tune_rounded,
                  title: 'Threshold Settings',
                  function: ShelfFunction.thresholdSettings,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.settings_rounded,
                  title: 'Shelf Settings',
                  function: ShelfFunction.shelfSettings,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.eco_rounded,
                  title: 'Growth Monitoring',
                  function: ShelfFunction.growthMonitoring,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.science_rounded,
                  title: 'Simulation',
                  function: ShelfFunction.simulation,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.smart_toy_rounded,
                  title: 'AI Assistant',
                  function: ShelfFunction.aiAssistant,
                ),

                _buildFunctionTile(
                  bottomSheetContext: bottomSheetContext,
                  icon: Icons.devices_rounded,
                  title: 'Device Management',
                  function: ShelfFunction.deviceManagement,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionTile({
    required BuildContext bottomSheetContext,
    required IconData icon,
    required String title,
    required ShelfFunction function,
  }) {
    final isSelected = _selectedFunction == function;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? FarmTabTheme.mist : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(bottomSheetContext);

            if (!mounted) return;

            setState(() {
              _selectedFunction = function;
            });

            // Coming back to Sensor Monitoring — refresh thresholds
            // so the Too High/Too Low/Normal badges always compare
            // against the latest saved values, not a stale copy
            // fetched when the page first opened.
            if (function == ShelfFunction.sensorMonitoring) {
              _loadShelfThresholdsForStatus();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? FarmTabTheme.grove : FarmTabTheme.textM,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: FarmTabTheme.font(
                      size: 14.5,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? FarmTabTheme.grove
                          : FarmTabTheme.textB,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: FarmTabTheme.grove,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be implemented later.')),
    );
  }

  void _showStartCycleCalibrationCheck() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Before Starting the Growing Cycle',
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          content: Text(
            'Have you completed sensor calibration?',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textB,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // Open the existing calibration dialog.
                _showCalibrationDialog();
              },
              child: Text(
                'Calibrate Now',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),
            ElevatedButton(
              style: FarmTabTheme.primaryButton,
              onPressed: () {
                Navigator.pop(dialogContext);

                _openThresholdSetup();
              },
              child: Text(
                'Yes, Continue',
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
  }

  Future<void> _openThresholdSetup() async {
    try {
      final shelf = await _shelfService.getShelf(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
      );

      if (!mounted) return;

      setState(() {
        _shelfThresholds = shelf;
      });

      _showThresholdSetupDialog();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showThresholdSetupDialog() {
    if (_shelfThresholds == null) {
      return;
    }

    // ------------------------------------------------------------
    // Threshold controllers
    // These stay alive throughout the entire Start Cycle flow.
    // ------------------------------------------------------------

    final phMinController = TextEditingController(
      text: _shelfThresholds!['ph_min']?.toString() ?? '',
    );

    final phMaxController = TextEditingController(
      text: _shelfThresholds!['ph_max']?.toString() ?? '',
    );

    final ecMinController = TextEditingController(
      text: _shelfThresholds!['ec_min']?.toString() ?? '',
    );

    final ecMaxController = TextEditingController(
      text: _shelfThresholds!['ec_max']?.toString() ?? '',
    );

    final temperatureMinController = TextEditingController(
      text: _shelfThresholds!['temperature_min']?.toString() ?? '',
    );

    final temperatureMaxController = TextEditingController(
      text: _shelfThresholds!['temperature_max']?.toString() ?? '',
    );

    final orpMinController = TextEditingController(
      text: _shelfThresholds!['orp_min']?.toString() ?? '',
    );

    final orpMaxController = TextEditingController(
      text: _shelfThresholds!['orp_max']?.toString() ?? '',
    );

    // ------------------------------------------------------------
    // Cycle setup state
    // ------------------------------------------------------------

    DateTime selectedStartDate = DateTime.now();

    final targetDaysController = TextEditingController(text: '30');

    int currentStep = 0;

    // 0 = Threshold Setup
    // 1 = Cycle Setup
    // 2 = Review

    bool isSavingThresholds = false;

    // ------------------------------------------------------------
    // ONE dialog for the entire flow
    // ------------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ------------------------------------------------------
            // Calculate target harvest date
            // ------------------------------------------------------

            final targetDays = int.tryParse(targetDaysController.text.trim());

            DateTime? targetHarvestDate;

            if (targetDays != null && targetDays > 0) {
              targetHarvestDate = selectedStartDate.add(
                Duration(days: targetDays),
              );
            }

            // ------------------------------------------------------
            // STEP 0 — THRESHOLD SETUP
            // ------------------------------------------------------

            if (currentStep == 0) {
              return AlertDialog(
                backgroundColor: FarmTabTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Monitoring Thresholds',
                  style: FarmTabTheme.font(
                    size: 16,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),

                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review or update the monitoring thresholds '
                        'before starting the growing cycle.',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textB,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildThresholdRow(
                        label: 'pH',
                        icon: Icons.science_rounded,
                        minController: phMinController,
                        maxController: phMaxController,
                      ),

                      const SizedBox(height: 18),

                      _buildThresholdRow(
                        label: 'EC',
                        icon: Icons.water_drop_rounded,
                        unit: 'µS/cm',
                        minController: ecMinController,
                        maxController: ecMaxController,
                      ),

                      const SizedBox(height: 18),

                      _buildThresholdRow(
                        label: 'Temperature',
                        icon: Icons.thermostat_rounded,
                        unit: '°C',
                        minController: temperatureMinController,
                        maxController: temperatureMaxController,
                      ),

                      const SizedBox(height: 18),

                      _buildThresholdRow(
                        label: 'ORP',
                        icon: Icons.bolt_rounded,
                        unit: 'mV',
                        minController: orpMinController,
                        maxController: orpMaxController,
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: isSavingThresholds
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
                    onPressed: isSavingThresholds
                        ? null
                        : () async {
                            // ----------------------------------------
                            // Read threshold values
                            // ----------------------------------------

                            final phMin = double.tryParse(
                              phMinController.text.trim(),
                            );

                            final phMax = double.tryParse(
                              phMaxController.text.trim(),
                            );

                            final ecMin = double.tryParse(
                              ecMinController.text.trim(),
                            );

                            final ecMax = double.tryParse(
                              ecMaxController.text.trim(),
                            );

                            final temperatureMin = double.tryParse(
                              temperatureMinController.text.trim(),
                            );

                            final temperatureMax = double.tryParse(
                              temperatureMaxController.text.trim(),
                            );

                            final orpMin = double.tryParse(
                              orpMinController.text.trim(),
                            );

                            final orpMax = double.tryParse(
                              orpMaxController.text.trim(),
                            );

                            // ----------------------------------------
                            // Validate values
                            // ----------------------------------------

                            if (phMin == null ||
                                phMax == null ||
                                ecMin == null ||
                                ecMax == null ||
                                temperatureMin == null ||
                                temperatureMax == null ||
                                orpMin == null ||
                                orpMax == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter valid values for all thresholds.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (phMin >= phMax ||
                                ecMin >= ecMax ||
                                temperatureMin >= temperatureMax ||
                                orpMin >= orpMax) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Minimum values must be lower than maximum values.',
                                  ),
                                ),
                              );
                              return;
                            }

                            // ----------------------------------------
                            // Save to backend
                            // ----------------------------------------

                            setDialogState(() {
                              isSavingThresholds = true;
                            });

                            try {
                              await _shelfService.updateShelfThresholds(
                                siteId: widget.shelf['site_id'],
                                shelfId: widget.shelf['id'],
                                phMin: phMin,
                                phMax: phMax,
                                ecMin: ecMin,
                                ecMax: ecMax,
                                temperatureMin: temperatureMin,
                                temperatureMax: temperatureMax,
                                orpMin: orpMin,
                                orpMax: orpMax,
                              );

                              // --------------------------------------
                              // Immediately update local values
                              // --------------------------------------

                              _shelfThresholds = {
                                ...?_shelfThresholds,
                                'ph_min': phMin,
                                'ph_max': phMax,
                                'ec_min': ecMin,
                                'ec_max': ecMax,
                                'temperature_min': temperatureMin,
                                'temperature_max': temperatureMax,
                                'orp_min': orpMin,
                                'orp_max': orpMax,
                              };

                              if (!mounted) return;

                              // --------------------------------------
                              // Move to Cycle Setup
                              //
                              // IMPORTANT:
                              // We do NOT close the dialog.
                              // --------------------------------------

                              setDialogState(() {
                                isSavingThresholds = false;
                                currentStep = 1;
                              });
                            } catch (e) {
                              if (!mounted) return;

                              setDialogState(() {
                                isSavingThresholds = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                    child: isSavingThresholds
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: FarmTabTheme.white,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: FarmTabTheme.font(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: FarmTabTheme.white,
                            ),
                          ),
                  ),
                ],
              );
            }

            // ------------------------------------------------------
            // STEP 1 — CYCLE SETUP
            // ------------------------------------------------------

            if (currentStep == 1) {
              final cropType =
                  widget.shelf['crop_type']?.toString() ?? 'Unknown';

              return AlertDialog(
                backgroundColor: FarmTabTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Cycle Setup',
                  style: FarmTabTheme.font(
                    size: 16,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),

                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crop Type',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w600,
                          color: FarmTabTheme.textH,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF7F7F7),
                        ),
                        child: Text(
                          cropType,
                          style: FarmTabTheme.font(
                            size: 14.5,
                            weight: FontWeight.w500,
                            color: FarmTabTheme.textH,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Start Date',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w600,
                          color: FarmTabTheme.textH,
                        ),
                      ),

                      const SizedBox(height: 8),

                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedStartDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: FarmTabTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: FarmTabTheme.grove,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                _formatCycleDate(
                                  selectedStartDate.toIso8601String(),
                                ),
                                style: FarmTabTheme.font(
                                  size: 14.5,
                                  weight: FontWeight.w500,
                                  color: FarmTabTheme.textH,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Target Harvest Days',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w600,
                          color: FarmTabTheme.textH,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: targetDaysController,
                        keyboardType: TextInputType.number,
                        style: FarmTabTheme.font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textH,
                        ),
                        onChanged: (_) {
                          setDialogState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. 30',
                          suffixText: 'days',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
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
                            borderSide: const BorderSide(
                              color: FarmTabTheme.fern,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Target Harvest Date',
                        style: FarmTabTheme.font(
                          size: 13,
                          weight: FontWeight.w600,
                          color: FarmTabTheme.textH,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF7F7F7),
                        ),
                        child: Text(
                          targetHarvestDate == null
                              ? '--'
                              : _formatCycleDate(
                                  targetHarvestDate.toIso8601String(),
                                ),
                          style: FarmTabTheme.font(
                            size: 14.5,
                            weight: FontWeight.w500,
                            color: FarmTabTheme.textH,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
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
                    onPressed: () {
                      if (targetDays == null || targetDays <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid number of harvest days.',
                            ),
                          ),
                        );
                        return;
                      }

                      // ----------------------------------------------
                      // Same dialog → Review
                      // ----------------------------------------------

                      setDialogState(() {
                        currentStep = 2;
                      });
                    },
                    child: Text(
                      'Continue',
                      style: FarmTabTheme.font(
                        size: 13.5,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.white,
                      ),
                    ),
                  ),
                ],
              );
            }

            // ------------------------------------------------------
            // STEP 2 — REVIEW
            // ------------------------------------------------------

            final cropType = widget.shelf['crop_type']?.toString() ?? 'Unknown';

            return AlertDialog(
              backgroundColor: FarmTabTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Review Growing Cycle',
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please review the cycle details before starting.',
                      style: FarmTabTheme.font(
                        size: 13,
                        weight: FontWeight.w400,
                        color: FarmTabTheme.textB,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildReviewItem('Crop Type', cropType),

                    _buildReviewItem(
                      'Start Date',
                      _formatCycleDate(selectedStartDate.toIso8601String()),
                    ),

                    _buildReviewItem(
                      'Target Harvest Days',
                      targetDays == null ? '--' : '$targetDays days',
                    ),

                    _buildReviewItem(
                      'Target Harvest Date',
                      targetHarvestDate == null
                          ? '--'
                          : _formatCycleDate(
                              targetHarvestDate.toIso8601String(),
                            ),
                    ),

                    const SizedBox(height: 12),

                    const Divider(color: FarmTabTheme.border),

                    const SizedBox(height: 12),

                    Text(
                      'Monitoring Thresholds',
                      style: FarmTabTheme.font(
                        size: 14,
                        weight: FontWeight.w700,
                        color: FarmTabTheme.textH,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildThresholdReviewItem(
                      'pH',
                      _shelfThresholds?['ph_min'],
                      _shelfThresholds?['ph_max'],
                    ),

                    _buildThresholdReviewItem(
                      'EC',
                      _shelfThresholds?['ec_min'],
                      _shelfThresholds?['ec_max'],
                      unit: 'µS/cm',
                    ),

                    _buildThresholdReviewItem(
                      'Temperature',
                      _shelfThresholds?['temperature_min'],
                      _shelfThresholds?['temperature_max'],
                      unit: '°C',
                    ),

                    _buildThresholdReviewItem(
                      'ORP',
                      _shelfThresholds?['orp_min'],
                      _shelfThresholds?['orp_max'],
                      unit: 'mV',
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    // Cancel the entire Start Cycle process.
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
                  onPressed: () async {
                    if (targetDays == null || targetDays <= 0) {
                      return;
                    }

                    await _startGrowingCycle(
                      dialogContext: dialogContext,
                      startDate: selectedStartDate,
                      targetHarvestDays: targetDays,
                    );
                  },
                  child: Text(
                    'Start Cycle',
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
    ).then((_) {
      // The whole dialog is now closed.
      // Safe place to dispose the controllers.
      phMinController.dispose();
      phMaxController.dispose();
      ecMinController.dispose();
      ecMaxController.dispose();
      temperatureMinController.dispose();
      temperatureMaxController.dispose();
      orpMinController.dispose();
      orpMaxController.dispose();
      targetDaysController.dispose();
    });
  }

  Widget _buildThresholdRow({
    required String label,
    required IconData icon,
    required TextEditingController minController,
    required TextEditingController maxController,
    String? unit,
  }) {
    InputDecoration fieldDecoration() {
      return InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
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
          borderSide: const BorderSide(color: FarmTabTheme.fern, width: 1.5),
        ),
      );
    }

    // Small label shown ABOVE each field — "Min" / "Max" plus the
    // unit in muted text, e.g. "Min · µS/cm". Keeping the unit out
    // of the field itself means long values are never cut off.
    Widget fieldLabel(String prefix) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: prefix,
                style: FarmTabTheme.font(
                  size: 12,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textB,
                ),
              ),
              if (unit != null)
                TextSpan(
                  text: '  ·  $unit',
                  style: FarmTabTheme.font(
                    size: 11.5,
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
      decoration: BoxDecoration(
        color: FarmTabTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FarmTabTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: FarmTabTheme.mist,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 15, color: FarmTabTheme.grove),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: FarmTabTheme.font(
                  size: 14.5,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Min'),
                    TextField(
                      controller: minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.textH,
                      ),
                      decoration: fieldDecoration(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Max'),
                    TextField(
                      controller: maxController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: FarmTabTheme.font(
                        size: 14.5,
                        weight: FontWeight.w600,
                        color: FarmTabTheme.textH,
                      ),
                      decoration: fieldDecoration(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w600,
                color: FarmTabTheme.textH,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdReviewItem(
    String label,
    dynamic min,
    dynamic max, {
    String unit = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textB,
              ),
            ),
          ),
          Text(
            '${_formatSensorValue(min)} - '
            '${_formatSensorValue(max)}'
            '${unit.isEmpty ? '' : ' $unit'}',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w600,
              color: FarmTabTheme.textH,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startGrowingCycle({
    required BuildContext dialogContext,
    required DateTime startDate,
    required int targetHarvestDays,
  }) async {
    try {
      final startDateString =
          '${startDate.year.toString().padLeft(4, '0')}-'
          '${startDate.month.toString().padLeft(2, '0')}-'
          '${startDate.day.toString().padLeft(2, '0')}';

      await _growingCycleService.createGrowingCycle(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        startDate: startDateString,
        targetHarvestDays: targetHarvestDays,
      );

      if (!mounted) return;

      Navigator.pop(dialogContext);

      await _loadActiveGrowingCycle();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Growing cycle started successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
  // ============================================================
  // CALIBRATION
  // ============================================================

  void _showCalibrationDialog() {
    _referenceController.clear();

    setState(() {
      _isCalibrationOpen = true;
      _isCalibrationRunning = false;
      _calibrationSensor = null;
      _calibrationReferenceValue = null;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: FarmTabTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Calibration',
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: _isCalibrationRunning
                      ? _buildCalibrationMonitoring(context, setDialogState)
                      : _buildCalibrationSetup(context, setDialogState),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _isCalibrationOpen = false;
        _isCalibrationRunning = false;
        _calibrationSensor = null;
        _calibrationReferenceValue = null;
      });

      _referenceController.clear();
    });
  }

  // ============================================================
  // CALIBRATION SETUP
  // ============================================================

  Widget _buildCalibrationSetup(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Sensor',
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w600,
            color: FarmTabTheme.textH,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                activeColor: FarmTabTheme.grove,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'EC',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                ),
                value: 'ec',
                groupValue: _calibrationSensor,
                onChanged: (value) {
                  setDialogState(() {
                    _calibrationSensor = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                activeColor: FarmTabTheme.grove,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'pH',
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                ),
                value: 'ph',
                groupValue: _calibrationSensor,
                onChanged: (value) {
                  setDialogState(() {
                    _calibrationSensor = value;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Reference Value',
          style: FarmTabTheme.font(
            size: 14,
            weight: FontWeight.w600,
            color: FarmTabTheme.textH,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 130,
              child: TextField(
                controller: _referenceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textH,
                ),
                decoration: InputDecoration(
                  hintText: _calibrationSensor == 'ec'
                      ? 'e.g. 1413'
                      : _calibrationSensor == 'ph'
                      ? 'e.g. 7.00'
                      : 'Value',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            if (_calibrationSensor == 'ec') ...[
              const SizedBox(width: 10),
              Text(
                'µS/cm',
                style: FarmTabTheme.font(
                  size: 14,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textB,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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

            const SizedBox(width: 8),

            ElevatedButton(
              style: FarmTabTheme.primaryButton,
              onPressed: () {
                _startCalibration(setDialogState);
              },
              child: Text(
                'Calibrate',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // START CALIBRATION
  // ============================================================

  void _startCalibration(StateSetter setDialogState) {
    if (_calibrationSensor == null) {
      _showCalibrationError(setDialogState, 'Please select EC or pH.');
      return;
    }

    final reference = double.tryParse(_referenceController.text.trim());

    if (reference == null) {
      _showCalibrationError(
        setDialogState,
        'Please enter a valid reference value.',
      );
      return;
    }

    if (reference < 0) {
      _showCalibrationError(
        setDialogState,
        'Reference value cannot be negative.',
      );
      return;
    }

    setState(() {
      _calibrationReferenceValue = reference;
      _isCalibrationRunning = true;
    });

    setDialogState(() {});
  }

  void _showCalibrationError(StateSetter setDialogState, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    setDialogState(() {});
  }

  // ============================================================
  // CALIBRATION MONITORING
  // ============================================================

  Widget _buildCalibrationMonitoring(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    final currentValue = _getCalibrationCurrentValue();

    final recordedAt = _latestSensorReading?['recorded_at'];

    final sensorName = _calibrationSensor == 'ec' ? 'EC' : 'pH';

    final unit = _calibrationSensor == 'ec' ? 'µS/cm' : 'pH';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$sensorName Calibration',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.textH,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: FarmTabTheme.mist,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reference Value',
                style: FarmTabTheme.font(
                  size: 12.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.grove,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${_formatSensorValue(_calibrationReferenceValue)} $unit',
                style: FarmTabTheme.font(
                  size: 23,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: FarmTabTheme.cardDecoration,
          child: Column(
            children: [
              Text(
                'Current $sensorName',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textM,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                currentValue == null
                    ? '--'
                    : '${_formatSensorValue(currentValue)} $unit',
                style: FarmTabTheme.font(
                  size: 29,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSensorLive
                        ? Icons.circle_rounded
                        : Icons.circle_outlined,
                    size: 10,
                    color: _isSensorLive
                        ? FarmTabTheme.grove
                        : FarmTabTheme.textM,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _isSensorLive ? 'Live' : 'Offline',
                    style: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textB,
                    ),
                  ),
                ],
              ),

              if (recordedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last updated: ${_formatRecordedTime(recordedAt)}',
                  style: FarmTabTheme.font(
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Perform the calibration on the physical device. '
          'When you are finished, press Done.',
          style: FarmTabTheme.font(
            size: 13,
            weight: FontWeight.w400,
            color: FarmTabTheme.textB,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: FarmTabTheme.primaryButton,
            onPressed: () {
              _finishCalibration(context, setDialogState);
            },
            child: Text(
              'Done',
              style: FarmTabTheme.font(
                size: 14,
                weight: FontWeight.w600,
                color: FarmTabTheme.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CURRENT CALIBRATION VALUE
  // ============================================================

  double? _getCalibrationCurrentValue() {
    if (_latestSensorReading == null) {
      return null;
    }

    final key = _calibrationSensor == 'ec' ? 'ec' : 'ph';

    final value = _latestSensorReading![key];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  // ============================================================
  // FINISH CALIBRATION
  // ============================================================

  void _finishCalibration(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) {
    final currentValue = _getCalibrationCurrentValue();

    final reference = _calibrationReferenceValue;

    // If no current reading is available,
    // let the user decide what to do.
    if (currentValue == null || reference == null) {
      _showCalibrationWarning(
        dialogContext,
        setDialogState,
        currentValue,
        reference,
      );

      return;
    }

    final difference = (currentValue - reference).abs();

    // Current tolerance:
    // reference ± 5
    if (difference > 5) {
      _showCalibrationWarning(
        dialogContext,
        setDialogState,
        currentValue,
        reference,
      );

      return;
    }

    // Within tolerance.
    Navigator.pop(dialogContext);
  }

  // ============================================================
  // OUTSIDE TOLERANCE WARNING
  // ============================================================

  void _showCalibrationWarning(
    BuildContext parentContext,
    StateSetter setDialogState,
    double? currentValue,
    double? reference,
  ) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (warningContext) {
        final sensorName = _calibrationSensor == 'ec' ? 'EC' : 'pH';

        final unit = _calibrationSensor == 'ec' ? 'µS/cm' : 'pH';

        return AlertDialog(
          backgroundColor: FarmTabTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Calibration Value Check',
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The current value is outside the expected tolerance.',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textB,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Reference: '
                '${_formatSensorValue(reference)} $unit',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textH,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Current: '
                '${currentValue == null ? '--' : _formatSensorValue(currentValue)} $unit',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textH,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Please check the physical device. '
                'You can retry the calibration or confirm to finish anyway.',
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textB,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(warningContext);

                // Stay in the calibration screen.
                // User can continue working with the physical device.
                setDialogState(() {});
              },
              child: Text(
                'Retry',
                style: FarmTabTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.textM,
                ),
              ),
            ),

            ElevatedButton(
              style: FarmTabTheme.primaryButton,
              onPressed: () {
                Navigator.pop(warningContext);
                Navigator.pop(parentContext);
              },
              child: Text(
                'Confirm',
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
  }

  // ============================================================
  // END
  // ============================================================
}

// ─────────────────────────────────────────────────────────────
// GROWTH PROGRESS RING — circular indicator for Growing Cycle
// ─────────────────────────────────────────────────────────────
class _GrowthProgressRing extends StatelessWidget {
  final double progress;
  final int growthDay;

  const _GrowthProgressRing({required this.progress, required this.growthDay});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(92, 92),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: FarmTabTheme.font(
                  size: 17,
                  weight: FontWeight.w800,
                  color: FarmTabTheme.textH,
                ),
              ),
              Text(
                'Day $growthDay',
                style: FarmTabTheme.font(
                  size: 9.5,
                  weight: FontWeight.w500,
                  color: FarmTabTheme.textM,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 9.0;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = FarmTabTheme.mist
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [FarmTabTheme.fern, FarmTabTheme.grove],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
