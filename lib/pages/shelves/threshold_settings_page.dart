// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../services/shelf_service.dart';

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
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   );

//   static InputDecoration fieldDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
//       filled: true,
//       fillColor: const Color(0xFFF7F7F7),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: fern, width: 1.5),
//       ),
//     );
//   }
// }

// class ThresholdSettingsPage extends StatefulWidget {
//   final Map<String, dynamic> shelf;
//   final Map<String, dynamic> organisation;
//   final bool embedded;

//   const ThresholdSettingsPage({
//     super.key,
//     required this.shelf,
//     required this.organisation,
//     this.embedded = false,
//   });

//   @override
//   State<ThresholdSettingsPage> createState() => _ThresholdSettingsPageState();
// }

// class _ThresholdSettingsPageState extends State<ThresholdSettingsPage> {
//   final ShelfService _shelfService = ShelfService();

//   late TextEditingController _phMinController;
//   late TextEditingController _phMaxController;

//   late TextEditingController _ecMinController;
//   late TextEditingController _ecMaxController;

//   late TextEditingController _orpMinController;
//   late TextEditingController _orpMaxController;

//   late TextEditingController _temperatureMinController;
//   late TextEditingController _temperatureMaxController;

//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();

//     _phMinController = TextEditingController(
//       text: '${widget.shelf['ph_min'] ?? ''}',
//     );

//     _phMaxController = TextEditingController(
//       text: '${widget.shelf['ph_max'] ?? ''}',
//     );

//     _ecMinController = TextEditingController(
//       text: '${widget.shelf['ec_min'] ?? ''}',
//     );

//     _ecMaxController = TextEditingController(
//       text: '${widget.shelf['ec_max'] ?? ''}',
//     );

//     _orpMinController = TextEditingController(
//       text: '${widget.shelf['orp_min'] ?? ''}',
//     );

//     _orpMaxController = TextEditingController(
//       text: '${widget.shelf['orp_max'] ?? ''}',
//     );

//     _temperatureMinController = TextEditingController(
//       text: '${widget.shelf['temperature_min'] ?? ''}',
//     );

//     _temperatureMaxController = TextEditingController(
//       text: '${widget.shelf['temperature_max'] ?? ''}',
//     );
//   }

//   @override
//   void dispose() {
//     _phMinController.dispose();
//     _phMaxController.dispose();

//     _ecMinController.dispose();
//     _ecMaxController.dispose();

//     _orpMinController.dispose();
//     _orpMaxController.dispose();

//     _temperatureMinController.dispose();
//     _temperatureMaxController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // SAVE
//   // ============================================================

//   Future<void> _saveThresholds() async {
//     final phMin = double.tryParse(_phMinController.text.trim());
//     final phMax = double.tryParse(_phMaxController.text.trim());

//     final ecMin = double.tryParse(_ecMinController.text.trim());
//     final ecMax = double.tryParse(_ecMaxController.text.trim());

//     final orpMin = double.tryParse(_orpMinController.text.trim());
//     final orpMax = double.tryParse(_orpMaxController.text.trim());

//     final temperatureMin = double.tryParse(
//       _temperatureMinController.text.trim(),
//     );

//     final temperatureMax = double.tryParse(
//       _temperatureMaxController.text.trim(),
//     );

//     if (phMin == null || phMax == null) {
//       _showMessage('Please enter valid pH values.');
//       return;
//     }

//     if (ecMin == null || ecMax == null) {
//       _showMessage('Please enter valid EC values.');
//       return;
//     }

//     if (orpMin == null || orpMax == null) {
//       _showMessage('Please enter valid ORP values.');
//       return;
//     }

//     if (temperatureMin == null || temperatureMax == null) {
//       _showMessage('Please enter valid temperature values.');
//       return;
//     }

//     if (phMin >= phMax) {
//       _showMessage('pH minimum must be lower than maximum.');
//       return;
//     }

//     if (ecMin >= ecMax) {
//       _showMessage('EC minimum must be lower than maximum.');
//       return;
//     }

//     if (orpMin >= orpMax) {
//       _showMessage('ORP minimum must be lower than maximum.');
//       return;
//     }

