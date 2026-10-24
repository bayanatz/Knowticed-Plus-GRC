/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_picker_dialog.dart
/// Purpose: Declares `NavBarPickerDialog` — the phone's "Bottom bar" picker
///          on Home Layout: which modules (up to 4) sit in the bottom bar;
///          More is always the last one.
/// Author: Knowticed Plus team
/// Updated: 21/10/2026 - Created (Owner: "select what I could see from the
///          four buttons … More will be always there").
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/helpers/date_time_in_arabic.dart'
    show localizeNumber;
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Same shell as the shortcut-icon picker (IconSelectorDialog): a header,
/// then two tiles in a row. No Save / Discard step: take a module out, pick
/// another, and the bar changes (and is saved) the moment 4 are picked.
class NavBarPickerDialog extends StatefulWidget {
  const NavBarPickerDialog({super.key});

  @override
  State<NavBarPickerDialog> createState() => _NavBarPickerDialogState();
}

class _NavBarPickerDialogState extends State<NavBarPickerDialog> {
  final NavBarCubit cubit = Get.find<NavBarCubit>();

  /// Closing with fewer than 4 picked keeps the bar as it was.
  @override
  void dispose() {
    cubit.discardNavBarDraft();
    super.dispose();
  }

  static const double _pad = 15;
  static const double _gap = 8;
  static const double _slotHeight = 68;
  static const double _slotRadius = 6;

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        width: double.infinity,
        padding: EdgeInsets.all(_pad.sp),
        decoration: BoxDecoration(
          color: lightMode ? AppColors.white : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: BlocBuilder<NavBarCubit, NavBarState>(
          bloc: cubit,
          builder: (BuildContext context, NavBarState state) {
            final List<Modules> chosen = cubit.pickedNavBarModules;
            final int slots = cubit.navBarSlots;
            final bool full = chosen.length >= slots;
            final List<Modules> available = <Modules>[
              for (final Modules m in cubit.selectableNavBarModules)
                if (!chosen.contains(m)) m,
            ];
            return Padding(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(context, chosen.length, slots),
                  SizedBox(height: 16.h),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // The bar as it will look (read only): the picked
                          // modules, empty places, then More.
                          _preview(context, chosen, slots),
                          SizedBox(height: 8.h),
                          Text(
                            full
                                ? S.of(context).bottomBarFull
                                : S.of(context).bottomBarHint,
                            style: StyleText.fontSize16Weight400.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            S.of(context).bottomBarInBar,
                            style: _sectionStyle,
                          ),
                          SizedBox(height: 4.h),
                          _barList(chosen),
                          if (available.isNotEmpty) ...<Widget>[
                            SizedBox(height: 14.h),
                            Text(
                              S.of(context).bottomBarAvailable,
                              style: _sectionStyle,
                            ),
                            SizedBox(height: 4.h),
                            // Three to a row (24/10/2026: "reduce the scroll").
                            LayoutBuilder(
                              builder: (BuildContext _, BoxConstraints box) {
                                final double w =
                                    (box.maxWidth - 2 * _gap.w) / 3;
                                return Wrap(
                                  spacing: _gap.w,
                                  runSpacing: _gap.h,
                                  children: <Widget>[
                                    for (final Modules m in available)
                                      SizedBox(
                                        width: w,
                                        child: _tile(m, blocked: full),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _actions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Cancel throws the pick away; Done makes it the bar (1 to 4 modules —
  /// the owner may want only three, 24/10/2026).
  Widget _actions(BuildContext context) {
    Widget button(String label, VoidCallback onTap, {required bool primary}) =>
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: onTap,
            child: Container(
              height: 38.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary ? AppColors.primary : AppColors.secondaryAction,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                label,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: primary
                      ? AppColors.textButton
                      : AppColors.onSecondaryAction,
                ),
              ),
            ),
          ),
        );
    return Row(
      children: <Widget>[
        button(S.of(context).cancel, () {
          HapticController.low();
          cubit.discardNavBarDraft();
          Navigator.of(context).pop();
        }, primary: false),
        SizedBox(width: 12.w),
        button(S.of(context).done, () {
          HapticController.low();
          // Applied once the dialog is gone: changing the tab count during
          // this frame's layout trips a framework assertion.
          final List<Modules> picked = cubit.pickedNavBarModules;
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => cubit.applyNavBarDraft(picked),
          );
        }, primary: true),
      ],
    );
  }

  Widget _header(BuildContext context, int picked, int slots) {
    return Row(
      children: <Widget>[
        Container(
          width: 26.sp,
          height: 26.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_nav_grid.svg',
              width: 14.sp,
              height: 14.sp,
              fit: BoxFit.scaleDown,
              color: AppColors.textButton,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            S.of(context).bottomBar,
            style: StyleText.fontSize16Weight400.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 3 / 4 — how many places are filled.
        Text(
          '${localizeNumber('$picked')} / ${localizeNumber('$slots')}',
          style: StyleText.fontSize16Weight400.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  /// The live bar: one place per slot, then More.
  Widget _preview(BuildContext context, List<Modules> chosen, int slots) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < slots; i++) ...<Widget>[
          if (i > 0) SizedBox(width: _gap.w),
          Expanded(
            child: i < chosen.length ? _filledSlot(i, chosen[i]) : _emptySlot(),
          ),
        ],
        SizedBox(width: _gap.w),
        Expanded(child: _moreSlot(context)),
      ],
    );
  }

  Widget _slotBody(Widget child, {required Color fill, Color? border}) =>
      Container(
        height: _slotHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 2.sp, vertical: 4.sp),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(_slotRadius.r),
          border: border == null ? null : Border.all(color: border),
        ),
        child: child,
      );

  /// A picked module as the bar will draw it: icon over name. Read only —
  /// changing the bar happens in the lists below.
  Widget _filledSlot(int index, Modules m) {
    return _slotBody(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomSvgImage(
            assetPath: m.iconPath,
            width: 20.w,
            height: 20.h,
            color: AppColors.textButton,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 4.h),
          Text(
            m.getModuleName,
            style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 9.sp, height: 1.2, color: AppColors.textButton),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      fill: AppColors.primary,
    );
  }

  /// The app's round action badge — the same drawn circle as the red minus
  /// on Home Layout cards — in a fixed box so every minus and plus in the
  /// lists share one centre line. Red minus removes, yellow plus adds.
  Widget _badge({required bool minus}) {
    final double d = 18.sp;
    final Color ink = minus ? AppColors.white : AppColors.textButton;
    return SizedBox(
      width: 36.sp,
      height: 36.sp,
      child: Center(
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            color: minus ? AppColors.red : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(width: d * 0.5, height: 2, color: ink),
                if (!minus) Container(width: 2, height: d * 0.5, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _sectionStyle => StyleText.fontSize16Weight400
      .copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500);

  /// "In the bar": the picked modules, each with a handle to drag it to
  /// another place and a button to take it out.
  Widget _barList(List<Modules> chosen) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: chosen.length,
      proxyDecorator: (Widget child, int _, Animation<double> __) =>
          Material(color: AppColors.transparent, child: child),
      onReorderItem: (int from, int to) {
        HapticController.medium();
        cubit.reorderNavBarModules(from, to);
      },
      itemBuilder: (BuildContext context, int i) {
        final Modules m = chosen[i];
        return Container(
          key: ValueKey<String>('bar_${m.name}'),
          height: 46.h,
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(_slotRadius.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: <Widget>[
              ReorderableDragStartListener(
                index: i,
                child: Padding(
                  padding: EdgeInsets.all(6.sp),
                  child: Icon(Icons.drag_indicator,
                      size: 20.sp, color: AppColors.secondaryText),
                ),
              ),
              SizedBox(width: 4.w),
              CustomSvgImage(
                assetPath: m.iconPath,
                width: 20.w,
                height: 20.h,
                color: AppColors.primary,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  m.getModuleName,
                  style:
                      StyleText.fontSize16Weight400.copyWith(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticController.low();
                  cubit.toggleNavBarModule(m);
                },
                child: _badge(minus: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptySlot() => _slotBody(
        Center(child: Icon(Icons.add, size: 20.sp, color: AppColors.primary)),
        fill: AppColors.transparent,
        border: AppColors.primary.withValues(alpha: 0.6),
      );

  /// More is always the last place and cannot be changed.
  Widget _moreSlot(BuildContext context) => Opacity(
        opacity: 0.6,
        child: _slotBody(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.menu, size: 20.sp, color: AppColors.text),
              SizedBox(height: 4.h),
              Text(
                S.of(context).more,
                style: StyleText.fontSize16Weight400
                    .copyWith(fontSize: 9.sp, color: AppColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          fill: AppColors.transparent,
          border: AppColors.secondaryText,
        ),
      );

  /// An available module as a tile: icon over name, a small + in the corner.
  /// Tapping the tile puts it in the next free place.
  Widget _tile(Modules m, {required bool blocked}) {
    return Opacity(
      opacity: blocked ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(_slotRadius.r),
        onTap: blocked
            ? null
            : () {
                HapticController.low();
                cubit.toggleNavBarModule(m);
              },
        child: Stack(
          children: <Widget>[
            Container(
              height: _slotHeight.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.sp, vertical: 6.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(_slotRadius.r),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: m.iconPath,
                    width: 22.w,
                    height: 22.h,
                    color: AppColors.primary,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    m.getModuleName,
                    style: StyleText.fontSize16Weight400
                        .copyWith(fontSize: 10.sp, height: 1.2),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 3.sp,
              end: 3.sp,
              child: Container(
                width: 14.sp,
                height: 14.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.add, size: 11.sp, color: AppColors.textButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
