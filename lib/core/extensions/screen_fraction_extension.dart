/// Module: core/extensions
/// Description: `0.05.h` = 5% of the screen height (`.w` width, `.r` the
///              shorter side). MOVED 17/10/2026 out of the theme font file —
///              it is layout, not theme. Still used for ~670 spacings
///              (Org Chart, Settings, Onboarding…); new code uses `.sp`.
library;

import 'dart:math';

import 'package:get/get.dart';

extension ScreenSizeExtension on double {
  double get r {
    return min(Get.height, Get.width) * this;
  }

  double get w {
    return Get.width * this;
  }

  double get h {
    return Get.height * this;
  }
}
