/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_entity.dart
/// Description: `AnalyticsEntity` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_text_field_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';

/// The analytics of one field: its chart data and/or the answers.
class AnalyticsEntity {
  FormFieldType type;
  String title;
  bool? isAggregated;
  List<AnalyticsTextFieldEntity>? data;
  List<FormChartData>? chartData;

  AnalyticsEntity(
      {required this.title, required this.type, this.data, this.chartData});

  /// Method Name: [getTotalChartSubmissions]
  ///
  /// Returns: the sum of all chart values (how many answers the chart counts).
  int get getTotalChartSubmissions {
    int total = 0;
    if (chartData != null) {
      for (var chart in chartData!) {
        total += chart.values.toInt();
      }
    }
    return total;
  }
}
