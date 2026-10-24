/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_card.dart
/// Purpose: THE notification card. Every notification list in the app renders
///          this one — the inbox, the Pinned page and the Cleared page.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// There were three cards: the inbox's — the design, Figma 4717:10740 — and a
/// hand-copied one on each of the Pinned and Cleared pages. The copies had
/// drifted, because every fix only ever landed on the page someone happened to
/// be looking at:
///
///   * no timestamp in the corner (the inbox grew one on 22/8/2026);
///   * 10.r body padding against the inbox's 8.r;
///   * no mobile type ramp — the sender chip kept its desktop 12/10/10 sizes
///     and its 40pt avatar at 375px;
///   * sender name / department / job title with no Flexible and no ellipsis,
///     so a long job title overflowed the chip;
///   * action buttons at the app-wide 135.sp rather than the shared width;
///   * the system-sender case handled differently again on each page.
///
/// So this file is the inbox's card, and the pages pass in the only part that
/// genuinely differs — the three action buttons:
///
///   inbox    Message  / Pin    / View
///   pinned   Message  / Unpin  / View
///   cleared  Restore  / Delete / View
///
/// Anything else that differs between the three lists is a bug in one of them,
/// not a reason to fork this widget.
///
/// Updated: 7/10/2026 - Owner round 4: the body shows the FULL message up to
///          3 lines (ellipsis only past the 3rd); action buttons and the
///          module icon box use corner radius 2; To-Do notifications never
///          draw the sender section ([hasSenderSection]) — a to-do is the
///          reader's own card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sender_info.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// One button in a card's action area.
///
/// A description, not a widget: the card owns the sizing — see
/// [NotificationCard.actionButtonWidth] — so a page cannot accidentally hand
/// in a button at a different width and re-open the drift this file exists to
/// close.
class NotificationCardAction {
  const NotificationCardAction({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.background,
    this.foreground,
  });

  final String title;
  final String iconPath;
  final VoidCallback onTap;

  /// Fill. Defaults to [AppColors.primary] — pass one only for a button that
  /// means something else, like Unpin (grey) or Delete (red).
  final Color? background;

