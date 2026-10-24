/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_shell.dart
/// Purpose: The card shell and small parts every Adding Widget card is built
///          from — `HomeWidgetCard`, `HomeCardButton`, `HomeStatTile`,
///          `HomeEntityRow`, `HomeProgressRow` and the grid constants.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// Figma lays these cards on a fixed grid inside the 1024-wide iPad
/// Horizontal frame: card widths 125 / 265 / 405 / 545 with a 15 gutter, and
/// a card height of 120 (200 for the taller progress-bar card).
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// One grid column.
const double kHomeWidgetNarrowWidth = 125;

/// The ONE gap between stat tiles / action items inside a card (18/10/2026).
const double kHomeTileGap = 16;

/// The THREE-STAT card width — Role Management's, and the narrower of the two
/// widths a stat card may take.
///
/// ADDED 28/8/2026. Role Management carried this as a bare `260` while the
/// cards beside it reached for whichever grid constant looked close, so a row
/// of otherwise identical three-stat cards came out at three different widths.
/// The stat cards now use exactly two widths — this one for three stats and
/// [kHomeWidgetWideWidth] for four — so they line up in the picker and on the
/// home layout. Named here, with the other grid constants, rather than repeated
/// as a literal in each card.
const double kHomeWidgetCompactWidth = 260;

/// Two grid columns — the most common card width.
const double kHomeWidgetWidth = 320;

/// Three grid columns.
const double kHomeWidgetWideWidth = 405;

/// Four grid columns.
const double kHomeWidgetFullWidth = 600;

/// Standard card height.
const double kHomeWidgetHeight = 120;

/// Height of the taller card (Figma: "Services Status").
const double kHomeWidgetTallHeight = 200;

/// SVG assets these cards use. Every path is inside a directory declared in
/// pubspec's `assets:` block, so none of them can fail at runtime.
abstract class HomeWidgetSvg {
  static const String service =
      'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg';
  static const String serviceRequest =
      'assets/icons_assets/main_icons_assets/ic_data_service_requests.svg';
  static const String serviceTap =
      'assets/icons_assets/home_assets/ic_data_service_total.svg';
  static const String sla = 'assets/icons_assets/home_assets/ic_time_sla.svg';
  static const String done =
      'assets/icons_assets/home_assets/ic_status_todo_done.svg';
  static const String approved =
      'assets/icons_assets/home_assets/ic_approved.svg';
  static const String closed = 'assets/icons_assets/home_assets/ic_closed.svg';
  static const String fixed = 'assets/icons_assets/home_assets/ic_fixed.svg';
  static const String open = 'assets/icons_assets/home_assets/ic_open.svg';

  static const String pending =
      'assets/icons_assets/main_icons_assets/ic_pending.svg';
  static const String rejected =
      'assets/icons_assets/home_assets/ic_rejected.svg';
  static const String hourglass =
      'assets/icons_assets/home_assets/ic_status_pending_hourglass.svg';
  static const String checkGreen =
      'assets/icons_assets/main_icons_assets/ic_status_success_small.svg';
  static const String rejectedStamp =
      'assets/icons_assets/home_assets/ic_status_rejected_stamp.svg';
  static const String chat =
      'assets/icons_assets/main_icons_assets/ic_messages_new.svg';
  static const String messages =
      'assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg';
  static const String avatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';
  static const String group =
      'assets/icons_assets/main_icons_assets/ic_user_group.svg';
  static const String bell =
      'assets/icons_assets/main_icons_assets/ic_comms_notification_bell.svg';
  static const String lowStock =
      'assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg';

  // ── Lifecycle statuses ────────────────────────────────────────────────────
  // ADDED 25/8/2026 for the four Roles cards (home_roles_widgets.dart), whose
  // tiles are role / access-grant / account states rather than the request
  // states above. Unlike [approved] / [pending] / [rejected], which carry their
  // own green-orange-red, these are monochrome and are meant to be tinted by
  // the caller with the feature's own status colour (`RoleStatus.color`,
  // `EmployeeStatusStyle.color`) so a tile and its module's screens agree.

  static const String statusActive =
      'assets/icons_assets/home_assets/ic_active_roles.svg';
  static const String statusInactive =
      'assets/icons_assets/home_assets/ic_inactice_roles.svg';

  /// A draft is something still being written — hence the pencil. Figma draws a
  /// bookmark here; there is no bookmark glyph in the app's icon set, and
  /// adding one for a single tile would leave the app with two marks for the
  /// same idea.
  static const String statusDraft =
      'assets/icons_assets/home_assets/ic_draft.svg';

