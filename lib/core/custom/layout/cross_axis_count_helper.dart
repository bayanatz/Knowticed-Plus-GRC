/// Module: core/custom/layout
/// Description: Kept for its getCrossAxisCountForDefaultTablet2 callers; the rule itself lives in
///              CrossAxisCountHelperResponsive (custom_grid_view.dart) so
///              there is ONE grid column rule (K-30). Changed 17/10/2026.
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';

abstract class CrossAxisCountHelper {
  static int getCrossAxisCountForDefaultTablet2(BuildContext context) =>
      CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(context);
}
