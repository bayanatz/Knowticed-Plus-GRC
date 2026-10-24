/// Module: database/db1_create_database
///
///*************************** FILE INFO ****************************///
/// File Name: picked_avatar_row.dart
/// Description: `PickedAvatarRow` widget — its own library so the page stays under 800 lines.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

library;

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';

/// The strip of picked avatars with a red remove badge (Figma 7398:7396).
///
/// Not `StackedAvatars` — that widget overlaps its avatars to save space and
/// has no per-avatar affordance. Here each face has its own tap target.
class PickedAvatarRow extends StatelessWidget {
  const PickedAvatarRow({
    super.key,
    required this.members,
    required this.onRemove,
  });

  final List<DatabaseMember> members;
  final ValueChanged<DatabaseMember> onRemove;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseMember member = members[index];
          return SizedBox(
            width: 34.r,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // Brought in line with the rest of the module.
                //
                // It already had a placeholder, but as a `backgroundImage` plus
                // a CONDITIONAL child: the SVG was drawn only while `photoUrl`
                // was empty, so a photo whose URL 404s left a bare grey circle —
                // the exact case a placeholder exists for. `foregroundImage`
                // draws OVER a child that is always present, so the fallback
                // survives a failed load.
                //
                // The asset was also a hardcoded string; it is
                // `AppAssets.defaultEmployeeAvatar` now — the same constant
                // `MemberGrid` hands the cards directly below this strip.
                CircleAvatar(
                  radius: 15.r,
                  backgroundColor: AppColors.moreLightGrey,
                  foregroundImage:
                      (member.photoUrl == null || member.photoUrl!.isEmpty)
                          ? null
                          : appImageProvider(member.photoUrl!),
                  child: ClipOval(
                    child: CustomSvgImage(
                      assetPath: AppAssets.defaultEmployeeAvatar,
                      width: 30.r,
                      height: 30.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: -2,
                  end: 0,
                  child: GestureDetector(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () => onRemove(member),
                    child: Container(
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 9.r,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