//     if (temperatureMin >= temperatureMax) {
//       _showMessage('Temperature minimum must be lower than maximum.');
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final result = await _shelfService.updateShelfThresholds(
//         siteId: widget.shelf['site_id'],
//         shelfId: widget.shelf['id'],
//         phMin: phMin,
//         phMax: phMax,
//         ecMin: ecMin,
//         ecMax: ecMax,
//         orpMin: orpMin,
//         orpMax: orpMax,
//         temperatureMin: temperatureMin,
//         temperatureMax: temperatureMax,
//       );

//       if (!mounted) return;

//       final updatedShelf = result['shelf'];

//       if (updatedShelf != null) {
//         widget.shelf['ph_min'] = updatedShelf['ph_min'];
//         widget.shelf['ph_max'] = updatedShelf['ph_max'];

//         widget.shelf['ec_min'] = updatedShelf['ec_min'];
//         widget.shelf['ec_max'] = updatedShelf['ec_max'];

//         widget.shelf['orp_min'] = updatedShelf['orp_min'];
//         widget.shelf['orp_max'] = updatedShelf['orp_max'];

//         widget.shelf['temperature_min'] = updatedShelf['temperature_min'];

//         widget.shelf['temperature_max'] = updatedShelf['temperature_max'];

//         widget.shelf['updated_at'] = updatedShelf['updated_at'];
//       }

//       _showMessage('Thresholds updated successfully.');

//       await Future.delayed(const Duration(milliseconds: 500));

//       if (!mounted) return;

//       if (!widget.embedded) {
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     if (widget.embedded) {
//       return Container(color: FarmTabTheme.white, child: _buildContent());
//     }

//     return Scaffold(
//       backgroundColor: FarmTabTheme.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 3,
//         shadowColor: FarmTabTheme.fern.withOpacity(0.35),
//         centerTitle: false,
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).maybePop(),
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//         ),
//         iconTheme: const IconThemeData(color: FarmTabTheme.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [FarmTabTheme.fern, Color(0xFF52B788)],
//             ),
//           ),
//         ),
//         title: Text(
//           'Threshold Settings',
//           style: FarmTabTheme.font(
//             size: 17,
//             weight: FontWeight.w700,
//             color: FarmTabTheme.white,
//             letterSpacing: -0.2,
//           ),
//         ),
//       ),
//       body: _buildContent(),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.shelf['name'] ?? 'Shelf',
//             style: FarmTabTheme.font(
//               size: 21,
//               weight: FontWeight.w800,
//               color: FarmTabTheme.textH,
//               letterSpacing: -0.3,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             'Configure sensor monitoring thresholds.',
//             style: FarmTabTheme.font(
//               size: 13.5,
//               weight: FontWeight.w400,
//               color: FarmTabTheme.textM,
//             ),
//           ),

//           const SizedBox(height: 22),

//           _buildThresholdCard(
//             title: 'pH',
//             icon: Icons.water_drop_rounded,
//             minController: _phMinController,
//             maxController: _phMaxController,
//           ),

//           const SizedBox(height: 14),

//           _buildThresholdCard(
//             title: 'EC',
//             icon: Icons.science_rounded,
//             minController: _ecMinController,
//             maxController: _ecMaxController,
//             unit: 'µS/cm',
//           ),

//           const SizedBox(height: 14),

//           _buildThresholdCard(
//             title: 'ORP',
//             icon: Icons.bolt_rounded,
//             minController: _orpMinController,
//             maxController: _orpMaxController,
//             unit: 'mV',
//           ),

//           const SizedBox(height: 14),

//           _buildThresholdCard(
//             title: 'Temperature',
//             icon: Icons.thermostat_rounded,
//             minController: _temperatureMinController,
//             maxController: _temperatureMaxController,
//             unit: '°C',
//           ),

//           const SizedBox(height: 26),

//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [FarmTabTheme.grove, FarmTabTheme.fern],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: FarmTabTheme.fern.withOpacity(0.35),
//                   blurRadius: 14,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(12),
//                 onTap: _isSaving ? null : _saveThresholds,
//                 child: SizedBox(
//                   height: 52,
//                   child: Center(
//                     child: _isSaving
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: FarmTabTheme.white,
//                             ),
//                           )
//                         : Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.save_rounded,
//                                 size: 19,
//                                 color: FarmTabTheme.white,
//                               ),
//                               const SizedBox(width: 9),
//                               Text(
//                                 'Save Thresholds',
//                                 style: FarmTabTheme.font(
//                                   size: 14.5,
//                                   weight: FontWeight.w600,
//                                   color: FarmTabTheme.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // THRESHOLD CARD
//   // ============================================================

//   Widget _buildThresholdCard({
//     required String title,
//     required IconData icon,
//     required TextEditingController minController,
//     required TextEditingController maxController,
//     String? unit,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: FarmTabTheme.cardDecoration,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
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

//               const SizedBox(width: 12),

//               Text(
//                 title,
//                 style: FarmTabTheme.font(
//                   size: 16,
//                   weight: FontWeight.w700,
//                   color: FarmTabTheme.textH,
//                 ),
//               ),

//               if (unit != null) ...[
//                 const SizedBox(width: 6),
//                 Text(
//                   '($unit)',
//                   style: FarmTabTheme.font(
//                     size: 12.5,
//                     weight: FontWeight.w400,
//                     color: FarmTabTheme.textM,
//                   ),
//                 ),
//               ],
//             ],
//           ),

//           const SizedBox(height: 16),

//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: minController,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                     signed: true,
//                   ),
//                   style: FarmTabTheme.font(
//                     size: 14,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textH,
//                   ),
//                   decoration: FarmTabTheme.fieldDecoration('Minimum'),
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: TextField(
//                   controller: maxController,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                     signed: true,
//                   ),
//                   style: FarmTabTheme.font(
//                     size: 14,
//                     weight: FontWeight.w500,
//                     color: FarmTabTheme.textH,
//                   ),
//                   decoration: FarmTabTheme.fieldDecoration('Maximum'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/shelf_service.dart';

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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static InputDecoration fieldDecoration(
    String label, {
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: font(size: 13, weight: FontWeight.w500, color: textM),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: hasError
            ? const BorderSide(color: alertRed, width: 1.3)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: hasError ? alertRed : fern, width: 1.5),
      ),
    );
  }
}

