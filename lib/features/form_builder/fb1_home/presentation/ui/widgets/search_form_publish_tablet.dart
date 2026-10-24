/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: search_form_publish_tablet.dart
/// Description: `SearchFormPublishTablet` widget, state and UI of the `SearchFormPublishTablet` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

// Keep for .tr translations
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_sort_option.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SearchFormPublishTablet extends StatefulWidget {
  const SearchFormPublishTablet({super.key});

  @override
  State<SearchFormPublishTablet> createState() =>
      _SearchFormPublishTabletState();
}

class _SearchFormPublishTabletState extends State<SearchFormPublishTablet> {
  // ── Figma spec: MESBAH / node 7444-37189, action row node 7444-37220 ──────
  // The row is 876 × 38 and lays out as
  //   search 481 | 15 | Filter 100 | 15 | Sort 100 | 15 | Create Form 150
  // (481 + 15 + 100 + 15 + 100 + 15 + 150 = 876). The search field is the
  // Expanded child, so only the three buttons and the three gaps are pinned.
  /// Filter and Sort share ONE number on purpose — the bug report asked for
  /// them to be equal, so the design values are not allowed to drift apart in
  /// two files. `kActionButtonWidth` is passed to both.
  static const double kActionButtonWidth = 100;
  static const double kCreateFormWidth = 150;
  static const double kButtonHeight = 38;

  // Icon box of the Create Form button (Filter and Sort draw ToolbarStyle):
  // 19 × 24, followed by an 8 gap before its label.
  static const double kCreateIconWidth = 19;
  static const double kCreateIconHeight = 24;
  static const double kIconTextGap = 8;

  /// ONE predicate for the whole row.
  ///
  /// This is the "make filter and sort button equal in size"
  /// item from the bug report. Filter tested `isTablett && isLandscape` while
  /// Sort tested its own `size.width >= 600 && isLandscape`, and the two
  /// disagree whenever the window is wide but short: at 800 × 500 the
  /// shortestSide (500) is under the tablet cut-off, so Filter collapsed to
  /// the 36-wide icon button while Sort's width-only test still saw 600+ and
  /// stayed 100 wide. Both buttons now read this single value, so they can
  /// only ever change together.
  bool isWideLayout(BuildContext context) =>
      ContextExtension(context).isTablett &&
      ContextExtension(context).isLandscape;

  /// The search text; owned here, not by the cubit (Home rule 7).
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = isWideLayout(context);

