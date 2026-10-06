/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: services_home_stats_cubit.dart
/// Purpose: Declares `ServicesHomeStatsCubit` — the live figures behind the
///          Services cards on the home page and in the Adding Widget picker.
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The seven Services cards shipped with the placeholder numbers their Figma
/// frames drew — 32 / 12 / 08, six bars all reading 84, four tiles all reading
/// 10, "Total 100". `home_service_widgets.dart` said so in its own header:
/// "Wiring them to the services cubits is a separate piece of work". This is
/// that work.
///
/// It could not simply read the services cubits, for the same reason
/// [RolesHomeStatsCubit] could not read the roles ones: `ServicesManagerCubit`
/// is provided by `responsive_services.dart`, the services module's own
/// composition root, and `DashboardMasterCubit` is built and disposed by one
/// page. A home widget has neither in scope, so `context.read` for either
/// throws there. This reads the same repository they read and keeps only the
/// numbers.
///
/// Modelled on [RolesHomeStatsCubit] deliberately — same lazy `ensureLoaded`
/// contract, same "one failed source blanks one card, not all of them" rule,
/// same counts-live-on-the-cubit shape. Two of these cubits with one shape is
/// a pattern; two with two shapes is a mess.
///
/// KEEPING THE BUCKETS HONEST
/// -------------------------
/// The status bucketing is [_finalStateOf], a copy of the rule
/// `DashboardMasterCubit.loadServiceStatusData` and
/// `ServicesDashboardCubit._getFinalStateFromModel` both apply: the request's
/// own state when it names one, otherwise a verdict derived from its approval
/// cycle. A card and the dashboard it links to must not be able to disagree
/// about how many requests are "pending".
///
/// It is copied rather than imported because both existing homes for it are
/// private to a cubit that a home widget cannot reach. If it is ever lifted
/// into the services module as shared code, delete this copy and import that.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grc_module/features/home/h1_home_page/presentation/controller/services_home_stats_state.dart';

/// The status buckets every Services card counts in.
///
/// The literals are the ones the request documents actually carry, lower-cased
/// and space-stripped — `branchsla`, not "Breached SLA". Same keys
/// `DashboardMasterCubit` builds its `statusCounts` map with.
abstract class ServiceStatusKey {
  static const String done = 'done';
  static const String approved = 'approved';
  static const String pending = 'pending';
  static const String inProgress = 'inprogress';
  static const String breachedSla = 'branchsla';
  static const String rejected = 'rejected';
  static const String cancel = 'cancel';

  /// Every bucket, in no particular order — used to zero the maps.
  static const List<String> all = <String>[
    done,
    approved,
    pending,
    inProgress,
    breachedSla,
    rejected,
    cancel,
  ];
}

/// One request, reduced to what a card row shows.
///
/// The cards render a name and a department, nothing else, so the whole
/// `ServicesHistoryModel` does not travel up here.
class ServiceRequestSummary {
  final String nameEnglish;
  final String nameArabic;
  final String departmentEnglish;
  final String departmentArabic;

  const ServiceRequestSummary({
    required this.nameEnglish,
    required this.nameArabic,
    required this.departmentEnglish,
    required this.departmentArabic,
  });

  /// The name in the reader's language, falling back to the other one rather
  /// than to an empty row — a request with only an English name is still a
  /// request an Arabic reader needs to see.
  String name(bool isArabic) {
    final String preferred = isArabic ? nameArabic : nameEnglish;
    if (preferred.trim().isNotEmpty) return preferred;
    return isArabic ? nameEnglish : nameArabic;
  }

  /// As [name], for the department line.
  String department(bool isArabic) {
    final String preferred = isArabic ? departmentArabic : departmentEnglish;
    if (preferred.trim().isNotEmpty) return preferred;
    return isArabic ? departmentEnglish : departmentArabic;
  }
}

/// Services management is not part of the inventory app, so this cubit keeps
/// the same public API the home cards read but always reports zero figures.
class ServicesHomeStatsCubit extends Cubit<ServicesHomeStatsState> {
  ServicesHomeStatsCubit() : super(ServicesHomeStatsInitial());

  Map<String, int> statusCounts = _zeroed();
  Map<String, int> myRequestCounts = _zeroed();
  int totalServices = 0;
  int totalRequests = 0;
  int myRequestTotal = 0;
  List<ServiceRequestSummary> recentRequests = <ServiceRequestSummary>[];
  List<ServiceRequestSummary> breachedRequests = <ServiceRequestSummary>[];

  double get breachedSlaRatio {
    if (totalRequests <= 0) return 0;
    return (statusCounts[ServiceStatusKey.breachedSla] ?? 0) / totalRequests;
  }

  int get statusPeak {
    int peak = 0;
    for (final int value in statusCounts.values) {
      if (value > peak) peak = value;
    }
    return peak == 0 ? 1 : peak;
  }

  static Map<String, int> _zeroed() =>
      <String, int>{for (final String key in ServiceStatusKey.all) key: 0};

  bool _loadedOnce = false;

  void emitSafely(ServicesHomeStatsState state) {
    if (isClosed) return;
    emit(state);
  }

  void ensureLoaded() {
    if (_loadedOnce) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      load();
    });
  }

  Future<void> load() async {
    _loadedOnce = true;
    emitSafely(ServicesHomeStatsLoaded());
  }
}
