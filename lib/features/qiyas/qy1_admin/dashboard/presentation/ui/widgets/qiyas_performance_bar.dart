/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_performance_bar.dart
/// Purpose: Displays a performance bar representing the performance values of different departments,
///          with each department's performance divided into segments. The bar is displayed as a horizontal stack of color-coded segments.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: The widget displays a performance bar where each department's value is represented by color-coded segments,
///              with the total width of the bar reflecting the department's overall performance. The segment colors depend on the value of the department's performance.
///              The bar also shows the department's name and numeric value. It supports dynamic width calculations based on the screen size.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constants/dashboard_constants.dart';

class QiyasPerformanceBar extends StatelessWidget {
  final DepartmentPerformance dept;
  final int value;
  final double width;

  QiyasPerformanceBar(
      {super.key,
      required this.dept,
      required this.value,
      required this.width});
  // A copy per bar: sortValuesDescending reorders it for this bar only.
  final List<EvidenceSubmissionStatus> colorLegend = List.of(departmentStatus);

  @override
  Widget build(BuildContext context) {
    sortValuesDescending();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dept.name,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.secondaryBlack)),
              Text(
                dept.number.toString(),
                style: StyleText.fontSize12Weight500,
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Container(
            height: 20.sp,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 2.sp,
              children: List.generate(dept.values.length, (index) {
                final int value = dept.values[index];
                return Expanded(
                  flex: value,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.sp),
                    decoration: BoxDecoration(
                      color: colorLegend[index].color,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        value.toString(),
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: getContrastColor(colorLegend[index].color),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  void sortValuesDescending() {
    // every index of the colorLegend is crossponding to the index of the values in the dept.values
    // I want to sort the values in descending order and keep the colorLegend and number in sync with the values
    List<int> sortedValues = List.from(dept.values);
    sortedValues.sort((a, b) => b.compareTo(a));
    List<EvidenceSubmissionStatus> sortedColorLegend = [];
    for (int value in sortedValues) {
      int index = dept.values.indexOf(value);
      while (sortedColorLegend.contains(colorLegend[index])) {
        index++;
      }
      sortedColorLegend.add(colorLegend[index]);
    }

    // Update the dept.values and colorLegend with the sorted values
    dept.values = sortedValues;
    colorLegend
      ..clear()
      ..addAll(sortedColorLegend);

    // Update the number to be the sum of the sorted values
  }

  Color getContrastColor(Color barColor) {
    return barColor.computeLuminance() > 0.5
        ? AppColors.black
        : AppColors.white;
  }
}
