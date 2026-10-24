/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_custom_home_table.dart
/// Purpose: Displays a custom data table in the home screen for the Qiyas module,
///          showing details about visions such as name, topic, criterion, goal, etc.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget creates a custom table layout where each row displays information
///              about a vision, and each column represents a different attribute of the vision
///              (e.g., name, goal, requirements). The table supports horizontal scrolling and adapts
///              to both portrait and landscape orientations. The appearance changes based on the theme.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/uploaded_data_formatter.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/utils/headers_enum.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class QiyasCustomHomeTable extends StatelessWidget {
  const QiyasCustomHomeTable({super.key, required this.columnNames});
  final List<String> columnNames;

  @override
  Widget build(BuildContext context) {
    final QiyasHomeCubit mainController = context.read<QiyasHomeCubit>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: AnimatedSizeWrap(
            child: Table(
          border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp)),
          columnWidths: {
            // Adjust according to your width logic
            0: FixedColumnWidth(50.sp),
            1: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.visionName, context)),
            2: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.topicName, context)),
            3: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.criterionName, context)),
            4: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.goals, context)),
            5: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.appRequirements, context)),
            6: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.evidence, context)),
            7: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.orders, context)),
            8: FixedColumnWidth(mainController.calculateWidthOfColum(
                HeadersEnum.scope, context)),
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.black87),
              children: columnNames.map((name) {
                debugPrint("Column Name: $name");
                return Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Text(name,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white)),
                );
              }).toList(),
            ),
            // Data rows
            ...List.generate(mainController.filteredVisionsList.length,
                (index) {
              final vision = mainController.filteredVisionsList[index];
              final isEven = index.isEven;
              final rowColor = Theme.of(context).brightness == Brightness.light
                  ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                  : (isEven ? const Color(0xFF1E1F24) : Colors.black45);

              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: [
                  tableCell(ArabicDigits('${index + 1}').toArabicNumbers()),
                  tableCell(vision.visionName.toString()),
                  tableCell(vision.topicName.toString()),
                  tableCell(vision.criterionName.toString()),
                  tableCell(vision.goal.toString(), isDescription: true),
                  tableCell(
                      UploadedDataFormatter.formatCustomText(
                          vision.requirements.toString()),
                      isDescription: true),
                  tableCell(
                      UploadedDataFormatter.formatCustomText(
                          vision.documents.toString()),
                      isDescription: true),
                  tableCell(
                      UploadedDataFormatter.formatCustomText(
                          vision.orders.toString()),
                      isDescription: true),
                  tableCell(vision.scope.toString()),
                ],
              );
            }),
          ],
        )),
      ),
    );
  }
}

Widget tableCell(String text, {bool isDescription = false}) {
  return Padding(
    padding: EdgeInsets.all(10.sp),
    child: Text(
      text.tr,
      style: StyleText.fontSize14Weight500.copyWith(height: 1.4),
      softWrap: true,
    ),
  );
}
