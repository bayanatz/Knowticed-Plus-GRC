/// Module: messaging / groups / presentation/ui/widgets/group_avatar.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_avatar.dart
/// Purpose: Declares `GroupAvatar` — a group's picture: its photo, or (no
///          photo) the people icon on the page colour, so a group never shows
///          an empty grey circle.
/// Author: Knowticed Team
/// Created At: 20/10/2026 (owner review of the Messages page)
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';

class GroupAvatar extends StatelessWidget {
  const GroupAvatar(
      {super.key, required this.imageUrl, required this.size, this.radius});

  /// The group's photo (null / empty = the default people icon).
  final String? imageUrl;
  final double size;

  /// Corner radius; null = a circle.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;
    final bool photo = url != null && url.trim().startsWith('http');
    final BorderRadius shape = BorderRadius.circular(radius ?? size / 2);
    return ClipRRect(
      borderRadius: shape,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: AppColors.background,
        child: photo
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _icon(),
              )
            : _icon(),
      ),
    );
  }

  Widget _icon() => CustomSvgImage.natural(
        assetPath: AppAssets.people,
        color: AppColors.text,
        width: size * 0.55,
        height: size * 0.55,
      );
}
