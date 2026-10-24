/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_grid_item_view.dart
/// Description: This file contains the HomeGridItemView widget, which is used to display a grid item in the home screen of the form builder module.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/menu.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/menu_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_form_actions.dart';

/// ── Figma spec: MESBAH / node 7444-37279 (a home grid card) ─────────────────
///
/// The card is 282 × 80 with 10 padding all round, so the content box is
/// 262 × 60. Inside it:
///
///   thumbnail          x 10,  y 10, 60 × 60   → exactly fills the content height
///   text column        x 75                   → 5 clear of the thumbnail
///   title              y 15
///   "Used by:"         y 31
///   "Access:"          y 46
///   "Published Date:"  y 61
///   ⋯ menu             x 254, y 10, 18 × 4    → 10 in from the right edge
///
/// The thumbnail was 80 on tablet — 20 taller than the whole
/// 60 content box — which pushed the card past its 80 height. That is why the
/// card rows in the bug report do not line up with the design.
const double _kThumbSize = 60;

/// Bug report #11: the cover is as tall as the card's content box (100.sp
/// card − 2 × 10.sp padding), and square.
const double _kThumbFill = 80;

/// The placeholder document glyph inside the thumbnail — Figma node
/// 7444-37289 ("g4024"), 30 × 38, centred in the 60 × 60 tile.
///
/// This replaces a `Transform.scale(scale: isTablett ? 1.5 : 1)`, which sized
/// the glyph off the SVG's own intrinsic box rather than off the design, and
/// would have overflowed the tile now that it is 60 rather than 80.
const double _kThumbGlyphWidth = 30;
const double _kThumbGlyphHeight = 38;

/// Side of the square box the ⋯ menu glyph is drawn in. Figma's dots span
/// 18 × 4 (node 7444-37332); 20 keeps a little breathing room around them and
/// matches the size `MenuDropdown` uses for its own default icon.
const double _kMoreIconSize = 20;

/// Invisible tap area around the ⋯ dots (18 × 4), so the target is 34 × 20.
const double _kMoreTapPadding = 8;

class HomeGridItemView extends StatelessWidget {
  const HomeGridItemView({
    required this.model,
    required this.index,
    this.gridAnimationController,
    this.slideAnimations,
    super.key,
  });

  final FormEntity model;
  final int index;
  final AnimationController? gridAnimationController;
  final List<Animation<Offset>>? slideAnimations;

  @override
  Widget build(BuildContext context) {
    final widget = _getGridViewWidget(model: model, context: context);

    // Apply animations if available
    if (slideAnimations != null &&
        index < slideAnimations!.length &&
        gridAnimationController != null) {
      return SlideTransition(
        position: slideAnimations![index],
        child: FadeTransition(opacity: gridAnimationController!, child: widget),
      );
    }

    return widget;
  }

