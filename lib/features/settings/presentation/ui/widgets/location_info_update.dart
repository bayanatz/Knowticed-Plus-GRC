import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/personal_info_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';

double spaceWidth = 0.03.w;

class LocationInfoUpdate extends StatefulWidget {
  LocationInfoUpdate({
    super.key,
  });

  @override
  State<LocationInfoUpdate> createState() => _LocationInfoUpdateState();
}

class _LocationInfoUpdateState extends State<LocationInfoUpdate> {
  @override
  void initState() {


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {},
                  (value) {},
                  'Enter Your Country'.tr,
                  capitalize('${employee!.country?.lastOrNull}'),
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {
                 //   country2 = value.toLowerCase();
                  },
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Country"
                            : "عنوان الدولة غير صحيح");
                  },
                  'Enter Your Country'.tr,
                  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {},
                  (value) {},
                  'Enter Your City'.tr,
                  capitalize('${employee!.city?.lastOrNull}'),
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {
                   // city2 = value.toLowerCase();
                  },
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid City"
                            : "عنوان المدينه غير صحيح");
                  },
                  'Enter Your City'.tr,
                  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {},
                  (value) {},
                  'Enter Your State Or Province'.tr,
                  capitalize('${employee!.province?.lastOrNull}'),
                  null,
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) async {
                 //   province2 = value.toLowerCase();
                  },
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Province"
                            : "عنوان الحي غير صحيح");
                  },
                  'Enter Your State Or Province'.tr,
                  null,
                  null,
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: textfieled(
                context,
                (value) async {},
                (value) {},
                'Enter Your Street Address'.tr,
                capitalize('${employee!.street?.lastOrNull}'),
                null,
                controller: null,
                isReadOnly: true,
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: textfieled(
                isRequestDialog: true,
                context,
                (value) async {
               //   address2 = value.toLowerCase();
                },
                (value) {
                  return Validator.text(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Street Address"
                          : "عنوان الشارع غير صحيح");
                },
                'Enter Your Street Address'.tr,
                null,
                null, // prefixIcon
                controller: null,
                isReadOnly: false,
              ),
            )
          ],
        )
      ],
    );
  }
}
