import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/home/core_widgets/services_management/DashBoard_widget.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import '../../../../../generated/l10n.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
import 'dashboard_view_data/chart_setting_firebase_service.dart';
import 'dashboard_view_data/chart_settings_dialog.dart';
import 'dashboard_view_data/chart_orientation_enum.dart';
import 'dashboard_view_data/chart_registry.dart';

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
  final ChartSettingsFirebaseService _chartSettingsService =
  ChartSettingsFirebaseService();
  Map<String, ChartOrientation> _chartOrientations = {};
  bool _isLoadingChartSettings = true;

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

  @override
  void initState() {
    super.initState();
    _loadChartSettings();
  }

  Future<void> _loadChartSettings() async {
    try {
      final userEmail = employeeFunctionHelper.email;
      if (userEmail == null) {
        setState(() => _isLoadingChartSettings = false);
        return;
      }
      final orientations = await _chartSettingsService.getAllChartOrientations(
        email: userEmail,
        module: 'services',
      );
      if (mounted) {
        setState(() {
          _chartOrientations = orientations;
          _isLoadingChartSettings = false;
        });
      }
    } catch (e) {
      print('❌ Error loading chart settings: $e');
      if (mounted) setState(() => _isLoadingChartSettings = false);
    }
  }

  ChartOrientation _getChartOrientation(String chartId) {
    if (_chartOrientations.containsKey(chartId)) {
      return _chartOrientations[chartId]!;
    }
    return ChartRegistry.getServicesChartById(chartId)?.defaultOrientation ??
        ChartOrientation.vertical;
  }

  Future<void> _handleSettingsIconTap(String chartId) async {
    try {
      final userEmail = employeeFunctionHelper.email;
      if (userEmail == null) throw Exception('User email is not available');

      await ChartSettingsDialog.show(
        context: context,
        userEmail: userEmail,
        onSettingsChanged: () async {
          await _loadChartSettings();
          widget.onChartSettingsChanged?.call();
          if (mounted) setState(() {});
        },
      );
    } catch (e) {
      print('❌ Error opening settings dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chart settings'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildSettingsIcon(String chartId) {
    return Positioned(
      top: 4.sp,
      right: -4.sp,
      child: GestureDetector(
        onTap: () => _handleSettingsIconTap(chartId),
        child: Container(
          width: 25.w,
          height: 25.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffC4C4C4),
          ),
          child: Center(
            child: CustomSvg(
              assetPath: "assets/settings_icon.svg",
              width: 15.w,
              height: 15.h,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart({
    required String chartId,
    required List<String> labels,
    required List<double> values,
    required String title,
    required bool lightMode,
    required bool isArabic,
  })
  {
    const double chartWidth  = 265;
    const double chartHeight = 200;

    if (_isLoadingChartSettings) {
      return Container(
        width: chartWidth.w,
        height: chartHeight.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    final orientation  = _getChartOrientation(chartId);
    // ── Format labels for Arabic display ──────────────
    final formattedLabels = _formatLabels(labels, isArabic);

    print('📊 Building chart $chartId as ${orientation.name}');

    return SizedBox(
      width: chartWidth.w,
      height: chartHeight.h,
      child: orientation == ChartOrientation.horizontal
          ? CustomHorizontalBarChartWidget(
        width: chartWidth,
        height: chartHeight,
        title: title,
        labels: formattedLabels,
        values: values,
        barHeight: 10,
        lightMode: lightMode,
        // ✅ REMOVED isArabic — widget detects it internally
      )
          : CustomVerticalBarChartWidget(
        width: chartWidth,
        height: chartHeight,
        title: title,
        labels: formattedLabels,
        values: values,
        barWidth: 20,
        lightMode: lightMode,
        // ✅ REMOVED isArabic — widget detects it internally
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
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
                    lightMode: lightMode,
                    isArabic: isArabic,
                  ),
                  _buildSettingsIcon('services_offered'),
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
                    lightMode: lightMode,
                    isArabic: isArabic,
                  ),
                  _buildSettingsIcon('number_of_services'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}