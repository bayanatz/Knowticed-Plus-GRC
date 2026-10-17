/// Module: services_management_module
/// Description: Shared side-frame/breadcrumb header widget (SideFrameMasterServices) used across
///   the services_management_module screen sub-modules (s1-s11). Renamed from the original
///   W3_Frame_Screen_tablet.dart (capitalized, non-snake_case) filename and relocated from the
///   non-canonical top-level widgets/ folder into presentation/ui/widgets/.
/// Author: Amr Mesbah
/// Created at: 2026-07-02
/// Dependencies: flutter, flutter_screenutil, flutter_svg, get, core/theme, core/theme/haptic_controller
/// Revision History: Moved + renamed for architecture compliance (services_management_module audit).
///   16/8/2026 — text now comes from `StyleText` (app_theme.dart) rather than
///   `StyleText` directly. Same two styles, resolved through the app's own
///   scale: `StyleText.fontSize24Weight600` and `fontSize28Weight600` redirect
///   to exactly the Cairo styles this file was naming by hand, so nothing
///   renders differently — but the breadcrumb now follows the scale every
///   screen reads from instead of pinning two font sizes of its own.
library;

import 'package:grc_module/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';

/// Pops [times] routes off the current navigator, never past the first route.
///
/// ADDED 8/9/2026 with the roles-module frame rollout. [SideFrameMasterServices]
/// hands each breadcrumb its own tap callback, and a page three levels deep
/// needs "go back two" for its middle crumb — this is that, in one place,
/// instead of a nest of `Navigator.pop` calls repeated per page.
void popFrameRoutes(BuildContext context, int times) {
  int remaining = times;
  Navigator.of(context).popUntil((route) => route.isFirst || remaining-- <= 0);
}

/// Gives its [child] a bounded height when [SideFrameMasterServices] is in its
/// PHONE layout, and gets out of the way otherwise.
///
/// ADDED 8/9/2026. The frame lays its child out two different ways: on tablet
/// and desktop the child goes into an `Expanded` (bounded height), but on a
/// phone it goes inside a `SingleChildScrollView`, so the incoming height is
/// UNBOUNDED. Any page that uses `Expanded`, a `GridView`, or a pinned bottom
/// button row therefore throws "RenderFlex children have non-zero flex but
/// incoming height constraints are unbounded" the moment it is wrapped in the
/// frame on a phone.
///
/// This is the same measure-and-bound dance `role_screen.dart` already does by
/// hand for its tabs, lifted here so every page that wears the frame can reuse
/// it. On the bounded branch the child is returned untouched.
///
/// [extraReserved] subtracts anything else the page must leave room for.
/// Pages normally pass nothing.
class SideFrameBoundedBody extends StatelessWidget {
  const SideFrameBoundedBody({
    super.key,
    required this.child,
    this.extraReserved = 0,
  });

  final Widget child;
  final double extraReserved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Tablet / desktop branch: the frame already bounded us.
        if (constraints.hasBoundedHeight) return child;

        // Phone branch. The frame's header is 15.sp top padding + 10.h vertical
        // padding around a fontSize24Weight600 title, plus the 20.sp spacer it
        // adds beneath — ~90.sp all told. The clamp keeps a very short viewport
        // usable rather than collapsing the content to nothing.
        final MediaQueryData media = MediaQuery.of(context);
        final double page = media.size.height - media.padding.vertical;
        final double available = (page - 90.sp - extraReserved).clamp(
          200.sp,
          page,
        );

        return SizedBox(height: available, child: child);
      },
    );
  }
}

