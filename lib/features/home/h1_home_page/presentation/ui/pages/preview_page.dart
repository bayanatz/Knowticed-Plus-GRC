/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: preview_page.dart
/// Purpose: Declares `HomePreview` — Settings › Home Layout › Home Preview.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
///          21/10/2026 - X-140: the device frame now holds the REAL home page
///          (`EmbeddedHomePage`) laid out at that device's size with the
///          UNSAVED layout, instead of a hand-built copy of the page; frame
///          centred and scaled to fit; ONE pinned button row — Discard Changes
///          left, Back To Edit + Save right (X-01).
library;

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/embedded_home_page.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomePreview extends StatelessWidget {
  const HomePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isTablet = !kpIsPhoneLayout(context);
    final AppHomeCubit homeCubit = context.read<AppHomeCubit>();
    final S l = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      // WATERMARK 25/8/2026. Wrapped here rather than relying on an ancestor: on
      // the phone branch this page is pushed onto an OUTER navigator, so it is
      // not a descendant of the wrapped HomeResponsivePage. On tablet it is,
      // and the inner layer then hands its child straight back — see the
      // nesting note in watermark_layer.dart.
      body: WatermarkLayer(
        module: Modules.settings, // Home Layout is a settings page
        child: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 16.sp, end: 16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(screensTitles: [
                  l.settings,
                  l.homeLayout,
                  l.homePreview,
                ]),

                SizedBox(height: 16.sp),

                // Device tabs
                BlocBuilder<AppHomeCubit, HomeState>(
                  builder: (context, state) {
                    return Row(
                      spacing: isMobile ? 40.sp : 30.sp,
                      children: [
                        _buildPreviewTab(
                          context: context,
                          title: l.desktopView,
                          isSelected: homeCubit.currentPreviewMode ==
                              PreviewMode.desktop,
                          onTap: () =>
                              homeCubit.setPreviewMode(PreviewMode.desktop),
                        ),
                        _buildPreviewTab(
                          context: context,
                          title: l.tabletView,
                          isSelected: homeCubit.currentPreviewMode ==
                              PreviewMode.tablet,
                          onTap: () =>
                              homeCubit.setPreviewMode(PreviewMode.tablet),
                        ),
                        _buildPreviewTab(
                          context: context,
                          title: l.mobileView,
                          isSelected: homeCubit.currentPreviewMode ==
                              PreviewMode.mobile,
                          onTap: () =>
                              homeCubit.setPreviewMode(PreviewMode.mobile),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 16.sp),

                // The real page inside the device frame, centred and scaled to
                // whatever room is left above the buttons.
                Expanded(
                  child: BlocBuilder<AppHomeCubit, HomeState>(
                    builder: (context, state) {
                      return Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: _buildDevicePreview(
                            context,
                            homeCubit,
                            key: ValueKey(homeCubit.currentPreviewMode),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.sp),

                // X-140 / X-01: ONE pinned row — Discard Changes at the left
                // edge, Back To Edit + Save at the right edge, all the same
                // size. Save persists exactly like the edit page's Save.
                _buildActions(context, isMobile),

                SizedBox(height: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isMobile) {
    final S l = S.of(context);
    final Widget discard = customButton(
      width: 150.w,
      fullWidth: isMobile,
      color: AppColors.darkGrey,
      title: l.discardChanges,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      function: () {
        // Drop the unsaved layout and leave the editor.
        context.read<AppHomeCubit>().discardEdits();
        Navigator.of(context).pop();
      },
    );
    final Widget backToEdit = customButton(
      width: 150.w,
      fullWidth: isMobile,
      color: AppColors.darkGrey,
      title: l.backToEdit,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      function: () => Navigator.of(context).pop(),
    );
    final Widget save = customButton(
      width: 150.w,
      fullWidth: isMobile,
      color: AppColors.primary,
      title: l.Save,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
      function: () {
        context.read<AppHomeCubit>().updateHomeComponents();
        Navigator.of(context).pop();
      },
    );

    if (isMobile) {
      // Phone: three buttons do not fit one row — Back To Edit + Save share
      // the row, Discard full width under them (rule 4.10).
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: backToEdit),
              SizedBox(width: 16.sp),
              Expanded(child: save),
            ],
          ),
          SizedBox(height: 12.sp),
          discard,
        ],
      );
    }
    return Row(
      children: <Widget>[
        discard,
        const Spacer(),
        backToEdit,
        SizedBox(width: 12.sp),
        save,
      ],
    );
  }

  // Build Preview Tab Button with animation
  Widget _buildPreviewTab({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: isMobile
                  ? StyleText.fontSize16Weight700.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (AppColors.secondaryPrimary)
                          : (AppColors.secondaryText),
                    )
                  : StyleText.fontSize20Weight500.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (AppColors.secondaryPrimary)
                          : (AppColors.secondaryText),
                    ),
              child: Text(title),
            ),
            SizedBox(height: 2.sp),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isSelected ? 1.sp : 0,
              color: isSelected
                  ? (AppColors.secondaryPrimary)
                  : (AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  /// The device frame with the REAL home page inside, laid out at that
  /// device's logical size and showing the layout being edited (X-140).
  Widget _buildDevicePreview(
    BuildContext context,
    AppHomeCubit homeCubit, {
    Key? key,
  }) {
    final Size deviceSize = _deviceSizeFor(homeCubit.currentPreviewMode);
    final DeviceInfo device = switch (homeCubit.currentPreviewMode) {
      // Owner 21/10/2026: the window IS the laptop screen — the stock
      // MacBook frame shows a small window over a wallpaper.
      PreviewMode.desktop => _fullScreenMac,
      PreviewMode.tablet => Devices.ios.iPadPro13InchesM4,
      PreviewMode.mobile => Devices.ios.iPhone13,
    };

    // scaleDown: the frame is drawn at the device's real size and shrunk to
    // the room available, so a Mac frame fits on a phone and nothing
    // overflows.
    return FittedBox(
      key: key,
      fit: BoxFit.scaleDown,
      child: DeviceFrame(
        device: device,
        screen: Container(
          color: AppColors.background,
          child: EmbeddedHomePage(size: deviceSize, previewUnsaved: true),
        ),
      ),
    );
  }
}

/// The logical screen size each preview device lays the home page out at.
/// The Mac home is a landscape 1366 × 768 window (the design size).
Size _deviceSizeFor(PreviewMode mode) => switch (mode) {
      PreviewMode.desktop => const Size(1366, 768),
      PreviewMode.tablet => const Size(1024, 1366),
      PreviewMode.mobile => const Size(375, 812),
    };

/// A laptop whose one window fills the whole screen: 1366 × 768 content
/// under the 30-high macOS title bar.
final DeviceInfo _fullScreenMac = DeviceInfo.genericLaptop(
  platform: TargetPlatform.macOS,
  id: 'kp-mac-full-screen',
  name: 'Mac',
  screenSize: const Size(1366, 798),
  windowPosition: const Rect.fromLTWH(0, 0, 1366, 798),
);
