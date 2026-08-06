import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/entity/user_access_entity.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/custom/53_custom_date_pic.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/helper/role/constants.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:grc_module/generated/l10n.dart';
class Filter extends StatefulWidget {
   Filter({
     super.key});
   

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
   late UserAccessCubit controller;
   String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    controller = context.read<UserAccessCubit>();

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
                  child: CustomSvgImage(assetPath: 'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                  width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              Text(S.of(context).Filter, style: AppTextStyles.font12BlackCairoRegular.copyWith(
                color: AppColors.text
              )),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 36.h,
            child: CustomDropdown<String>(
              value: selectedDepartment,
              fillColor: AppColors.background,
              hint: S.of(context).department,
              items: context.read<MainCoreDepartmentCubit>()
                  .departmentIds
                  .map((String department) {
                return DropdownItem<String>(
                  value: department,
                  label: FormatHelper.capitalize(
                    context.isArabic
                        ? context.read<MainCoreDepartmentCubit>()
                            .getArabicDepartmentNameFromDepartmentId(
                                departmentId: department)!
                        : context.read<MainCoreDepartmentCubit>()
                            .getEnglishDepartmentNameFromDepartmentId(
                                departmentId: department)!,
                  ),
                );
              }).toList(),
              onChanged: (p0) {
                setState(() {
                  selectedDepartment = p0;
                });
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: customButton(
                    color: AppColors.secondaryButton,
                    textStyle: AppTextStyles.font16BlackCairoMedium,
                    title: S.of(context).discard,
                    function: () {
                      Navigator.of(context).pop();

                    }),
              ),
              SizedBox(width: 20.sp),
              Expanded(
                child: customButton(
                    title:  S.of(context).Save,
                    function: () {
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
         Text(S.of(context).scheduleForActivate, style: AppTextStyles.font14BlackCairoRegular),
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
                   CustomSvgImage(assetPath: 
                     'assets/icons_assets/roles_assets/calendar.svg',
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
             ? context.read<MainCoreDepartmentCubit>()
             .getArabicDepartmentNameFromDepartmentId(
             departmentId: selectedDepartment!)!
             : context.read<MainCoreDepartmentCubit>()
             .getEnglishDepartmentNameFromDepartmentId(
             departmentId: selectedDepartment!)!,
       ) :'Department'),
       style: selectedDepartment != null
           ?  AppTextStyles.font12BlackCairoRegular
           : AppTextStyles.font12SecondaryBlackCairoRegular,
       overflow: TextOverflow.ellipsis,
     );
   }
}
