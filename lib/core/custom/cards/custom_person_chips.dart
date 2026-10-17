/// Module: core/custom/cards
/// Description: Avatar, removable value chip and removable person chip.
///              MOVED 17/10/2026 from the Time Tracker (CustomAvatar,
///              CustomRemovableChip, CustomPersonChip — owner-approved) to replace
///              the unused RemovableAvatarChip (K-30: one component).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

const String _defaultAvatar =
    'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';

/// Round employee photo (network URL, asset path, or the default avatar).
class CustomAvatar extends StatelessWidget {
  const CustomAvatar({super.key, required this.photo, this.size});

  final String photo;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double s = size ?? 44.r;
    final Widget fallback =
        Image.asset(_defaultAvatar, width: s, height: s, fit: BoxFit.cover);
    final Widget image = photo.startsWith('http')
        ? Image.network(photo,
            width: s,
            height: s,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback)
        : Image.asset(photo.isEmpty ? _defaultAvatar : photo,
            width: s,
            height: s,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback);
    return ClipOval(child: SizedBox(width: s, height: s, child: image));
  }
}

/// A selected value with a red ⊖ (radius 8, one height).
class CustomRemovableChip extends StatelessWidget {
  const CustomRemovableChip({super.key, required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? remove = onRemove;
    return Container(
      height: 30.h,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text)),
          if (remove != null) ...<Widget>[
            SizedBox(width: 6.w),
            GestureDetector(
              onTapDown: (_) => HapticController.high(),
              onTap: () {
                remove();
              },
              child: CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
                  width: 16.r,
                  height: 16.r),
            ),
          ],
        ],
      ),
    );
  }
}

/// ADDED 13/10/2026 (owner U2): a picked person — avatar, name, ✕ to remove.
class CustomPersonChip extends StatelessWidget {
  const CustomPersonChip(
      {super.key,
      required this.name,
      required this.photo,
      required this.onRemove});

  final String name;
  final String photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(4.r, 4.r, 8.r, 4.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomAvatar(photo: photo, size: 24.r),
          SizedBox(width: 6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 140.w),
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text)),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => HapticController.high(),
            onTap: () {
              onRemove();
            },
            child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_action_cancel.svg',
                width: 14.r,
                height: 14.r,
                color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
