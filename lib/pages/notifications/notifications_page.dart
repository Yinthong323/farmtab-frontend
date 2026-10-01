import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/notification_service.dart';
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
      // Disables ligatures (like the "fi" glyph merge that was
      // hiding the dot on the "i" in "Notifications") so every
      // letter always renders as its own separate glyph.
      fontFeatures: const [
        FontFeature.disable('liga'),
        FontFeature.disable('clig'),
      ],
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

class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic> organisation;

  const NotificationsPage({super.key, required this.organisation});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();

  final ShelfService _shelfService = ShelfService();

  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> _getNotificationsByStatus(String status) {
    return _notifications.where((notification) {
      return notification['status'] == status;
    }).toList();
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    final int notificationId = notification['id'];
    final int siteId = notification['site_id'];
    final int shelfId = notification['shelf_id'];

    try {
      // Mark notification as read if it is unread.
      if (notification['is_read'] == false) {
        await _notificationService.markAsRead(notificationId);

        if (!mounted) return;

        setState(() {
          notification['is_read'] = true;
        });
      }

      // Get the latest shelf information.
      final shelf = await _shelfService.getShelf(
        siteId: siteId,
        shelfId: shelfId,
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
        SnackBar(content: Text('Unable to open notification: $e')),
      );
    }
  }

  String _getSensorDisplayName(String sensorType) {
    switch (sensorType) {
      case 'PH':
        return 'pH';
      case 'EC':
        return 'EC';
      case 'TEMPERATURE':
        return 'Temperature';
      case 'ORP':
        return 'ORP';
      default:
        return sensorType;
    }
  }

  String _getAlertTitle(Map<String, dynamic> notification) {
    final sensorType = _getSensorDisplayName(notification['sensor_type']);

    final alertType = notification['alert_type'];

    if (alertType == 'HIGH') {
      return '$sensorType Too High';
    }

    return '$sensorType Too Low';
  }

  String _getValueDisplay(Map<String, dynamic> notification) {
    final sensorType = notification['sensor_type'];
    final value = notification['value'];

    switch (sensorType) {
      case 'PH':
        return value.toStringAsFixed(2);

      case 'EC':
        return '${value.toStringAsFixed(2)} µS/cm';

      case 'TEMPERATURE':
        return '${value.toStringAsFixed(2)} °C';

      case 'ORP':
        return '${value.toStringAsFixed(2)} mV';

      default:
        return value.toString();
    }
  }

  String _getThresholdDisplay(Map<String, dynamic> notification) {
    final sensorType = notification['sensor_type'];
    final threshold = notification['threshold_value'];

    switch (sensorType) {
      case 'PH':
        return threshold.toStringAsFixed(2);

      case 'EC':
        return '${threshold.toStringAsFixed(2)} µS/cm';

      case 'TEMPERATURE':
        return '${threshold.toStringAsFixed(2)} °C';

      case 'ORP':
        return '${threshold.toStringAsFixed(2)} mV';

      default:
        return threshold.toString();
    }
  }

  String _getTimeDisplay(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();

      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  IconData _getSensorIcon(String sensorType) {
    switch (sensorType) {
      case 'PH':
        return Icons.science_rounded;

      case 'EC':
        return Icons.electric_bolt_rounded;

      case 'TEMPERATURE':
        return Icons.thermostat_rounded;

      case 'ORP':
        return Icons.water_drop_rounded;

      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return FarmTabTheme.alertRed;

      case 'STABILIZING':
        return FarmTabTheme.amber;

      case 'RESOLVED':
        return FarmTabTheme.grove;

      default:
        return FarmTabTheme.textM;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'ACTIVE';

      case 'STABILIZING':
        return 'STABILIZING';

      case 'RESOLVED':
        return 'RESOLVED';

      default:
        return status;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final activeNotifications = _getNotificationsByStatus('ACTIVE');

    final stabilizingNotifications = _getNotificationsByStatus('STABILIZING');

    final resolvedNotifications = _getNotificationsByStatus('RESOLVED');

    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(
        activeNotifications,
        stabilizingNotifications,
        resolvedNotifications,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: FarmTabTheme.grove,
                strokeWidth: 2,
              ),
            )
          : _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(activeNotifications),
                _buildNotificationList(stabilizingNotifications),
                _buildNotificationList(resolvedNotifications),
              ],
            ),
    );
  }

  // ── APP BAR (gradient + embedded pill tab switcher) ─────────

  PreferredSizeWidget _buildAppBar(
    List<Map<String, dynamic>> active,
    List<Map<String, dynamic>> stabilizing,
    List<Map<String, dynamic>> resolved,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: FarmTabTheme.fern.withOpacity(0.35),
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleSpacing: 20,
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
              colors: [FarmTabTheme.fern, Color.fromARGB(255, 112, 212, 167)],
            ),
          ),
        ),
      ),
      title: Text(
        'Notifications',
        style: FarmTabTheme.font(
          size: 18,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: FarmTabTheme.white,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: FarmTabTheme.grove,
              unselectedLabelColor: Colors.white,
              labelPadding: EdgeInsets.zero,
              tabs: [
                _buildTabLabel(
                  'Active',
                  active.any((n) => n['is_read'] == false),
                ),
                _buildTabLabel(
                  'Stabilizing',
                  stabilizing.any((n) => n['is_read'] == false),
                ),
                _buildTabLabel(
                  'Resolved',
                  resolved.any((n) => n['is_read'] == false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabLabel(String label, bool hasUnread) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: FarmTabTheme.font(
              size: 12.5,
              weight: FontWeight.w600,
              color: FarmTabTheme.textH,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(width: 5),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: FarmTabTheme.alertRed,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['is_read'] == true;

    final String status = notification['status'];

    final Color statusColor = _getStatusColor(status);

    final String title = _getAlertTitle(notification);

    final String sensorType = notification['sensor_type'];

    final String value = _getValueDisplay(notification);

    final String threshold = _getThresholdDisplay(notification);

    final String siteName = notification['site_name'];

    final String shelfName = notification['shelf_name'];

    final String cropType = notification['crop_type'];

    final String createdAt = _getTimeDisplay(notification['created_at']);

    return GestureDetector(
      onTap: () => _openNotification(notification),
      child: Container(
        decoration: FarmTabTheme.cardDecoration.copyWith(
          border: Border.all(
            color: isRead ? FarmTabTheme.border : statusColor.withOpacity(0.35),
            width: isRead ? 1 : 1.3,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: icon, title, unread dot
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getSensorIcon(sensorType),
                    size: 20,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: FarmTabTheme.font(
                                size: 15,
                                weight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: FarmTabTheme.textH,
                              ),
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: FarmTabTheme.skyBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '$siteName · $shelfName · $cropType',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FarmTabTheme.font(
                          size: 12.5,
                          weight: FontWeight.w400,
                          color: FarmTabTheme.textM,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: FarmTabTheme.border, height: 1),
            const SizedBox(height: 14),

            // ── Value vs Threshold — organized side by side
            Row(
              children: [
                Expanded(
                  child: _buildReadingBlock(
                    label: 'Reading',
                    value: value,
                    color: statusColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: FarmTabTheme.border,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                ),
                Expanded(
                  child: _buildReadingBlock(
                    label: 'Threshold',
                    value: threshold,
                    color: FarmTabTheme.textB,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Footer: status badge + timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: FarmTabTheme.font(
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: FarmTabTheme.textM,
                ),
                const SizedBox(width: 4),
                Text(
                  createdAt,
                  style: FarmTabTheme.font(
                    size: 11.5,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingBlock({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FarmTabTheme.font(
            size: 11,
            weight: FontWeight.w500,
            color: FarmTabTheme.textM,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: FarmTabTheme.font(
            size: 15,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LIST / EMPTY / ERROR STATES
  // ============================================================

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        color: FarmTabTheme.grove,
        onRefresh: _loadNotifications,
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
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: FarmTabTheme.fern,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Notifications',
                    style: FarmTabTheme.font(
                      size: 18,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textH,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nothing here at the moment.',
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
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
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
                Icons.error_outline_rounded,
                size: 30,
                color: FarmTabTheme.alertRed,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Unable to load notifications',
              style: FarmTabTheme.font(
                size: 17,
                weight: FontWeight.w600,
                color: FarmTabTheme.textH,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w400,
                color: FarmTabTheme.textM,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: Text(
                'Retry',
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
}
