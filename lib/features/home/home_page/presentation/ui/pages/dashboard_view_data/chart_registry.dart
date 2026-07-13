import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_config_model.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_orientation_enum.dart';

/// Registry of all available charts per module
class ChartRegistry {
  /// All charts available in Services module
  static final List<ChartConfig> servicesCharts = [
    ChartConfig(
      id: 'services_offered',
      nameEnglish: 'Services Offered',
      nameArabic: 'الخدمات المقدمة',
      defaultOrientation: ChartOrientation.horizontal,
    ),
    ChartConfig(
      id: 'number_of_services',
      nameEnglish: 'Number of Services',
      nameArabic: 'عدد الخدمات',
      defaultOrientation: ChartOrientation.vertical,
    ),
  ];

  /// Get chart config by ID from Services module
  static ChartConfig? getServicesChartById(String id) {
    try {
      return servicesCharts.firstWhere((chart) => chart.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all chart IDs for Services module
  static List<String> getServicesChartIds() {
    return servicesCharts.map((chart) => chart.id).toList();
  }

  /// Get chart name based on locale
  static String getChartName(String id, bool isArabic) {
    final chart = getServicesChartById(id);
    if (chart == null) return id;
    return isArabic ? chart.nameArabic : chart.nameEnglish;
  }
}