    return BlocConsumer<HomeCubit, HomeState>(
      // The filter's Reset and a tab change clear the query in the cubit;
      // clear the field to match.
      listener: (context, state) {
        final String query = context.read<HomeCubit>().searchQuery;
        if (_searchController.text != query) _searchController.text = query;
      },
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppSearchTextField(
              controller: _searchController,
              onChanged: (value) {
                cubit.onSearch(value);
              },
            ),

            SizedBox(width: ButtonSizing.toolbarGap(context)),
            // Bug report #24: no Filter on the Submissions tab.
            if (cubit.selectedTabIndex != 3) ...[
              // CHANGED 18/10/2026 (Moataz: Filter and Sort must look the
              // same in every module): the shared CustomFilterIcon, not a
              // hand-built 16/500 button — same 100 × 38 box, label style and
              // icon colour as CustomSortButton beside it.
              // Owner 21/10/2026: Filter is pinned to the exact box Sort gets (same width + height), so the pair is identical; fill, border, icon and label already come from the shared ToolbarStyle.
              SizedBox(
                width: isWide
                    ? ToolbarStyle.labelledWidth
                    : ButtonSizing.iconButtonSize,
                height: ButtonSizing.height,
                child: CustomFilterIcon(
                  onTap: () => AppDialogs.filterDialog(context),
                  iconOnly: !isWide,
                ),
              ),

              SizedBox(width: ButtonSizing.toolbarGap(context)),
            ],

            // Sort dropdown menu — same box as Filter, from the SAME width
            // constant and the SAME `isWide` value, so the pair cannot
            // diverge again the way the bug report caught them doing.
            CustomSortButton<String>(
              // Bug report #11/#24: the Knowticed Admin sort button —
              // neutral until a pick, primary while one is active, tap the
              // active row again to clear it. The Submissions tab sorts by
              // Submission / Received date.
              value: cubit.activeSortOption,
              items: cubit.selectedTabIndex == 3
                  ? FormSortOption.submissionValues
                  : FormSortOption.values,
              labelBuilder: FormSortOption.labelOf,
              // Icon-only in
              // portrait, like Filter — the label only shows in the wide
              // (landscape tablet / desktop) row.
              showTitle: isWide,
              // Bug report p.69: `.sp`, like Filter / Create Form (whose
              // height ButtonSizing pins to 38.sp) — `.h` made Sort a
              // different height from its neighbours.
              width: isWide
                  ? ToolbarStyle.labelledWidth
                  : ButtonSizing.iconButtonSize,
              height: ButtonSizing.height,
              onChanged: cubit.updateSortOption,
            ),

            SizedBox(width: ButtonSizing.toolbarGap(context)),

            // Create Form — Figma 150 × 38 (was 130, and the 130 was being
            // ignored anyway: customButtonWithSvg drops `width:` and used
            // the app-wide 135.sp). Icon is 19 × 24 with an 8 gap.
            //
            // Bug report p.69 ("when close switch of
            // create form it still appears"): the Create New Form
            // permission gate had been commented out.
            //
            // On a phone the button
            // is icon-only — the same 38-high square as Filter / Sort — so
            // the search field (Expanded) gets the width the label took.
            //
            // Icon-only on the vertical
            // tablet too, not just the phone — the button now follows the
            // same `isWide` switch as Filter and Sort, so all three show
            // their label only in the wide (landscape tablet / desktop) row.
            // CHANGED 18/10/2026 (Moataz: no Create Form button on the
            // desktop / iPad home): the permission is read inside a
            // GetBuilder on the employee controller, so the button appears
            // as soon as the role's permissions finish loading. Before, it
            // was read once when the forms loaded; if the role's permission
            // cache was still empty at that moment the button stayed hidden
            // until something else rebuilt the row. Same gate as before
            // (Create_New_Form), nothing is loosened.
            _buildCreateFormButton(context, isWide),
          ],
        );
      },
    );
  }

  Widget _buildCreateFormButton(BuildContext context, bool isWide) {
    Widget button() {
      if (!FormBuilderAccess.canCreateForm) return const SizedBox.shrink();
      if (!isWide) {
        return _buildIconWidget(
          asset: "assets/icons_assets/main_icons_assets/ic_create_form.svg",
          text: S.of(context).createForm,
          onTap: () => _navigateToCreateForm(context),
          showText: false,
          isPrime: true,
          context: context,
        );
      }
      return customButtonWithSvg(
        fixedWidth: kCreateFormWidth.w,
        height: kButtonHeight.h,
        title: S.of(context).createForm,
        function: () {
          _navigateToCreateForm(context);
        },
        svgColor: AppColors.textButton,
        color: AppColors.primary,
        radius: 8.r,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.textButton,
        ),
        image: "assets/icons_assets/main_icons_assets/ic_create_form.svg",
        widthImage: kCreateIconWidth,
        heightImage: kCreateIconHeight,
        colorBorder: AppColors.transparent,
        space: kIconTextGap.w,
      );
    }

    if (!Get.isRegistered<MainCoreEmployeeController>()) return button();
    return GetBuilder<MainCoreEmployeeController>(builder: (_) => button());
  }

  void _navigateToCreateForm(BuildContext context) {
    // The editor picks the phone or tablet layout itself.
    context.FormNavigateTo(Routes.create);
  }

  Widget _buildIconWidget({
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    required BuildContext context,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      // Icon-only Filter / Create
      // Form were 36.h × 38.h — not square, and a different unit from Sort
      // (38.sp × 38.sp). Now a perfect kButtonHeight.sp square on mobile and
      // tablet, matching Sort.
      child: Container(
        height: kButtonHeight.sp,
        width: showText
            ? (isPrime ? kCreateFormWidth.w : kActionButtonWidth.w)
            : kButtonHeight.sp,
        decoration: BoxDecoration(
          color: isPrime ? AppColors.primary : AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CustomSvgImage.natural(
                  assetPath: asset,
                  colorFilter: ColorFilter.mode(
                    isPrime ? AppColors.textButton : AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.secondaryText)
                      .copyWith(color: isPrime ? AppColors.textButton : null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
