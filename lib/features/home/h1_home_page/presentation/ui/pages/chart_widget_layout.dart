import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/24-custom_chart_card.dart';
import 'package:grc_module/core/custom/26-custom_bar_chart_card.dart';
import 'package:grc_module/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
class HomeLayoutChartWidget extends StatefulWidget {
  final VoidCallback? onChartSettingsChanged;

  const HomeLayoutChartWidget({
    super.key,
    this.onChartSettingsChanged,
  });

  @override
  State<HomeLayoutChartWidget> createState() => _HomeLayoutChartWidgetState();
}

class _HomeLayoutChartWidgetState extends State<HomeLayoutChartWidget> {

  EmployeeEntityPro get employeeFunctionHelper {
    final controller = Get.find<MainCoreEmployeeController>();
    if (controller.employeeEntity == null) {
      throw Exception('EmployeeEntity is not initialized yet');
    }
    return controller.employeeEntity!;
  }

  // ── Arabic number converter ────────────────────────────
  String _formatNumber(int number, bool isArabic) {
    if (!isArabic) return number.toString();
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // ── Convert labels to Arabic if needed ────────────────
  List<String> _formatLabels(List<String> labels, bool isArabic) {
    if (!isArabic) return labels;
    const english = ['0','1','2','3','4','5','6','7','8','9',
      'S','s','A','a','B','b','C','c','D','d'];
    const arabic  = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩',
      'س','س','أ','أ','ب','ب','ج','ج','د','د'];
    return labels.map((label) {
      String result = label;
      for (int i = 0; i < english.length; i++) {
        result = result.replaceAll(english[i], arabic[i]);
      }
      return result;
    }).toList();
  }


  /// Default orientation per chart id.
  ///
  /// Replaces the removed ChartRegistry + per-user ChartSettingsFirebaseService:
  /// charts now render with a fixed default using the core cards
  /// (BarChartCard / HorizontalBarChartCard).
  ChartOrientation _getChartOrientation(String chartId) {
    switch (chartId) {
      case 'services_offered':
        return ChartOrientation.horizontal;
      case 'number_of_services':
      default:
        return ChartOrientation.vertical;
    }
  }



  Widget _buildChart({
    required String chartId,
    required List<String> labels,
    required List<double> values,
    required String title,
    required bool isArabic,
  }) {
    const double chartWidth = 265;
    const double chartHeight = 200;

    final orientation = _getChartOrientation(chartId);
    // ── Format labels for Arabic display ──────────────
    final formattedLabels = _formatLabels(labels, isArabic);

    final bars = <ChartData>[
      for (int i = 0; i < formattedLabels.length; i++)
        ChartData(label: formattedLabels[i], value: values[i]),
    ];

    return orientation == ChartOrientation.horizontal
        ? HorizontalBarChartCard(
            title: title,
            bars: bars,
            width: chartWidth.w,
            barHeight: 10,
          )
        : BarChartCard(
            title: title,
            bars: bars,
            width: chartWidth.w,
            chartHeight: chartHeight.h,
            barWidth: 20,
          );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic  = Localizations.localeOf(context).languageCode == 'ar';
    final l         = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Chart 1: Services Offered ──────────────────────
              Stack(
                alignment: Alignment.topRight,
                children: [
                  _buildChart(
                    chartId: 'services_offered',
                    labels: const ['S1', 'S2', 'S3', 'S4'], // converted internally
                    values: const [10, 20, 30, 40],          // always doubles ✅
                    title: l.servicesOffered,
                    isArabic: isArabic,
                  ),
                ],
              ),

              SizedBox(width: 20.sp),

              // ── Chart 2: Number of Services ────────────────────
              Stack(
                alignment: Alignment.topRight,
                children: [
                  _buildChart(
                    chartId: 'number_of_services',
                    labels: const ['S1', 'S2', 'S3', 'S4'], // converted internally
                    values: const [100, 120, 104, 125],      // always doubles ✅
                    title: l.numberOfServices,
                    isArabic: isArabic,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}