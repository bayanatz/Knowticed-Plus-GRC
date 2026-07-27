/// Shared layout helper for a form's paired fields. On tablets each child is
/// wrapped in an [Expanded] and laid out in a [Row] with a 10.w gap between
/// them; on phones the children stack in a [Column] with a 15.h gap. This is
/// the single source of truth for the `isTablet ? Row(...) : Column(...)`
/// pattern used across the GRC Control and Policy forms (originally
/// introduced in AddEditControlPage as `_responsiveFieldRow`, promoted here
/// once PolicyControlItemWidget and PolicyInfoFormWidget needed the
/// identical pattern).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcResponsiveFieldRow extends StatelessWidget {
  final bool isTablet;
  final List<Widget> children;

  const GrcResponsiveFieldRow({
    super.key,
    required this.isTablet,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(isTablet ? Expanded(child: children[i]) : children[i]);
      if (i != children.length - 1) {
        spaced.add(isTablet ? SizedBox(width: 10.w) : SizedBox(height: 15.h));
      }
    }
    return isTablet ? Row(children: spaced) : Column(children: spaced);
  }
}
