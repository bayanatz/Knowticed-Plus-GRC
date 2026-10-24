/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_page_logic.dart
/// Description: Logic and event handlers of `_MyRequestPageState` — split out of `request_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/request_page.dart';

// Split from request_page.dart to keep every file under 700 lines.

extension _MyRequestPageStateLogic on _MyRequestPageState {
  // Counts are derived from allRequests, never cached in fields. Cached copies
  // only updated inside _fetchRequests, so any code path that
  // changed the list without re-fetching (or a hot reload, which keeps the
  // State object and its stale field values) left the chips disagreeing with
  // the cards they sit above.
  int get totalRequests => allRequests.length;

  int get pendingCount => _countOf(_MyRequestPageState.kPending);

  int get approvedCount => _countOf(_MyRequestPageState.kApproved);

  int get rejectedCount => _countOf(_MyRequestPageState.kRejected);

  int get cancelledCount => _countOf(_MyRequestPageState.kCancelled);

  /// Icon for a request card, chosen from the request's `section`.
  /// Health Insurance requests get the health icon; everything else falls back
  /// to the generic employee-record icon.
  /// Item 174 (21/10/2026, Moataz: "the icon is white and the container is
  /// black, inside the box"): the same LINE icons Request Details uses in its
  /// section title, never an icon that draws its own box.
  String _sectionIconPath(String? section) =>
      RequestSectionLabel.iconOf(section);

  /// FIXED 13/8/2026: this local copy was missing the 'Personal Information'
  /// case, so that chip rendered in English beside a translated
  /// 'التأمين الصحي'. It also hardcoded the Arabic instead of using the
  /// l10n keys that already existed. Both copies now defer to
  /// [RequestSectionLabel].
  String _translateTitle(String englishTitle) =>
      RequestSectionLabel.of(context, englishTitle);

  Future<void> _fetchRequests() async {
    rebuild(() => isLoading = true);

    final String employeeId =
        Get.find<MainCoreEmployeeController>().employeeEntity?.id ?? '';

    await _requestsCubit.loadForEmployee(employeeId);
    if (!mounted) return;

    final RequestsState state = _requestsCubit.state;

    if (state.status == RequestsStatus.failure) {
      _requestsCubit.clearMessages();
      rebuild(() => isLoading = false);
      _showError();
      return;
    }

    rebuild(() {
      allRequests = state.requests.map(_asRow).toList();
      _filterRequests();
      isLoading = false;
    });
  }

  /// Adapts one entity to the map shape the list rows read.
  Map<String, dynamic> _asRow(ChangeRequest request) {
    final FieldChange? first =
        request.changes.isEmpty ? null : request.changes.first;

    return <String, dynamic>{
      'id': request.id,
      'title': request.section,
      'dateRequested': request.requestDate?.millisecondsSinceEpoch ?? 0,
      'status': request.status.wireValue,
      'requestNote': request.requestNote,
      'employeeId': request.employeeId,
      'employeeEmail': request.employeeEmail,
      'section': request.section,
      'changes': request.changes.map((FieldChange c) => c.toMap()).toList(),
      'numberOfChanges': request.numberOfChanges,
      'whatChanged': first?.fieldName ?? '',
      'oldValue': first?.oldValue ?? '',
      'newValue': first?.newValue ?? '',
    };
  }

  /// Was `Get.snackbar` with raw AppColors.primary/white and the interpolated
  /// exception text (CR-SKEL-SE6-N04, N06).
  void _showError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorOccurred,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _normalizeStatus(dynamic raw) {
    final value = (raw ?? '').toString().toLowerCase().trim();
    return value == 'canceled' ? _MyRequestPageState.kCancelled : value;
  }

  int _countOf(String status) =>
      allRequests.where((r) => _normalizeStatus(r['status']) == status).length;

  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(allRequests);

    // Filter by status. selectStatus holds a canonical key, not a display
    // label — comparing against localized labels meant the Pending / Rejected
    // chips silently matched nothing under an Arabic locale.
    if (selectStatus != _MyRequestPageState.kAll) {
      filtered = filtered
          .where(
              (request) => _normalizeStatus(request['status']) == selectStatus)
          .toList();
    }

    // Filter by search text (search in title)
    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((request) {
        final title = request['title'].toString().toLowerCase();
        final translatedTitle = _translateTitle(request['title']).toLowerCase();
        return title.contains(searchText) ||
            translatedTitle.contains(searchText);
      }).toList();
    }

    // Sort by request date. `dateRequested` is stored as epoch millis by
    // _asRow, so this is an int compare — no date parsing, and requests with a
    // missing date (0) sort to the far end rather than throwing.
    if (_sortOrder != null) {
      filtered.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int dateA = (a['dateRequested'] as int?) ?? 0;
        final int dateB = (b['dateRequested'] as int?) ?? 0;
        return _sortOrder == RequestDateSort.ascending
            ? dateA.compareTo(dateB) // oldest request first
            : dateB.compareTo(dateA); // newest request first
      });
    }

    rebuild(() {
      filteredRequests = filtered;
    });
  }

  /// Menu label for one sort option.
  ///
  /// CHANGED 8/9/2026 — was "Ascending" / "Descending".
  ///
  /// This sort only ever applies to `dateRequested`, and ascending/descending
  /// says nothing about which end of a DATE it means: a reader has to decide
  /// for themselves whether "ascending" counts up towards today or up towards
  /// the newest request. "Oldest First" / "Newest First" name the outcome, so
  /// there is nothing left to work out before tapping.
  ///
  /// The mapping matches the comparator in [_applyFilters]: ascending compares
  /// `dateA.compareTo(dateB)`, which puts the smallest epoch — the oldest
  /// request — at the top.
  ///
  /// Both keys already existed in `intl_en.arb` and `intl_ar.arb`
  /// ("الأقدم أولاً" / "الأحدث أولاً"), so this needs no regeneration.
  String _sortLabel(BuildContext context, RequestDateSort order) =>
      order == RequestDateSort.ascending
          ? S.of(context).oldestFirst
          : S.of(context).newestFirst;

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // 21/10/2026: in the app language (was always English).
    final String locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMM yyyy', locale == 'ar' ? 'ar' : 'en').format(date);
  }

  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case _MyRequestPageState.kApproved:
        return AppColors.lightGreen;
      case _MyRequestPageState.kPending:
        // statusPending (0xFFFF814A), not AppColors.secondaryPrimary — Pending is the
        // orange in the status palette, and yellow reads too close to the
        // brand primary used elsewhere on this screen.
        return AppColors.statusPending;
      case _MyRequestPageState.kRejected:
        // NOT AppColors.primary: that getter returns currentThemeColors
        // ['primary'] — the brand yellow — so Rejected was rendering in the
        // same family as Pending (bug report p.15, "wrong color").
        return AppColors.red;
      case _MyRequestPageState.kCancelled:
        return AppColors
            .secondaryText; // 21/10/2026: grey, so it reads apart from Rejected
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case _MyRequestPageState.kApproved:
        return S.of(context).Approved;
      case _MyRequestPageState.kPending:
        return S.of(context).pending;
      case _MyRequestPageState.kRejected:
        return S.of(context).rejected;
      case _MyRequestPageState.kCancelled:
        return S.of(context).canceled;
      default:
        return status;
    }
  }
}
