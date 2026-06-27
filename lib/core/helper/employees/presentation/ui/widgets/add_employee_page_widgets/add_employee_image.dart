import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';

import 'package:demo_app/core/helper/employees/presentation/controller/add_new_employee_controller.dart';

class AddEmployeeImage extends StatelessWidget {
  AddEmployeeImage({super.key});
  final AddNewEmployeeController addNewEmployeeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.01.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          addNewEmployeeController.imageUrl == null
              ? CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      const AssetImage("assets/images/male_avatar.png"),
                  radius: 0.06.h,
                )
              : CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      NetworkImage(addNewEmployeeController.imageUrl!),
                  radius: 0.06.h,
                ),
          Padding(
            padding: EdgeInsets.only(
                left: Get.locale.toString().contains('en') ? 0.02.w : 0,
                right: Get.locale.toString().contains('en') ? 0 : 0.02.w),
            child: MainCustomIconButton(
              onPressed: () async {
                await addNewEmployeeController.uploadImage(
                    "${addNewEmployeeController.firstName.text}_${addNewEmployeeController.lastName.text}");
              },
              buttonText: "Add Photo".tr,
            
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: Size(0.11.w, 0.06.h),
                backgroundColor:
                    Theme.of(context).colorScheme.onTertiaryContainer,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(8),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
