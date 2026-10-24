/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_chart_live.dart
/// Purpose: Declares `HomeChartLive` — the REAL figures of the modules whose
///          counters are wired to Chart & Graph cards. A module that is wired
///          publishes its figures here; [HomeChartCatalog] hands them out in
///          place of the sample numbers, and a card listening to this store
///          redraws when they change.
/// Author: Knowticed Plus team
/// Created at: 24/10/2026
library;

import 'package:flutter/foundation.dart';

/// One bar / slice of a live value whose parts are not known in advance
/// (departments, request types): the module publishes the labels as well.
class HomeChartLiveSeries {
  const HomeChartLiveSeries(this.en, this.ar, this.value);

  final String en;
  final String ar;
  final double value;
}

class HomeChartLive extends ChangeNotifier {
  HomeChartLive._();

  static final HomeChartLive instance = HomeChartLive._();

  final Map<String, List<double>> _figures = <String, List<double>>{};

  static String _id(String moduleKey, String valueKey) =>
      '$moduleKey/$valueKey';

  /// The live figures of [valueKey] of [moduleKey], one per series, in the
  /// catalog's order; null while the module has not published any (the card
  /// then shows the sample).
  List<double>? figures(String moduleKey, String valueKey) =>
      _figures[_id(moduleKey, valueKey)];

  final Map<String, List<HomeChartLiveSeries>> _series =
      <String, List<HomeChartLiveSeries>>{};

  /// The live, labelled parts of [valueKey] of [moduleKey], or null while
  /// none were published. They replace the catalog's series entirely.
  List<HomeChartLiveSeries>? labelled(String moduleKey, String valueKey) =>
      _series[_id(moduleKey, valueKey)];

  /// Publish a value whose parts the module decides (an empty list is
  /// allowed: the chart then has nothing to draw, which is the truth).
  void publishLabelled(
      String moduleKey, String valueKey, List<HomeChartLiveSeries> series) {
    _series[_id(moduleKey, valueKey)] = series;
    notifyListeners();
  }

  /// Replace the figures of one module (every value it publishes at once).
  void publish(String moduleKey, Map<String, List<double>> byValue) {
    byValue.forEach((String valueKey, List<double> figures) {
      _figures[_id(moduleKey, valueKey)] = figures;
    });
    notifyListeners();
  }

  /// Forget everything (sign-out), so the next account never sees these.
  void clear() {
    _figures.clear();
    _series.clear();
    notifyListeners();
  }
}
