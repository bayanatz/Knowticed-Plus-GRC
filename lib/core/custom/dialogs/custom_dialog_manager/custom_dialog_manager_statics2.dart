/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dialog_manager_statics2.dart
/// Description: `_CustomDialogManagerStatics2` — split out of `57-custom_dialog_manager.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_dialog_manager.dart';

// Split from 57-custom_dialog_manager.dart to keep every file under 700 lines.

abstract final class _CustomDialogManagerStatics2 {
  static Future<void> showExport({
    required BuildContext context,
    required Future<void> Function(String fileName) onDownload,
    String? initialFileName,
    // ADDED 13/10/2026 (Time Tracker owner): the dialog's width, as given
    // (like `showContent`), so Export matches the module's Filter dialog.
    // Null keeps 300 (phone) / 500.
    double? width,
  }) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final TextEditingController fileNameController = TextEditingController(
      text: initialFileName ?? '',
    );

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: isLight ? AppColors.white : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: SizedBox(
              // EDIT 29/8/2026: 300 was a phone width used on every form factor.
              // On desktop it left the File Name field a narrow slot in the
              // middle of a wide window while Discard and Download — 150 each —
              // nearly filled the row beneath it. 500 is what every other dialog
              // in this file uses (confirm, success, error, restore); the phone
              // keeps 300, where 500 would overflow the screen.
              width: width ?? (isMobile ? 300.sp : 500.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: circular badge + title
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath: AppAssets.export,
                            width: 15.w,
                            height: 15.h,
                            fit: BoxFit.contain,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        isArabic ? 'تصدير' : 'Export',
                        style: StyleText.fontSize20Weight500.copyWith(
                          color:
                              isLight ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // File name field (label above + placeholder inside)
                  CustomTextField(
                    controller: fileNameController,
                    label: isArabic ? 'اسم الملف' : 'File Name',
                    hint: isArabic ? 'اكتب هنا' : 'Text here',
                    fillColor: AppColors.background,
                  ),
                  SizedBox(height: 12.h),
                  // Actions
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: [
                      customButton(
                        title: isArabic ? 'إلغاء' : 'Discard',
                        function: () => Navigator.of(
                          dlgCtx,
                          rootNavigator: true,
                        ).maybePop(),
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.text,
                        ),
                        width: isMobile ? 100.sp : 120.sp,
                        height: 38.sp,
                        radius: 8.r,
                        color: AppColors.darkGrey,
                      ),
                      const Spacer(),
                      customButton(
                        title: isArabic ? 'تحميل' : 'Download',
                        function: () async {
                          final String name = fileNameController.text.trim();
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          await Future.delayed(
                            const Duration(milliseconds: 120),
                          );
                          await onDownload(name);
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 100.sp : 120.sp,
                        height: 38.sp,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
