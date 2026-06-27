import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/DatePicker.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';

class ScheduleActivation extends StatefulWidget {
   ScheduleActivation({
     required this.selectedDate,
     required this.accountStatusAccessEntity,
     super.key});
   DateTime selectedDate;
   AccountStatusAccessEntity accountStatusAccessEntity;

  @override
  State<ScheduleActivation> createState() => _ScheduleActivationState();
}

class _ScheduleActivationState extends State<ScheduleActivation> {
   late AccountStatusCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<AccountStatusCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
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
                  child: SvgPicture.asset('assets/skeleton/roles/icons/edit_schedule_icon.svg',
                  width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              Text('Schedule'.tr, style: AppTextStyles.font12BlackCairoRegular.copyWith(
                color: AppColors.text
              )),
            ],
          ),
          scheduleCalendar(context),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                  width: 130,
                  buttonColor: AppColors.secondaryButton,
                  textStyle: AppTextStyles.font16BlackCairoMedium,
                  buttonText: 'Discard'.tr,
                  onTap: () {
                    Navigator.of(context).pop();

                  }),
              CustomButton(
                  width: 130,
                  buttonText:  'Save'.tr,
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.scheduleReactivation(
                        widget.accountStatusAccessEntity,
                        DateFormat(Constants.userAccessDateFormat, 'en')
                            .format(widget.selectedDate));
                  }),
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
             List<DateTime?>? dates = await DatePicker().showDatePicker(
                 context,
                 [widget.selectedDate],
                 DateTime.now(),
                 CalendarDatePicker2Type.single,
                 firstDate: DateTime.now());
             if (dates != null && dates.first != null) {
               widget.selectedDate = dates.first!;
               setState(() {});
             }
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
                     DateFormat(Constants.userAccessDateFormat,
                         context.isArabic ? 'ar' : 'en')
                         .format(widget.selectedDate),
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
}
