import 'package:demo_app/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/DatePicker.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';

class Filter extends StatefulWidget {
   Filter({
     super.key});
   

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
   late AccountStatusCubit controller;
   String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    controller = context.read<AccountStatusCubit>();

    selectedDepartment = controller.selectedDepartment;
  }
  @override
  Widget build(BuildContext context) {

    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color:  AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      width: isTablet ? 400.sp : 300.sp,
      child: Column(
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Row(
            spacing: 5.sp,
            children: [
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: AppColors.primary,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: SvgPicture.asset('assets/icons_assets/main_icons_assets/filter_table.svg',
                  width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              Text('Filter'.tr, style: AppTextStyles.font12BlackCairoRegular.copyWith(
                color: AppColors.text
              )),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 36.h,
            child: AppDropdown(
              value: selectedDepartment,
              width: double.infinity,
              fillColor: AppColors.background,
              textButton: 'Department'.tr,
              customButton: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDropdownText(),
                    SvgPicture.asset(
                      AppAssets.arrowDown,
                      height: 22.sp,
                      width: 22.sp,
                      colorFilter: ColorFilter.mode(
                          AppColors.secondaryBlack, BlendMode.srcIn),
                    ),

                  ],
                ),
              ),
              items: Get.find<MainCoreDepartmentController>()
                  .departmentIds
                  .map((String department) {
                bool isSelected = selectedDepartment == department;
                return DropdownMenuItem<String>(
                  value: department.tr,
                  child: Text(
                    FormatHelper.capitalize(
                      context.isArabic
                          ? Get.find<MainCoreDepartmentController>()
                          .getArabicDepartmentNameFromDepartmentId(
                          departmentId: department)!
                          : Get.find<MainCoreDepartmentController>()
                          .getEnglishDepartmentNameFromDepartmentId(
                          departmentId: department)!,
                    ),
                    style: AppTextStyles.font14SecondaryBlackCairo.copyWith(
                      color: isSelected ? AppColors.text : AppColors.secondaryBlack,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (p0) {
               setState(() {
                 selectedDepartment = p0;
               }
               );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CustomButton(
                    width: 130,
                    buttonColor: AppColors.secondaryButton,
                    textStyle: AppTextStyles.font16BlackCairoMedium,
                    buttonText: 'Discard'.tr,
                    onTap: () {
                      Navigator.of(context).pop();

                    }),
              ),
              SizedBox(width: 20.sp),
              Expanded(
                child: CustomButton(
                    width: 130,
                    buttonText:  'Save'.tr,
                    onTap: () {
                    controller.selectedDepartment = selectedDepartment;
                    controller.searchAccountsStatusEntities(controller.searchController.text, controller.selectedSortOption);
                    Navigator.of(context).pop();
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }

   Widget scheduleCalendar(BuildContext context) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       spacing: 8.sp,
       children: [
         Text('Schedule for Activate'.tr, style: AppTextStyles.font14BlackCairoRegular),
         InkWell(
           onTap: () async {

           },
           child: Container(
               padding: EdgeInsets.symmetric(horizontal: 10.sp),
               height: 36.sp,
               decoration: BoxDecoration(
                 color: AppColors.background,
                 borderRadius: BorderRadius.circular(4.sp),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     "",
                     style: AppTextStyles.font12SecondaryBlackCairoRegular,
                   ),
                   SvgPicture.asset(
                     'assets/icons/calendar.svg',
                     color: AppColors.secondaryText,
                   )
                 ],
               )),
         )
       ],
     );
   }
   Text _buildDropdownText() {
     return Text(
       (   selectedDepartment!=null?  FormatHelper.capitalize(
         context.isArabic
             ? Get.find<MainCoreDepartmentController>()
             .getArabicDepartmentNameFromDepartmentId(
             departmentId: selectedDepartment!)!
             : Get.find<MainCoreDepartmentController>()
             .getEnglishDepartmentNameFromDepartmentId(
             departmentId: selectedDepartment!)!,
       ) :'Department').tr,
       style: selectedDepartment != null
           ?  AppTextStyles.font12BlackCairoRegular
           : AppTextStyles.font12SecondaryBlackCairoRegular,
       overflow: TextOverflow.ellipsis,
     );
   }
}
