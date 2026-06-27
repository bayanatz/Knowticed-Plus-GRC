// Responsive layout helper — shows mobileWidget or tabletWidget based on screen size.
import 'package:flutter/material.dart';

class ResponsiveHelper extends StatelessWidget {
  final Widget mobileWidget;
  final Widget tabletWidget;

  const ResponsiveHelper({
    super.key,
    required this.mobileWidget,
    required this.tabletWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return isTablet ? tabletWidget : mobileWidget;
  }
}
