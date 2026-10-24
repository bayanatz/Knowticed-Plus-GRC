// ***************************** FILE INFO ***************************** //
// File Name: hr_table_viewport.dart
// Purpose: Provides a start-aligned scrolling viewport for HR data tables.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:flutter/material.dart';

/// Aligns an HR table to the logical start edge while preserving scrolling.
class HrTableViewport extends StatelessWidget {
  const HrTableViewport({required this.child, super.key});

  final Widget child;

  /// Method Name: [build]
  ///
  /// Purpose: Gives the table the available viewport width when possible and
  /// keeps intrinsic-width tables horizontally scrollable.
  ///
  /// Parameters:
  /// - [context]: Provides the current layout constraints.
  ///
  /// Returns: A vertically and horizontally scrollable table viewport.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : constraints.minWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Owner 21/10/2026: the table itself gets the full width as its minimum (no Align), so it fills the card and its columns share the free width; wider tables still scroll.
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
