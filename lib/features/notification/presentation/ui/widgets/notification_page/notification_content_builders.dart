/// Module: notification/notification_page
///
///*************************** FILE INFO ****************************///
/// File Name: notification_content_builders.dart
/// Description: UI builder methods of `_NotificationContentState` — split out of `notification_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/notification_page.dart';

// Split from notification_page.dart to keep every file under 700 lines.

extension _NotificationContentStateBuilders on _NotificationContentState {
  /// One card. The layout lives in [NotificationCard], shared with the Pinned
  /// and Cleared pages — this only decides what the three buttons do here.
  Widget _buildNotificationCard(
    NotificationModelSystem notification,
    bool isMobile,
    S s,
  ) {
    // No Message button on a system notification (nobody to message) nor on
    // a To-Do one (personal — owner, 7/10/2026). Same rule the card uses.
    final bool hasHumanSender = NotificationCard.hasSenderSection(
      notification,
      widget.employeeController,
    );

    return NotificationCard(
      notification: notification,
      employeeController: widget.employeeController,
      isMobile: isMobile,
      onTap: () => _handleViewNotification(notification),
      primaryAction: hasHumanSender
          ? NotificationCardAction(
              title: s.message,
              iconPath:
                  "assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg",
              onTap: () => _handleMessageSender(notification),
            )
          : null,
      leadingAction: NotificationCardAction(
        // Same button pins and unpins; yellow either way (owner 22/10/2026),
        // so the LABEL says which one it is.
        title: notification.isPinned ? s.unpin : s.pin,
        iconPath: "assets/icons_assets/main_icons_assets/ic_action_pin.svg",
        onTap: () => _handlePinToggle(notification),
      ),
      trailingAction: NotificationCardAction(
        title: s.view,
        iconPath:
            "assets/icons_assets/notification_assets/ic_action_view_document.svg",
        onTap: () => _handleViewNotification(notification),
      ),
    );
  }
}
