import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';
import 'package:demo_app/features/messaging/interface/message_interface_consumer.dart';
import 'package:demo_app/features/home/data/models/direct_message_model.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';

class DirectMessages extends StatelessWidget {
  DirectMessages({required this.model, super.key});
  DirectMessageModel model;
  @override
  Widget build(BuildContext context) {
    return StandardContainer(
        height: 175.h,
        child: Column(
          children: [
            Container(width: 140.sp),
            Row(
              spacing: 10.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (String email in model.usersEmails)
                  directChat(email, context)
              ],
            ),
          ],
        ));
  }

  Widget directChat(String email, BuildContext context) {
    String image =
        EmployeeHelper.getEmployeeImageWithEmail(employeeEmail: email);
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: (image.contains('http'))
              ? NetworkImage(image) as ImageProvider
              : AssetImage(image),
        ),
        SizedBox(height: 5.sp),
        Text(
          FormatHelper.capitalize(
              EmployeeHelper.getEmployeeLocalizedNameWithEmail(
                  employeeEmail: email)),
          style: AppTextStyles.font10BlackCairoRegular
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 23.sp),
        CustomButton(
            buttonText: 'Message'.tr,
            width: 140,
            onTap: () {
              MessageInterfaceConsumer.openSingleChat(email, context);
            })
      ],
    );
  }
}
