import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/settings_controller.dart';
import '../../../controller/social_controller.dart';

class Certificates extends StatelessWidget {
  Certificates({super.key});
  SocialController socialController =
      Get.find<SettingsController>().socialController;
  SettingsController settingsController = Get.find<SettingsController>();
  bool isTablet = MediaQuery.of(Get.context!).size.shortestSide > 600;
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return /*Container(
      decoration: !isTablet
          ? BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary)
          : null,
      padding: EdgeInsets.symmetric(
          horizontal: !isTablet ? 0.04.w : 0, vertical: !isTablet ? 0.02.h : 0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.02.h),
            child: SettingsHeader(
              imagePath: 'assets/icons_assets/main_icons_assets/certificates.svg',
              text: 'Certificates'.tr,
            ),
          ),
          for (var fieldSet
              in socialController.certificateFields.asMap().entries) ...[
            SizedBox(
              width: isPortrait ? double.infinity : 0.23.w,
              child: Padding(
                padding: EdgeInsets.only(
                    right: Get.locale.toString().contains('en')
                        ? isPortrait
                            ? 0
                            : 0.02.h
                        : 0,
                    left: Get.locale.toString().contains('ar')
                        ? isPortrait
                            ? 0
                            : 0.02.h
                        : 0),
                child: CustomIconContainer(
                  text: 'Certificate'.tr,
                  image: settingsController
                              .employee!.certificate!.certificateFile!.length <=
                          fieldSet.key
                      ? null
                      : FilePathFunctions.isImage(settingsController.employee!
                              .certificate!.certificateFile![fieldSet.key]!)
                          ? settingsController.employee!.certificate!
                              .certificateFile![fieldSet.key]
                          : null,
                  onPressed: () async {
                    try {
                      var link = Uri.parse(settingsController.employee!
                          .certificate!.certificateFile![fieldSet.key]!);
                      FilePathFunctions.isImage(settingsController.employee!
                              .certificate!.certificateFile![fieldSet.key]!)
                          ? showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RequestExcalateDialog(
                                  isSetting: true,
                                  title: "",
                                  imageUrl: settingsController
                                      .employee!
                                      .certificate!
                                      .certificateFile![fieldSet.key]!,
                                  isExclate: false,
                                  isToShowImage: true,
                                );
                              },
                            )
                          : await launchUrl(link,
                              mode: LaunchMode.externalApplication);
                    } catch (e) {
                      *//*         pickAndUploadFile(
                          '${employee!.firstName!.firstNames!.last!}${employee!.lastName!.lastNames!.last!}',
                          fieldSet.key);*//*
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 0.01.h),
            settingsController.employee!.certificate!.certificateName!.length <=
                    fieldSet.key
                ? textfieled(
                    isReadOnly: false,
                    context,
                    (value) {
                      try {
                        socialController.certificateNames[fieldSet.key] = value;
                      } catch (e) {
                        socialController.certificateNames
                            .add(value.trim().toLowerCase());
                      }
                      print(
                          ' socialController.certificateNames=${socialController.certificateNames}');
                    },
                    (value) {
                      return Validator.name(value, "Invalid Name".tr);
                    },
                    'Name of Certificate'.tr,
                    settingsController
                                .employee!.certificate!.certificateName!.length <=
                            fieldSet.key
                        ? ""
                        : settingsController.employee!.certificate
                            ?.certificateName?[fieldSet.key],
                    null,
                  )
                : settingsController.employee!.certificate!
                            .certificateNameStatus?[fieldSet.key] ==
                        'removed'
                    ? SizedBox()
                    : textfieled(
                        isReadOnly: false,
                        context,
                        (value) {
                          try {
                            socialController.certificateNames[fieldSet.key] =
                                value;
                          } catch (e) {
                            socialController.certificateNames
                                .add(value.trim().toLowerCase());
                          }
                          print(
                              ' socialController.certificateNames=${socialController.certificateNames}');
                        },
                        (value) {
                          return Validator.name(value, "Invalid Name".tr);
                        },
                        'Name of Certificate'.tr,
                        settingsController.employee!.certificate!.certificateName!
                                    .length <=
                                fieldSet.key
                            ? ""
                            : settingsController.employee!.certificate
                                ?.certificateName?[fieldSet.key],
                        null,
                      ),
            settingsController.employee!.certificate!.issuedBy!.length <=
                    fieldSet.key
                ? textfieled(
                    isReadOnly: false,
                    context,
                    (value) {
                      try {
                        socialController.issuedBys[fieldSet.key] = value;
                      } catch (e) {
                        socialController.issuedBys
                            .add(value.trim().toLowerCase());
                      }
                      print(
                          ' socialController.issuedBys=${socialController.issuedBys}');
                    },
                    (value) {
                      return Validator.name(value, "Invalid Name".tr);
                    },
                    'Issuing Authority'.tr,
                    settingsController.employee!.certificate!.issuedBy!.length <=
                            fieldSet.key
                        ? ""
                        : settingsController
                            .employee!.certificate?.issuedBy?[fieldSet.key],
                    null,
                  )
                : settingsController.employee!.certificate!
                            .issuedByStatus?[fieldSet.key] ==
                        'removed'
                    ? SizedBox()
                    : textfieled(
                        isReadOnly: false,
                        context,
                        (value) {
                          try {
                            socialController.issuedBys[fieldSet.key] = value;
                          } catch (e) {
                            socialController.issuedBys
                                .add(value.trim().toLowerCase());
                          }
                          print(
                              ' socialController.issuedBys=${socialController.issuedBys}');
                        },
                        (value) {
                          return Validator.name(value, "Invalid Name".tr);
                        },
                        'Issuing Authority'.tr,
                        settingsController
                                    .employee!.certificate!.issuedBy!.length <=
                                fieldSet.key
                            ? ""
                            : settingsController
                                .employee!.certificate?.issuedBy?[fieldSet.key],
                        null,
                      ),
            settingsController.employee!.certificate!.yearOfIssue!.length <=
                    fieldSet.key
                ? textfieled(
                    isReadOnly: false,
                    context,
                    (value) {
                      try {
                        socialController.yearOfIssues[fieldSet.key] = value;
                      } catch (e) {
                        socialController.yearOfIssues
                            .add(value.trim().toLowerCase());
                      }
                      print('yearOfIssues=${socialController.yearOfIssues}');
                    },
                    (value) {
                      return Validator.insurancePolicyNumber(
                          value, "Invalid Number".tr);
                    },
                    'Year of Certification'.tr,
                    settingsController
                                .employee!.certificate!.yearOfIssue!.length <=
                            fieldSet.key
                        ? ""
                        : settingsController
                            .employee!.certificate?.yearOfIssue?[fieldSet.key],
                    null,
                  )
                : settingsController.employee!.certificate!
                            .yearOfIssueStatus?[fieldSet.key] ==
                        'removed'
                    ? SizedBox()
                    : textfieled(
                        isReadOnly: false,
                        context,
                        (value) {
                          try {
                            socialController.yearOfIssues[fieldSet.key] = value;
                          } catch (e) {
                            socialController.yearOfIssues
                                .add(value.trim().toLowerCase());
                          }
                          print('yearOfIssues=${socialController.yearOfIssues}');
                        },
                        (value) {
                          return Validator.insurancePolicyNumber(
                              value, "Invalid Number".tr);
                        },
                        'Year of Certification'.tr,
                        settingsController
                                    .employee!.certificate!.yearOfIssue!.length <=
                                fieldSet.key
                            ? ""
                            : settingsController.employee!.certificate
                                ?.yearOfIssue?[fieldSet.key],
                        null,
                      ),
            fieldSet.key != 0
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.02.h),
                    child: Container(
                      height: 0.8,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  )
                : SizedBox.shrink(),
            socialController.certificateFields.length < 2
                ? Padding(
                    padding: EdgeInsets.only(top: 0.02.h),
                    child: CustomBlackButton(
                      buttonText: 'Add More'.tr,
                      onPressed: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact);
                        // Create new controllers for a new set of certificate fields
                        socialController.certificateFields.add({
                          'nameOfCertificate': TextEditingController(),
                          'issueBy': TextEditingController(),
                          'issueDate': TextEditingController(),
                        });

                        // Print the current value of each controller and its number
                        for (int i = 0;
                            i < socialController.certificateFields.length;
                            i++) {
                          for (var entry
                              in socialController.certificateFields[i].entries) {
                            print(
                                'Field ${i + 1} - ${entry.key}: ${entry.value.text}');
                          }
                        }
                        settingsController.update();
                      },
                    ),
                  )
                : SizedBox(),
          ],
        ],
      ),
    );*/Container();
  }
}
