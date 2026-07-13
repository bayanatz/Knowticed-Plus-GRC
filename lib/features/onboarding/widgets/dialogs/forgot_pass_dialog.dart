// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/onboarding/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/onboarding/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/features/onboarding/core_widgets/main_widget/column_request_data.dart';

import 'package:demo_app/features/onboarding/helper/functions.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/custom/loading.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/constants/system_actions.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_settings_dialog.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/new_employee_model.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';

class ForgotPassDialog extends StatefulWidget {
  ForgotPassDialog({
    super.key,
  });

  @override
  State<ForgotPassDialog> createState() => _ForgotPassDialogState();
}

class _ForgotPassDialogState extends State<ForgotPassDialog> {
  ButtonStyle buttonStyle(Color buttonColor) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.3.w, 0.05.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }

  final HapticController hapticController = Get.put(HapticController());
  final SystemLogsController systemLogsController = Get.find<SystemLogsController>();
  String? email;
  EmployeeController addEmployeeController =
      Get.put(EmployeeController());
  NewEmployeeModelHistory? employee;
  final TextEditingController emailController = TextEditingController();

  String? emailError;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isVertical ? 0.22.w : 0.33.w) : 0.15.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 411,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Forgot Password".tr,
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppColors.text
                ),
              ),
              SizedBox(
                height: 15.sp,
              ),
              CustomTextField(
                label: S.of(context).email,
                hint: S.of(context).textHere,
                controller: emailController,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                onChanged: (value) {
                  setState(() {
                    email = value;
                    // Clear error when user starts typing
                    if (emailError != null) {
                      emailError = null;
                    }
                  });
                },
                fillColor: AppColors.background,
              ),

              SizedBox(height: 5.sp),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[

                  customButton(
                      title: "Submit Request".tr,
                      function:  () async {
                        if (await checkInternet()) {
                          showLoadingIndicator();
                          if (email != null) {
                            employee = await addEmployeeController
                                .getEmployee(email!);
                            if (employee != null &&
                                employee!.status!.last ==
                                    'request to reset password') {
                              hideLoadingIndicator();
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ResponseDialog(
                                      title: "Attention".tr,
                                      subtitle:
                                      'You Sent The Request To The System Administrator. Please Wait For The Administrator To Approve Your Request.'
                                          .tr,
                                      lottieAsset:
                                      "assets/images/newAttension.json",
                                    );
                                  });
                              // Navigator.of(context).pop();
                            } else if (employee != null) {
                              employee!.status!
                                  .add('request to reset password');
                              employee!.timestamps!
                                  .add(DateTime.now().millisecondsSinceEpoch);
                              await addEmployeeController.createEmployee(
                                employee!,
                                employee!.email!.last!,
                              );
                              systemLogsController.systemLogsAction(
                                  SystemActions.updateEmployee);
                              hideLoadingIndicator();
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const ResponseDialog(
                                    title: "Successful",
                                    subtitle:
                                    "The System Administrator Is Notified With Your Request And Should Reach Out To You Shortly.",
                                    lottieAsset: "assets/images/correct.json",
                                  );
                                },
                              );
                            } else {
                              hideLoadingIndicator();
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ResponseDialog(
                                      title: "Error".tr,
                                      subtitle: 'This Email Not Found'.tr,
                                      lottieAsset: "assets/images/error.json",
                                    );
                                  });
                            }
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ResponseDialog(
                                  title: "Error".tr,
                                  subtitle:
                                  "Please Check Your Internet Connection"
                                      .tr,
                                  lottieAsset: "assets/lottie_assets/main_lottie_assets/internet.json",
                                );
                              });
                        }
                      },
                      width: 150.w,
                      height: 38.h,
                      textStyle: StyleText.fontSize16Weight700.copyWith(
                        color: AppColors.textButton
                      ),
                      color: AppColors.primary,
                      radius: 8.r,


                  ),


                  // Expanded(
                  //   child: MainCustomIconButton(
                  //     buttonStyle: buttonStyle(AppColors.bubbleColor),
                  //     onPressed: () async {
                  //       if (await checkInternet()) {
                  //         showLoadingIndicator();
                  //         if (email != null) {
                  //           employee = await addEmployeeController
                  //               .getEmployee(email!);
                  //           if (employee != null &&
                  //               employee!.status!.status!.last ==
                  //                   'request to reset password') {
                  //             hideLoadingIndicator();
                  //             Navigator.of(context).pop();
                  //             showDialog(
                  //                 context: context,
                  //                 builder: (context) {
                  //                   return ResponseDialog(
                  //                     title: "Attention".tr,
                  //                     subtitle:
                  //                         'You Sent The Request To The System Administrator. Please Wait For The Administrator To Approve Your Request.'
                  //                             .tr,
                  //                     lottieAsset:
                  //                         "assets/images/newAttension.json",
                  //                   );
                  //                 });
                  //             // Navigator.of(context).pop();
                  //           } else if (employee != null) {
                  //             employee!.status!.status!
                  //                 .add('request to reset password');
                  //             employee!.status!.timestamps!
                  //                 .add(Timestamp.now());
                  //             await addEmployeeController.createEmployee(
                  //                 employee!,
                  //                 employee!.email!.emails!.last!,
                  //                 );
                  //             systemLogsController.systemLogsAction(
                  //                 SystemActions.updateEmployee);
                  //             hideLoadingIndicator();
                  //             Navigator.of(context).pop();
                  //             showDialog(
                  //               context: context,
                  //               builder: (BuildContext context) {
                  //                 return const ResponseDialog(
                  //                   title: "Successful",
                  //                   subtitle:
                  //                       "The System Administrator Is Notified With Your Request And Should Reach Out To You Shortly.",
                  //                   lottieAsset: "assets/images/correct.json",
                  //                 );
                  //               },
                  //             );
                  //           } else {
                  //             hideLoadingIndicator();
                  //             Navigator.of(context).pop();
                  //             showDialog(
                  //                 context: context,
                  //                 builder: (context) {
                  //                   return ResponseDialog(
                  //                     title: "Error".tr,
                  //                     subtitle: 'This Email Not Found'.tr,
                  //                     lottieAsset: "assets/images/error.json",
                  //                   );
                  //                 });
                  //           }
                  //         }
                  //       } else {
                  //         showDialog(
                  //             context: context,
                  //             builder: (context) {
                  //               return ResponseDialog(
                  //                 title: "Error".tr,
                  //                 subtitle:
                  //                     "Please Check Your Internet Connection"
                  //                         .tr,
                  //                 lottieAsset: "assets/lottie_assets/main_lottie_assets/internet.json",
                  //               );
                  //             });
                  //       }
                  //     },
                  //     buttonText: "Submit Request".tr,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
