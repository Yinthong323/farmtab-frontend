import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      // Disables ligatures (e.g. the "fi" glyph merge that can
      // hide the dot on the "i") so every letter always renders
      // as its own separate glyph.
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

class ShelfNotificationsPage extends StatefulWidget {
  final int shelfId;
  final String shelfName;

  const ShelfNotificationsPage({
    super.key,
    required this.shelfId,
    required this.shelfName,
  });

  @override
  State<ShelfNotificationsPage> createState() => _ShelfNotificationsPageState();
}

class _ShelfNotificationsPageState extends State<ShelfNotificationsPage>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();

  late TabController _tabController;

  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = true;
  String? _errorMessage;

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
      // Get notifications belonging to this shelf only.
      final notifications = await _notificationService.getShelfNotifications(
        shelfId: widget.shelfId,
      );

      // Opening this page means the user has seen
      // the notifications for this shelf.
      await _notificationService.markShelfNotificationsAsRead(
        shelfId: widget.shelfId,
      );

      // Update local state so they appear as read immediately.
      for (final notification in notifications) {
        notification['is_read'] = true;
      }

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getNotificationsByStatus(String status) {
    return _notifications.where((notification) {
      return notification['status'] == status;
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmTabTheme.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ── APP BAR (gradient + embedded pill tab switcher) ─────────

  PreferredSizeWidget _buildAppBar() {
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
        '${widget.shelfName} Notifications',
        style: FarmTabTheme.font(
          size: 16.5,
          weight: FontWeight.w700,
          color: FarmTabTheme.white,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      bottom: _isLoading || _errorMessage != null
          ? null
          : PreferredSize(
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
                    labelStyle: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.grove,
                    ),
                    unselectedLabelStyle: FarmTabTheme.font(
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'Stabilizing'),
                      Tab(text: 'Resolved'),
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationList(_getNotificationsByStatus('ACTIVE')),
        _buildNotificationList(_getNotificationsByStatus('STABILIZING')),
        _buildNotificationList(_getNotificationsByStatus('RESOLVED')),
      ],
    );
  }

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
                    'Nothing here for this shelf right now.',
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

  // ============================================================
  // NOTIFICATION CARD
  // (Not clickable — same as before, this is an indicator-only
  // list for this specific shelf.)
  // ============================================================

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final sensorType = notification['sensor_type']?.toString() ?? '';

    final alertType = notification['alert_type']?.toString() ?? '';

    final status = notification['status']?.toString() ?? '';

    final value = notification['value']?.toString() ?? '-';

    final threshold = notification['threshold_value']?.toString() ?? '-';

    final createdAt = _getTimeDisplay(
      notification['created_at']?.toString() ?? '',
    );

    final statusColor = _getStatusColor(status);

    return Container(
      decoration: FarmTabTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: icon, title, status badge
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
                child: Text(
                  _getAlertTitle(sensorType, alertType),
                  style: FarmTabTheme.font(
                    size: 15,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.textH,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // This is only an indicator.
              // The card itself is NOT clickable.
              _buildStatusLabel(status),
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

          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: FarmTabTheme.textM),
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

  Widget _buildStatusLabel(String status) {
    String text;

    switch (status) {
      case 'ACTIVE':
        text = 'Active';
        break;

      case 'STABILIZING':
        text = 'Stabilizing';
        break;

      case 'RESOLVED':
        text = 'Resolved';
        break;

      default:
        text = status;
    }

    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: FarmTabTheme.font(
          size: 10.5,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Formats the raw timestamp as DD/MM/YYYY HH:MM:SS — parsing it
  // properly instead of just showing whatever raw string the
  // server sent, and always including seconds.
  // ------------------------------------------------------------
  String _getTimeDisplay(String createdAt) {
    final dateTime = DateTime.tryParse(createdAt)?.toLocal();

    if (dateTime == null) {
      return createdAt;
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute:$second';
  }

  IconData _getSensorIcon(String sensorType) {
    switch (sensorType.toUpperCase()) {
      case 'PH':
        return Icons.science_rounded;

      case 'EC':
        return Icons.bolt_rounded;

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

  String _getAlertTitle(String sensorType, String alertType) {
    String sensorName;

    switch (sensorType.toUpperCase()) {
      case 'PH':
        sensorName = 'pH';
        break;

      case 'EC':
        sensorName = 'EC';
        break;

      case 'TEMPERATURE':
        sensorName = 'Temperature';
        break;

      case 'ORP':
        sensorName = 'ORP';
        break;

      default:
        sensorName = sensorType;
    }

    final direction = alertType.toUpperCase() == 'HIGH' ? 'High' : 'Low';

    return '$sensorName $direction';
  }
}
