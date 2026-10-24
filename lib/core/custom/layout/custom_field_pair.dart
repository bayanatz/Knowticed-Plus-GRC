/// Module: core/custom/layout
/// Description: Two fields side by side, TOP-aligned (stacked on the phone).
///              MOVED 17/10/2026 from the Time Tracker (CustomFieldPair).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Two fields side by side, TOP-aligned (stacked on phone).
class CustomFieldPair extends StatelessWidget {
  const CustomFieldPair({super.key, required this.start, this.end});

  final Widget start;
  final Widget? end;

  @override
  Widget build(BuildContext context) {
    final Widget? second = end;
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          start,
          if (second != null) ...<Widget>[SizedBox(height: 15.h), second]
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: start),
        SizedBox(width: 15.w),
        Expanded(child: second ?? const SizedBox.shrink()),
      ],
    );
  }
}
