/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: crm_control_dialogs_statics.dart
/// Description: `_CrmControlDialogsStatics` — split out of `crm_control_dialogs.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../crm_control_dialogs.dart';

// Split from crm_control_dialogs.dart to keep every file under 700 lines.

abstract final class _CrmControlDialogsStatics {
  static Future<void> showAddTemplateDialog({
    required BuildContext context,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) async {
    final TextEditingController nameEnController = TextEditingController();
    final TextEditingController nameArController = TextEditingController();

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String? nameEnError;
        String? nameArError;

        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final String enCurrent = nameEnController.text.trim();
              final String arCurrent = nameArController.text.trim();
              final bool canAdd = enCurrent.isNotEmpty &&
                  arCurrent.isNotEmpty &&
                  nameEnError == null &&
                  nameArError == null;

              return Container(
                constraints: BoxConstraints(maxWidth: 440.sp),
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmTemplate,
                          width: 24.sp,
                          height: 24.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Template',
                          style: StyleText.fontSize18Weight600.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Template Name',
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: nameEnController,
                      hint: 'Text Here',
                      errorText: nameEnError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          final dynamic res = Validator.isEnglish(text);
                          if (res is String) err = res;
                        }
                        setState(() => nameEnError = err);
                      },
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اسم القالب',
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: nameArController,
                      hint: 'اكتب هنا',
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.right,
                      errorText: nameArError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          err = Validator.isArabic(
                            text,
                            'الحقل مطلوب',
                            'يرجى إدخال النص باللغة العربية',
                          );
                        }
                        setState(() => nameArError = err);
                      },
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmDiscard,
                              function: () => Navigator.pop(ctx),
                              color: AppColors.darkGrey,
                              textStyle: StyleText.fontSize14Weight600.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmAdd,
                              function: canAdd
                                  ? () {
                                      final String enText =
                                          nameEnController.text.trim();
                                      final String arText =
                                          nameArController.text.trim();

                                      String? enErr;
                                      if (enText.isEmpty) {
                                        enErr = 'Field Required';
                                      } else {
                                        final dynamic res = Validator.isEnglish(
                                          enText,
                                        );
                                        if (res is String) enErr = res;
                                      }

                                      final String? arErr = Validator.isArabic(
                                        arText,
                                        'الحقل مطلوب',
                                        'يرجى إدخال النص باللغة العربية',
                                      );

                                      if (enErr != null || arErr != null) {
                                        setState(() {
                                          nameEnError = enErr;
                                          nameArError = arErr;
                                        });
                                      } else {
                                        Navigator.pop(ctx);
                                        onConfirm(enText, arText);
                                      }
                                    }
                                  : () {},
                              color: canAdd
                                  ? AppColors.primary
                                  : AppColors.disabledGrey,
                              textStyle: StyleText.fontSize14Weight600.copyWith(
                                color: canAdd
                                    ? AppColors.black
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameEnController.dispose();
    nameArController.dispose();
  }

  static Future<void> showEditTemplateDialog({
    required BuildContext context,
    required String nameEn,
    required String nameAr,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) async {
    final TextEditingController nameEnController = TextEditingController(
      text: nameEn,
    );
    final TextEditingController nameArController = TextEditingController(
      text: nameAr,
    );

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String? nameEnError;
        String? nameArError;
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final String enCurrent = nameEnController.text.trim();
              final String arCurrent = nameArController.text.trim();
              final bool hasChanged =
                  enCurrent != nameEn.trim() || arCurrent != nameAr.trim();
              final bool canSave = enCurrent.isNotEmpty &&
                  arCurrent.isNotEmpty &&
                  hasChanged &&
                  nameEnError == null &&
                  nameArError == null;

              return Container(
                constraints: BoxConstraints(maxWidth: 440.sp),
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmTemplate,
                          width: 28.sp,
                          height: 28.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.sp),
                        Text(
                          'Edit Template',
                          style: StyleText.fontSize18Weight600.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.sp),
                    Text(
                      'Template Name',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    CustomTextField(
                      controller: nameEnController,
                      hint: 'Text Here',
                      errorText: nameEnError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          final dynamic res = Validator.isEnglish(text);
                          if (res is String) err = res;
                        }
                        setState(() => nameEnError = err);
                      },
                    ),
                    SizedBox(height: 16.sp),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اسم القالب',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    CustomTextField(
                      controller: nameArController,
                      hint: 'اكتب هنا',
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.right,
                      errorText: nameArError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          err = Validator.isArabic(
                            text,
                            'الحقل مطلوب',
                            'يرجى إدخال النص باللغة العربية',
                          );
                        }
                        setState(() => nameArError = err);
                      },
                    ),
                    SizedBox(height: 28.sp),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmDiscard,
                              function: () => Navigator.pop(ctx),
                              color: AppColors.darkGrey,
                              textStyle: StyleText.fontSize14Weight600.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmSave,
                              function: canSave
                                  ? () {
                                      final String enText =
                                          nameEnController.text.trim();
                                      final String arText =
                                          nameArController.text.trim();
                                      String? enErr;
                                      if (enText.isEmpty) {
                                        enErr = 'Field Required';
                                      } else {
                                        final dynamic res = Validator.isEnglish(
                                          enText,
                                        );
                                        if (res is String) enErr = res;
                                      }

                                      final String? arErr = Validator.isArabic(
                                        arText,
                                        'الحقل مطلوب',
                                        'يرجى إدخال النص باللغة العربية',
                                      );

                                      if (enErr != null || arErr != null) {
                                        setState(() {
                                          nameEnError = enErr;
                                          nameArError = arErr;
                                        });
                                        return;
                                      }
                                      Navigator.pop(ctx);
                                      onConfirm(enText, arText);
                                    }
                                  : () {},
                              color: canSave
                                  ? AppColors.primary
                                  : AppColors.disabledGrey,
                              textStyle: StyleText.fontSize14Weight600.copyWith(
                                color: canSave
                                    ? AppColors.black
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameEnController.dispose();
    nameArController.dispose();
  }
}