  Widget _getGridViewWidget({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();

    if (cubit.selectedTabIndex == 2 || cubit.selectedTabIndex == 3) {
      return _getGridViewRequestedItem(model: model, context: context);
    }
    return _getGridViewPublishItem(model: model, context: context);
  }

  // ... rest of the code remains the same
  Widget _getGridViewRequestedItem({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();
    bool isPhone = kpIsPhoneLayout(context);

    return GestureDetector(
      onTap: () {
        HapticController.low(); // list row: on the tap (X-117)
        HomeFormActions.openForm(context, model);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: Row(
            // Bug report #11: the cover fills the card's full content height
            // (all the text rows), square.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: _kThumbFill.sp,
                decoration: BoxDecoration(
                  // Bug report p.7 ("remove these background"): no filled
                  // square behind the form icon / cover.
                  color: AppColors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: model.formHeadModel.cover != null &&
                        model.formHeadModel.cover!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        child: Image.network(
                          model.formHeadModel.cover!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: CustomSvgImage.natural(
                                assetPath: AppAssets.defaultIcon,
                                width: _kThumbGlyphWidth.w,
                                height: _kThumbGlyphHeight.h,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  AppColors.icon,
                                  BlendMode.srcIn,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircleProgressMaster.inline(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: CustomSvgImage.natural(
                          assetPath: AppAssets.defaultIcon,
                          width: _kThumbGlyphWidth.w,
                          height: _kThumbGlyphHeight.h,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            AppColors.icon,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
              ),
              horizontalSpace(isPhone ? 8 : 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(end: 5, top: 5),
                  // This Column overflowed by ~10px on the
                  // Submissions tab (index 3), where a fourth row (Submission
                  // The two `SizedBox(height: 10.sp)` gaps plus `Spacer` were
                  // 20px of gap the card could not spare once that row
                  // appeared. `spaceBetween` distributes whatever is left
                  // instead of demanding a fixed amount — the same thing
                  // `_getGridViewPublishItem`'s column already does, which is
                  // why the publish card never overflowed.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getTitleForItem(model.formHeadModel, context),
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.fullBlack,
                              ),
                              // Owner 21/10/2026: one line + ellipsis, so the narrower 5-column card never wraps the title.
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // (vertical bug report p.17 — "same
                      // font size"): this line sat in a FittedBox, so a long
                      // e-mail was scaled down below the date lines. It is now
                      // the same 10 sp as the dates and ellipsizes instead.
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${S.of(context).requestedBy}: ',
                              style: StyleText.fontSize10Weight400.copyWith(
                                color: AppColors.spanText,
                              ),
                            ),
                            TextSpan(
                              text: ' ${model.requestedBy}',
                              style: StyleText.fontSize10Weight400.copyWith(
                                color: AppColors.fullBlack,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Owner 21/10/2026: the two date lines are one Text.rich each (1 line, ellipsis) instead of a Row of two Texts, so they cannot overflow the narrower 5-column card.
                      if (cubit.selectedTabIndex == 3)
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${S.of(context).submissionDate}: ',
                                style: StyleText.fontSize10Weight400.copyWith(
                                  color: AppColors.spanText,
                                ),
                              ),
                              TextSpan(
                                // `submissionDate!` crashed
                                // every Submissions card whose date was missing
                                // (older responses whose index lists were out of
                                // step). Shows "-" instead.
                                text: model.submissionDate != null
                                    ? ' ${FormDateTimeHelper.formatDate(model.submissionDate!)}'
                                    : ' -',
                                style: StyleText.fontSize10Weight400.copyWith(
                                  color: AppColors.fullBlack,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${S.of(context).receivedDate}: ',
                                style: StyleText.fontSize10Weight400.copyWith(
                                  color: AppColors.spanText,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' ${FormDateTimeHelper.formatDate(model.createDate)}',
                                style: StyleText.fontSize10Weight400.copyWith(
                                  color: AppColors.fullBlack,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGridViewPublishItem({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();
    kpIsPhoneLayout(context);

    return GestureDetector(
      onTap: () {
        HapticController.low(); // list row: on the tap (X-117)
        HomeFormActions.openForm(context, model);
      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
              child: Row(
                // Bug report #11: the cover fills the card's full content height
                // (all the text rows), square.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width:
                        _kThumbSize.sp, // Figma 7444-37393: 60 × 60 thumbnail
                    decoration: BoxDecoration(
                      // Bug report p.7 ("remove these background"): no filled
                      // square behind the form icon / cover.
                      color: AppColors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: model.formHeadModel.cover != null &&
                            model.formHeadModel.cover!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                            // (vertical bug report p.2 — "remove
                            // this background"): `cover` blew the picture up so its
                            // own backdrop filled the whole 60 × 60 box. `contain`
                            // keeps the full artwork at its own size, centred.
                            child: Image.network(
                              model.formHeadModel.cover!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: CustomSvgImage.natural(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_create_form.svg",
                                    width: _kThumbGlyphWidth.w,
                                    height: _kThumbGlyphHeight.h,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.icon,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircleProgressMaster.inline(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/ic_create_form.svg",
                              width: _kThumbGlyphWidth.w,
                              height: _kThumbGlyphHeight.h,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                AppColors.icon,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                  ),
                  // Figma 7444-37393: the text column starts 5 after the
                  // thumbnail (x 75 = 10 padding + 60 thumbnail + 5).
                  horizontalSpace(5),
                  Expanded(child: _buildPublishTextColumn(model, context)),
                ],
              ),
            ),
          ),
          // The Deleted tab gets a menu too, holding only Restore — see
          // _menuItemsForTab. Publish (0) and Deleted (4) are the two tabs this
          // card is built for that have any card action at all; Draft (1) has
          // none, so _menuItemsForTab returns empty and nothing is placed.
          if (_menuItemsForTab(cubit.selectedTabIndex).isNotEmpty)
            // Was
            // `Positioned(right: 10)`, so in Arabic the ⋯ menu sat on top of
            // the thumbnail (which is on the right in RTL). `end` puts it at
            // the far corner from the thumbnail in both directions, and it
            // sits higher so it no longer touches the title line.
            // D-03 diagonal cut, 10 / 10 (17/10/2026).
            // The dots themselves (18 × 4) sit exactly 10 / 10 from the corner;
            // the tap padding around them is taken out of the offset.
            PositionedDirectional(
              top: CardStyles.cornerInset - _kMoreTapPadding.r,
              end: CardStyles.cornerInset - _kMoreTapPadding.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MenuDropdown(
                    customIcon: _buildMoreIcon(),
                    currentEnumValue: null,
                    items: _menuItemsForTab(cubit.selectedTabIndex),
                    onChanged: (value) {
                      HomeFormActions.onMenuSelect(
                        context,
                        value,
                        formModel: model,
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// The four text lines of a Publish / Draft / Deleted card.
  ///
  /// REBUILT 12/10/2026 to Figma MESBAH node 7444-37393 (282 × 80 card):
  ///   title            12, dark
  ///   Used by: `<n>`     10, label #797979 + dark value
  ///   Access: `<value>`  10, label #797979 + dark value
  ///   Published Date   10, label #797979 + dark value (Figma says 8; the
  ///                    owner, 22/10/2026: every line of the card is 10)
  ///
  /// The old column used 14 / 11 / 11 / 11 with extra padding, and Cairo's
  /// tall default line height on top of that — four lines did not fit the
  /// 60-high content box, which is the "BOTTOM OVERFLOWED BY 3.7 PIXELS"
  /// stripe. Every line here is one line high (height 1.2), ellipsised, and
  /// the four are spread evenly over the content box like the design's
  /// y 15 / 31 / 46 / 61 rows.
  Widget _buildPublishTextColumn(FormEntity model, BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final int tab = cubit.selectedTab.index;

    TextStyle style(double size, Color color) => StyleText.fontSize12Weight400
        .copyWith(fontSize: size.sp, height: 1.2, color: color);

    Widget line(String label, String value, double size) {
      return Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: label, style: style(size, AppColors.secondaryText)),
            TextSpan(text: value, style: style(size, AppColors.text)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // Exact line height in both languages: Arabic glyphs are taller and
        // pushed the four lines 0.112 px over the card ("BOTTOM OVERFLOWED").
        strutStyle: StrutStyle(
          fontSize: size.sp,
          height: 1.2,
          forceStrutHeight: true,
        ),
      );
    }

    final String usedBy = model.numberUsed == 0
        ? '-'
        : FormDateTimeHelper.formatInt(model.numberUsed);
    final String access = tab == 1
        ? '-'
        : AccessManagementExtension.labelFor(
            model.formHeadModel.accessManagement,
          );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            // Leave room for the ⋯ menu in the top-right corner.
            padding: EdgeInsetsDirectional.only(end: (_kMoreIconSize + 8).sp),
            child: Text(
              _getTitleForItem(model.formHeadModel, context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style(12, AppColors.text),
              strutStyle: StrutStyle(
                fontSize: 12.sp,
                height: 1.2,
                forceStrutHeight: true,
              ),
            ),
          ),
          line('${S.of(context).fbUsedBy}: ', usedBy, 10),
          line('${S.of(context).access}: ', access, 10),
          // Drafts have no date; deleted forms show when they were deleted.
          if (tab != 1)
            line(
              tab == 4
                  ? '${S.of(context).fbDeletedDate}: '
                  : '${S.of(context).published_date}: ',
              tab == 4 && model.deleteDate != null
                  ? FormDateTimeHelper.formatDate(model.deleteDate!).trim()
                  : FormDateTimeHelper.formatDate(model.createDate).trim(),
              10,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// Which card-menu entries a given home tab offers.
  ///
  /// Together with `MenuEnum.restore`. The menu used to be
  /// `items: MenuEnum.values` behind `if (selectedTabIndex == 0)` — every
  /// action on the Publish tab, no menu anywhere else. That has two problems
  /// once Restore exists: a deleted form has no way to be restored from the
  /// grid, and `values` would have silently added "Restore" to the Publish
  /// card's menu.
  ///
  /// Listing the entries per tab fixes both and makes the next addition a
  /// decision rather than an accident.
  ///
  /// Tab indices follow `HomeCubit.onTabChange`: 0 Publish, 1 Draft,
  /// 2 Requested, 3 Submissions, 4 Deleted. 2 and 3 never reach here — they
  /// render `_getGridViewRequestedItem`, which has no menu.
  List<MenuEnum> _menuItemsForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const [
          MenuEnum.duplicate,
          MenuEnum.edit,
          MenuEnum.convertToPDF,
          MenuEnum.delete,
        ];
      case 4:
        return const [MenuEnum.restore];
      default:
        return const [];
    }
  }

  /// The horizontal ⋯ that opens the card's menu.
  ///
  /// `MenuDropdown` falls back to `AppAssets.menu` when no
  /// `customIcon` is given, and that asset is `menu_lines_bold.svg` — a
  /// hamburger, not three dots. Figma (node 7444-37332) shows an 18 × 4
  /// horizontal ⋯ in the card's top-right corner, so the card passes its own
  /// icon rather than changing `AppAssets.menu`, which other screens use as an
  /// actual hamburger.
  ///
  /// `vectors_more.svg` draws the dots VERTICALLY, so it is turned a quarter
  /// turn. `RotatedBox` rather than `Transform.rotate`: it rotates during
  /// layout, so the tap target rotates with the artwork instead of staying
  /// axis-aligned behind a visually rotated child. The 24 × 24 viewBox is
  /// square, so the turn neither clips the glyph nor changes its footprint.
  Widget _buildMoreIcon() {
    // 24/10/2026 (owner): the same three dots as the Database cards — the
    // shared `dotsHorizontal` glyph in the secondary grey — instead of three
    // hand-drawn black dots. The tap padding is kept.
    return Padding(
      padding: EdgeInsets.all(_kMoreTapPadding.r),
      child: CustomSvgImage(
        assetPath: AppAssets.dotsHorizontal,
        width: 20.r,
        height: 20.r,
        fit: BoxFit.contain,
        color: AppColors.secondaryText,
      ),
    );
  }

  String _getTitleForItem(FormHeadData formHeadModel, BuildContext context) =>
      formHeadModel.titleFor(arabic: context.isArabic);
}
