/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_feedback_cubit.dart
/// Purpose: Holds the "Request Details" list — the employee's own feedback
///          submissions — plus the chip filter, search text and sort order,
///          and owns the submit call.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
///
/// Shaped after `MyRequestCubit`: one loaded state carrying both the full list
/// and the filtered one, so the widget never filters and the chip counts can
/// never disagree with the cards below them.
library;

import 'dart:typed_data';

// `hide State`: dartz exports its own State, which collides with the Flutter
// one that `flutter/widgets.dart` brings in below. Same treatment as
// comments_and_feedback_screen.dart used to need.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/repository/feedback_repository.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/base_repository/feedback_base_repository.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_state.dart';

class CommentsFeedbackCubit extends Cubit<CommentsFeedbackState> {
  CommentsFeedbackCubit({FeedbackBaseRepository? repository})
      : _repository = repository ?? FeedbackRepository(),
        super(const CommentsFeedbackInitial()) {
    searchController.addListener(_onSearchChanged);
  }

  final FeedbackBaseRepository _repository;
  final LiveRefresh _live = LiveRefresh();

  /// Owned here, not by the screen, so `close()` disposes it exactly once.
  final TextEditingController searchController = TextEditingController();

  /// The last successful load. Kept so a failed refresh can put the list back
  /// instead of leaving the screen on an error state with nothing on it.
  CommentsFeedbackLoaded? _lastLoaded;

