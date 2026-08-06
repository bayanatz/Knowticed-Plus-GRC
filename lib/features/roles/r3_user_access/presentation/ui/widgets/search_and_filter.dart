///************************** FILE INFO ****************************///
/// File Name: search_and_filter.dart
/// Purpose : Contains the ui for search and filter in account status screen.
/// Author: Amr Mesbah
/// Created at : 28/1/2025
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';


import 'package:grc_module/core/helper/main_helper/icon_size.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import './filter.dart';
import './filter_widget.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class SearchAndFilter extends StatelessWidget {
  SearchAndFilter({super.key});
  late UserAccessCubit controller;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    controller = context.read<UserAccessCubit>();
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return IntrinsicHeight(
      child: Row(
        spacing: 5.sp,
        crossAxisAlignment:
        isPortrait ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // AppSearchTextField already returns an Expanded, so it must NOT be
          // wrapped in one here (nested Expanded is a runtime error).
          AppSearchTextField(
            controller: controller.searchController,
            onChanged: (value) {
              controller.searchAccountsStatusEntities(
                  value, controller.selectedSortOption);
            },
          ),

          // ✅ Replace the entire dropdown code with SortDropdownWidget
          if (!isMobile)
            SortDropdownWidgetRole(
              onChanged: (value) {
                controller.sortAccountsStatusEntities(value);
              },
              isMobile: isMobile,
              isPortrait: isPortrait,
              selectedSortOptionRole: controller.selectedSortOption,
            ),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: BlocProvider<UserAccessCubit>.value(
                      value: controller,
                      child: Filter(),
                    ),
                  );
                },
              );
            },
            child: Container(
              height: 38.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: IconSizeHelper.getIconSize(context),
                    child: CustomSvgImage(
                        assetPath: "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                        width: 15.sp,
                        height: 15.sp,
                        color: AppColors.secondaryText
                    ),
                  ),

                  (isTablet) ? SizedBox(width: 8.sp) : Container(),

                  (isTablet)
                      ? Text(
                      S.of(context).Filter,
                      style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.secondaryText
                      )
                  )
                      : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}