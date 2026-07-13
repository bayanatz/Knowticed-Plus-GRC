///************************** FILE INFO ****************************///
/// File Name: search_and_filter.dart
/// Purpose : Contains the ui for search and filter in account status screen.
/// Author: Mohamed Elrashidy
/// Created at : 28/1/2025
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';


import 'package:demo_app/features/roles/account_status/utils/account_status_helper.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';
import 'filter.dart';
import 'filter_widget.dart';

class SearchAndFilter extends StatelessWidget {
  SearchAndFilter({super.key});
  late AccountStatusCubit controller;

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    controller = context.read<AccountStatusCubit>();
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isArabic = Get.locale?.languageCode == 'ar';

    return IntrinsicHeight(
      child: Row(
        spacing: 5.sp,
        crossAxisAlignment:
        isPortrait ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // ✅ Replace AppSearchTextField with Customdemo_appTextField
          Expanded(
            child: CustomTextField(
              hint: isArabic ? 'بحث' : 'Search',
              controller: controller.searchController,
              fillColor: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              height: 36.h,
              valueStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              hintStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText.withOpacity(.5),
              ),
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                controller.searchAccountsStatusEntities(
                    value, controller.selectedSortOption);
              },
            ),
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
                    child: BlocProvider<AccountStatusCubit>.value(
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
                    scale: AccountStatusHelper.getIconSize(context),
                    child: SvgPicture.asset(
                        width: 15.sp,
                        height: 15.sp,
                        "assets/icons_assets/main_icons_assets/filter_table.svg",
                        color: AppColors.secondaryText
                    ),
                  ),

                  (isTablet) ? SizedBox(width: 8.sp) : Container(),

                  (isTablet)
                      ? Text(
                      "Filter".tr,
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