  /// Both "Scheduled" (a grant that has not started) and "Scheduled
  /// Deactivation" — in each case the state is *waiting on a date*.
  static const String statusScheduled =
      'assets/icons_assets/home_assets/ic_scheduled_deactivation.svg';
  static const String statusDeactivated =
      'assets/icons_assets/home_assets/ic_deactivate.svg';
  static const String statusLocked =
      'assets/icons_assets/home_assets/ic_locked.svg';
}

/// The white rounded card every Adding Widget entry sits in.
///
/// Header is `Title ................ [module icon]`, matching Figma, with the
/// body filling whatever height is left.
class HomeWidgetCard extends StatelessWidget {
  /// ADDED 22/10/2026 — Owner: "make the icon a bit bigger" — ONE size for
  /// every home card's title glyph (was 16.r); 20 = ToolbarStyle.iconSize.
  /// The title line (14 Cairo) is taller than 20, so the row does not grow.
  static double get iconSize => 20.r;

  final String title;

  /// Module glyph drawn at the top-right. Null renders no icon.
  final String? icon;

  /// Replaces [icon] when the card needs something richer up there
  /// (Figma: the "20%" on Near Breached SLA).
  final Widget? trailing;

  final Widget child;
  final double width;

  /// Figma's card height, applied as a MINIMUM rather than a fixed size.
  ///
  /// A fixed height would overflow the moment a translation runs longer than
  /// the English string — Arabic labels here are routinely wider — so the card
  /// grows instead of throwing a RenderFlex error. Null removes the floor.
  final double? minHeight;

  /// True for tile cards: the card is exactly as wide as its tiles (no type
  /// minimum), so it ends 16 after the last tile (Owner 21/10/2026).
  final bool hugContent;

  const HomeWidgetCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.width = kHomeWidgetWidth,
    this.minHeight = kHomeWidgetHeight,
    this.hugContent = false,
  });

  @override
  Widget build(BuildContext context) {
    // Owner 21/10/2026 (Figma 2289-37365): the card is its TYPE width
    // (narrow 125 / compact 260 / default 320 / wide 405), never measured
    // from the content; content that needs more only widens it.
    return Container(
      constraints: BoxConstraints(
        // 22/10/2026: never wider than the screen allows — a 4-contact
        // Employee Messages card (468) on a 375 phone spilled past it.
        minWidth: hugContent
            ? 0
            : math.min(width.w, HomeCardMetrics.maxWidthOf(context)),
        minHeight: minHeight == null ? 0 : minHeight!.h,
      ),
      // D-226 (21/10/2026): padding 16 on all four sides (diagonal cut).
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Title and glyph never touch (the card hugs its content).
              if (trailing != null || icon != null) SizedBox(width: 8.w),
              if (trailing != null)
                trailing!
              else if (icon != null)
                CustomSvgImage(
                  assetPath: icon!,
                  width: HomeWidgetCard.iconSize,
                  height: HomeWidgetCard.iconSize,
                  color: AppColors.primary,
                ),
            ],
          ),
          // Owner item 200 (21/10/2026): title, 8, content — the content sits
          // right under the title; a card's spare height is at its bottom,
          // never between the title and the content.
          SizedBox(height: 8.r),
          // Owner 21/10/2026 12:10 (the To-Do checklist card is the pattern):
          // the title stays, the body scrolls DOWN inside the card when
          // there is more than fits; the card never grows.
          // 12:19: a body that fits spreads down to the bottom inset (its
          // column uses spaceBetween); one that does not fit scrolls.
          Expanded(
            child: HomeCardBodyViewport(
              child: SingleChildScrollView(
                child: HomeCardBodyFill(child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The small yellow pill button used inside the cards.
///
/// Deliberately not `customButton` (core 5): that one enforces a 135/150.sp
/// app-wide width, which is wider than these 125-wide cards.
class HomeCardButton extends StatelessWidget {
  final String label;

  /// Optional leading glyph, as Figma draws on "Create Form", "Asset", etc.
  final String? icon;

  final VoidCallback? onTap;
  final Color? color;

  /// Stretch to the parent's width. Figma's stacked action buttons do.
  final bool fullWidth;

  const HomeCardButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // 18/10/2026 (Moataz): card buttons carry no icon — label only.

        Flexible(
          child: Text(
            label,
            // Owner item 198 / D-117 (21/10/2026): button text 12.
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.textButton),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return InkWell(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        // Owner 21/10/2026 (Figma 2289-37365): a button INSIDE a home card
        // is small — 24 high, radius 4, text 12, full card width, so the
        // stacked buttons share one left and one right edge.
        // 12:26: .r, not .h — the landscape height scale (1.34) made 24 into 32
        // and three buttons overflowed the card.
        width: fullWidth ? double.infinity : null,
        height: 24.r,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: content,
      ),
    );
  }
}

/// Stacked [HomeCardButton]s spread so every visible gap is the SAME —
/// title → first button, button → button, last button → card edge
/// (Owner 21/10/2026, "diagonal cut": the padding divided equally). The card
/// already has 8 under the title and 16 at the bottom; the gaps make up the
/// rest. Falls back to 8 apart when the card is too short to spread.
class HomeCardButtonStack extends StatelessWidget {
  const HomeCardButtonStack({super.key, required this.buttons});

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    // The card measures its width from its content's intrinsic width, which
    // a LayoutBuilder cannot report (the card blew up to full width). An
    // invisible plain column gives the size; the spread layout is drawn over
    // it.
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        ExcludeSemantics(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              // Smallest gap (2): this column only supplies the WIDTH and a
              // floor height; at 8 it was taller than the card body and made
              // the body scroll, cutting the last button.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2.r,
                children: buttons,
              ),
            ),
          ),
        ),
        Positioned.fill(child: _spread()),
      ],
    );
  }

  Widget _spread() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final int n = buttons.length;
        final double b = 24.r; // HomeCardButton height
        final double title = 8.r; // HomeWidgetCard: title, 8, body
        final double bottom = 16.r; // HomeWidgetCard bottom padding
        double k = 0;
        if (box.maxHeight.isFinite && n > 0) {
          k = (box.maxHeight - n * b + title + bottom) / (n + 1);
        }
        if (k < bottom) {
          // 23/10/2026 (Moataz: "the third button is cut"): 8 apart did not
          // fit three buttons in the fixed card height, so the last one
          // scrolled out of sight. The gap shrinks to what the card has
          // (never above 8), so every button shows whole.
          double gap = 8.r;
          if (box.maxHeight.isFinite && n > 1) {
            gap = ((box.maxHeight - n * b) / (n - 1)).clamp(2.0, 8.r);
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: buttons,
          );
        }
        return Column(
          children: <Widget>[
            SizedBox(height: k - title),
            for (int i = 0; i < n; i++) ...<Widget>[
              if (i > 0) SizedBox(height: k),
              buttons[i],
            ],
          ],
        );
      },
    );
  }
}

