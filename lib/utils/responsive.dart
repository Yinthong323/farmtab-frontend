import 'package:flutter/material.dart';

class Responsive {
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) {
      return 1;
    }

    if (width < 1024) {
      return 2;
    }

    return 3;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) {
      return 16;
    }

    if (width < 1024) {
      return 24;
    }

    return 32;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1400) {
      return 1400;
    }

    return width;
  }
}
