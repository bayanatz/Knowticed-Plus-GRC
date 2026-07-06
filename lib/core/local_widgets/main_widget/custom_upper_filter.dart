import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';


// ignore: must_be_immutable
class UpperFilters extends StatefulWidget {
  UpperFilters({
    super.key,
    required this.selectedIndex,
    required this.selectedDepartmentState,
    required this.selectedIndexState,
    required this.filterTitles,
    this.isSettingsPage = false,
  });
  int selectedIndex;
  ValueChanged<String> selectedDepartmentState;
  ValueChanged<int> selectedIndexState;
  List<String> filterTitles;
  bool? isSettingsPage;

  @override
  State<UpperFilters> createState() => _UpperFiltersState();
}

class _UpperFiltersState extends State<UpperFilters> {
  AddDepartmentController addDepartmentController = Get.find();

  Widget filterItems(String title, int index) {
    bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        hapticController.triggerHapticFeedback(
            vibration: VibrateType.lightImpact,
            hapticFeedback: HapticFeedback.lightImpact);
        setState(() {
          widget.selectedIndex = index;
          widget.selectedDepartmentState(title);
          widget.selectedIndexState(index);
        });
      },
      child: IntrinsicWidth( // 👈 key fix
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // 👈 stretch to IntrinsicWidth
          children: [
            Text(
              title.tr,
              style: AppTextStyles.font23BlackRegularCairo.copyWith(
                color: isSelected ? AppColors.primary : AppColors.text,
              ),
            ),
            SizedBox(height: 3.h),
            if (isSelected)
              Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget upSpacer() {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return SizedBox(
      width: isTablet ? (orientation ? 0.04.w : 0.06.h) : 0.06.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.05.h,
      width: double.infinity,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Row(
            children: [
              filterItems(widget.filterTitles[index], index),
              if (index != widget.filterTitles.length - 1) upSpacer(),
            ],
          );
        },
        itemCount: widget.filterTitles.length,
      ),
    );
  }
}