/// One boxed metric: glyph on top, label, then value.
///
/// Figma uses this inside the "Services" / "Inventory" / "Knowledge Hub"
/// totals cards, where several tiles sit side by side with a hairline between.
class HomeStatTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  /// Tint for the glyph. Null keeps the asset's own colors, which is right
  /// for the status icons that are already green/orange/red.
  final Color? iconColor;

  /// How many lines the label may wrap onto. ADDED 25/8/2026.
  ///
  /// Pass 1 for a card whose labels must stay on one line. The TYPE SIZE DOES
  /// NOT ADAPT — 9pt always — so a label that will not fit ellipses. That is
  /// deliberate: shrinking one label leaves the tiles in a row at different
  /// sizes, which reads as a bug rather than as a long word. If a label does
  /// not fit, the card is too narrow; widen it. Size against the ARABIC label,
  /// which runs wider than the English here.
  final int labelMaxLines;

  const HomeStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.labelMaxLines = 2,
  });

  /// 22/10/2026 — the Arabic font's lines are ~2px taller than the English
  /// ones, so in Arabic the Knowledge Hub card overflowed its fixed height by
  /// 1.4px. In Arabic the tile text gets a fixed 1.4 line height; English is
  /// untouched.
  static StrutStyle? englishLineStrut(BuildContext context, double size) {
    if (Localizations.localeOf(context).languageCode == 'en') return null;
    return StrutStyle(
      fontSize: size.sp,
      height: 1.4,
      forceStrutHeight: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Owner 21/10/2026 (Figma 2289-37365 "Widget Seventeen"): every counter
    // tile sits in its OWN box (padding 8, radius 4, the panel background),
    // icon top-left, label and number at the bottom — four equal blocks.
    // Owner 21/10/2026 13:07: a tile is its icon, label and number plus 8
    // inside — no minimum width, so no dead space after a short label.
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // 12:30: icon at the top, number on the bottom inset.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CustomSvgImage(
              assetPath: icon,
              width: 20.r,
              height: 20.r,
              fit: BoxFit.contain,
              color: iconColor,
            ),
          ),
          SizedBox(height: 6.r),
          // CHANGED 28/9/2026 (bug report p.23 — "titles must show completely
          // not three dots"): a one-line label is now scaled DOWN to fit its
          // tile instead of being cut off with "...". It is only ever shrunk,
          // never grown, so a label that already fits is drawn exactly as before.
          // This reverses the "type size does not adapt" rule documented on
          // [labelMaxLines] above for the one-line case.
          if (labelMaxLines == 1)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text),
                strutStyle: englishLineStrut(context, 12),
                maxLines: 1,
              ),
            )
          else
            Text(
              label,
              style:
                  StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              strutStyle: englishLineStrut(context, 12),
              maxLines: labelMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 6.r),
          // 23/10/2026 (Moataz): the number sits on the END side — the left in
          // Arabic, the right in English — opposite the icon and label.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(value,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
                strutStyle: englishLineStrut(context, 14)),
          ),
        ],
      ),
    );
  }
}

