/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: forms_submission_summary.dart
/// Purpose: Stub of the Home "Forms Submission" card data. The Form Builder
///          module is not part of the inventory app, so there is never a
///          published form; the card falls back to its empty state.
library;

import 'package:flutter/widgets.dart';

/// Minimal stand-in for the Form Builder's form entity.
class PublishedFormStub {
  String get getTitle => '';
}

class FormsSubmissionSummary {
  PublishedFormStub? form;

  int get submitted => 0;
  int get pending => 0;
  double get completion => 0;

  /// Always false: no Form Builder in this app.
  Future<bool> load(TickerProvider vsync) async => false;

  Future<int> remindAll() async => 0;

  void dispose() {}
}
