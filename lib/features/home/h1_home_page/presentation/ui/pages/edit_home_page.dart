/// Module: home/h1_home_page
///
///*********************** FILE INFO ****************************///
/// File Name: edit_home_page.dart
/// Description: UI for editing home page components
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 11/8/2026 - Added the BlocListener that surfaces HomeError. The
///          cubit had been emitting HomeError with no listener anywhere in the
///          app, so a failed layout save looked like a success to the user.
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/adding_widget_page.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/helpers/constants/home_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_widget.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/nav_bar_picker_dialog.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_date.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_greetings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/dashed_icon_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/edit_home_page_custom_button.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_widget_settings_dialog.dart';
// The same calendar column HomeScreen renders on the right of its tablet
// layout — the editor previews the real home page, so it shows the real widget.
import 'package:knowticed_plus/features/calendar/presentation/ui/pages/home_calendar_page.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class EditHomePage extends StatelessWidget {
  const EditHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    final bool isTablet = !kpIsPhoneLayout(context);
    AppHomeCubit homeCubit = context.read<AppHomeCubit>();
    Theme.of(context).brightness == Brightness.light;
    // Fill the Forms / Group Messages lists now, so those gears open at once.
    warmHomePickerLists(isArabic: context.isArabic);

    // Same condition HomeScreen._tabletLayout uses for its calendar column, so
    // the editor splits left/right exactly when the real home page does.
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool showSideCalendar = isTablet && !isPortrait;
    // Owner items 191 / 193 (21/10/2026): on the tablet (portrait and
    // landscape) the rows are the same HomeContentGrid as the home page —
    // 4 columns, every card at its content width, one height. The phone
    // keeps 1 card per line.
    // Owner 21/10/2026: the phone too shows the 3 rows × 4 columns grid,
    // each row scrolling sideways like the tablet.
    final int perLine = HomeCardMetrics.columns;

    return BlocListener<AppHomeCubit, HomeState>(
      // HomeError is emitted when a layout save fails. Without this listener
      // the reorder silently did nothing and the user was never told.
      listenWhen: (HomeState previous, HomeState current) =>
          current is HomeError,
      listener: (BuildContext context, HomeState state) {
        if (state is! HomeError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.message,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          );
      },
      // CHANGED: the page frame is SideFrameMasterServices — the breadcrumb
      // frame the settings pages use — in place of the hand-built
      // Scaffold > SafeArea > Padding > Column > PaginationAppBar stack. The
      // frame supplies the SafeArea, the horizontal inset and the trail.
      //
      // TWO segments: this page is pushed with exactly ONE route, so
      // `onFirstTap` pops exactly once.
      //
      // The Scaffold stays: the frame only supplies one on phone.
      child: _ReorderingAutoOff(
          child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () => Navigator.of(context).maybePop(),
          secondTitle: S.of(context).homeLayout,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner 21/10/2026: "Enable Drawer Reordering" moved to the top of
              // the drawer (DrawerReorderButton), shown while this page is open.
              // The phone has no drawer: it picks its bottom-bar modules here.
              if (isMobile && Get.isRegistered<NavBarCubit>())
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.sp),
                    onTap: () {
                      HapticController.low();
                      showDialog<void>(
                        context: context,
                        // Done applies the pick, Cancel drops it; an outside
                        // tap would drop it silently, so it is off.
                        barrierDismissible: false,
                        builder: (_) => const NavBarPickerDialog(),
                      );
                    },
                    child: Container(
                      height: _bottomBarButtonHeight,
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sp),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomSvgImage.natural(
                            assetPath:
                                'assets/icons_assets/main_icons_assets/ic_action_reorder.svg',
                            width: 18.sp,
                            height: 18.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.sp),
                          Text(
                            S.of(context).bottomBar,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10.sp), // D-217: half
              _expandOnTablet(
                isMobile: isMobile,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left — the editor itself. flex 5 against the calendar's
                    // flex 3 is HomeScreen's split, so the widgets are laid
                    // out at the width they will actually get on the home
                    // page. Without the calendar it takes the row whole.
                    Expanded(
                      flex: showSideCalendar ? 5 : 1,
                      // D-202 (20/10/2026): Discard / Preview / Save are
                      // PINNED at the bottom; only the layout scrolls.
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const ScrollBehavior().copyWith(
                                scrollbars: false,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // Drawer reordering toggle.
                                    //
                                    // The flag used to be a module-global RxBool declared
                                    // in h3's custom_drawer.dart; it is now AppDrawerCubit
                                    // state. The cubit only exists on layouts that show a
                                    // drawer (it is deleted on mobile), so the toggle is
                                    // hidden when it is not registered — previously it
                                    // rendered there and flipped a flag nothing read.

                                    // SizedBox(height: 20.sp),
                                    Row(
                                      spacing: 10.sp,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // Owner 21/10/2026: 12 between date, greeting, quote and
                                            // grid by eye (was 15 / 15 / 27) so the page fits
                                            // without scrolling. Set per gap: the grid's slots
                                            // already keep 12 on top for the minus badge.
                                            children: [
                                              // ✅ FIX: Wrapped in LayoutBuilder to prevent Row overflow.
                                              // The icons row now uses Flexible so it won't overflow
                                              // when 3 icons are added.
                                              Row(
                                                spacing: 10.sp,
                                                // Bottoms aligned: the date sits 12 above the
                                                // greeting, not in the middle of the taller
                                                // shortcut icons (Owner 21/10/2026).
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(10.sp),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.sp),
                                                    ),
                                                    child: AppBarDate(
                                                        // D-217: the date is the smallest.
                                                        style: StyleText
                                                            .fontSize14Weight500),
                                                  ),
                                                  // Header icons + the add button sit at the END
                                                  // of the row, on the calendar's edge
                                                  // (18/10/2026 — Flexible after a Spacer left
                                                  // them in the middle).
                                                  Expanded(
                                                    child: BlocBuilder<
                                                        AppHomeCubit,
                                                        HomeState>(
                                                      builder:
                                                          (context, state) {
                                                        return SingleChildScrollView(
                                                          reverse: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            spacing: 4.sp,
                                                            children: [
                                                              for (int i = 0;
                                                                  i < homeCubit.selectedHeaderIcons.length &&
                                                                      (!isMobile ||
                                                                          i < 2);
                                                                  i++)
                                                                Padding(
                                                                  // Top 4 = room for the minus badge; none
                                                                  // below, so the date / icons row ends where
                                                                  // the icons end (Owner 21/10/2026).
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                    left: 2.sp,
                                                                    right: 2.sp,
                                                                    top: 4.sp,
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .of(
                                                                        context,
                                                                      ).push(
                                                                        MaterialPageRoute(
                                                                          builder: (context) => homeCubit
                                                                              .selectedHeaderIcons[i]
                                                                              .navigateTo(
                                                                            context,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        DashedIconContainer(
                                                                      svgAssetPath: homeCubit
                                                                          .selectedHeaderIcons[
                                                                              i]
                                                                          .svgPath,
                                                                      onMinusTap:
                                                                          () {
                                                                        homeCubit
                                                                            .removeHeaderIcon(
                                                                          i,
                                                                        );
                                                                      },
                                                                      dashColor:
                                                                          AppColors
                                                                              .primary,
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .primary,
                                                                      width: isMobile
                                                                          ? 38.sp
                                                                          : 48.sp,
                                                                      height: isMobile
                                                                          ? 38.sp
                                                                          : 48.sp,
                                                                    ),
                                                                  ),
                                                                ),

                                                              // MOVED 24/8/2026 (again): the add button is now the
                                                              // last child of the ICON STRIP, not a sibling of it.
                                                              //
                                                              // As a sibling it left dead space at the end of the
                                                              // row: `Row.spacing` inserted a gap on each side of
                                                              // it and the SizedBox added 8 more, and once three
                                                              // icons were chosen the button collapsed to
                                                              // SizedBox.shrink() while all that padding stayed —
                                                              // so the strip stopped short of the column edge with
                                                              // nothing visible in the gap.
                                                              //
                                                              // Inside the strip there is nothing after the last
                                                              // icon, so the row now ends exactly where its content
                                                              // does, and the button still follows the icons.
                                                              // MOVED 24/8/2026: the add button used to be the FIRST child of
                                                              // this row, so it sat to the LEFT of the icons already chosen and
                                                              // the row grew away from it. It belongs after them — new icons
                                                              // appear where the button is, not on the far side of the strip.
                                                              //
                                                              // Order, not alignment: in Arabic the Row mirrors with the rest of
                                                              // the UI, so "after the icons" stays correct in both directions.
                                                              BlocBuilder<
                                                                  AppHomeCubit,
                                                                  HomeState>(
                                                                builder:
                                                                    (context,
                                                                        state) {
                                                                  // Owner 21/10/2026: 3 shortcut icons on the tablet, 2 on the phone.
                                                                  if (homeCubit
                                                                          .selectedHeaderIcons
                                                                          .length <
                                                                      (isMobile
                                                                          ? 2
                                                                          : 3)) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        hapticController
                                                                            .triggerHapticFeedback(
                                                                          vibration:
                                                                              VibrateType.lightImpact,
                                                                          hapticFeedback:
                                                                              HapticFeedback.lightImpact,
                                                                        );
                                                                        showAppDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (dialogContext) =>
                                                                              IconSelectorDialog(
                                                                            addedPaths:
                                                                                homeCubit.selectedHeaderIcons.map<String>((i) => i.svgPath).toSet(),
                                                                            onIconSelected:
                                                                                (icon) {
                                                                              homeCubit.addHeaderIcon(
                                                                                icon,
                                                                                max: isMobile ? 2 : 3,
                                                                              );
                                                                            },
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        // D-227: the same height as the date box beside it.
                                                                        width: 38
                                                                            .sp,
                                                                        height:
                                                                            38.sp,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppColors.primary,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            8.r, // the calendar's round corner (Moataz 24/10/2026)
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            SizedBox(
                                                                          child:
                                                                              CustomSvgImage(
                                                                            assetPath:
                                                                                "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                                                                            width:
                                                                                12.w,
                                                                            height:
                                                                                12.h,
                                                                            color:
                                                                                AppColors.textButton,
                                                                            fit:
                                                                                BoxFit.scaleDown,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return SizedBox
                                                                        .shrink();
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.sp),
                                              Container(
                                                padding: EdgeInsets.all(10.sp),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppColors.primary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8.sp,
                                                  ),
                                                ),
                                                child: AppBarGreetings(
                                                    // D-217: the greeting is the biggest.
                                                    style: StyleText
                                                        .fontSize20Weight600),
                                              ),
                                              SizedBox(height: 12.sp),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 80.sp,
                                                      padding:
                                                          EdgeInsets.all(10.sp),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          8.sp,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        context
                                                            .read<
                                                                AppHomeCubit>()
                                                            .quote,
                                                        // D-217: greeting > quote > date.
                                                        style: StyleText
                                                            .fontSize16Weight500
                                                            .copyWith(
                                                          color: AppColors.text,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              BlocBuilder<AppHomeCubit,
                                                  HomeState>(
                                                builder: (_, state) {
                                                  return Column(
                                                    // D-217: row gap = column gap.
                                                    // Owner 21/10/2026 (tablet): every slot keeps the 12 badge room on top, so
                                                    // gap − 12 here shows a 16 gap between rows.
                                                    spacing: perLine > 1
                                                        ? HomeCardMetrics
                                                            .gapBesideBadge
                                                        : HomeCardMetrics.gap,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      for (int rowIndex = 1;
                                                          rowIndex <=
                                                              HomeConstants
                                                                  .kNumberOfRows;
                                                          rowIndex++)
                                                        // The grid is always
                                                        // NUMBER_OF_COLUMNS (4) wide —
                                                        // the count is fixed by the
                                                        // layout, never derived from
                                                        // how wide the cards happen to
                                                        // be.
                                                        //
                                                        // Each slot takes the width IT
                                                        // needs: no Expanded (that
                                                        // forced every card to an
                                                        // identical quarter of the
                                                        // panel) and no fixed card
                                                        // width. Only the HEIGHT is
                                                        // pinned, by
                                                        // HomeCardMetrics.heightBox in
                                                        // item() below.
                                                        //
                                                        // spacing: HomeCardMetrics.gap
                                                        // (20.sp) is the gap BETWEEN
                                                        // two cards and nothing at the
                                                        // two outer ends — see the
                                                        // note on `gap`.
                                                        //
                                                        // ✅ RESTORED 31/8/2026: the
                                                        // horizontal scroll view.
                                                        // Natural widths mean a row's
                                                        // total is whatever its four
                                                        // cards happen to need, and a
                                                        // row of wide ones exceeded the
                                                        // panel — Flutter reported
                                                        // "RIGHT OVERFLOWED BY 61
                                                        // PIXELS" and clipped the last
                                                        // card behind a striped bar.
                                                        // A Row cannot both keep its
                                                        // children at their own width
                                                        // and guarantee they fit a
                                                        // fixed space; the scroll view
                                                        // is what makes the surplus
                                                        // reachable instead of clipped.
                                                        // COLUMN COUNT IS DERIVED,
                                                        // NOT FIXED.
                                                        //
                                                        // It was pinned to
                                                        // NUMBER_OF_COLUMNS, so on a
                                                        // wide row the slots stopped
                                                        // partway across and on a
                                                        // narrow one the last slot
                                                        // was cut off by the panel
                                                        // edge. LayoutBuilder gives
                                                        // the width actually
                                                        // available; the row then
                                                        // holds as many
                                                        // natural-width slots as fit.
                                                        //
                                                        // The +gap / (slot + gap)
                                                        // shape is what makes the
                                                        // count right: N slots have
                                                        // only N-1 gaps between them
                                                        // (Row.spacing adds nothing
                                                        // at the two outer ends), so
                                                        // lending the row one extra
                                                        // gap before dividing stops
                                                        // it dropping a slot that
                                                        // would have fitted.
                                                        //
                                                        // NUMBER_OF_COLUMNS stays as
                                                        // the FLOOR — a narrow panel
                                                        // still offers the full grid,
                                                        // reachable by scrolling.
                                                        if (perLine > 1)
                                                          // Owner 21/10/2026: empty "+" slots share the row's leftover width equally, so a row never ends in a blank strip; filled cards keep their own width, and a row wider than the panel still scrolls sideways.
                                                          LayoutBuilder(
                                                            builder: (BuildContext
                                                                        context,
                                                                    BoxConstraints
                                                                        constraints) =>
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    BoxConstraints(
                                                                        minWidth:
                                                                            constraints.maxWidth),
                                                                child:
                                                                    IntrinsicWidth(
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    // Owner 21/10/2026: 16 between every two slots by eye — a filled card already
                                                                    // keeps 12 badge room on its end side, so 4 follows it; an empty slot keeps none.
                                                                    children: <Widget>[
                                                                      for (int columnIndex =
                                                                              1;
                                                                          columnIndex <=
                                                                              HomeCardMetrics.columns;
                                                                          columnIndex++) ...<Widget>[
                                                                        if (columnIndex >
                                                                            1)
                                                                          SizedBox(
                                                                            width: homeCubit.getEditedComponent(columnIndex: columnIndex - 1, rowIndex: rowIndex) == null
                                                                                // Owner 24/10/2026 "equal padding": between two empty slots
                                                                                // the gap is the badge room (12) — the same visible gap as
                                                                                // between rows and after a filled card.
                                                                                ? HomeCardMetrics.badgeInset
                                                                                : HomeCardMetrics.gapBesideBadge,
                                                                          ),
                                                                        homeCubit.getEditedComponent(columnIndex: columnIndex, rowIndex: rowIndex) ==
                                                                                null
                                                                            ? Expanded(
                                                                                child: item(width: null, columnIndex: columnIndex, rowIndex: rowIndex, cubit: homeCubit),
                                                                              )
                                                                            : item(
                                                                                width: null,
                                                                                columnIndex: columnIndex,
                                                                                rowIndex: rowIndex,
                                                                                cubit: homeCubit),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        else
                                                          LayoutBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                BoxConstraints
                                                                    constraints) {
                                                              final double
                                                                  cellW =
                                                                  HomeCardMetrics
                                                                      .cellWidth(
                                                                          constraints
                                                                              .maxWidth,
                                                                          1);
                                                              return Wrap(
                                                                spacing:
                                                                    HomeCardMetrics
                                                                        .gap,
                                                                runSpacing:
                                                                    HomeCardMetrics
                                                                        .gap,
                                                                children: [
                                                                  for (int columnIndex =
                                                                          1;
                                                                      columnIndex <=
                                                                          HomeCardMetrics
                                                                              .columns;
                                                                      columnIndex++)
                                                                    item(
                                                                      width:
                                                                          cellW,
                                                                      columnIndex:
                                                                          columnIndex,
                                                                      rowIndex:
                                                                          rowIndex,
                                                                      cubit:
                                                                          homeCubit,
                                                                    ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        // ✅ FIX: Removed the fixed-width Container(355.sp) that was
                                        // causing a large empty space on the left in RTL (Arabic) mode.
                                        // In RTL layouts, a trailing spacer becomes a leading spacer,
                                        // pushing all content away from the drawer side.
                                      ],
                                    ),
                                    // Tablet: nothing under the grid, so the page fits
                                    // without scrolling (Owner 21/10/2026).
                                    if (isMobile) SizedBox(height: 20.sp),
                                    // Phone: the real Home page shows the month calendar
                                    // at the end of its scroll (HomeScreen._mobileCalendar),
                                    // so the editor shows it in the same place. Month grid
                                    // only — the day timeline sits in an Expanded and this
                                    // column has unbounded height.
                                    if (isMobile) ...[
                                      // Owner 21/10/2026: a picture of the home calendar only — not tappable here.
                                      IgnorePointer(
                                        child: HomeCalendarWidget(
                              loadEvents: false,
                                          showDayTimeline: false,
                                          currentUserEmail: Get.find<
                                                      MainCoreEmployeeController>()
                                                  .employeeEntity
                                                  ?.email ??
                                              '',
                                        ),
                                      ),
                                      SizedBox(height: 20.sp),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.sp),
                          const EditHomePageCustomButton(),
                          SizedBox(height: 15.sp),
                        ],
                      ),
                    ),

                    // Right — the calendar column, landscape tablet only,
                    // matching HomeScreen. No `onDateSelected`: this page has
                    // no upcoming-schedule list to filter, it only shows
                    // where the calendar sits on the real home page.
                    if (showSideCalendar) SizedBox(width: HomeCardMetrics.gap),
                    if (showSideCalendar)
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0.sp, bottom: 15.sp),
                          // Owner 21/10/2026: a picture of where the calendar sits on Home — not tappable here.
                          child: IgnorePointer(
                            child: HomeCalendarWidget(
                              loadEvents: false,
                              currentUserEmail:
                                  Get.find<MainCoreEmployeeController>()
                                          .employeeEntity
                                          ?.email ??
                                      '',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        ),
      )),
    );
  }

  /// [child] in an [Expanded] on tablet, as-is on phone.
  ///
  /// SideFrameMasterServices hands its child UNBOUNDED height on phone — the
  /// child sits inside the frame's own SingleChildScrollView — so an Expanded
  /// there throws. On tablet the frame wraps the child in an Expanded itself,
  /// and the pinned layout keeps working unchanged.
  ///
  /// D-202 (21/10/2026): on the phone the child is given a BOUNDED height by
  /// [SideFrameBoundedBody] (page minus frame header, nav bar and the toggle
  /// row above), so the layout scrolls inside it and Discard / Preview / Save
  /// stay pinned at the bottom — an Expanded in the frame's own scroll view
  /// threw and left the page blank.
  /// The phone's "Bottom bar" button (NavBarPickerDialog) — fixed so the
  /// bounded layout below can leave room for it.
  double get _bottomBarButtonHeight => 36.sp;

  Widget _expandOnTablet({required bool isMobile, required Widget child}) =>
      isMobile
          // Owner 21/10/2026: 70 left ~67 empty under Discard / Save; 20 cuts it
          // by 75%. 24/10/2026 (Moataz: "reduce the space above the nav by
          // half"): 20 -> 2, so Discard / Save sit ~17 from the bar, not ~35.
          // Plus the "Bottom bar" button row above the layout.
          ? SideFrameBoundedBody(
              extraReserved: 2.sp + _bottomBarButtonHeight + 10.sp,
              child: child)
          : Expanded(child: child);

  Widget item({
    required double? width,
    required int columnIndex,
    required int rowIndex,
    required AppHomeCubit cubit,
  }) {
    HomeComponentModel? model = cubit.getEditedComponent(
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );

    return Builder(
      builder: (BuildContext context) {
        // X-132 (20/10/2026): with "Reordering Active" on, a placed widget can
        // be long-pressed and dropped on any cell; the two cells swap.
        final bool reordering = Get.isRegistered<AppDrawerCubit>() &&
            Get.find<AppDrawerCubit>().isReorderingActive;
        Widget dropTarget(Widget child) {
          if (!reordering) return child;
          return DragTarget<HomeComponentModel>(
            onAcceptWithDetails: (DragTargetDetails<HomeComponentModel> d) {
              HapticController.medium();
              cubit.swapComponents(d.data,
                  toRow: rowIndex, toColumn: columnIndex);
            },
            builder: (BuildContext _, List<HomeComponentModel?> candidates,
                    List<dynamic> __) =>
                Opacity(opacity: candidates.isNotEmpty ? 0.6 : 1, child: child),
          );
        }

        if (model == null) {
          return dropTarget(InkWell(
            hoverColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              cubit.selectComponentToEdit(
                rowIndex: rowIndex,
                columnIndex: columnIndex,
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider<AppHomeCubit>.value(
                    value: cubit,
                    child: AddingWidgetPage(),
                  ),
                ),
              );
            },
            child: AddComponentWidget(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
              width: width,
            ),
          ));
        } else {
          // ✅ CHANGED 31/8/2026: heightBox, not box — HEIGHT is pinned to
          // HomeCardMetrics.height so every slot in a row lines up, WIDTH is
          // the card's own. Forcing a shared width here squeezed cards that
          // need more and padded out cards that need less.
          // D-217 (21/10/2026): the card FITS its cell. A card narrower than
          // the cell fills it; one wider than the cell is scaled down to it
          // (FittedBox) instead of being cut by the panel edge or scrolled.
          // Owner items 191 / 193 (21/10/2026): [width] null = the tablet
          // content grid — the card keeps its content width and the card
          // height (HomeContentGrid measures it); the phone gives the cell
          // width and the card fills it.
          final Widget card = width == null
              ? RemoveComponentWrapper(
                  model: model,
                  component: HomeCardMetrics.heightBox(
                    capWidth: false,
                    height: HomeCardMetrics.chartHeightFor(model.component),
                    child: model.component.widget(model) ??
                        const SizedBox.shrink(),
                  ),
                )
              : SizedBox(
                  width: width,
                  child: RemoveComponentWrapper(
                    model: model,
                    component: HomeGridCell(
                      width: width,
                      height: HomeCardMetrics.chartHeightFor(model.component),
                      inset: HomeCardMetrics.badgeInset,
                      child: model.component.widget(model) ??
                          const SizedBox.shrink(),
                    ),
                  ),
                );
          if (!reordering) return card;
          return dropTarget(LongPressDraggable<HomeComponentModel>(
            data: model,
            onDragStarted: HapticController.medium,
            feedback: Material(
              color: AppColors.transparent,
              child: Opacity(
                opacity: 0.85,
                child:
                    width == null ? card : SizedBox(width: width, child: card),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: card),
            child: card,
          ));
        }
      },
    );
  }
}

/// X-132 (20/10/2026): "Reordering Active" turns itself off when the user
/// leaves Home Layout — it is a mode of this page, not of the app.
class _ReorderingAutoOff extends StatefulWidget {
  const _ReorderingAutoOff({required this.child});
  final Widget child;

  @override
  State<_ReorderingAutoOff> createState() => _ReorderingAutoOffState();
}

class _ReorderingAutoOffState extends State<_ReorderingAutoOff> {
  @override
  void initState() {
    super.initState();
    // 21/10/2026 (Moataz): the page always opens on the SAVED layout —
    // widgets removed or moved without Save were still missing on return.
    context.read<AppHomeCubit>().discardEdits();
    // The drawer shows its Reorder button only while this page is open.
    // After the first frame: the drawer is mid-build when this page mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.isRegistered<AppDrawerCubit>()) {
        Get.find<AppDrawerCubit>().setHomeLayoutOpen(true);
      }
    });
  }

  @override
  void dispose() {
    // Also ends reordering — it is a mode of this page, not of the app.
    if (Get.isRegistered<AppDrawerCubit>()) {
      Get.find<AppDrawerCubit>().setHomeLayoutOpen(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