  /// Function Name: [employeeId]
  ///
  /// Purpose: Whose submissions to read.
  ///
  /// Guarded rather than a bare `Get.find`: this screen is also reachable
  /// through `Routes.settingsCommentsAndFeedback`, where the settings shell
  /// may never have been built. Same pattern `settings_screen.dart` uses.
  String get employeeId {
    if (!Get.isRegistered<SettingsController>()) return '';
    return Get.find<SettingsController>().employee?.id ?? '';
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read the employee's submissions and publish the first filtered
  ///          view.
  ///
  /// Parameters:
  /// - [showLoading]: false for the silent refresh that follows a submit, so
  ///   the list does not flash a spinner over content the user is looking at.
  Future<void> load({bool showLoading = true}) async {
    if (isClosed) return;

    if (showLoading && _lastLoaded == null) {
      emit(const CommentsFeedbackLoading());
    }

    final Either<Failure, List<FeedbackRequest>> result =
        await _repository.listForEmployee(employeeId);

    if (isClosed) return;

    result.fold(
      (Failure failure) {
        emit(CommentsFeedbackError(failure.errMessage));
        // Put the list back. A refresh that failed must not blank the screen —
        // the previous data is still the truest thing we have.
        final CommentsFeedbackLoaded? previous = _lastLoaded;
        if (previous != null) {
          emit(previous);
        } else {
          _publish(const <FeedbackRequest>[]);
        }
      },
      (List<FeedbackRequest> items) {
        _publish(items);
        _live.watchPaths(<String>[
          '${FeedbackCollectionPaths.settingsDoc}/'
              '${FeedbackCollectionPaths.feedbackCollection}',
        ], () => load(showLoading: false));
      },
    );
  }

  void updateStatus(FeedbackStatusFilter status) {
    final CommentsFeedbackLoaded? current = _lastLoaded;
    if (current == null) return;
    _publish(current.allItems, selectedStatus: status);
  }

  /// [option] null = the active sort was tapped again: deselect it (Moataz
  /// 23/10/2026 — the list goes back to the default order).
  void updateSort(FeedbackSortOption? option) {
    final CommentsFeedbackLoaded? current = _lastLoaded;
    if (current == null) return;
    _publish(current.allItems, sortOption: option, clearSort: option == null);
  }

  void _onSearchChanged() {
    final CommentsFeedbackLoaded? current = _lastLoaded;
    if (current == null) return;
    if (current.searchText == searchController.text) return;
    _publish(current.allItems, searchText: searchController.text);
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Send one submission, then refresh the list so the new rows
  ///          appear without the user leaving the screen.
  ///
  /// Returns: [Future<Failure?>] — null on success. The screen decides which
  ///          dialog to show; a cubit has no business building UI.
  Future<Failure?> submit(AppFeedback feedback) async {
    // CR-KNP-SET-APP-10 (20/10/2026): the guard used to live on the loaded
    // state, which is null until the list has loaded — so a double tap on
    // Submit before the first load wrote the feedback twice. The flag is a
    // plain field now, independent of what has been emitted.
    if (_submitting) {
      return FeatureFailure('A submission is already in progress.');
    }
    _submitting = true;
    _setSubmitting(true);

    final Either<Failure, void> result = await _repository.submit(feedback);

    if (isClosed) return null;

    return await result.fold(
      (Failure failure) async {
        _setSubmitting(false);
        return failure;
      },
      (_) async {
        _setSubmitting(false);
        // Silent: the success dialog is already on screen, and a spinner
        // underneath it would be noise.
        await load(showLoading: false);
        return null;
      },
    );
  }

  /// Function Name: [uploadAttachment]
  ///
  /// Purpose: Put one picked file in Storage.
  ///
  /// A straight pass-through, and deliberately so: it exists only to keep the
  /// screen from holding its own [FeedbackBaseRepository] alongside this one.
  /// Two repository instances would be harmless today but is exactly how a
  /// screen ends up reading from a different place than it writes to.
  ///
  /// No state is emitted — which file is uploading is a form concern, and the
  /// form owns it.
  Future<Either<Failure, FeedbackAttachment>> uploadAttachment({
    required FeedbackKind kind,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) {
    return _repository.uploadAttachment(
      kind: kind,
      fileName: fileName,
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// True from the start of [submit] until its write returns, whatever the
  /// emitted state is (CR-KNP-SET-APP-10).
  bool _submitting = false;

  void _setSubmitting(bool value) {
    _submitting = value;
    final CommentsFeedbackLoaded? current = _lastLoaded;
    if (current == null || isClosed) return;
    _lastLoaded = current.copyWith(isSubmitting: value);
    emit(_lastLoaded!);
  }

  /// Recomputes counts and the displayed list from [items] and publishes.
  ///
  /// Every mutator goes through here, which is why the chips, the cards and
  /// the "All" total are always derived from the same pass.
  void _publish(
    List<FeedbackRequest> items, {
    FeedbackStatusFilter? selectedStatus,
    FeedbackSortOption? sortOption,
    String? searchText,
    bool clearSort = false,
  }) {
    if (isClosed) return;

    final CommentsFeedbackLoaded? previous = _lastLoaded;

    final FeedbackStatusFilter status =
        selectedStatus ?? previous?.selectedStatus ?? FeedbackStatusFilter.all;
    // CHANGED 2/9/2026 — two variables where there used to be one.
    //
    // [sort] is what the user PICKED and may be null (nobody has opened the
    // menu yet). It goes into the state so the Sort button can draw itself
    // dimmed until there is a choice. [effectiveSort] is what the list is
    // actually ordered by, which has always been "descending unless told
    // otherwise" and still is. Collapsing them back into one field would make
    // the button claim a choice the user never made.
    final FeedbackSortOption? sort =
        clearSort ? null : (sortOption ?? previous?.sortOption);
    final FeedbackSortOption effectiveSort =
        sort ?? FeedbackSortOption.descending;
    final String query = searchText ?? previous?.searchText ?? '';

    final Map<FeedbackStatus, int> counts = <FeedbackStatus, int>{
      for (final FeedbackStatus value in FeedbackStatus.values) value: 0,
    };
    for (final FeedbackRequest item in items) {
      counts[item.status] = (counts[item.status] ?? 0) + 1;
    }

    final String needle = query.trim().toLowerCase();

    final List<FeedbackRequest> displayed = items.where((FeedbackRequest item) {
      if (!_matchesStatus(item, status)) return false;
      if (needle.isEmpty) return true;
      // Body and kind only. The date is deliberately not searchable: it is
      // rendered in the user's locale (Arabic-Indic digits included), so a
      // substring match against the raw DateTime would find nothing the user
      // can actually see on the card.
      return item.body.toLowerCase().contains(needle) ||
          item.kind.wireValue.toLowerCase().contains(needle);
    }).toList();

    _sort(displayed, effectiveSort);

    _lastLoaded = CommentsFeedbackLoaded(
      allItems: items,
      displayedItems: displayed,
      counts: counts,
      totalCount: items.length,
      selectedStatus: status,
      sortOption: sort,
      searchText: query,
      isSubmitting: previous?.isSubmitting ?? false,
    );

    emit(_lastLoaded!);
  }

  static bool _matchesStatus(
      FeedbackRequest item, FeedbackStatusFilter filter) {
    switch (filter) {
      case FeedbackStatusFilter.all:
        return true;
      case FeedbackStatusFilter.open:
        return item.status == FeedbackStatus.open;
      case FeedbackStatusFilter.fixed:
        return item.status == FeedbackStatus.fixed;
      case FeedbackStatusFilter.closed:
        return item.status == FeedbackStatus.closed;
    }
  }

  /// Sorts in place.
  ///
  /// A null `createdAt` is a server timestamp that has not resolved yet, i.e.
  /// something written seconds ago — so it sorts as the NEWEST item, not the
  /// oldest. See `FeedbackRemoteDataSource.listForEmployee`.
  static void _sort(List<FeedbackRequest> items, FeedbackSortOption option) {
    switch (option) {
      case FeedbackSortOption.descending:
        items.sort(_newestFirst);
        break;
      case FeedbackSortOption.ascending:
        items.sort(_oldestFirst);
        break;
    }
  }

  static int _newestFirst(FeedbackRequest a, FeedbackRequest b) {
    final DateTime? left = a.createdAt;
    final DateTime? right = b.createdAt;
    if (left == null && right == null) return 0;
    if (left == null) return -1; // unresolved stamp = written seconds ago
    if (right == null) return 1;
    return right.compareTo(left);
  }

  static int _oldestFirst(FeedbackRequest a, FeedbackRequest b) {
    final DateTime? left = a.createdAt;
    final DateTime? right = b.createdAt;
    if (left == null && right == null) return 0;
    if (left == null) return 1; // the newest item belongs last here
    if (right == null) return -1;
    return left.compareTo(right);
  }

  @override
  Future<void> close() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _live.dispose();
    return super.close();
  }
}
