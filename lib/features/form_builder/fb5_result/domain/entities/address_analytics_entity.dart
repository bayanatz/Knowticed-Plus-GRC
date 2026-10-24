/// Module: form_builder_module/f6_result
///
/// FILE INFO
/// File Name   : address_analytics_entity.dart
/// Description: `AddressAnalyticsEntity` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Domain entity holding address-analytics data. UI-free (§3) —
///               the Material table builders live in the presentation layer
///               (presentation/ui/widgets/address_analytics_table_builder.dart).
library;

import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';

/// The analytics of an Address field: one chart per part and a table.
class AddressAnalyticsEntity extends AnalyticsEntity {
  List<String>? addressItems;
  List<List<FormChartData>>? addressChartData;
  List<String>? headerItems;
  List<List<String>>? addressTableList;
  List<String>? images;

  AddressAnalyticsEntity({
    required super.title,
    required super.type,
  });
}
