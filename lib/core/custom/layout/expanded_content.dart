/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: expanded_content.dart
/// Description: Declares `ExpandedContent`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

class ExpandedContent extends StatefulWidget {
  const ExpandedContent({super.key, required this.content, required this.title});
  final String title;
  final Widget content;
  @override
  State<ExpandedContent> createState() => _ExpandedContentState();
}

class _ExpandedContentState extends State<ExpandedContent> {
  bool isHide = false;
  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
            Spacer(),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                isHide = !isHide;
                setState(() {});
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).show : S.of(context).hide,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(height: 1, color: AppColors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Implicit animation: the content expands / collapses smoothly.
        ImplicitExpand(expanded: !isHide, child: widget.content),
      ],
    );
  }
}
