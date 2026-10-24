import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_values.dart';

void main() {
  test('line chart offers only values over time', () {
    for (final m in HomeChartCatalog.modulesFor(HomeComponents.lineChart)) {
      final list = HomeChartCatalog.valuesFor(m.name, HomeComponents.lineChart);
      expect(list, isNotEmpty);
      expect(list.every((v) => v.trend), isTrue, reason: m.name);
      expect(list.every((v) => v.series.length == 6), isTrue, reason: m.name);
    }
  });

  test('pie, donut and stacked offer only snapshots', () {
    for (final c in <HomeComponents>[
      HomeComponents.pieChart,
      HomeComponents.donutChart,
      HomeComponents.stackedBarChart,
      HomeComponents.radialBarChart,
    ]) {
      for (final m in HomeChartCatalog.modulesFor(c)) {
        final list = HomeChartCatalog.valuesFor(m.name, c);
        expect(list.any((v) => v.trend), isFalse, reason: '${c.name}/${m.name}');
      }
    }
  });

  test('every module with values has a trend value and a snapshot', () {
    for (final m in HomeChartCatalog.modules) {
      final all = HomeChartCatalog.valuesOf(m.name);
      expect(all.any((v) => v.trend), isTrue, reason: m.name);
      expect(all.any((v) => !v.trend), isTrue, reason: m.name);
    }
  });

  test('bar charts offer both kinds', () {
    final m = HomeChartCatalog.modules.first;
    expect(HomeChartCatalog.valuesFor(m.name, HomeComponents.barChart).length,
        HomeChartCatalog.valuesOf(m.name).length);
  });
}
