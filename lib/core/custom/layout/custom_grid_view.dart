/// Module: core/custom/layout
/// Description: THE grid column rule for every card grid in the app (K-30:
///              one rule, no copies). `CrossAxisCountHelper` and the Qiyas
///              legacy helper delegate here.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Revision History:
///   17/10/2026 — Moataz (chat 17 Oct, closes Q-05): phone = 1 card per row,
///   iPad upright = 2, iPad sideways = 3; bigger screens (desktop / web) grow
///   with the width. The old tablet branch was width-only, so a 13" iPad
///   sideways (1376 pt) counted as a laptop and showed 5 cards.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class CrossAxisCountHelperResponsive {
  static int getCrossAxisCountForDefaultTabletResponsive(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isLandscape = size.width > size.height;

    // `defaultTargetPlatform` instead of dart:io `Platform`: the latter
    // throws on web. Web counts as desktop.
    final bool isDesktop = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (!isDesktop) {
      // Phones and tablets: the device decides, not the raw width.
      final bool isPhone = size.shortestSide < 600;
      if (isPhone) return 1;
      return isLandscape ? 3 : 2;
    }

    // Desktop / web: responsive to the window width.
    if (size.width >= 1920) return isLandscape ? 5 : 4;
    if (size.width >= 1366) return isLandscape ? 4 : 3;
    if (size.width >= 768) return isLandscape ? 3 : 2;
    return 1;
  }
}
