import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';


import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/core/extension/context_extensions.dart';


//Youssef Ashraf , mohammed Ashraf
///Default Table Style for active_directory
class DefaultDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? columnSpacing;
  const DefaultDataTable(
      {super.key,
      required this.columns,
      required this.rows,
      this.columnSpacing});

  @override
  Widget build(BuildContext context) {
    var isLandScape = ContextExtension(context).isLandscape;
    bool isDarkMode =
        themeController.currentTheme.value == AppColors.darkTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r),
            topRight: Radius.circular(8.r),
          ),
          child: DataTable(
            border: TableBorder(
              horizontalInside: BorderSide(
                width: 0,
                color: isDarkMode ? AppColors.totalBlack : AppColors.white,
              ),
            ),
            // columnSpacing: 45.w, //columnSpacing,
            // AppColors.header is already 0xff2D2D2D in the light palette and
            // 0xFF171717 in the dark one, so it replaces the manual ternary.
            headingRowColor: WidgetStatePropertyAll(AppColors.header),
            dataRowMinHeight: 46.h,
            dataRowMaxHeight: 46.h,
            headingRowHeight: 46.h,
            horizontalMargin: isLandScape ? 29.w : 16.w,
            dividerThickness: 0,
            showCheckboxColumn: false,
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}