class ThresholdSettingsPage extends StatefulWidget {
  final Map<String, dynamic> shelf;
  final Map<String, dynamic> organisation;
  final bool embedded;

  const ThresholdSettingsPage({
    super.key,
    required this.shelf,
    required this.organisation,
    this.embedded = false,
  });

  @override
  State<ThresholdSettingsPage> createState() => _ThresholdSettingsPageState();
}

class _ThresholdSettingsPageState extends State<ThresholdSettingsPage> {
  final ShelfService _shelfService = ShelfService();

  late TextEditingController _phMinController;
  late TextEditingController _phMaxController;

  late TextEditingController _ecMinController;
  late TextEditingController _ecMaxController;

  late TextEditingController _orpMinController;
  late TextEditingController _orpMaxController;

  late TextEditingController _temperatureMinController;
  late TextEditingController _temperatureMaxController;

  bool _isSaving = false;

  // ------------------------------------------------------------
  // Live validation — one error message per card, recomputed on
  // every keystroke so the message appears immediately without
  // needing to press Save.
  // ------------------------------------------------------------
  String? _phError;
  String? _ecError;
  String? _orpError;
  String? _temperatureError;

  @override
  void initState() {
    super.initState();

    _phMinController = TextEditingController(
      text: '${widget.shelf['ph_min'] ?? ''}',
    );

    _phMaxController = TextEditingController(
      text: '${widget.shelf['ph_max'] ?? ''}',
    );

    _ecMinController = TextEditingController(
      text: '${widget.shelf['ec_min'] ?? ''}',
    );

    _ecMaxController = TextEditingController(
      text: '${widget.shelf['ec_max'] ?? ''}',
    );

    _orpMinController = TextEditingController(
      text: '${widget.shelf['orp_min'] ?? ''}',
    );

    _orpMaxController = TextEditingController(
      text: '${widget.shelf['orp_max'] ?? ''}',
    );

    _temperatureMinController = TextEditingController(
      text: '${widget.shelf['temperature_min'] ?? ''}',
    );

    _temperatureMaxController = TextEditingController(
      text: '${widget.shelf['temperature_max'] ?? ''}',
    );

    // Re-validate the relevant card every time any of its fields
    // change, so errors show up live as the user types.
    _phMinController.addListener(_validatePh);
    _phMaxController.addListener(_validatePh);
    _ecMinController.addListener(_validateEc);
    _ecMaxController.addListener(_validateEc);
    _orpMinController.addListener(_validateOrp);
    _orpMaxController.addListener(_validateOrp);
    _temperatureMinController.addListener(_validateTemperature);
    _temperatureMaxController.addListener(_validateTemperature);

    // Run once immediately, in case the shelf already has
    // out-of-range values saved from before.
    _validatePh();
    _validateEc();
    _validateOrp();
    _validateTemperature();
  }