/// A row of [HomeStatTile]s separated by the vertical hairline Figma draws.
class HomeStatTileRow extends StatelessWidget {
  final List<HomeStatTile> tiles;

  const HomeStatTileRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    // CHANGED 28/9/2026 (bug report p.23 — "padding between them must be
    // equal"): each tile used to take an equal-width `Expanded` slot with its
    // text pinned to the start of it, so the visible gap after a short label
    // ("Active") was far wider than after a long one ("Deactivated"). Tiles
    // now take their own width (capped at an equal share, loose flex) and
    // `spaceBetween` hands out the leftover room evenly, so every gap matches.
    // 18/10/2026 (Moataz: "too much padding"): ONE fixed gap between the
    // tiles on every card — the card is as wide as its tiles need.
    // Owner 21/10/2026 (Figma): boxed tiles 8 apart, all the same height.
    // 12:30: the tiles stretch to the body height (bottom inset).
    // Owner 21/10/2026 (R-11, by eye): the boxed tiles SHARE the card width
    // equally — every tile the same width, 8 apart, and the card keeps the
    // same 16 on all four sides. At their own text width they left an empty
    // strip on the card's end side and tiles of different widths in one row.
    // 22:00: every tile is as wide as the WIDEST tile (its longest label
    // + 8 each side) — IntrinsicWidth over equal Expanded slots gives
    // exactly widest × count — and the card hugs the row (hugContent).
    // 22/10/2026 (Moataz: "Inventory is compact on the phone — apply it to the
    // other widgets, but do not damage tablet and desktop"): Inventory's tiles
    // sit in a FittedBox(scaleDown), which is what shrinks them to the phone
    // card. Every counter row (To-Do, Knowledge Hub, Approvals, ...) goes
    // through here, so the same wrapper lives here. scaleDown only ever
    // SHRINKS: where the row already fits (tablet, desktop) it is drawn
    // exactly as before. IntrinsicHeight gives the stretched tiles the bounded
    // height the FittedBox would otherwise take away.
    final Widget row = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8.w,
            children: <Widget>[
              for (final HomeStatTile tile in tiles) Expanded(child: tile),
            ],
          ),
        ),
      ),
    );
    return row;
  }
}

/// `[glyph] Name / subtitle .......... [action]` — the two-line list row used
/// by the Requested Service and Near Breached SLA cards.
class HomeEntityRow extends StatelessWidget {
  final String icon;
  final String name;
  final String subtitle;

  /// Right-hand affordance: a [HomeCardButton] or a small icon button.
  final Widget? trailing;

  const HomeEntityRow({
    super.key,
    required this.icon,
    required this.name,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Room for a service name + department (18/10/2026: the card shrank to
    // "—" placeholders and hid the names once they loaded).
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 220.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Row(
          children: <Widget>[
            CustomSvgImage(
              assetPath: icon,
              width: 18.r,
              height: 18.r,
              color: AppColors.primary,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: CardStyles.value(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: CardStyles.label(12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              SizedBox(width: 6.w),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// `Label .... [track/fill] .... value` — one line of the Services Status card.
class HomeProgressRow extends StatelessWidget {
  final String label;
  final String value;

  /// 0..1 fill fraction.
  final double fraction;
  final Color color;

  const HomeProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  // D-226 / D-227: one label size in every card. Owner item
                  // 194 (21/10/2026): label 12, number 14/500 — the house
                  // sizes, nothing under 12 on the tablet.
                  style: CardStyles.label(12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(value, style: CardStyles.value(14)),
            ],
          ),
          SizedBox(height: 2.r),
          Stack(
            children: <Widget>[
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `[glyph] value` — the compact count line on the My Request / Stocks cards.
class HomeCountLine extends StatelessWidget {
  final String icon;
  final String value;

  const HomeCountLine({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: <Widget>[
          // Owner item 192 (21/10/2026): the three glyphs share one 16 box
          // and keep their proportions (the 12×16 hourglass was stretched).
          SizedBox(
            width: 16.sp,
            height: 16.sp,
            child: CustomSvgImage(
              assetPath: icon,
              width: 16.sp,
              height: 16.sp,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 4.w),
          Text(value, style: CardStyles.value(14)),
        ],
      ),
    );
  }
}