  /// Label and icon colour. Defaults to [AppColors.textButton].
  final Color? foreground;
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.employeeController,
    required this.isMobile,
    required this.onTap,
    required this.leadingAction,
    required this.trailingAction,
    this.primaryAction,
  });

  final NotificationModelSystem notification;

  /// Resolves the sender's name, department and job title, and decides whether
  /// a person or the system raised this.
  final MainCoreEmployeeController employeeController;

  final bool isMobile;

  /// Tapping anywhere on the card. Every page opens the notification.
  final VoidCallback onTap;

  /// The wide button above the pair — Message on the inbox and the Pinned
  /// page, Restore on the Cleared page.
  ///
  /// Null draws no button at all. The inbox and the Pinned page pass null for
  /// a SYSTEM notification: Message would have nobody to message.
  final NotificationCardAction? primaryAction;

  /// The pair beneath: Pin / Unpin / Delete on the leading side, View on the
  /// trailing side.
  final NotificationCardAction leadingAction;
  final NotificationCardAction trailingAction;

  /// Shared width for [leadingAction] and [trailingAction]. TIGHTENED
  /// 26/8/2026 from the app-wide 135.sp — these labels are short and the cards
  /// are grid tiles.
  ///
  /// Going lower needs more than a smaller number: ButtonSizing.width() only
  /// honours a fixed width while `label + icon + 12.sp padding either side`
  /// fits inside it and otherwise falls back to sizing each button to its own
  /// content — at which point the two stop matching. [_actionButton] gets
  /// under that floor by pinning the box here and passing
  /// `fixedWidth: double.infinity`; see the note there.
  static double get actionButtonWidth => 65.sp;

  /// Function Name: [moduleIconPath]
  ///
  /// Purpose: The glyph for the module a notification came from.
  ///
  /// Lives here rather than on each page — all three had the same private
  /// copy. Falls back to the generic document glyph for a stored module key
  /// that resolves to no drawer module.
  static String moduleIconPath(String storedModuleKey) {
    final Modules? module =
        NotificationRouting.moduleForStoredKey(storedModuleKey);
    return module?.iconPath ??
        "assets/icons_assets/notification_assets/ic_action_view_document.svg";
  }

  /// The reader's language — NOT the sender's.
  ///
  /// ADDED 30/8/2026 with the bilingual notification document. A stored
  /// notification now carries both renderings, and the card is where the
  /// choice is made, so switching the app to Arabic re-renders the whole inbox
  /// rather than only affecting notifications sent from then on. See the
  /// language note in `notification_data_model.dart`.
  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// Lines of body text a card shows before it ellipsises. Owner round 4
  /// (7/10/2026): "make it fit as a sentence, max 3 lines".
  static const int bodyMaxLines = 3;

  /// Function Name: [hasSenderSection]
  ///
  /// Purpose: Whether a card draws the sender section (avatar chip and the
  /// Message button). The three notification pages use this too, so the card
  /// and the page's `primaryAction` can never disagree.
  ///
  /// False for a system sender, and ALWAYS false for a To-Do notification:
  /// to-dos are personal, so the card is the reader's own (owner, 7/10/2026)
  /// — including To-Do notifications written before they were system-sent,
  /// whose sender is the reader themself.
  ///
  /// Parameters:
  ///   [NotificationModelSystem] notification
  ///   [MainCoreEmployeeController] employeeController
  ///
  /// Return type: [bool]
  static bool hasSenderSection(
    NotificationModelSystem notification,
    MainCoreEmployeeController employeeController,
  ) {
    if (notification.nameOfModule.trim().toLowerCase() == AppModule.todo.key) {
      return false;
    }
    // 23/10/2026 (Moataz: "why is there an avatar without a name?"): an
    // employee record can exist for the sender yet carry no name, and the card
    // then drew a bare avatar and a Message button to nobody. A sender with no
    // name to show is treated as a system sender: no sender section.
    return employeeController.isKnownEmployee(notification.senderEmail) &&
        employeeController
            .getEmployeeName(notification.senderEmail)
            .trim()
            .isNotEmpty;
  }

  // ── Figma 1611-47512 (owner 21/10/2026 14:32) ─────────────────────────
  // Card 133 high (the grid cell), inset 10, strip 5; icon = 30 circle in
  // light yellow with the module icon in yellow; title 12/500 centred on the
  // icon; date small grey at the top-right of the same row; body grey 12;
  // buttons 25 high, radius 4, text 12, icon 16, on the bottom inset:
  //   no sender  → Pin (75) left, View (75) right [+ primary at the left];
  //   sender     → sender box 167×55 (photo 40, name 12, department 10, job
  //                title 10) bottom-left; Message (117) over Pin · View (hug,
  //                6 apart) bottom-right.
  static double get _inset => 10.r;
  static double get _buttonHeight => 25.r;
  static double get _buttonRadius => 4.r;
  static double get _iconBox => 30.r;

  @override
  Widget build(BuildContext context) {
    final String senderName =
        employeeController.getEmployeeName(notification.senderEmail);
    final String senderDepartment = NotificationSenderInfo.departmentName(
      employeeController,
      notification.senderEmail,
      isEnglish: !_isArabic(context),
    );
    final String senderJobTitle =
        employeeController.getEmployeeJobTitle(notification.senderEmail);
    final bool hasHumanSender =
        hasSenderSection(notification, employeeController);

    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // 22/10/2026 — Owner (phone: "the cards don't appear"): in the
        // phone ListView a card has no height limit, and a stretched Row
        // under an unbounded height throws — no card was drawn, and on
        // Pinned / Cleared the rows above them collapsed onto each other.
        // IntrinsicHeight sizes the Row to its content first, so the strip
        // still runs the card's full height. The grid (tablet) is bounded.
        child: _phoneHeight(Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5.w, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(_inset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleRow(context),
                    SizedBox(height: 6.r),
                    Text(
                      notification.displayBodyFor(_isArabic(context)),
                      // two lines on every variant — never "…" on a short
                      // body (C-01); the grid cell is sized for it.
                      // phone: the whole body (3 lines) — owner 14:53.
                      maxLines: isMobile ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize12Weight400.copyWith(
                        height: 1.35,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    // phone cards are content-high (ListView): a fixed gap, not
                    // a Spacer, which needs a bounded height.
                    if (isMobile) SizedBox(height: 10.r) else const Spacer(),
                    _actions(
                      hasHumanSender: hasHumanSender,
                      senderName: senderName,
                      senderDepartment: senderDepartment,
                      senderJobTitle: senderJobTitle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _phoneHeight(Widget row) =>
      isMobile ? IntrinsicHeight(child: row) : row;

  Widget _titleRow(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _iconBox,
            height: _iconBox,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvgImage(
                assetPath: moduleIconPath(notification.nameOfModule),
                width: 16.r,
                height: 16.r,
                color: AppColors.primary,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 5.r),
          Expanded(
            child: SizedBox(
              height: _iconBox,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  notification.titleFor(_isArabic(context)),
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text, height: 1.2),
                  // phone: the title wraps instead of being cut by the date.
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.r),
          Text(
            NotificationRouting.formatTimestamp(
                context, notification.timestamp),
            style: StyleText.fontSize10Weight400
                .copyWith(color: AppColors.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

  Widget _actions({
    required bool hasHumanSender,
    required String senderName,
    required String senderDepartment,
    required String senderJobTitle,
  }) {
    if (!hasHumanSender) {
      return Row(
        children: [
          if (primaryAction != null) ...[
            _button(primaryAction!, width: 117.w),
            SizedBox(width: 6.r),
          ],
          _button(leadingAction, width: 75.w),
          const Spacer(),
          _button(trailingAction, width: 75.w),
        ],
      );
    }
    if (isMobile) {
      // Owner 21/10/2026 14:53: on the phone the sender box takes the full
      // width and the three buttons sit in ONE row under it.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _senderBox(
            senderName: senderName,
            senderDepartment: senderDepartment,
            senderJobTitle: senderJobTitle,
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              if (primaryAction != null) _button(primaryAction!),
              const Spacer(),
              _button(leadingAction),
              SizedBox(width: 6.r),
              _button(trailingAction),
            ],
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Owner 21/10/2026 15:11 (third report of the right gap): this was
        // Flexible(box) + Spacer. Flutter splits the free width between the
        // two flex children, the box uses less than its half, and the unused
        // part lands at the END of the row, so the buttons stopped 30–45
        // short of the inset depending on the sender's name length. One
        // Expanded that holds the box at the start leaves no loose space: the
        // buttons sit on the 10 inset, whatever the name.
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: _senderBox(
              senderName: senderName,
              senderDepartment: senderDepartment,
              senderJobTitle: senderJobTitle,
            ),
          ),
        ),
        SizedBox(width: 8.r),
        // Owner 21/10/2026 14:39: Message is exactly as wide as Pin + 6 +
        // View under it (Figma 117 = 49 + 6 + 63), one right edge on the
        // card's inset.
        IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (primaryAction != null) ...[
                _button(primaryAction!),
                SizedBox(height: 5.r),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _button(leadingAction),
                  SizedBox(width: 6.r),
                  _button(trailingAction),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _senderBox({
    required String senderName,
    required String senderDepartment,
    required String senderJobTitle,
  }) =>
      Container(
        // 167 in Figma; here the box hugs the name up to the room left of
        // the buttons, so a long name is never cut with "…" (C-01).
        height: 55.r,
        padding: EdgeInsets.symmetric(horizontal: 7.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40.r,
              height: 40.r,
              child: ClipOval(
                child: CustomSvgImage(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                  width: 40.r,
                  height: 40.r,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 5.r),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatHelper.capitalize(senderName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text, height: 1.2),
                  ),
                  Text(
                    FormatHelper.capitalize(senderDepartment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: AppColors.secondaryText, height: 1.2),
                  ),
                  Text(
                    FormatHelper.capitalize(senderJobTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: AppColors.secondaryText, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// The Figma card button: 25 high, radius 4, icon 16 + 6 + text 12, in the
  /// brand colour with its readable text; [width] fixed when Figma fixes it.
  Widget _button(NotificationCardAction action, {double? width}) {
    final Color bg = action.background ?? AppColors.primary;
    final Color fg = action.foreground ?? AppTheme.readableOn(bg);
    return InkWell(
      onTapDown: (_) => HapticController.low(),
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(_buttonRadius),
      child: Container(
        // 23/10/2026 (Moataz, Arabic: "غير ..." instead of "غير مثبت"): the
        // button was a fixed 75 wide and clipped a longer label. [width] is now
        // the MINIMUM; the button grows to show the whole label.
        constraints: BoxConstraints(minWidth: width ?? 0),
        height: _buttonHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.r),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: action.iconPath,
              width: 16.r,
              height: 16.r,
              color: fg,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 6.r),
            Flexible(
              child: Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight500.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
