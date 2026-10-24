/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: form_chart_data.dart
/// Description: `FormChartData`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

class FormChartData {
  final String text;
  final double values;

  const FormChartData(this.text, this.values);

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given fields changed.
  ///
  /// Returns: the new object.
  FormChartData copyWith({
    String? text,
    double? values,
  }) {
    return FormChartData(
      text ?? this.text,
      values ?? this.values,
    );
  }
}
