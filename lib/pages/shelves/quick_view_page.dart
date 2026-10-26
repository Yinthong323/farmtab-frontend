import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/layer_service.dart';
import 'growth_style.dart';

// ─────────────────────────────────────────────────────────────
// QUICK VIEW
// Opens a large photo and lets the user step through the days:
//   mouse wheel, arrow keys (down / up, right / left), Page Up / Down,
//   swipe up / down on a phone, the slider, or the play button.
// Made to see the daily change of a layer clearly.
// ─────────────────────────────────────────────────────────────

class QuickViewPage extends StatefulWidget {
  final String layerName;

  // Days that have a photo, oldest first (entries from the layer detail endpoint)
  final List<Map<String, dynamic>> entries;

  final int startIndex;

  const QuickViewPage({
    super.key,
    required this.layerName,
    required this.entries,
    this.startIndex = 0,
  });

  @override
  State<QuickViewPage> createState() => _QuickViewPageState();
}

class _QuickViewPageState extends State<QuickViewPage> {
  final FocusNode _focusNode = FocusNode();

  late int _index;
  bool _showOverlay = false;
  bool _playing = false;
  Timer? _timer;
  DateTime _lastWheel = DateTime.fromMillisecondsSinceEpoch(0);

  static const Color _background = Color(0xFF121614);

