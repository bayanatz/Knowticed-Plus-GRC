import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/settings/settings_screen/views/owner_screens/company_info_update_dialog/company_contact_info.dart';

// Globals previously declared in the removed company_contact_info.dart
TextEditingController email = TextEditingController();
TextEditingController contactEmail = TextEditingController();
TextEditingController contactPhone = TextEditingController();

class CompanyServiceUpdateContent extends StatefulWidget {
  const CompanyServiceUpdateContent({super.key});

  @override
  State<CompanyServiceUpdateContent> createState() =>
      _CompanyServiceUpdateContentState();
}

class _CompanyServiceUpdateContentState
    extends State<CompanyServiceUpdateContent> {
  CompanyController addCompanyController = Get.find();
  @override
  Widget build(BuildContext context) {
    double widthSpace = 0.02.w;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Company Industry'.tr, // hintText
                  addCompanyController.company!.companyIndustry!
                      .companyIndustry!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Company Industry'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: contactEmail,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.number(value);
                  },
                  'Company Size'.tr, // hintText
                  addCompanyController.company!.companySize!.companySize!.last!,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.number(value);
                  },
                  'Company Size'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: contactPhone,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Modules'.tr, // hintText
                  addCompanyController
                      .company!.modules!.modules!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Modules'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: contactEmail,
                  isReadOnly: false,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