/// Gives its [child] a scroll view ONLY where [SideFrameMasterServices] is not
/// already providing one — the mirror image of [SideFrameBoundedBody].
///
/// ADDED 10/9/2026. The frame scrolls its child on the PHONE branch and hands
/// the child an `Expanded` (bounded, non-scrolling) on tablet and desktop. A
/// page that writes its own `SingleChildScrollView` is therefore right on one
/// and wrong on the other:
///
///  * On tablet/desktop it is REQUIRED — nothing else makes a long page scroll.
///  * On a phone it is a vertical viewport nested directly inside another
///    vertical viewport with an unbounded height, which throws
///    "Vertical viewport was given unbounded height" during layout. The page
///    then paints nothing below the frame's own title row, and — because the
///    subtree never gets laid out — every following frame also trips
///    `'!semantics.parentDataDirty': is not true` in `flushSemantics`, which is
///    the loud, hundreds-of-frames-deep error that actually reaches the console.
///    The layout failure that caused it is a single line far above it.
///
/// Wrapping the page's own scroll view in [SideFrameBoundedBody] LOOKS like a
/// fix — the inner viewport gets a height and stops throwing — but it is the
/// wrong one: it leaves two nested scroll areas fighting for the drag, and pins
/// the page to one screen's worth of height inside a frame that was already
/// scrolling. Use this instead and let exactly one of them scroll.
class SideFrameScrollableBody extends StatelessWidget {
  const SideFrameScrollableBody({super.key, required this.child, this.physics});

  final Widget child;

  /// Physics for the scroll view this adds. Ignored on the phone branch, where
  /// the frame's own scroll view is the one doing the scrolling.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Phone branch: the frame is already a scroll view. Adding another one
        // here is the bug this class exists to prevent.
        if (!constraints.hasBoundedHeight) return child;

        // Tablet / desktop: the frame gave us a fixed height, so the scrolling
        // is ours to do.
        return SingleChildScrollView(physics: physics, child: child);
      },
    );
  }
}

class SideFrameMasterServices extends StatelessWidget {
  final String titleText;
  final String? secondTitle;
  final String? thirdTitle;
  final String? fourthTitle;
  final Widget? child;

  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;
  final VoidCallback? onThirdTap;
  final VoidCallback? onFourthTap;

  /// How many path items a portrait tablet shows (default 2, the last two).
  /// ADDED 14/10/2026 — KH vertical report p.16 wanted "Knowledge Hub" kept
  /// in the path on Submission details.
  final int verticalTabletCrumbs;

  const SideFrameMasterServices({
    super.key,
    required this.titleText,
    this.secondTitle,
    this.thirdTitle,
    this.fourthTitle,
    this.onFirstTap,
    this.onSecondTap,
    this.onThirdTap,
    this.onFourthTap,
    this.verticalTabletCrumbs = 2,
    this.child,
    this.titlePadding,
  });

