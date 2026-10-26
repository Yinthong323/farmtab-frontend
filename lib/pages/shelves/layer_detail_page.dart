import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/layer_service.dart';
import 'shelf_detail_page.dart' show FarmTabTheme;

// ─────────────────────────────────────────────────────────────
// LAYER DETAIL PAGE
// Tab 1 "Overview": cycle status, canopy figures, trend charts
// Tab 2 "History":  every day of the cycle from Day 1, newest first
// ─────────────────────────────────────────────────────────────

class LayerDetailPage extends StatefulWidget {
  final Map<String, dynamic> shelf;

  // One entry from the Growth Monitoring list (layer_id, code, display_name)
  final Map<String, dynamic> layer;

  const LayerDetailPage({super.key, required this.shelf, required this.layer});

  @override
  State<LayerDetailPage> createState() => _LayerDetailPageState();
}

class _LayerDetailPageState extends State<LayerDetailPage>
    with SingleTickerProviderStateMixin {
  final LayerService _layerService = LayerService();

  late final TabController _tabController;

  Map<String, dynamic>? _detail;
  bool _isLoading = true;
  String? _error;

  // 0 = canopy area, 1 = green pixels, 2 = growth rate
  int _chartIndex = 0;

  // Days (in History) currently showing the canopy overlay
  final Set<int> _overlayDays = {};
  bool _heroOverlay = false;

  static const Color _pageBackground = Color(0xFFF6F8F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      if (_detail == null) _isLoading = true;
    });

    try {
      final detail = await _layerService.getLayerDetail(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        layerId: widget.layer['layer_id'] as int,
      );

      if (!mounted) return;

      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ------------------------------------------------------------
  // Data helpers
  // ------------------------------------------------------------

  Map<String, dynamic>? get _cycle => _detail?['cycle'] == null
      ? null
      : Map<String, dynamic>.from(_detail!['cycle'] as Map);

  Map<String, dynamic>? get _summary => _detail?['summary'] == null
      ? null
      : Map<String, dynamic>.from(_detail!['summary'] as Map);

  List<Map<String, dynamic>> get _days {
    final list = (_detail?['days'] as List?) ?? const [];
    return list.map((d) => Map<String, dynamic>.from(d as Map)).toList();
  }

  List<Map<String, dynamic>> get _measuredDays =>
      _days.where((d) => d['canopy_pixels'] != null).toList();

  double? _num(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _thousands(dynamic value) {
    final number = _num(value)?.round();
    if (number == null) return '--';

    final text = number.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }

    return number < 0 ? '-$buffer' : buffer.toString();
  }

  String _compact(double value) {
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value.abs() >= 10) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  static const List<String> _months = [
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

  String _date(dynamic value, {bool withYear = true}) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '--';

    final base = '${date.day} ${_months[date.month - 1]}';
    return withYear ? '$base ${date.year}' : base;
  }

  String _clock(dynamic value) {
    final dateTime = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (dateTime == null) return '';

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final name = widget.layer['display_name']?.toString() ?? 'Layer';
    final code = widget.layer['code']?.toString() ?? '';

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: _buildAppBar(name, code),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String name, String code) {
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: FarmTabTheme.font(
              size: 17,
              weight: FontWeight.w700,
              color: FarmTabTheme.white,
              letterSpacing: -0.2,
            ),
          ),
          Text(
            'Camera $code',
            style: FarmTabTheme.font(
              size: 12,
              weight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
      actions: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _load,
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
                Icons.refresh_rounded,
                size: 19,
                color: FarmTabTheme.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFEB),
        borderRadius: BorderRadius.circular(11),
      ),
      child: TabBar(
        controller: _tabController,
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
          Tab(text: 'Overview'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: FarmTabTheme.grove),
      );
    }

    if (_error != null && _detail == null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildOverviewTab(), _buildHistoryTab()],
    );
  }

  // ============================================================
  // TAB 1 — OVERVIEW
  // ============================================================

  Widget _buildOverviewTab() {
    final cycle = _cycle;

    return RefreshIndicator(
      color: FarmTabTheme.grove,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: cycle == null
            ? [_buildNoCycleState()]
            : [
                _buildCycleCard(cycle),
                const SizedBox(height: 16),
                _buildLatestPhotoCard(),
                const SizedBox(height: 26),
                _sectionTitle('Canopy', 'Latest measured values'),
                const SizedBox(height: 12),
                _buildStatsGrid(),
                const SizedBox(height: 26),
                _sectionTitle('Trends', 'Day by day since transplant'),
                const SizedBox(height: 12),
                _buildChartCard(),
                const SizedBox(height: 14),
                _buildFootnote(),
              ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.textH,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: FarmTabTheme.font(
            size: 12.5,
            weight: FontWeight.w400,
            color: FarmTabTheme.textM,
          ),
        ),
      ],
    );
  }

  // ── Cycle status card ──────────────────────────────────────

  Widget _buildCycleCard(Map<String, dynamic> cycle) {
    final status = cycle['status']?.toString() ?? '';
    final isHarvested = status == 'HARVESTED';
    final day = cycle['current_day'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FarmTabTheme.forest, FarmTabTheme.grove],
        ),
        boxShadow: [
          BoxShadow(
            color: FarmTabTheme.forest.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day badge
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAY',
                  style: FarmTabTheme.font(
                    size: 10.5,
                    weight: FontWeight.w700,
                    color: FarmTabTheme.mint,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${day ?? '--'}',
                  style: FarmTabTheme.font(
                    size: 30,
                    weight: FontWeight.w800,
                    color: FarmTabTheme.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
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
                    color: isHarvested
                        ? FarmTabTheme.amber.withOpacity(0.25)
                        : FarmTabTheme.mint.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isHarvested ? 'Harvested' : 'Growing',
                    style: FarmTabTheme.font(
                      size: 11.5,
                      weight: FontWeight.w700,
                      color: isHarvested
                          ? const Color(0xFFFFD8B5)
                          : FarmTabTheme.mist,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _cycleLine(
                  Icons.event_rounded,
                  'Transplanted ${_date(cycle['transplant_date'])}',
                ),
                const SizedBox(height: 5),
                _cycleLine(
                  Icons.eco_rounded,
                  '${cycle['plant_count'] ?? '--'} plants  \u00B7  '
                  '${cycle['variety'] ?? 'lettuce'}',
                ),
                if (isHarvested) ...[
                  const SizedBox(height: 5),
                  _cycleLine(
                    Icons.agriculture_rounded,
                    'Harvested ${_date(cycle['harvest_date'])}'
                    '${_num(cycle['final_weight_g']) == null ? '' : '  \u00B7  ${_thousands(cycle['final_weight_g'])} g'}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cycleLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: FarmTabTheme.mint),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: FarmTabTheme.font(
              size: 12.5,
              weight: FontWeight.w500,
              color: FarmTabTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Latest photo ───────────────────────────────────────────

  Widget _buildLatestPhotoCard() {
    final withPhoto = _days.where((d) => d['image'] != null).toList();

    if (withPhoto.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: FarmTabTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FarmTabTheme.mist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                color: FarmTabTheme.fern,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No photo in this cycle yet. Cameras take a photo every day at 8:00 PM.',
                style: FarmTabTheme.font(
                  size: 13,
                  weight: FontWeight.w400,
                  color: FarmTabTheme.textB,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final latest = withPhoto.last;
    final image = Map<String, dynamic>.from(latest['image'] as Map);

    final overlay = image['overlay_url']?.toString();
    final hasOverlay = overlay != null && overlay.isNotEmpty;
    final String path = (_heroOverlay && overlay != null && overlay.isNotEmpty)
        ? overlay
        : image['image_url'].toString();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => _openFullImage(
                    'Day ${latest['day']}',
                    path,
                    image['captured_at'],
                  ),
                  child: _networkImage(path),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _darkChip('Day ${latest['day']}  \u00B7  Latest'),
                ),
                if (hasOverlay)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _overlaySwitch(
                      showOverlay: _heroOverlay,
                      onTap: () => setState(() => _heroOverlay = !_heroOverlay),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: FarmTabTheme.textM,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_date(latest['date'], withYear: false)}, ${_clock(image['captured_at'])}',
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textB,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final summary = _summary ?? const {};

    final latestCm2 = _num(summary['latest_cm2']);
    final growth = _num(summary['growth_cm2_per_day']);
    final growthAvg = _num(summary['growth_3day_avg_cm2']);
    final growthPct = _num(summary['growth_pct']);
    final latestDay = summary['latest_day'];

    String growthText = '--';
    if (growth != null) {
      growthText = '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}';
    }

    String growthSub = 'Needs two days with photos';
    if (growth != null) {
      final pct = growthPct == null
          ? ''
          : '${growthPct >= 0 ? '+' : ''}${growthPct.toStringAsFixed(1)}%';
      growthSub = growthAvg == null
          ? pct
          : '3-day avg ${growthAvg >= 0 ? '+' : ''}${growthAvg.toStringAsFixed(1)}  \u00B7  $pct';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statTile(
                icon: Icons.crop_free_rounded,
                label: 'Canopy area',
                value: latestCm2 == null ? '--' : latestCm2.toStringAsFixed(1),
                unit: 'cm\u00B2',
                sub: latestDay == null
                    ? 'No measurement yet'
                    : 'Day $latestDay  \u00B7  approx.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statTile(
                icon: Icons.grain_rounded,
                label: 'Green pixels',
                value: _thousands(summary['latest_pixels']),
                unit: '',
                sub: latestDay == null
                    ? 'No measurement yet'
                    : 'Day $latestDay',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statTile(
                icon: growth != null && growth < 0
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                label: 'Growth rate',
                value: growthText,
                unit: 'cm\u00B2/day',
                sub: growthSub,
                accent: growth != null && growth < 0
                    ? FarmTabTheme.alertRed
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statTile(
                icon: Icons.photo_library_outlined,
                label: 'Days with photos',
                value: '${summary['photo_days'] ?? 0}',
                unit: '/ ${summary['total_days'] ?? 0}',
                sub: 'Days recorded in this cycle',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String sub,
    Color? accent,
  }) {
    final color = accent ?? FarmTabTheme.grove;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: FarmTabTheme.font(
                    size: 22,
                    weight: FontWeight.w800,
                    color: accent ?? FarmTabTheme.textH,
                    letterSpacing: -0.4,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: FarmTabTheme.font(
                      size: 12,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.textM,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FarmTabTheme.font(
              size: 11.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
            ),
          ),
        ],
      ),
    );
  }

  // ── Charts ─────────────────────────────────────────────────

  Widget _buildChartCard() {
    const labels = ['Canopy Area', 'Green Pixels', 'Growth Rate'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart selector
          Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: List.generate(labels.length, (index) {
                final selected = _chartIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _chartIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: selected
                            ? FarmTabTheme.grove
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        labels[index],
                        style: FarmTabTheme.font(
                          size: 12,
                          weight: FontWeight.w600,
                          color: selected
                              ? FarmTabTheme.white
                              : FarmTabTheme.textM,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            switch (_chartIndex) {
              0 => 'Canopy area (cm\u00B2, approx.)',
              1 => 'Green pixels',
              _ => 'Growth rate (cm\u00B2 per day)',
            },
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: _chartIndex == 2 ? _buildGrowthChart() : _buildCanopyChart(),
          ),
        ],
      ),
    );
  }

  Widget _chartEmpty(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.show_chart_rounded,
            size: 34,
            color: Color(0xFFC8D3CB),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: FarmTabTheme.font(
              size: 12.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
            ),
          ),
        ],
      ),
    );
  }

  double _dayInterval(double minX, double maxX) {
    final range = maxX - minX;
    return math.max(1, (range / 6).ceil()).toDouble();
  }

  Widget _dayLabel(double value, TitleMeta meta) {
    if (value != value.roundToDouble()) return const SizedBox.shrink();

    return SideTitleWidget(
      meta: meta,
      child: Text(
        'D${value.toInt()}',
        style: FarmTabTheme.font(
          size: 10.5,
          weight: FontWeight.w500,
          color: FarmTabTheme.textM,
        ),
      ),
    );
  }

  Widget _valueLabel(double value, TitleMeta meta) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        _compact(value),
        textAlign: TextAlign.right,
        style: FarmTabTheme.font(
          size: 10.5,
          weight: FontWeight.w400,
          color: FarmTabTheme.textM,
        ),
      ),
    );
  }

  Widget _buildCanopyChart() {
    final key = _chartIndex == 0 ? 'canopy_cm2' : 'canopy_pixels';
    final unit = _chartIndex == 0 ? ' cm\u00B2' : ' px';

    final spots = <FlSpot>[];

    for (final day in _measuredDays) {
      final x = _num(day['day']);
      final y = _num(day[key]);
      if (x != null && y != null) spots.add(FlSpot(x, y));
    }

    if (spots.isEmpty) {
      return _chartEmpty(
        'Canopy data appears after the first photo of this cycle.',
      );
    }

    final minX = math.max(0.0, spots.first.x - 1);
    final maxX = spots.last.x + 1;
    final maxValue = spots.map((s) => s.y).reduce(math.max);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.18;
    final interval = _dayInterval(minX, maxX);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: FarmTabTheme.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(color: FarmTabTheme.border)),
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
              reservedSize: 44,
              interval: maxY / 4,
              getTitlesWidget: _valueLabel,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: _dayLabel,
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final value = _chartIndex == 0
                    ? spot.y.toStringAsFixed(1)
                    : _thousands(spot.y);

                return LineTooltipItem(
                  'Day ${spot.x.toInt()}\n$value$unit',
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
            curveSmoothness: 0.25,
            preventCurveOverShooting: true,
            color: FarmTabTheme.grove,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: FarmTabTheme.grove,
                  strokeWidth: 2,
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
                  FarmTabTheme.mint.withOpacity(0.45),
                  FarmTabTheme.mint.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    final bars = <BarChartGroupData>[];
    final values = <double>[];

    for (final day in _days) {
      final x = _num(day['day']);
      final y = _num(day['growth_cm2_per_day']);
      if (x == null || y == null) continue;

      values.add(y);
      bars.add(
        BarChartGroupData(
          x: x.toInt(),
          barRods: [
            BarChartRodData(
              toY: y,
              width: 14,
              color: y >= 0 ? FarmTabTheme.fern : FarmTabTheme.alertRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (bars.isEmpty) {
      return _chartEmpty('Growth rate appears once two days have photos.');
    }

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);

    double maxY = math.max(0.0, maxValue) * 1.25;
    double minY = math.min(0.0, minValue) * 1.25;
    if (maxY == 0 && minY == 0) maxY = 1;

    final step = (maxY - minY) / 4;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (value) => FlLine(
            color: value == 0 ? const Color(0xFFBDBDBD) : FarmTabTheme.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
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
              reservedSize: 44,
              interval: step,
              getTitlesWidget: _valueLabel,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: _dayLabel,
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              return BarTooltipItem(
                'Day ${group.x}\n${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)} cm\u00B2/day',
                FarmTabTheme.font(
                  size: 12,
                  weight: FontWeight.w600,
                  color: FarmTabTheme.white,
                ),
              );
            },
          ),
        ),
        barGroups: bars,
      ),
    );
  }

  Widget _buildFootnote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: FarmTabTheme.textM,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Canopy area is an estimate from a fixed side-angle camera. '
            'Compare a layer with itself over time, not with other layers.',
            style: FarmTabTheme.font(
              size: 11.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB 2 — HISTORY
  // ============================================================

  Widget _buildHistoryTab() {
    if (_cycle == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [_buildNoCycleState()],
      );
    }

    final days = _days.reversed.toList();

    return RefreshIndicator(
      color: FarmTabTheme.grove,
      onRefresh: _load,
      child: days.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                SizedBox(
                  height: 260,
                  child: _chartEmpty('No days recorded in this cycle yet.'),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _buildHistoryEntry(days[index]),
            ),
    );
  }

  Widget _dayBadge(dynamic day, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? FarmTabTheme.grove : FarmTabTheme.mist,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Day $day',
        style: FarmTabTheme.font(
          size: 12,
          weight: FontWeight.w700,
          color: highlight ? FarmTabTheme.white : FarmTabTheme.grove,
        ),
      ),
    );
  }

  Widget _buildHistoryEntry(Map<String, dynamic> entry) {
    final dayNumber = entry['day'] as int;
    final isHarvestDay = entry['is_harvest_day'] == true;

    final image = entry['image'] == null
        ? null
        : Map<String, dynamic>.from(entry['image'] as Map);

    // A day without a photo: one compact row
    if (image == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FarmTabTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FarmTabTheme.border),
        ),
        child: Row(
          children: [
            _dayBadge(dayNumber),
            const SizedBox(width: 12),
            Text(
              _date(entry['date']),
              style: FarmTabTheme.font(
                size: 13,
                weight: FontWeight.w600,
                color: FarmTabTheme.textB,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.no_photography_outlined,
              size: 16,
              color: FarmTabTheme.textM,
            ),
            const SizedBox(width: 6),
            Text(
              'No photo',
              style: FarmTabTheme.font(
                size: 12.5,
                weight: FontWeight.w500,
                color: FarmTabTheme.textM,
              ),
            ),
          ],
        ),
      );
    }

    final overlay = image['overlay_url']?.toString();
    final hasOverlay = overlay != null && overlay.isNotEmpty;
    final showOverlay = hasOverlay && _overlayDays.contains(dayNumber);
    final String path = (showOverlay && overlay != null)
        ? overlay
        : image['image_url'].toString();

    final cm2 = _num(entry['canopy_cm2']);
    final growth = _num(entry['growth_cm2_per_day']);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                _dayBadge(dayNumber, highlight: isHarvestDay),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_date(entry['date'])}  \u00B7  ${_clock(image['captured_at'])}',
                    style: FarmTabTheme.font(
                      size: 13,
                      weight: FontWeight.w600,
                      color: FarmTabTheme.textB,
                    ),
                  ),
                ),
                if (isHarvestDay)
                  Text(
                    'Harvest',
                    style: FarmTabTheme.font(
                      size: 12,
                      weight: FontWeight.w700,
                      color: FarmTabTheme.grove,
                    ),
                  ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => _openFullImage(
                    'Day $dayNumber',
                    path,
                    image['captured_at'],
                  ),
                  child: _networkImage(path),
                ),
                if (hasOverlay)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _overlaySwitch(
                      showOverlay: showOverlay,
                      onTap: () {
                        setState(() {
                          if (showOverlay) {
                            _overlayDays.remove(dayNumber);
                          } else {
                            _overlayDays.add(dayNumber);
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _miniStat(
                    'Canopy area',
                    cm2 == null ? '--' : '${cm2.toStringAsFixed(1)} cm\u00B2',
                  ),
                ),
                Expanded(
                  child: _miniStat(
                    'Green pixels',
                    _thousands(entry['canopy_pixels']),
                  ),
                ),
                Expanded(
                  child: _miniStat(
                    'Growth',
                    growth == null
                        ? '--'
                        : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}/day',
                    color: growth != null && growth < 0
                        ? FarmTabTheme.alertRed
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
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
            size: 14,
            weight: FontWeight.w700,
            color: color ?? FarmTabTheme.textH,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHARED PIECES
  // ============================================================

  Widget _networkImage(String path) {
    final url = LayerService.imageUrl(path);

    return Image.network(
      url,
      key: ValueKey(url),
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: const Color(0xFFF2F4F2),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: FarmTabTheme.grove,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF2F4F2),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 30,
            color: Color(0xFFB0B0B0),
          ),
        );
      },
    );
  }

  Widget _darkChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: FarmTabTheme.font(
          size: 11.5,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _overlaySwitch({
    required bool showOverlay,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showOverlay ? Icons.photo_outlined : Icons.layers_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                showOverlay ? 'Photo' : 'Canopy',
                style: FarmTabTheme.font(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullImage(String title, String path, dynamic capturedAt) {
    final url = LayerService.imageUrl(path);
    final when = _clock(capturedAt);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              when.isEmpty ? title : '$title  \u00B7  $when',
              style: FarmTabTheme.font(
                size: 14.5,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoCycleState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: FarmTabTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: FarmTabTheme.mist,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 30,
              color: FarmTabTheme.fern,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No growing cycle yet',
            style: FarmTabTheme.font(
              size: 16,
              weight: FontWeight.w700,
              color: FarmTabTheme.textH,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a cycle for this layer on the Growth Monitoring page. '
            'Its daily photos and canopy trends will appear here.',
            textAlign: TextAlign.center,
            style: FarmTabTheme.font(
              size: 13,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 34,
              color: FarmTabTheme.alertRed,
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Unable to load layer details.',
              textAlign: TextAlign.center,
              style: FarmTabTheme.font(
                size: 13.5,
                weight: FontWeight.w400,
                color: FarmTabTheme.textB,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _load,
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
      ),
    );
  }
}
