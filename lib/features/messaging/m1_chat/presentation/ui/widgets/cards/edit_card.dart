import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EditCard extends StatelessWidget {
  final String? content;

  // ── ADDED 2/9/2026 ───────────────────────────────────────────────────────
  // Both default to what the card already did. The composer overrides them so
  // the edit preview is exactly as tall as the message field it sits above.

  /// Height box for the card. Defaults to 40–60.h.
  final BoxConstraints? constraints;

  /// Outer margin. Defaults to 8.h along the bottom.
  final EdgeInsetsGeometry? margin;

  /// Pinned at the end of the card, with the text taking what is left —
  /// the composer's ✕.
  final Widget? trailing;

  const EditCard({
    super.key,
    this.content,
    this.constraints,
    this.margin,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      margin: margin ?? EdgeInsets.only(bottom: 8.h),
      width: double.infinity,
      constraints:
          constraints ?? BoxConstraints(maxHeight: 60.h, minHeight: 40.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ContextExtension(context).isPhone
            ? AppColors.darkGrey.withValues(alpha: 0.1)
            : AppColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              content ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