  /// Padding around the breadcrumb/title row.
  ///
  /// ADDED 18/8/2026. Null keeps the historical 15.sp used by every module
  /// that already ships this frame; `form_builder_module` passes
  /// `formBuilderTitlePadding` (20.sp) so its Share/Groups pages match the
  /// rest of the module. Only the TITLE row is affected — the content padding
  /// below it is untouched.
  final EdgeInsetsGeometry? titlePadding;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    // ADDED 14/10/2026 (Amr) — the crumb row's explicit direction.
    final TextDirection crumbDirection =
        isArabic ? TextDirection.rtl : TextDirection.ltr;
    final bool isTablet = ContextExtension(context).isTablet;
    final bool isLandscape = ContextExtension(context).isLandscape;
    final bool isVerticalTablet = isTablet && !isLandscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    if (isMobile) {
      // CHANGED 8/9/2026 — the title/breadcrumb row used to sit INSIDE the
      // SingleChildScrollView, so it scrolled away with the content and the
      // user lost both the page name and the back chevron as soon as they
      // scrolled down. It is now a fixed row above the scroll view, and only
      // the content scrolls — the same split the tablet branch below already
      // used (fixed header, `Expanded` scroll area under it).
      //
      // What the child sees is unchanged: it is still the direct child of a
      // SingleChildScrollView, so it still gets an unbounded height and no
      // screen that relies on that needs touching.
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Fixed (non-scrollable) title / breadcrumb ----------
              Row(
                // ADDED 14/10/2026 — explicit direction, same as the tablet branch.
                textDirection: crumbDirection,
                children: [
                  if (secondTitle != null ||
                      thirdTitle != null ||
                      fourthTitle != null)
                    GestureDetector(
                      onTapDown: (_) =>
                          HapticController.low(), // top-of-page navigation
                      onTap: () {
                        Navigator.of(context).maybePop(); // Go back
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 3.sp,
                          top: 15.sp,
                          left: 12.sp,
                        ),
                        child: Transform.rotate(
                          angle: isArabic ? 0 : 3.1416,
                          child: CustomSvgImage.natural(
                            assetPath:
                                'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: thirdTitle == null &&
                                secondTitle == null &&
                                fourthTitle == null
                            ? 10.h
                            : 0.sp,
                        horizontal: thirdTitle == null &&
                                secondTitle == null &&
                                fourthTitle == null
                            ? 15
                            : 0,
                      ),
                      child: GestureDetector(
                        onTapDown: (_) =>
                            HapticController.low(), // top-of-page navigation
                        onTap: () {
                          (onFourthTap ??
                                  onThirdTap ??
                                  onSecondTap ??
                                  onFirstTap)
                              ?.call();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.sp),
                          child: Text(
                            fourthTitle ??
                                thirdTitle ??
                                secondTitle ??
                                titleText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: StyleText.fontSize24Weight600.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Scrollable content ----------
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.sp,
                      vertical: 0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20.sp),
                        if (child != null) child!,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // ⬇️ Replace your whole Expanded(...) block with this:
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.background
                        : AppColors.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- Fixed (non-scrollable) header/breadcrumb ----------
                        Padding(
                          // Title sits 20.sp from the top, left and right
                          // (KH vertical report p.1/3/5/12/21).
                          padding: titlePadding ??
                              EdgeInsets.only(
                                left: 20.sp,
                                right: 20.sp,
                                top: 20.sp,
                                bottom: 15.sp,
                              ),
                          // CHANGED 14/10/2026 (iPad Arabic bug report):
                          //  1. Direction — the crumbs are laid out with an
                          //     EXPLICIT text direction taken from the app
                          //     locale, inside a full-width box aligned to the
                          //     directional start. In Arabic the first crumb
                          //     now sits against the RIGHT edge and the trail
                          //     runs right-to-left, instead of the whole
                          //     breadcrumb hugging the left side.
                          //  2. Overflow — every crumb is width-limited and
                          //     single-line with an ellipsis. A long form name
                          //     ("تفاصيل نموذج …") now ends in "…" instead of
                          //     painting the yellow/black overflow stripes.
                          //     Each crumb gets a share of the row in
                          //     proportion to its text, so "…" appears only
                          //     when the crumbs really do not fit.
                          child: Directionality(
                            textDirection: crumbDirection,
                            child: SizedBox(
                              width: double.infinity,
                              child: LayoutBuilder(
                                builder: (context, rowConstraints) => Row(
                                  textDirection: crumbDirection,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: () {
                                    List<String?> titles = [
                                      titleText,
                                      secondTitle,
                                      thirdTitle,
                                      fourthTitle,
                                    ];
                                    List<VoidCallback?> taps = [
                                      onFirstTap,
                                      onSecondTap,
                                      onThirdTap,
                                      onFourthTap,
                                    ];

                                    List<MapEntry<String, VoidCallback?>>
                                        valid = [];
                                    for (int i = 0; i < titles.length; i++) {
                                      if (titles[i] != null) {
                                        valid.add(
                                          MapEntry(titles[i]!, taps[i]),
                                        );
                                      }
                                    }

                                    if (isVerticalTablet && valid.length > 2) {
                                      valid = valid.sublist(
                                        valid.length - 2,
                                      ); // last 2 items in vertical tablet
                                    } else if (!isVerticalTablet &&
                                        valid.length > 3) {
                                      valid = valid.sublist(
                                        valid.length - 3,
                                      ); // last 3 items in horizontal mode
                                    }

                                    final TextStyle crumbStyle =
                                        StyleText.fontSize28Weight600.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    );

                                    // CHANGED 14/10/2026 ("why '…' when there is
                                    // space"): each crumb's share of the row is
                                    // proportional to its own full text width. When
                                    // the crumbs fit, every share is at least the
                                    // full text, so nothing is cut; only when they
                                    // really do not fit do they all shrink and end
                                    // in "…". (Was a fixed 40% cap on the earlier
                                    // crumbs, which cut them even with room left.)
                                    final TextScaler scaler =
                                        MediaQuery.textScalerOf(context);
                                    int crumbFlex(String text) {
                                      final TextPainter painter = TextPainter(
                                        // FIXED 14/10/2026: measure with the SAME style the Text
                                        // widget paints with — the inherited DefaultTextStyle (the
                                        // app font from the theme) merged with crumbStyle. Measuring
                                        // crumbStyle alone used the fallback font, came out too
                                        // narrow, and the crumb still got "…" with room to spare.
                                        text: TextSpan(
                                          text: text,
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .merge(crumbStyle),
                                        ),
                                        locale: Localizations.maybeLocaleOf(
                                          context,
                                        ),
                                        maxLines: 1,
                                        textDirection: crumbDirection,
                                        textScaler: scaler,
                                      )..layout();
                                      return painter.width.ceil() + 6;
                                    }

                                    Widget crumbText(String text) => Text(
                                          text,
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: crumbDirection,
                                          style: crumbStyle,
                                        );

                                    List<Widget> widgets = [];

                                    for (int i = 0; i < valid.length; i++) {
                                      if (i != 0) {
                                        widgets.add(SizedBox(width: 10.sp));
                                        widgets.add(
                                          Transform.rotate(
                                            angle: isArabic ? 3.1416 : 0,
                                            child: Padding(
                                              padding: isArabic
                                                  ? EdgeInsets.only(
                                                      bottom: 7.sp,
                                                    )
                                                  : EdgeInsets.only(top: 3.sp),
                                              child: CustomSvgImage.natural(
                                                assetPath:
                                                    'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
                                                width: 30.sp,
                                                height: 30.sp,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.blackButton
                                                    : AppColors.whiteShadow,
                                              ),
                                            ),
                                          ),
                                        );
                                        widgets.add(SizedBox(width: 10.sp));
                                      }

                                      final Widget crumb = GestureDetector(
                                        onTapDown: (_) =>
                                            HapticController.low(),
                                        onTap: () {
                                          HapticController
                                              .low(); // top-of-page navigation
                                          valid[i].value?.call();
                                        },
                                        child: crumbText(valid[i].key),
                                      );

                                      widgets.add(
                                        Flexible(
                                          flex: crumbFlex(valid[i].key),
                                          child: crumb,
                                        ),
                                      );
                                    }

                                    return widgets;
                                  }(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ---------- Scrollable content ----------
                        Expanded(
                          child: Padding(
                            // Form-builder bug report #6: when the caller sets
                            // its own title padding (form builder: 20.sp all
                            // round), the content uses the same horizontal
                            // inset so title and content line up.
                            // CHANGED 14/10/2026 (iPad vertical bug report):
                            // on a VERTICAL tablet the gap from the page title
                            // to the first widget is exactly 20.sp — the
                            // title row's own 20.sp bottom padding — so the
                            // content adds nothing on top. Other layouts keep
                            // the old 10 above and below.
                            padding: EdgeInsets.only(
                              left: titlePadding is EdgeInsets
                                  ? (titlePadding as EdgeInsets).left
                                  : 15.sp,
                              right: titlePadding is EdgeInsets
                                  ? (titlePadding as EdgeInsets).left
                                  : 15.sp,
                              top: isVerticalTablet ? 0 : 10,
                              bottom: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 0.sp,
                                ), // same spacing that was under the breadcrumb
                                if (child != null)
                                  Expanded(
                                    child: child!,
                                  ), // ← give the screen area a bounded height
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
