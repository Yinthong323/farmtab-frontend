import 'package:flutter/material.dart';

import 'growth_style.dart';

// ─────────────────────────────────────────────────────────────
// QUICK ACTIONS: the two things a farmer needs fast on the
// Sensor Monitoring page, Calibration and Thresholds.
// ─────────────────────────────────────────────────────────────

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onCalibrate;
  final VoidCallback onSetThresholds;

  // Not shown any more (the card is kept short). Still accepted so the
  // existing call in shelf_detail_page.dart keeps compiling.
  final String? thresholdSummary;

  const QuickActionsCard({
    super.key,
    required this.onCalibrate,
    required this.onSetThresholds,
    this.thresholdSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GrowthStyle.card(),
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.science_outlined,
              color: GrowthColors.blue,
              background: GrowthColors.blueSoft,
              title: 'Calibration',
              onTap: onCalibrate,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionTile(
              icon: Icons.tune_rounded,
              color: GrowthColors.accentStrong,
              background: GrowthColors.accentSoft,
              title: 'Thresholds',
              onTap: onSetThresholds,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GrowthStyle.text(size: 13.5, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// THRESHOLD DIALOG (thresholds only, no cycle steps)
// Owns its text fields, so they are only disposed after the
// dialog has fully closed.
// ─────────────────────────────────────────────────────────────

class ThresholdQuickDialog extends StatefulWidget {
  // The shelf map, with ph_min, ph_max, ec_min ... orp_max
  final Map<String, dynamic> initial;

  // Saves the values on the server (throws on failure)
  final Future<void> Function(Map<String, double> values) onSave;

  const ThresholdQuickDialog({
    super.key,
    required this.initial,
    required this.onSave,
  });

  @override
  State<ThresholdQuickDialog> createState() => _ThresholdQuickDialogState();
}

class _ThresholdQuickDialogState extends State<ThresholdQuickDialog> {
  static const List<String> _keys = [
    'ph_min',
    'ph_max',
    'ec_min',
    'ec_max',
    'temperature_min',
    'temperature_max',
    'orp_min',
    'orp_max',
  ];

  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    for (final key in _keys) {
      _controllers[key] = TextEditingController(text: _initialText(key));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // 5.50 -> "5.5", 1200.00 -> "1200"
  String _initialText(String key) {
    final value = double.tryParse('${widget.initial[key]}');

    if (value == null) return '';

    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  Future<void> _save() async {
    final values = <String, double>{};

    for (final key in _keys) {
      final parsed = double.tryParse(_controllers[key]!.text.trim());

      if (parsed == null) {
        _toast('Please enter a valid number for every threshold.');
        return;
      }

      values[key] = parsed;
    }

    if (values['ph_min']! >= values['ph_max']! ||
        values['ec_min']! >= values['ec_max']! ||
        values['temperature_min']! >= values['temperature_max']! ||
        values['orp_min']! >= values['orp_max']!) {
      _toast('Each minimum must be lower than its maximum.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(values);

      if (!mounted) return;

      Navigator.pop(context, values);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _row({
    required String label,
    required IconData icon,
    required Color color,
    required Color background,
    required String minKey,
    required String maxKey,
    String? unit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowthColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GrowthStyle.iconChip(icon, color, background, size: 32),
              const SizedBox(width: 10),
              Text(
                label,
                style: GrowthStyle.text(size: 14, weight: FontWeight.w700),
              ),
              if (unit != null) ...[
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: GrowthStyle.text(
                    size: 12,
                    weight: FontWeight.w500,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('Min', minKey)),
              const SizedBox(width: 12),
              Expanded(child: _field('Max', maxKey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: GrowthStyle.text(
              size: 11.5,
              weight: FontWeight.w600,
              color: GrowthColors.body,
            ),
          ),
        ),
        TextField(
          controller: _controllers[key],
          enabled: !_isSaving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GrowthStyle.text(size: 14.5, weight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: GrowthColors.page,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
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
              borderSide: const BorderSide(
                color: GrowthColors.accent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GrowthColors.page,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 4),
      contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      title: Row(
        children: [
          GrowthStyle.iconChip(
            Icons.tune_rounded,
            GrowthColors.accentStrong,
            GrowthColors.accentSoft,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Thresholds',
                  style: GrowthStyle.text(size: 17, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Alerts trigger outside these limits',
                  style: GrowthStyle.text(
                    size: 12,
                    weight: FontWeight.w400,
                    color: GrowthColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _row(
              label: 'pH',
              icon: Icons.science_rounded,
              color: GrowthColors.accentStrong,
              background: GrowthColors.accentSoft,
              minKey: 'ph_min',
              maxKey: 'ph_max',
            ),
            _row(
              label: 'EC',
              icon: Icons.water_drop_rounded,
              color: GrowthColors.blue,
              background: GrowthColors.blueSoft,
              unit: '\u00B5S/cm',
              minKey: 'ec_min',
              maxKey: 'ec_max',
            ),
            _row(
              label: 'Temperature',
              icon: Icons.thermostat_rounded,
              color: GrowthColors.amber,
              background: GrowthColors.amberSoft,
              unit: '\u00B0C',
              minKey: 'temperature_min',
              maxKey: 'temperature_max',
            ),
            _row(
              label: 'ORP',
              icon: Icons.bolt_rounded,
              color: GrowthColors.teal,
              background: GrowthColors.tealSoft,
              unit: 'mV',
              minKey: 'orp_min',
              maxKey: 'orp_max',
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GrowthStyle.text(
              size: 13.5,
              weight: FontWeight.w600,
              color: GrowthColors.muted,
            ),
          ),
        ),
        ElevatedButton(
          style: GrowthStyle.primaryButton,
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save Thresholds',
                  style: GrowthStyle.text(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}
