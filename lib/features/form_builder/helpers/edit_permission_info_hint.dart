/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : edit_permission_info_hint.dart
/// Description: `EditPermissionInfoHint` widget, state and UI of the `EditPermissionInfoHint` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Small hover/tap info indicator shown next to the
///               "edit permission" toggle in the summary/share dialogs.
///               Replaces the former hover_example.dart demo widget (§18)
///               and routes typography through StyleText (§12).
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// A warning icon that reveals an explanatory tooltip on hover (desktop)
/// or tap. Used to explain the "edit permission" option to end users.
class EditPermissionInfoHint extends StatefulWidget {
  const EditPermissionInfoHint({super.key});

  @override
  State<EditPermissionInfoHint> createState() => _EditPermissionInfoHintState();
}

class _EditPermissionInfoHintState extends State<EditPermissionInfoHint> {
  OverlayEntry? _overlayEntry;
  final iconKey = GlobalKey();

  void _showPopup(BuildContext context) {
    final renderBox = iconKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: ContextExtension(context).isPhone ? -70.w + offset.dx : offset.dx,
        top: offset.dy + renderBox.size.height,
        child: Container(
          padding: const EdgeInsets.all(8),
          width: 188,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '• ',
                  style: StyleText.fontSize18Weight400
                      .copyWith(color: AppColors.secondaryBlack)
                      .copyWith(color: AppColors.text),
                ),
                TextSpan(
                  text: S.of(context).fbEditPermissionReviewHint,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: iconKey,
      onEnter: (event) => _showPopup(context),
      onExit: (event) => _hidePopup(),
      child: InkWell(
        onTap: () {},
        splashColor: AppColors.transparent,
        child: CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_warning_exclamation_circle.svg",
          width: 14.w,
          height: 14.h,
          colorFilter: ColorFilter.mode(
            AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
