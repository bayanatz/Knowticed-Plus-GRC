/// Module: messaging / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_list_fit.dart
/// Description: How many chat rows fit on screen before "See More" is needed.
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// "See More" showed whenever a list had more than 3 rows — even with the
/// whole panel empty under them (Moataz: "why see more when I have this
/// space?"). The cut-off is now the number of rows the screen really holds;
/// See More appears only when the list is longer than that.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Rows that fit below the Messages header (one row ≈ 96, header ≈ 380).
/// Fallback when the panel's height is unknown (see [kpMessagingSplit]).
int kpMessagingFitCount(BuildContext context) {
  final double h = MediaQuery.sizeOf(context).height;
  final int n = ((h - 380.sp) / 96.sp).floor();
  return n < 3 ? 3 : n;
}

/// How many group and direct-message rows the "All" list shows before
/// "See More" (ADDED 20/10/2026 — Moataz: "the logic doesn't make sense").
///
/// Before, each list took the rows the whole SCREEN holds, so the two lists
/// together overflowed the panel (it scrolled) and See More showed anyway.
/// Now both share the panel's real [height]: groups get up to half of it,
/// direct messages the rest, and any room left goes back to the groups. When
/// everything fits nobody gets See More. [overhead] = the headers and gaps.
({int groups, int dms}) kpMessagingSplit({
  required double height,
  required int groups,
  required int dms,
  required double overhead,
}) {
  final double groupRow = 80.sp; // card + gap
  final double dmRow = 100.sp; // card + gap
  final double budget = height - overhead;
  if (groups * groupRow + dms * dmRow <= budget) {
    return (groups: groups, dms: dms);
  }
  int g = ((budget / 2) / groupRow).floor().clamp(0, groups);
  final int d = ((budget - g * groupRow) / dmRow).floor().clamp(0, dms);
  g = ((budget - d * dmRow) / groupRow).floor().clamp(0, groups);
  // Never an empty section while it has chats.
  return (
    groups: groups > 0 && g == 0 ? 1 : g,
    dms: dms > 0 && d == 0 ? 1 : d,
  );
}
