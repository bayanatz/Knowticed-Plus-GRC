import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
class RoundedImageTextContainer extends StatelessWidget {
  final String imagePath;
  final String text;
  final bool showPlusIcon;

  final Widget? plusIcon;
  final Color? imageIcon;

  RoundedImageTextContainer({
    required this.imagePath,
    required this.text,
    this.showPlusIcon = false,
    this.plusIcon,
    this.imageIcon,
  });

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.sp : 10.sp),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: isTablet ? (orientation ? 90.w : 70.w) : 70.w,
                height: isTablet ? (orientation ? 90.w : 70.w) : 70.w,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  // color: AppColors.colorWhite,
                  border:
                      Border.all(color:AppColors.primary, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: showPlusIcon
                    ? Row(
                        mainAxisSize:
                            orientation ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: Get.locale.toString().contains('en')
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: orientation ? 0 : 40.w),
                            child: Container(
                              child: SvgPicture.asset(
                                imagePath,
                                height:(isTablet ? 70.h : 55.h),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: text == "Create Tasks"
                                ? isTablet
                                    ? 0
                                    : 0
                                : 1.w),
                        child: SvgPicture.asset(
                          imagePath,
                          color: imageIcon,
                          height: AppDrawerCubit.isOwner == true ? 60.h : 80.h,
                        ),
                      ),
              ),
              if (plusIcon != null)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: plusIcon!,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: isTablet
                    ? AppTextStyles.font12BlackCairoRegular
                    : AppTextStyles.font12BlackCairoRegular

            ),
          ),
        ],
      ),
    );
  }
}
