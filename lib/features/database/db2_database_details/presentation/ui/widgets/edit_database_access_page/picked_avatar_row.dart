/// Module: database/db2_database_details
///
///*************************** FILE INFO ****************************///
/// File Name: picked_avatar_row.dart
/// Description: `EditAccessPickedAvatarRow` widget — its own library so the page stays under 800 lines.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

library;

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_metrics.dart';

/// The strip of picked avatars with a red remove badge.
/// Sizes come off `Ellipse 230` and `Close Circle` in the Figma: a 32pt face
/// on a 40pt pitch (so an 8pt gap) with a 10pt badge pinned to its trailing
/// top corner.
class EditAccessPickedAvatarRow extends StatelessWidget {
  const EditAccessPickedAvatarRow({
    super.key,
    required this.metrics,
    required this.members,
    required this.onRemove,
  });

  final DatabaseDetailsMetrics metrics;
  final List<DatabaseMember> members;
  final ValueChanged<DatabaseMember> onRemove;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final double size = metrics.avatarSize;
    final double badge = metrics.avatarBadgeSize;

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => SizedBox(width: metrics.avatarGap),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseMember member = members[index];

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // A member with no photo shows the default avatar, not a bare
                // grey circle. `backgroundImage: null` is not a placeholder —
                // it is the absence of one, and this strip sits directly above
                // the people cards, which always show a face.
                //
                // `foregroundImage` plus an SVG child, NOT `backgroundImage`:
                // the default avatar is an SVG and `AssetImage` cannot decode
                // one. A foreground image draws OVER the child, so the
                // placeholder shows while a real photo loads and stays visible
                // if the URL 404s. Same arrangement as `AccessTable._avatar`
                // and `PersonChipCard`, which is why these faces now match the
                // cards under them.
                CircleAvatar(
                  radius: size / 2,
                  backgroundColor: AppColors.moreLightGrey,
                  foregroundImage:
                      (member.photoUrl == null || member.photoUrl!.isEmpty)
                          ? null
                          : appImageProvider(member.photoUrl!),
                  child: ClipOval(
                    child: CustomSvgImage(
                      assetPath: AppAssets.defaultEmployeeAvatar,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: GestureDetector(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () => onRemove(member),
                    child: Container(
                      width: badge,
                      height: badge,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: badge * 0.7,
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
