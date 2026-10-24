/// Module: knowledge_hub/kh7_dashboard/domain/usecases
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_statistics.dart
/// Description: Pure calculation of every dashboard figure from the loaded
///              documents and usage records.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

/// Status keys used by the dashboard cards.
class DashboardStatus {
  const DashboardStatus._();
  static const String published = 'published';
  static const String approved = 'approved';
  static const String pending = 'pending_approval';
  static const String rejected = 'rejected';
  static const String removed = 'removed';
  static const String archived = 'archived';
  static const String view = 'view';
  static const String download = 'download';
  static const List<String> all = [
    published,
    approved,
    pending,
    rejected,
    removed,
    archived,
  ];
}

/// Every figure the dashboard draws.
class DashboardFigures {
  const DashboardFigures({
    required this.statusCounts,
    required this.departmentCounts,
    required this.totalViews,
    required this.totalDownloads,
    required this.monthlyUploaded,
    required this.monthlyPublished,
    required this.monthlyRemoved,
    required this.monthlyDownloads,
    required this.monthlyViews,
    required this.extensionCounts,
    required this.departmentComparison,
  });

  final Map<String, int> statusCounts;

  /// Published documents per department id.
  final Map<String, int> departmentCounts;
  final int totalViews;
  final int totalDownloads;

  /// Monthly series, keyed by the first day of the month (year AND month),
  /// covering the last 12 months only (KH-DASH-01).
  final Map<DateTime, int> monthlyUploaded;
  final Map<DateTime, int> monthlyPublished;
  final Map<DateTime, int> monthlyRemoved;
  final Map<DateTime, int> monthlyDownloads;
  final Map<DateTime, int> monthlyViews;
  final Map<String, int> extensionCounts;

  /// Per department id: {published, removed}.
  final Map<String, Map<String, int>> departmentComparison;
}

class DashboardStatistics {
  const DashboardStatistics({required this.now, required this.departmentIdOf});

  final DateTime now;

  /// Turns a stored owning-department value (an id, or a name on older
  /// documents) into the department id.
  final String Function(String stored) departmentIdOf;

  /// The 12 months the charts cover, oldest first.
  static List<DateTime> lastTwelveMonths(DateTime now) =>
      List<DateTime>.generate(
        12,
        (int i) => DateTime(now.year, now.month - 11 + i),
      );

  DashboardFigures compute(
    List<CreateKnowledgeModel> documents,
    List<DocumentUtilizationModel> utilization,
  ) {
    final List<CreateKnowledgeModel> published = documents
        .where((d) => _status(d) == DashboardStatus.published)
        .toList();
    final List<CreateKnowledgeModel> removedAfterPublishing = documents
        .where(
          (d) => _status(d) == DashboardStatus.removed && _wasEverPublished(d),
        )
        .toList();

    final Map<String, int> statusCounts = {
      for (final String s in DashboardStatus.all) s: 0,
    };
    for (final CreateKnowledgeModel doc in documents) {
      final String status = _status(doc);
      if (!statusCounts.containsKey(status)) continue;
      if (status == DashboardStatus.removed && !_wasEverPublished(doc)) {
        continue;
      }
      statusCounts[status] = statusCounts[status]! + 1;
    }

    final Map<String, int> departmentCounts = {};
    final Map<String, int> extensionCounts = {};
    final Map<DateTime, int> monthlyPublished = {};
    for (final CreateKnowledgeModel doc in published) {
      final String dept = departmentIdOf(doc.currentOwningDepartment.trim());
      if (dept.isNotEmpty) _add(departmentCounts, dept);
      String extension = doc.currentDocumentExtension.toLowerCase();
      if (extension.startsWith('.')) extension = extension.substring(1);
      if (extension.isNotEmpty) _add(extensionCounts, extension);
      _addMonth(
        monthlyPublished,
        doc.firstTimeOfStatus(DashboardStatus.published),
      );
    }

    final Map<DateTime, int> monthlyRemoved = {};
    for (final CreateKnowledgeModel doc in removedAfterPublishing) {
      _addMonth(monthlyRemoved, doc.firstTimeOfStatus(DashboardStatus.removed));
    }

    final Map<DateTime, int> monthlyUploaded = {};
    for (final CreateKnowledgeModel doc in documents) {
      if (doc.timestamps.isEmpty) continue;
      _addMonth(
        monthlyUploaded,
        DateTime.fromMillisecondsSinceEpoch(doc.timestamps.first),
      );
    }

    final Set<String> documentIds = documents
        .expand((d) => d.knowledgeId)
        .where((id) => id.isNotEmpty)
        .toSet();
    int views = 0;
    int downloads = 0;
    final Map<DateTime, int> monthlyViews = {};
    final Map<DateTime, int> monthlyDownloads = {};
    for (final DocumentUtilizationModel record in utilization) {
      if (!documentIds.contains(record.currentFileId)) continue;
      final String action = record.currentTypeOfAction.toLowerCase();
      final DateTime? at = record.timestamp.isEmpty
          ? null
          : KhLocale.parseStoredTime(record.timestamp.last);
      if (action == DashboardStatus.view) {
        views++;
        _addMonth(monthlyViews, at);
      } else if (action == DashboardStatus.download) {
        downloads++;
        _addMonth(monthlyDownloads, at);
      }
    }

    final Map<String, Map<String, int>> comparison = {};
    for (final CreateKnowledgeModel doc in [
      ...published,
      ...removedAfterPublishing,
    ]) {
      final String dept = departmentIdOf(doc.currentOwningDepartment.trim());
      if (dept.isEmpty) continue;
      final Map<String, int> row = comparison.putIfAbsent(
        dept,
        () => {DashboardStatus.published: 0, DashboardStatus.removed: 0},
      );
      _add(row, _status(doc));
    }

    return DashboardFigures(
      statusCounts: statusCounts,
      departmentCounts: departmentCounts,
      totalViews: views,
      totalDownloads: downloads,
      monthlyUploaded: monthlyUploaded,
      monthlyPublished: monthlyPublished,
      monthlyRemoved: monthlyRemoved,
      monthlyDownloads: monthlyDownloads,
      monthlyViews: monthlyViews,
      extensionCounts: extensionCounts,
      departmentComparison: comparison,
    );
  }

  String _status(CreateKnowledgeModel doc) =>
      doc.currentStatus.trim().toLowerCase();

  bool _wasEverPublished(CreateKnowledgeModel doc) => doc.status.any(
    (s) => s.trim().toLowerCase() == DashboardStatus.published,
  );

  void _add(Map<String, int> map, String key) => map[key] = (map[key] ?? 0) + 1;

  /// Counts [at] in its month when that month is one of the last 12.
  void _addMonth(Map<DateTime, int> map, DateTime? at) {
    if (at == null) return;
    final DateTime month = DateTime(at.year, at.month);
    final DateTime first = DateTime(now.year, now.month - 11);
    final DateTime end = DateTime(now.year, now.month + 1);
    if (month.isBefore(first) || !month.isBefore(end)) return;
    map[month] = (map[month] ?? 0) + 1;
  }
}
