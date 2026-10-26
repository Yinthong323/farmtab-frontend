import 'package:flutter/material.dart';

import 'shelf_detail_page.dart' show FarmTabTheme;

// ─────────────────────────────────────────────────────────────
// A lighter, fresher palette for the growth pages.
// Only the growth pages use it, so the rest of the app is unchanged.
// ─────────────────────────────────────────────────────────────
class GrowthColors {
  // Surfaces
  static const Color page = Color(0xFFF4F8F5);
  static const Color line = Color(0xFFE5ECE7);

  // Greens (fresh, not dark)
  static const Color accent = Color(0xFF3FB27F);
  static const Color accentStrong = Color(0xFF2A9D6B); // text / icons on white
  static const Color accentSoft = Color(0xFFE4F5EC);
  static const Color accentMid = Color(0xFF9ADDBB);

  // Text
  static const Color ink = Color(0xFF1E2B25);
  static const Color body = Color(0xFF4F5F57);
  static const Color muted = Color(0xFF8A988F);

  // Supporting colours (each stat gets its own tint)
  static const Color teal = Color(0xFF2AA7A1);
  static const Color tealSoft = Color(0xFFE0F5F3);
  static const Color blue = Color(0xFF4F95D1);
  static const Color blueSoft = Color(0xFFE6F1FA);
  static const Color amber = Color(0xFFF2A154);
  static const Color amberSoft = Color(0xFFFDF0E1);
  static const Color red = Color(0xFFE5484D);
  static const Color redSoft = Color(0xFFFCE8E9);
}

class GrowthStyle {
  static BoxDecoration card({Color color = Colors.white, double radius = 20}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: GrowthColors.line),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E2B25).withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle text({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color color = GrowthColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return FarmTabTheme.font(
      size: size,
      weight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: GrowthColors.accent,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle softButton = ElevatedButton.styleFrom(
    backgroundColor: GrowthColors.accentSoft,
    foregroundColor: GrowthColors.accentStrong,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: GrowthColors.accentStrong,
    side: const BorderSide(color: GrowthColors.accentMid),
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle dangerOutlinedButton = OutlinedButton.styleFrom(
    foregroundColor: GrowthColors.red,
    side: const BorderSide(color: Color(0xFFF4B9BE)),
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // A small rounded tag, e.g. "Day 6" or "No cycle"
  static Widget pill(String label, Color textColor, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: text(size: 11, weight: FontWeight.w700, color: textColor),
      ),
    );
  }

  // A rounded square with an icon, used on stat tiles and headers
  static Widget iconChip(
    IconData icon,
    Color color,
    Color background, {
    double size = 36,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
