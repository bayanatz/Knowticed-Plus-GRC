import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';

class AdaptiveUiHandler extends StatelessWidget {
  const AdaptiveUiHandler(
      {required this.tabletWidget, required this.mobileWidget, super.key});
  final Widget tabletWidget;
  final Widget mobileWidget;
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    if (isTablet) {
      return tabletWidget;
    } else {
      return mobileWidget;
    }
  }
}
