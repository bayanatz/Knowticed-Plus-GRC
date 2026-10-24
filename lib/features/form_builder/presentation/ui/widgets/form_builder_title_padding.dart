/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_title_padding.dart
/// Description: The single page-title padding every Form Builder page uses.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Added: 18/8/2026
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// 20.sp on all four sides, applied to the breadcrumb / page title of EVERY
/// page in `form_builder_module`.
///
/// The breadcrumb widgets ship other defaults —
/// `PaginationAppBar` had 30.sp vertical and **no horizontal padding at all**
/// (which is why the title sat flush against the page edge), and
/// `SideFrameMasterServices` uses 15.sp — and both are shared with other
/// modules, so their defaults are deliberately left alone. This value is
/// passed in explicitly at each Form Builder call site instead.
///
/// Change it here, not at a call site: the point of the constant is that the
/// title cannot drift page to page, which is exactly what it did before.
/// Not `const` because `.sp` needs ScreenUtil initialised at call time.
EdgeInsets get formBuilderTitlePadding =>
    EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp);

/// The space a Form Builder page puts ABOVE its first widget.
///
/// On a VERTICAL tablet the gap
/// from the page title to the first widget must be exactly 20.sp. The title
/// row already leaves that (the 20.sp bottom of [formBuilderTitlePadding]),
/// so on a vertical tablet a page adds 0 here. Everywhere else the page's
/// own [other] value is kept, so phones and landscape are unchanged.
double formBuilderTopGap(BuildContext context, double other) {
  final bool isVerticalTablet = ContextExtension(context).isTablett &&
      !ContextExtension(context).isLandscape;
  return isVerticalTablet ? 0 : other;
}
