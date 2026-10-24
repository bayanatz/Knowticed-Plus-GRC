/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_cubit.dart
/// Description: `ResultCubit`, the people of a form on the Results page
///              (pending / submitted), their filters, reminders and the CSV
///              export. No BuildContext, dialogs or controllers here: the
///              pages own their controllers and show [ResultNotice]s.
///              The analytics live in `ResultAnalyticsCubit`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_notifier.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/base_repository/result_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/table_row_data.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/users_responses.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/use_cases/get_users_responses_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/result_table_headers.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

/// The people of a form on the Results page.
class ResultCubit extends Cubit<ResultState> {
  /// The Results data (injected).
  final ResultBaseRepository resultRepository;

  /// Splits the people into pending / submitted (injected).
  final GetUsersResponsesUseCase usersResponsesUseCase;

  /// Sends the reminder notification (injected).
  final FormBuilderNotifier notifier;

  /// Writes the CSV export where the user can open it (injected).
  final CSVHelper csvHelper;

  /// Loads the department list; false when it failed (injected).
  final Future<bool> Function() ensureDepartmentsLoaded;

  ResultCubit({
    required this.resultRepository,
    required this.usersResponsesUseCase,
    required this.notifier,
    required this.csvHelper,
    required this.ensureDepartmentsLoaded,
  }) : super(ResultInitial());

  /// Tab the NEXT [initialize] opens on (0 = Pending, 1 = Submissions), then
  /// cleared. The Home "View Submissions" button must land on Submissions.
  static int? openOnTab;

  int _noticeId = 0;

  ResultLoaded? get _loaded =>
      state is ResultLoaded ? state as ResultLoaded : null;

  void _emitLoaded(ResultLoaded next) {
    if (isClosed) return;
    emit(next);
  }

  /// Method Name: [initialize]
  ///
  /// Purpose: opens the Results page of [formEntity] and loads its people.
  /// FB-FILL-05: no ticker or TabController here any more; the page owns
  /// its TabController and starts it on [ResultLoaded.isPendingScreen].
  ///
  /// Parameters:
  /// - [formEntity]: the form.
  ///
  /// Returns: [Future] that completes when the people are loaded.
  Future<void> initialize(FormEntity formEntity) async {
    if (isClosed) return;
    emit(ResultLoading());

    int initialTab = (openOnTab ?? 0).clamp(0, 1);
    // Large-screen bug report p.12: start on the tab the role may see.
    if (initialTab == 0 &&
        !FormBuilderAccess.canSeePendingSubmissions &&
        FormBuilderAccess.canViewSubmissions) {
      initialTab = 1;
    } else if (initialTab == 1 &&
        !FormBuilderAccess.canViewSubmissions &&
        FormBuilderAccess.canSeePendingSubmissions) {
      initialTab = 0;
    }
    openOnTab = null;

    emit(
      ResultLoaded(
        formEntity: formEntity,
        pendingUsers: const [],
        filteredPendingUsers: const [],
        submittedUsers: const [],
        filteredSubmittedUsers: const [],
        isPendingScreen: initialTab == 0,
        // Lists are loading — show the circle, not "no data".
        isLoadingUsers: true,
      ),
    );

    await getUsersResponses();
  }

