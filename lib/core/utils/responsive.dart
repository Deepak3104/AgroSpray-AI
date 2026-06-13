import 'package:flutter/widgets.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1024;

  static double padding(BuildContext context) {
    if (isDesktop(context)) {
      return 28;
    }
    if (isTablet(context)) {
      return 24;
    }
    return 16;
  }
}
