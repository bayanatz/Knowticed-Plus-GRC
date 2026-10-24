/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: search_bar_share_widget.dart
/// Description: `SearchBarShareWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/department_display_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Keep for .tr translations
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/pages/group_screen.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/synced_search_field.dart';

class SearchBarShareWidget extends StatelessWidget {
  const SearchBarShareWidget({super.key, required this.form});
  final FormEntity form;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    // (vertical bug report p.32 — "add name, not just
    // icon"): the Group button was icon-only below 1200 wide, i.e. on every
    // tablet in portrait. It now shows its label on any tablet; phones stay
    // icon-only for room.
    bool showText = !ContextExtension(context).isPhone;

    return BlocBuilder<ShareCubit, ShareState>(
      builder: (context, state) {
        if (state is! ShareLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchBar(context, state, widthScreen),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              _buildDropDown(context, state),
            ],
            _buildSpace(context),
            _buildIconWidget(
              context: context,
              asset: AppAssets.group,
              text: S.of(context).group,
              onTap: () {
                context.read<FormsGroupCubit>().resetGroupController();
                // FB-SHARE-03: hand over the people who already have access
                // from the ShareCubit this page owns.
                final ShareState shareState = context.read<ShareCubit>().state;
                context.read<FormsGroupCubit>().getGroups(
                  previousSelectedPersons: shareState is ShareLoaded
                      ? shareState.previousSelectedPersons
                      : const [],
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return GroupScreen(form: form);
                    },
                  ),
                );
              },
              showText: showText,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(
    BuildContext context,
    ShareLoaded state,
    double widthScreen,
  ) {
    return SyncedSearchField(
      text: state.searchText,
      onChanged: (value) => context.read<ShareCubit>().search(value),
    );
  }

  Widget _buildIconWidget({
    required BuildContext context,
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        // Bug report p.8: same height as the search bar beside it
        // (AppSearchTextField is 38, scaled in .sp). Was a raw 36.
        height: 38.sp,
        // Width follows the label when shown, so "المجموعة" / "Group" never
        // clips; 12 of padding each side.
        width: showText ? null : 38.sp,
        padding: showText
            ? EdgeInsets.symmetric(horizontal: 12.sp)
            : EdgeInsets.zero,
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
                width: 20,
                height: 20,
                child: CustomSvgImage.natural(
                  assetPath: asset,
                  colorFilter: ColorFilter.mode(
                    isPrime ? AppColors.black : AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText)
                      .copyWith(color: isPrime ? AppColors.black : null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Multi-select (CustomMultiSelectFilter) instead
  /// of a single-pick AppDropdown: tick any number of departments; none
  /// ticked = everyone.
  Widget _buildDropDown(BuildContext context, ShareLoaded state) {
    final departments = context
        .read<ShareCubit>()
        .departmentCubit
        .departmentModels
        .where((e) => e.departmentID != null)
        .toList();

    return SizedBox(
      // Bug report p.8: same 38.sp height as the search bar.
      width: 180.w,
      child: CustomMultiSelectFilter<String>(
        height: 38,
        heightSizesWholeTrigger: true,
        // Same fill as the search bar beside it.
        fillColor: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        hint: S.of(context).department,
        // Same text style as the Group button beside it.
        // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
        hintStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
        ),
        valueStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
        ),
        values: state.departments,
        items: departments
            .map(
              (e) => MultiSelectDropdownItem<String>(
                value: e.departmentID!,
                label: e.displayName(arabic: context.isArabic),
              ),
            )
            .toList(),
        onChanged: (ids) {
          context.read<ShareCubit>().updateDepartments(ids);
        },
      ),
    );
  }
}