  /// Method Name: [getUsersResponses]
  ///
  /// Purpose: loads the pending and submitted people. FB-RESULT-01: any
  /// error ends in [ResultError] with a message (it used to leave empty
  /// lists, so the owner was told nobody had answered). FB-RESULT-07: a
  /// failed department load is shown as a warning, not swallowed.
  ///
  /// Returns: [Future] that completes when the lists are emitted.
  Future<void> getUsersResponses() async {
    final ResultLoaded? current = _loaded;
    if (current == null) return;

    final bool departmentsOk = await ensureDepartmentsLoaded();
    if (isClosed) return;
    if (!departmentsOk) {
      _emitLoaded(
        _withNotice(
          _loaded ?? current,
          ResultNoticeType.warning,
          S.current.departmentsLoadFailed,
        ),
      );
    }

    final Either<Failure, List<String>> recipients = await resultRepository
        .getActiveRecipients(current.formEntity!.id);
    if (isClosed) return;
    // FB-RESULT-10: when the access list cannot be read, show an error
    // instead of an empty Pending tab ("everyone has answered").
    if (recipients.isLeft()) {
      emit(ResultError(S.current.resultsLoadFailed));
      return;
    }
    final List<String> activeUsers = recipients.getOrElse(() => const []);

    final Either<Failure, UsersResponses> result = await usersResponsesUseCase
        .execute(formId: current.formEntity!.id, userIds: activeUsers);
    if (isClosed) return;

    result.fold((_) => emit(ResultError(S.current.resultsLoadFailed)), (users) {
      final ResultLoaded latest = _loaded ?? current;
      _emitLoaded(
        _filtered(
          latest.copyWith(
            pendingUsers: users.pending,
            submittedUsers: users.submitted,
            isLoadingUsers: false,
          ),
        ),
      );
      _live.watchPaths([
        getBaseUrl(FormApiConstants.formPrivacy),
        getBaseUrl(
          '${FormApiConstants.formResponses}/${current.formEntity!.id}/${FormApiConstants.responses}',
        ),
        FormApiConstants.userResponses,
      ], getUsersResponses);
    });
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Method Name: [onChangeTab]
  ///
  /// Purpose: Pending (0) or Submissions (1) tab picked.
  ///
  /// Parameters:
  /// - [value]: the tab index.
  void onChangeTab(int value) {
    final ResultLoaded? current = _loaded;
    if (current == null) return;
    _emitLoaded(current.copyWith(isPendingScreen: value == 0));
  }

  /// Method Name: [remindClicked]
  ///
  /// Purpose: sends one reminder. FB-RESULT-05: the 24-hour rule is checked
  /// here for every layout (and again in the repository against the stored
  /// last reminder); the reminder is SAVED first and the notification goes
  /// out only when the save worked.
  ///
  /// Parameters:
  /// - [model]: the person reminded.
  ///
  /// Returns: true when the reminder was recorded (the page then shows the
  /// success dialog).
  Future<bool> remindClicked(UserGridItem model) async {
    final ResultLoaded? current = _loaded;
    if (current == null) return false;
    if (!isMoreThan24Hours(model.lastReminderTime)) return false;

    final Either<Failure, void> result = await resultRepository.remindUser(
      userId: model.person.id,
      formId: current.formEntity!.id,
    );
    if (result.isLeft()) return false;

    FormBuilderLogService.log(FormBuilderLogService.actionSendReminder);
    notifier.notifyReminder(
      formId: current.formEntity!.id,
      recipientEmail: model.person.id,
      formNameEn: current.formEntity!.formHeadModel.title,
      formNameAr: current.formEntity!.formHeadModel.arTitle,
    );
    model.lastReminderTime = DateTime.now();
    model.reminderCounter++;
    // Re-read the CURRENT state, so this does not overwrite newer changes
    // with an older copy.
    final ResultLoaded? latest = _loaded;
    if (latest != null) {
      _emitLoaded(latest.copyWith(revision: latest.revision + 1));
    }
    return true;
  }

  /// Method Name: [remindAllClicked]
  ///
  /// Purpose: sends every due reminder, one at a time (FB-RESULT-05: no
  /// reminder overwrites the state with an older copy).
  ///
  /// Returns: how many reminders went out.
  Future<int> remindAllClicked() async {
    final ResultLoaded? current = _loaded;
    if (current == null) return 0;
    final List<UserGridItem> due = current.filteredPendingUsers
        .where((element) => isMoreThan24Hours(element.lastReminderTime))
        .toList();
    int sent = 0;
    for (final UserGridItem user in due) {
      if (await remindClicked(user)) sent++;
    }
    return sent;
  }

  /// Method Name: [isMoreThan24Hours]
  ///
  /// Parameters:
  /// - [dateTime]: the last reminder, or null.
  ///
  /// Returns: true when a new reminder may be sent.
  bool isMoreThan24Hours(DateTime? dateTime) {
    if (dateTime == null) return true;
    return DateTime.now().difference(dateTime).inHours > 24;
  }

  /// Method Name: [getRemainingTimeText]
  ///
  /// Purpose: the cooldown chip text ("Resend in 5 hours", "24 Minutes").
  ///
  /// Parameters:
  /// - [reminderSentTime]: when the last reminder went out.
  ///
  /// Returns: the translated text.
  String getRemainingTimeText(DateTime reminderSentTime) {
    final Duration sent = DateTime.now().difference(reminderSentTime);
    final int hoursRemaining = 24 - sent.inHours;
    final int minutesRemaining = (24 * 60 - sent.inMinutes) % 60;
    if (hoursRemaining <= 0 && minutesRemaining <= 0) {
      return S.current.fbResendNow;
    } else if (hoursRemaining < 1) {
      return '${FormDateTimeHelper.formatInt(minutesRemaining)} ${S.current.fbMinutes}';
    }
    return '${S.current.fbResendIn} ${FormDateTimeHelper.formatInt(hoursRemaining)} ${S.current.hours}';
  }

  /// Method Name: [changeDataView]
  ///
  /// Parameters:
  /// - [value]: true for the grid, false for the table.
  void changeDataView(bool value) {
    final ResultLoaded? current = _loaded;
    if (current == null || value == current.isGridView) return;
    HapticController.low(); // list / grid view switch
    _emitLoaded(current.copyWith(isGridView: value));
  }

  /// Method Name: [onChangeSwitch]
  ///
  /// Purpose: Users / Analytics switch. FB-RESULT-07: the state is read
  /// when the switch is APPLIED (after the short delay that lets chart
  /// animations finish), so changes made in between stay.
  ///
  /// Parameters:
  /// - [value]: true for Users, false for Analytics.
  void onChangeSwitch(bool value) {
    final ResultLoaded? current = _loaded;
    if (current == null || value == current.isUser) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      final ResultLoaded? latest = _loaded;
      if (latest != null) _emitLoaded(latest.copyWith(isUser: value));
    });
  }

  /// Method Name: [search]
  ///
  /// Purpose: filters both lists by name (and the department filter).
  ///
  /// Parameters:
  /// - [query]: the text typed in the search box.
  void search(String query) {
    final ResultLoaded? current = _loaded;
    if (current == null) return;
    _emitLoaded(_filtered(current.copyWith(searchQuery: query)));
  }

  /// Method Name: [updateSelectedDepartmentFilters]
  ///
  /// Purpose: the Department multi-select changed. FB-RESULT-04: matched by
  /// department ID, never by the shown name. Empty = everyone.
  ///
  /// Parameters:
  /// - [departmentIds]: the picked department ids.
  void updateSelectedDepartmentFilters(List<String> departmentIds) {
    final ResultLoaded? current = _loaded;
    if (current == null) return;
    _emitLoaded(
      _filtered(
        current.copyWith(
          selectedDepartmentIds: List<String>.from(departmentIds),
        ),
      ),
    );
  }

  /// [state] with both filtered lists rebuilt from its filters.
  ResultLoaded _filtered(ResultLoaded state) {
    final Set<String> picked = state.selectedDepartmentIds.toSet();
    final String query = state.searchQuery.toLowerCase();
    bool keep(UserGridItem item) =>
        (picked.isEmpty || picked.contains(item.person.department)) &&
        item.person.name.toLowerCase().contains(query);
    return state.copyWith(
      filteredPendingUsers: state.pendingUsers.where(keep).toList(),
      filteredSubmittedUsers: state.submittedUsers.where(keep).toList(),
    );
  }

  /// Method Name: [selectUser]
  ///
  /// Purpose: picks the submission opened on the details page (the page
  /// builds its own field controllers from [UserGridItem.page]).
  ///
  /// Parameters:
  /// - [user]: the person whose answers are opened.
  void selectUser(UserGridItem user) {
    final ResultLoaded? current = _loaded;
    if (current == null) return;
    _emitLoaded(current.copyWith(selectedUser: user));
  }

  /// The rows of the CSV export: the table headers, then one row per
  /// submitted person shown.
  List<List<dynamic>> _getExportData(ResultLoaded current) {
    final List<List<dynamic>> rows = [
      buildResultTableHeaders(current.formEntity!),
    ];
    for (final UserGridItem user in current.filteredSubmittedUsers) {
      rows.add(TableRowData.fromUserGridItem(user).getTableList());
    }
    return rows;
  }

  /// Method Name: [exportToCSV]
  ///
  /// Purpose: exports the submissions table as CSV through the app's save
  /// path (system save sheet on phones, Downloads on desktop).
  /// FB-RESULT-03: an exception while building the rows becomes an export
  /// failure; the outcome is emitted as a [ResultNotice] the page shows.
  ///
  /// Parameters:
  /// - [fileName]: the name typed by the user.
  ///
  /// Returns: [Future] that completes when the notice is emitted.
  Future<void> exportToCSV(String fileName) async {
    final ResultLoaded? current = _loaded;
    if (current == null) return;
    if (fileName.trim().isEmpty) {
      _emitLoaded(
        _withNotice(
          current,
          ResultNoticeType.exportFailed,
          S.current.pleaseEnterAFileName,
        ),
      );
      return;
    }

    Either<String, String> result;
    try {
      final List<List<dynamic>> rows = _getExportData(current);
      result = await csvHelper.exportRowsForUser(
        fileName: fileName,
        rows: rows.map((row) => row.map(_safeCsvCell).toList()).toList(),
      );
    } catch (e) {
      result = Left(S.current.exportFailed);
    }
    if (isClosed) return;

    final ResultLoaded latest = _loaded ?? current;
    final String? error = result.fold((String e) => e, (String _) => null);
    if (error != null) {
      _emitLoaded(_withNotice(latest, ResultNoticeType.exportFailed, error));
      return;
    }
    // The phone save sheet was dismissed: nothing written, nothing failed.
    if (result.getOrElse(() => CSVHelper.exportCancelled) ==
        CSVHelper.exportCancelled) {
      return;
    }
    FormBuilderLogService.log(FormBuilderLogService.actionExportFormResults);
    _emitLoaded(_withNotice(latest, ResultNoticeType.exported, ''));
  }

  ResultLoaded _withNotice(
    ResultLoaded state,
    ResultNoticeType type,
    String message,
  ) => state.copyWith(
    notice: ResultNotice(type: type, message: message, id: ++_noticeId),
  );

  /// FB-RESULT-03: a cell that starts with = + - or @ is run as a formula
  /// when the CSV is opened in Excel. A leading ' makes it plain text.
  static dynamic _safeCsvCell(dynamic cell) {
    if (cell is String && cell.isNotEmpty && '=+-@'.contains(cell[0])) {
      return "'$cell";
    }
    return cell;
  }
}