  @override
  void dispose() {
    _phMinController.dispose();
    _phMaxController.dispose();

    _ecMinController.dispose();
    _ecMaxController.dispose();

    _orpMinController.dispose();
    _orpMaxController.dispose();

    _temperatureMinController.dispose();
    _temperatureMaxController.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  // Generic pair validator: checks both values are present, both
  // fall within the allowed range (or are non-negative when
  // maxBound is null), and that min is lower than max.
  String? _validatePair({
    required String minText,
    required String maxText,
    required double lowerBound,
    double? upperBound,
    required String label,
  }) {
    if (minText.trim().isEmpty || maxText.trim().isEmpty) {
      // Both fields empty (e.g. brand new shelf) isn't an error
      // to show yet — only flag it once the user has entered
      // something invalid.
      if (minText.trim().isEmpty && maxText.trim().isEmpty) return null;
      return 'Please enter both minimum and maximum values.';
    }

    final min = double.tryParse(minText.trim());
    final max = double.tryParse(maxText.trim());

    if (min == null || max == null) {
      return 'Please enter valid numbers.';
    }

    final rangeDescription = upperBound != null
        ? 'between $lowerBound and $upperBound'
        : 'zero or higher';

    if (min < lowerBound || (upperBound != null && min > upperBound)) {
      return '$label must be $rangeDescription.';
    }

    if (max < lowerBound || (upperBound != null && max > upperBound)) {
      return '$label must be $rangeDescription.';
    }

    if (min >= max) {
      return 'Minimum must be lower than maximum.';
    }

    return null;
  }

  void _validatePh() {
    setState(() {
      _phError = _validatePair(
        minText: _phMinController.text,
        maxText: _phMaxController.text,
        lowerBound: 0,
        upperBound: 14,
        label: 'pH',
      );
    });
  }

  void _validateEc() {
    setState(() {
      _ecError = _validatePair(
        minText: _ecMinController.text,
        maxText: _ecMaxController.text,
        lowerBound: 0,
        label: 'EC',
      );
    });
  }

  void _validateOrp() {
    setState(() {
      _orpError = _validatePair(
        minText: _orpMinController.text,
        maxText: _orpMaxController.text,
        lowerBound: 0,
        label: 'ORP',
      );
    });
  }

  void _validateTemperature() {
    setState(() {
      _temperatureError = _validatePair(
        minText: _temperatureMinController.text,
        maxText: _temperatureMaxController.text,
        lowerBound: -20,
        upperBound: 50,
        label: 'Temperature',
      );
    });
  }

  bool get _hasAnyError =>
      _phError != null ||
      _ecError != null ||
      _orpError != null ||
      _temperatureError != null;

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveThresholds() async {
    // Re-run validation one final time right before saving, as a
    // safeguard, and bail out silently if anything is still wrong
    // — the inline error text under each card already explains why.
    _validatePh();
    _validateEc();
    _validateOrp();
    _validateTemperature();

    if (_hasAnyError) {
      return;
    }

    final phMin = double.parse(_phMinController.text.trim());
    final phMax = double.parse(_phMaxController.text.trim());

    final ecMin = double.parse(_ecMinController.text.trim());
    final ecMax = double.parse(_ecMaxController.text.trim());

    final orpMin = double.parse(_orpMinController.text.trim());
    final orpMax = double.parse(_orpMaxController.text.trim());

    final temperatureMin = double.parse(_temperatureMinController.text.trim());
    final temperatureMax = double.parse(_temperatureMaxController.text.trim());

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await _shelfService.updateShelfThresholds(
        siteId: widget.shelf['site_id'],
        shelfId: widget.shelf['id'],
        phMin: phMin,
        phMax: phMax,
        ecMin: ecMin,
        ecMax: ecMax,
        orpMin: orpMin,
        orpMax: orpMax,
        temperatureMin: temperatureMin,
        temperatureMax: temperatureMax,
      );

      if (!mounted) return;

      final updatedShelf = result['shelf'];

      if (updatedShelf != null) {
        widget.shelf['ph_min'] = updatedShelf['ph_min'];
        widget.shelf['ph_max'] = updatedShelf['ph_max'];

        widget.shelf['ec_min'] = updatedShelf['ec_min'];
        widget.shelf['ec_max'] = updatedShelf['ec_max'];

        widget.shelf['orp_min'] = updatedShelf['orp_min'];
        widget.shelf['orp_max'] = updatedShelf['orp_max'];

        widget.shelf['temperature_min'] = updatedShelf['temperature_min'];

        widget.shelf['temperature_max'] = updatedShelf['temperature_max'];

        widget.shelf['updated_at'] = updatedShelf['updated_at'];
      }

      _showMessage('Thresholds updated successfully.');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (!widget.embedded) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(color: FarmTabTheme.white, child: _buildContent());
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
          'Threshold Settings',
          style: FarmTabTheme.font(
            size: 17,
            weight: FontWeight.w700,
            color: FarmTabTheme.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shelf['name'] ?? 'Shelf',
            style: FarmTabTheme.font(
              size: 21,
              weight: FontWeight.w800,
              color: FarmTabTheme.textH,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Configure sensor monitoring thresholds.',
            style: FarmTabTheme.font(
              size: 13.5,
              weight: FontWeight.w400,
              color: FarmTabTheme.textM,
            ),
          ),

          const SizedBox(height: 22),

          _buildThresholdCard(
            title: 'pH',
            icon: Icons.water_drop_rounded,
            minController: _phMinController,
            maxController: _phMaxController,
            errorText: _phError,
          ),

          const SizedBox(height: 14),

          _buildThresholdCard(
            title: 'EC',
            icon: Icons.science_rounded,
            minController: _ecMinController,
            maxController: _ecMaxController,
            unit: 'µS/cm',
            errorText: _ecError,
          ),

          const SizedBox(height: 14),

          _buildThresholdCard(
            title: 'ORP',
            icon: Icons.bolt_rounded,
            minController: _orpMinController,
            maxController: _orpMaxController,
            unit: 'mV',
            errorText: _orpError,
          ),

          const SizedBox(height: 14),

          _buildThresholdCard(
            title: 'Temperature',
            icon: Icons.thermostat_rounded,
            minController: _temperatureMinController,
            maxController: _temperatureMaxController,
            unit: '°C',
            errorText: _temperatureError,
          ),

          const SizedBox(height: 26),

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
                onTap: _isSaving ? null : _saveThresholds,
                child: SizedBox(
                  height: 52,
                  child: Center(
                    child: _isSaving
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
                                Icons.save_rounded,
                                size: 19,
                                color: FarmTabTheme.white,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Save Thresholds',
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

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // THRESHOLD CARD
  // ============================================================

  Widget _buildThresholdCard({
    required String title,
    required IconData icon,
    required TextEditingController minController,
    required TextEditingController maxController,
    String? unit,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: FarmTabTheme.cardDecoration.copyWith(
        border: Border.all(
          color: hasError
              ? FarmTabTheme.alertRed.withOpacity(0.4)
              : FarmTabTheme.border,
          width: hasError ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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

              const SizedBox(width: 12),

              Text(
                title,
                style: FarmTabTheme.font(
                  size: 16,
                  weight: FontWeight.w700,
                  color: FarmTabTheme.textH,
                ),
              ),

              if (unit != null) ...[
                const SizedBox(width: 6),
                Text(
                  '($unit)',
                  style: FarmTabTheme.font(
                    size: 12.5,
                    weight: FontWeight.w400,
                    color: FarmTabTheme.textM,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                  decoration: FarmTabTheme.fieldDecoration(
                    'Minimum',
                    hasError: hasError,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: FarmTabTheme.font(
                    size: 14,
                    weight: FontWeight.w500,
                    color: FarmTabTheme.textH,
                  ),
                  decoration: FarmTabTheme.fieldDecoration(
                    'Maximum',
                    hasError: hasError,
                  ),
                ),
              ),
            ],
          ),

          // ── Inline error message — appears live as the user
          // types, without needing to press Save.
          if (hasError) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: FarmTabTheme.alertRed,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText,
                    style: FarmTabTheme.font(
                      size: 12,
                      weight: FontWeight.w500,
                      color: FarmTabTheme.alertRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
