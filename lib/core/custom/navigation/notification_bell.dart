/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: notification_bell.dart
/// Purpose: Declares `NotificationBell` — the ONE notification bell in every
///          app bar (tablet / desktop shell and phone).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner 22/10/2026: the ringing bell (red waves + red circle) is the bell;
/// the unseen count is written INSIDE its circle, and with nothing unseen
/// the bell is drawn in the normal icon colour with only its circle in
/// the primary colour. Before, the app bars swapped
/// between two drawings — the ringing bell (whose "3" was drawn into the
/// file, so it always said 3) and a plain bell with a pink Material badge
/// that "popped" in when something was unseen.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({
    super.key,
    required this.controller,
    required this.size,
  });

  /// Source of the live unseen-notifications stream.
  final AppNotificationCubit controller;

  /// Width and height of the bell.
  final double size;

  static const String asset =
      'assets/icons_assets/main_icons_assets/ic_comms_notification_bell_ring.svg';

  /// Just the circle of [asset], drawn over the bell in the primary colour
  /// when nothing is unseen.
  static const String circleAsset =
      'assets/icons_assets/main_icons_assets/ic_comms_notification_bell_ring_circle.svg';

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  /// Read once: a fresh `snapshots()` on every rebuild re-subscribed and
  /// flashed the waiting state.
  late final Stream<QuerySnapshot>? _unseen =
      widget.controller.getUnseenNotificationsStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _unseen,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        final int count = snapshot.data?.docs.length ?? 0;
        return NotificationBellIcon(count: count, size: widget.size);
      },
    );
  }
}

/// The drawing (public for tests): the ringing bell, [count] inside its circle (22×22 viewBox:
/// circle centre 16.2 / 8.4, inner radius ~3.8).
class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon(
      {super.key, required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double unit = size / 22;
    final String digits = count > 99 ? '99+' : '$count';
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomSvgImage.natural(
              assetPath: NotificationBell.asset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              // Nothing unseen: the bell in the normal icon colour, and only
              // the circle in the primary colour (owner 22/10/2026).
              // Always the icon colour, so the bell matches the gear beside it
              // (Moataz 24/10/2026); the circle is drawn over it below.
              color: AppColors.icon,
            ),
          ),
          Positioned.fill(
            child: CustomSvgImage.natural(
              assetPath: NotificationBell.circleAsset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              // The circle: red when something is unseen, primary when not.
              color: count == 0 ? AppColors.primary : AppColors.red,
            ),
          ),
          // The number is always drawn, 0 included (Moataz 22/10/2026: "show me
          // zero").
          Positioned(
            left: (16.2 - 3.6) * unit,
            top: (8.4 - 3.6) * unit,
            width: 7.2 * unit,
            height: 7.2 * unit,
            child: FittedBox(
              child: Text(
                context.isEnglish
                    ? digits
                    : ArabicDigits(digits).toArabicNumbers(),
                style: StyleText.fontSize16Weight400.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
