import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

// ignore: must_be_immutable
class AdditionInformationContainer extends StatelessWidget {
  AdditionInformationContainer({
    super.key,
    required this.title,
    required this.onPressed,
  });
  final String title;
  Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
        // border:
        //     Border.all(
        //       color: Theme.of(context).colorScheme.scrim, 
        //       width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.015.w, vertical: 0.012.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title.tr,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize016.w,
                  fontWeight: Get.locale.toString().contains('en')
                      ? FontWeight.w600
                      : FontWeight.w500,
                  height: 0.002.h,
                  color: Theme.of(context).colorScheme.inverseSurface),
            ),
            MainCustomIconButton(
              onPressed: onPressed,
              buttonText: "Upload".tr,
      
              widgetIcon: "assets/images/upload_pic.svg",
              buttonStyle: ElevatedButton.styleFrom(
                minimumSize: Size(0.088.w, 0.05.h),
                backgroundColor:
                    Theme.of(context).colorScheme.onTertiaryContainer,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(8),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
