import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_orientation_enum.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_registry.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_setting_firebase_service.dart';

/// Dialog for selecting and changing chart orientation
class ChartSettingsDialog extends StatefulWidget {
  final String userEmail;
  final VoidCallback? onSettingsChanged;

  const ChartSettingsDialog({
    Key? key,
    required this.userEmail,
    this.onSettingsChanged,
  }) : super(key: key);

  /// Show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String userEmail,
    VoidCallback? onSettingsChanged,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ChartSettingsDialog(
        userEmail: userEmail,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }

  @override
  State<ChartSettingsDialog> createState() => _ChartSettingsDialogState();
}

class _ChartSettingsDialogState extends State<ChartSettingsDialog> {
  final ChartSettingsFirebaseService _firebaseService =
  ChartSettingsFirebaseService();

  String? _selectedChartId;
  ChartOrientation? _selectedOrientation;
  bool _isLoading = false;
  bool _isSaving = false;

  // Dropdown items lists
  final List<Map<String, String>> _moduleItems = [
    {'key': 'services', 'value': 'Services'}, // Will be localized in UI
  ];

  List<Map<String, String>> _chartItems = [];

  @override
  void initState() {
    super.initState();
    _initializeChartItems();
    _loadInitialData();
  }

  void _initializeChartItems() {
    // Build chart items from registry
    _chartItems = ChartRegistry.servicesCharts.map((chart) {
      return {
        'key': chart.id,
        'value': chart.nameEnglish, // Will display localized name in dropdown
      };
    }).toList();
  }

  Future<void> _loadInitialData() async {
    // Load first chart by default
    if (ChartRegistry.servicesCharts.isNotEmpty) {
      final firstChart = ChartRegistry.servicesCharts.first;
      setState(() {
        _selectedChartId = firstChart.id;
      });
      await _loadChartOrientation(firstChart.id);
    }
  }

  Future<void> _loadChartOrientation(String chartId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orientation = await _firebaseService.getChartOrientation(
        email: widget.userEmail,
        module: 'services',
        chartId: chartId,
      );

      // If no saved orientation, use default from registry
      final defaultOrientation = ChartRegistry.getServicesChartById(chartId)
          ?.defaultOrientation ??
          ChartOrientation.vertical;

      setState(() {
        _selectedOrientation = orientation ?? defaultOrientation;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chart orientation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrientation() async {
    if (_selectedChartId == null || _selectedOrientation == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firebaseService.saveChartOrientation(
        email: widget.userEmail,
        module: 'services',
        chartId: _selectedChartId!,
        orientation: _selectedOrientation!,
      );

      if (mounted) {
        // Call callback to refresh charts
        widget.onSettingsChanged?.call();

        // Close dialog with success result
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Silently handle error and close dialog
        Navigator.of(context).pop(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getLocalizedChartName(String chartId) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final chart = ChartRegistry.getServicesChartById(chartId);
    if (chart == null) return chartId;
    return isArabic ? chart.nameArabic : chart.nameEnglish;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    // Update chart items with localized names
    final localizedChartItems = ChartRegistry.servicesCharts.map((chart) {
      return {
        'key': chart.id,
        'value': isArabic ? chart.nameArabic : chart.nameEnglish,
      };
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.w : 40.w,
        vertical: isMobile ? 24.h : 40.h,
      ),
      child: Container(
        width: isMobile ? double.infinity : 580.w,
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 580.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(32.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvg(
                      assetPath: "assets/icons_assets/home_assets/chart_settings.svg",
                      width: 18.sp,
                      height: 18.sp,
                      fit: BoxFit.scaleDown,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  isArabic ? 'إعدادات الرسم البياني' : 'Chart Settings',
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),

            SizedBox(height: 28.h),

            // Two Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Module
                Expanded(
                  child: CustomDropdownFormFieldAmr(
                    selectedValue: 'services',
                    items: [
                      {
                        'key': 'services',
                        'value': isArabic ? 'الخدمات' : 'Services'
                      },
                    ],
                    onChanged: (value) {
                      // Module is fixed to services for now
                    },
                    widthIcon: 14,
                    heightIcon: 14,
                    label: isArabic ? 'الوحدة' : 'Module',
                    height: 40,
                    spaceHeight: 8,
                    dropdownColor: lightMode
                        ? Color(0xFFF5F5F5)
                        : AppColors.background.withOpacity(0.5),
                  ),
                ),

                SizedBox(width: 20.w),

                // Right Column - Values (Chart Selection)
                Expanded(
                  child: CustomDropdownFormFieldAmr(
                    selectedValue: _selectedChartId,
                    items: localizedChartItems,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedChartId = value;
                        });
                        _loadChartOrientation(value);
                      }
                    },
                    widthIcon: 14,
                    heightIcon: 14,
                    label: isArabic ? 'القيم' : 'Values',
                    height: 40,
                    spaceHeight: 8,
                    hint: Text(
                      isArabic ? 'اختر الرسم البياني' : 'Select Chart',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    dropdownColor: lightMode
                        ? Color(0xFFF5F5F5)
                        : AppColors.background.withOpacity(0.5),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Preview Section
            Text(
              isArabic ? 'معاينة' : 'Preview',
              style: StyleText.fontSize14Weight500.copyWith(
                color:AppColors.text,
              ),
            ),

            SizedBox(height: 12.h),

            // Preview Area with Loading or Orientation Options
            Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: lightMode
                    ? Color(0xFFFAFAFA)
                    : AppColors.background.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: lightMode
                      ? Color(0xFFE0E0E0)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : Padding(
                padding: EdgeInsets.all(16.sp),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOrientationOption(
                        orientation: ChartOrientation.horizontal,
                        label: isArabic ? 'أفقي' : 'Horizontal',
                        icon: Icons.horizontal_distribute,
                        isSelected: _selectedOrientation ==
                            ChartOrientation.horizontal,
                        lightMode: lightMode,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildOrientationOption(
                        orientation: ChartOrientation.vertical,
                        label: isArabic ? 'عمودي' : 'Vertical',
                        icon: Icons.vertical_distribute,
                        isSelected: _selectedOrientation ==
                            ChartOrientation.vertical,
                        lightMode: lightMode,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Action Buttons
            Row(
              children: [
                // Discard Button
                customButton(
                  title: isArabic ? 'تجاهل' : 'Discard',
                  function: _isSaving
                      ? () {}
                      : () => Navigator.of(context).pop(false),
                  width: 130.w,
                  height: 44.h,
                  radius: 8.r,
                  color: lightMode ? Color(0xFFE0E0E0) : Colors.grey.shade700,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode ? Colors.black87 : Colors.white,
                  ),
                ),
                Spacer(),

                // Save Button
                customButton(
                  title: isArabic ? 'حفظ' : 'Save',
                  function: _isSaving ? () {} : _saveOrientation,
                  width: 130.w,
                  height: 44.h,
                  radius: 8.r,
                  color: _isSaving
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.primary,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationOption({
    required ChartOrientation orientation,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool lightMode,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrientation = orientation;
        });
      },
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : (AppColors.background),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (lightMode
                ? Color(0xFFE0E0E0)
                : Colors.grey.withOpacity(0.3)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isSelected
                  ? AppColors.primary
                  : (lightMode
                  ? Colors.grey.shade500
                  : AppColors.white.withOpacity(0.5)),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: StyleText.fontSize14Weight400.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (lightMode
                    ? Colors.grey.shade700
                    : AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Button Widget
Widget customButton({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  TextStyle? textStyle,
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height ?? 38.h,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          title,
          style: textStyle ??
              StyleText.fontSize14Weight500.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    ),
  );
}