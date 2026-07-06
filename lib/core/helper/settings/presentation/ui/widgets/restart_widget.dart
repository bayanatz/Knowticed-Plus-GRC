/// Module: Settings · Presentation · Widgets · Restart Widget
/// Description: Wraps a subtree with a rebuildable key so callers can force
///              a full app restart (used after branding/theme changes).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: flutter/material.dart
///*************************** FILE INFO ****************************///
/// File Name: restart_widget.dart
/// Purpose: Force-restart wrapper widget.

import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, this.child});

  final Widget? child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<StatefulWidget> createState() {
    return _RestartWidgetState();
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child ?? Container(),
    );
  }
}