  int get _count => widget.entries.length;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, _count - 1).toInt();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheNeighbours();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Data helpers
  // ------------------------------------------------------------

  Map<String, dynamic> get _entry => widget.entries[_index];

  Map<String, dynamic> get _image =>
      Map<String, dynamic>.from(_entry['image'] as Map);

  String _pathFor(Map<String, dynamic> entry) {
    final image = Map<String, dynamic>.from(entry['image'] as Map);
    final overlay = image['overlay_url']?.toString();

    if (_showOverlay && overlay != null && overlay.isNotEmpty) {
      return overlay;
    }

    return image['image_url'].toString();
  }

  bool get _hasOverlay {
    final overlay = _image['overlay_url']?.toString();
    return overlay != null && overlay.isNotEmpty;
  }

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

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _dateText(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '--';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String _clock(dynamic value) {
    final dateTime = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (dateTime == null) return '';

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  // ------------------------------------------------------------
  // Navigation
  // ------------------------------------------------------------

  void _go(int target) {
    final next = target.clamp(0, _count - 1).toInt();

    if (next == _index) return;

    setState(() {
      _index = next;
    });

    _precacheNeighbours();
  }

  void _next() => _go(_index + 1);
  void _previous() => _go(_index - 1);

  // Loads the next and previous photos in the background so
  // stepping through the days feels instant
  void _precacheNeighbours() {
    for (final offset in const [1, -1, 2]) {
      final i = _index + offset;

      if (i < 0 || i >= _count) continue;

      final url = LayerService.imageUrl(_pathFor(widget.entries[i]));

      precacheImage(NetworkImage(url), context, onError: (_, __) {});
    }
  }

  void _togglePlay() {
    if (_playing) {
      _timer?.cancel();
      setState(() {
        _playing = false;
      });
      return;
    }

    // Start from the first day again if we are already at the end
    if (_index >= _count - 1) {
      setState(() {
        _index = 0;
      });
    }

    setState(() {
      _playing = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;

      if (_index >= _count - 1) {
        timer.cancel();
        setState(() {
          _playing = false;
        });
        return;
      }

      _next();
    });
  }

  void _stopPlaying() {
    if (!_playing) return;

    _timer?.cancel();
    setState(() {
      _playing = false;
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown) {
      _stopPlaying();
      _next();
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp) {
      _stopPlaying();
      _previous();
    } else if (key == LogicalKeyboardKey.home) {
      _stopPlaying();
      _go(0);
    } else if (key == LogicalKeyboardKey.end) {
      _stopPlaying();
      _go(_count - 1);
    } else if (key == LogicalKeyboardKey.space) {
      _togglePlay();
    } else if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    // One wheel turn sends many events; only react a few times a second
    final now = DateTime.now();

    if (now.difference(_lastWheel).inMilliseconds < 140) return;

    _lastWheel = now;

    _stopPlaying();

    if (event.scrollDelta.dy > 0) {
      _next();
    } else if (event.scrollDelta.dy < 0) {
      _previous();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'No photos in this range.',
            style: GrowthStyle.text(color: Colors.white70, size: 14),
          ),
        ),
      );
    }

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildViewer()),
                _buildBottomPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick view  \u00B7  ${widget.layerName}',
                  style: GrowthStyle.text(
                    size: 15,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Scroll, swipe or use the \u2191 \u2193 keys to change day',
                  style: GrowthStyle.text(
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_index + 1} / $_count',
              style: GrowthStyle.text(
                size: 12.5,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    final url = LayerService.imageUrl(_pathFor(_entry));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        _stopPlaying();

        if (velocity < -200) {
          _next(); // swipe up = next day
        } else if (velocity > 200) {
          _previous();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                // Keeps the previous photo on screen until the next one has
                // loaded, so the picture never flashes empty between days
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.white38,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 12,
            child: _overlayChip(
              'Day ${_entry['day']}',
              background: GrowthColors.accent,
              large: true,
            ),
          ),
          if (_hasOverlay)
            Positioned(
              right: 24,
              top: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverlay = !_showOverlay;
                  });
                  _precacheNeighbours();
                },
                child: _overlayChip(
                  _showOverlay ? 'Photo' : 'Canopy',
                  icon: _showOverlay
                      ? Icons.photo_outlined
                      : Icons.layers_rounded,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _overlayChip(
    String text, {
    IconData? icon,
    Color? background,
    bool large = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 11,
        vertical: large ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: background ?? Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GrowthStyle.text(
              size: large ? 14 : 12,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Bottom panel: day info, numbers, slider and controls
  // ------------------------------------------------------------

  Widget _buildBottomPanel() {
    final entry = _entry;
    final image = _image;

    final cm2 = _num(entry['canopy_cm2']);
    final growthPct = _num(entry['growth_pct']);

    final growthText = growthPct == null
        ? '--'
        : '${growthPct >= 0 ? '+' : ''}${growthPct.toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_dateText(entry['date'])}  \u00B7  ${_clock(image['captured_at'])}',
                  style: GrowthStyle.text(size: 13.5, weight: FontWeight.w700),
                ),
              ),
              if (entry['is_harvest_day'] == true)
                GrowthStyle.pill(
                  'Harvest day',
                  GrowthColors.amber,
                  GrowthColors.amberSoft,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _stat(
                  'Green pixels',
                  _thousands(entry['canopy_pixels']),
                ),
              ),
              Expanded(
                child: _stat(
                  'Canopy area',
                  cm2 == null ? '--' : '${cm2.toStringAsFixed(1)} cm\u00B2',
                ),
              ),
              Expanded(
                child: _stat(
                  'vs previous day',
                  growthText,
                  color: growthPct != null && growthPct < 0
                      ? GrowthColors.red
                      : GrowthColors.accentStrong,
                ),
              ),
            ],
          ),
          if (_count > 1) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: GrowthColors.accent,
                inactiveTrackColor: GrowthColors.accentSoft,
                thumbColor: GrowthColors.accent,
                overlayColor: GrowthColors.accent.withOpacity(0.15),
                trackHeight: 4,
              ),
              child: Slider(
                value: _index.toDouble(),
                min: 0,
                max: (_count - 1).toDouble(),
                divisions: _count - 1,
                onChanged: (value) {
                  _stopPlaying();
                  _go(value.round());
                },
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _control(Icons.skip_previous_rounded, 'Previous day',
                  _index > 0 ? () {
                    _stopPlaying();
                    _previous();
                  } : null),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: GrowthColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _control(Icons.skip_next_rounded, 'Next day',
                  _index < _count - 1 ? () {
                    _stopPlaying();
                    _next();
                  } : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GrowthStyle.text(
            size: 11,
            weight: FontWeight.w500,
            color: GrowthColors.muted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GrowthStyle.text(
            size: 16,
            weight: FontWeight.w800,
            color: color ?? GrowthColors.ink,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _control(IconData icon, String tooltip, VoidCallback? onPressed) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 30,
      color: GrowthColors.accentStrong,
      disabledColor: GrowthColors.line,
      icon: Icon(icon),
    );
  }
}