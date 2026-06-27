part of '../pages/adding_new_role.dart';

class _RoleStatusChangeDialog extends StatelessWidget {
  final bool activating;

  const _RoleStatusChangeDialog({required this.activating});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 411.sp,
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/Edit Document.json',
              width: 70.w,
              height: 70.h,
              fit: BoxFit.scaleDown,
              repeat: true,
              animate: true,
            ),
            SizedBox(height: 20.sp),
            Text(
              S.of(context).changingStatus,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 18.sp),
            Text(
              activating
                  ? S.of(context).areYouSureYouWantToActivateThisRole
                  : S.of(context).areYouSureYouWantToDeactivateThisRole,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 15.sp),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 38.sp,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryText,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        S.of(context).no,
                        style: StyleText.fontSize16Weight500
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 28.sp),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 38.sp,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        S.of(context).yes,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
