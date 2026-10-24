/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_cubit.dart
/// Description: `HomeCubit`, the Form Builder home lists (load, filter,
///              sort, save). No BuildContext, dialogs, navigation, timers
///              or controllers here: the page owns the TabController and
///              text controllers, and `HomeFormActions` / `HomePublishActions`
///              show the dialogs and navigate.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Dialogs, navigation and controllers moved to the UI.
/// Updated: 23/10/2026 - No Firestore models here: the access list is a
///                       domain [FormAccessGrant] (Home rule 9).
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_directory.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_sort_option.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/edit_validator.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/base_repository/form_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_grant.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_record.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/base_repository/response_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/user_submissions.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

part 'home_cubit/home_cubit_methods.dart';
part 'home_cubit/home_cubit_methods_2.dart';

/// The Form Builder home lists: published, drafts, requested, submitted and
/// deleted forms, with search, filter and sort.
class HomeCubit extends Cubit<HomeState> with EditValidator {
  /// Home reads (submissions index, one response, usage count).
  final HomeBaseRepository homeRepository;

  /// Form reads and writes.
  final FormRepo formRepo;

  /// The one response store.
  final ResponseRepo responseRepo;

  /// The signed-in employee and the employee list.
  final MainCoreEmployeeController mainCoreEmployeeController;

  HomeCubit({
    required this.homeRepository,
    required this.formRepo,
    required this.responseRepo,
    required this.mainCoreEmployeeController,
  }) : super(HomeInitial());

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Every emit is skipped once the cubit is closed (Home rule 8): many run
  /// after an await.
  @override
  void emit(HomeState state) {
    if (isClosed) return;
    super.emit(state);
  }

  bool isLoading = true;
  List<FormEntity> publishFormModels = [];
  List<FormEntity> draftFormModels = [];
  List<FormEntity> deleteFormModels = [];
  List<FormEntity> requestedFormModels = [];
  List<FormEntity> submissionsFormModels = [];
  List<FormEntity> shownFormModels = [];
  FormStatus selectedTab = FormStatus.publish;
  List<FormEntity> formsEntity = [];

  /// The open tab (0 Publish, 1 Drafts, 2 Requested, 3 Submissions,
  /// 4 Deleted). The page's TabController follows this value.
  int selectedTabIndex = 0;

  /// The text in the search bar (the page owns the text controller).
  String searchQuery = '';

  /// The access type picked in the filter, or null.
  String? currentDropDownValue;

  /// The date picked in the filter (formatted), or null.
  String? currentDateValue;

  String selectedSortOption = FormSortOption.publishedDate;
  bool isAscending = false;

  /// The option the user actively picked in Sort (null = none, the button
  /// shows neutral). [selectedSortOption] keeps the effective default.
  String? activeSortOption;

  int _stateRevision = 0;

  /// Max time [getData] waits for the user profile (FB-HOME-10).
  static const Duration _profileWaitLimit = Duration(seconds: 15);
  static const Duration _profilePollInterval = Duration(milliseconds: 100);

  /// Method Name: [waitUntilLoaded]
  ///
  /// Purpose: waits for the first load to finish, so a tab opened from a
  /// shortcut shows its forms. Gives up after [timeout] or when the cubit
  /// closes.
  ///
  /// Parameters:
  /// - [timeout]: the longest wait.
  ///
  /// Returns: [Future<void>] that completes when loaded or on time-out.
  Future<void> waitUntilLoaded({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!isLoading) return;
    try {
      await stream
          .firstWhere((s) => (s is HomeLoaded || s is HomeError) && !isLoading)
          .timeout(timeout);
    } catch (e, stackTrace) {
      // Timed out or closed: the caller switches anyway.
      fbFailure(e, stackTrace);
    }
  }

  /// Method Name: [initialize]
  ///
  /// Purpose: opens the home screen on the Publish tab and loads the forms.
  ///
  /// Returns: [Future<void>] that completes when the first load ends.
  Future<void> initialize() async {
    selectedTabIndex = 0;
    selectedTab = FormStatus.publish;
    shownFormModels = publishFormModels;
    await getData();
  }

  /// Method Name: [getData]
  ///
  /// Purpose: waits (with a limit) for the user profile, then loads the
  /// forms. FB-HOME-10: emits [HomeError] when the profile never loads.
  ///
  /// Returns: [Future<void>].
  Future<void> getData() async {
    final DateTime deadline = DateTime.now().add(_profileWaitLimit);
    while (mainCoreEmployeeController.employeeEntity == null) {
      if (isClosed) return;
      if (DateTime.now().isAfter(deadline)) {
        isLoading = false;
        emit(HomeError(S.current.formsLoadFailed));
        return;
      }
      await Future.delayed(_profilePollInterval);
    }
    if (isClosed) return;
    await getForms();
  }

  /// Method Name: [updateSortOption]
  ///
  /// Purpose: applies the Sort pick (null clears it to the tab's default).
  ///
  /// Parameters:
  /// - [option]: a [FormSortOption] value, or null.
  void updateSortOption(String? option) {
    activeSortOption = option;
    selectedSortOption = option ?? _defaultSortForTab();
    sortForms();
  }

  /// Bug report #24: the Submissions tab sorts by Submission / Received
  /// date; every other tab by Published date / Last update.
  String _defaultSortForTab() => selectedTabIndex == 3
      ? FormSortOption.submissionDate
      : FormSortOption.publishedDate;

  /// Method Name: [toggleSortOrder]
  ///
  /// Purpose: flips ascending / descending and re-sorts.
  void toggleSortOrder() {
    isAscending = !isAscending;
    sortForms();
  }

  DateTime _getPublishedDate(FormEntity form) => form.createDate;

  DateTime _getLastUpdate(FormEntity form) =>
      form.submissionDate ?? form.createDate;

  /// Method Name: [saveFormAccess]
  ///
  /// Purpose: saves the access list of [model]; the repository logs the
  /// change and notifies the recipients (Section 2.3).
  ///
  /// Parameters:
  /// - [grant]: the recipients, period and edit permission.
  /// - [model]: the form (its id and names).
  ///
  /// Returns: the failure, or null when the save worked (FB-HOME-04).
  Future<Failure?> saveFormAccess(
    FormAccessGrant grant,
    FormEntity model,
  ) async {
    final response = await formRepo.saveFormAccess(
      formId: model.id,
      grant: grant,
      formNameEn: model.formHeadModel.title,
      formNameAr: model.formHeadModel.arTitle,
    );
    return response.fold((failure) => failure, (_) => null);
  }

  /// Method Name: [duplicateVersionFor]
  ///
  /// Purpose: the next "_N" suffix for a copy of a form.
  ///
  /// Parameters:
  /// - [originalTitle]: the title of the form being copied.
  ///
  /// Returns: the version number to suggest.
  int duplicateVersionFor(String originalTitle) {
    int maxVersion = 1;
    final List<FormEntity> allForms = [
      ...publishFormModels,
      ...draftFormModels,
      ...deleteFormModels,
    ];
    for (final form in allForms) {
      final String formTitle = form.formHeadModel.title;
      if (!formTitle.contains(originalTitle)) continue;
      final Match? match = RegExp(r'_(\d+)$').firstMatch(formTitle);
      if (match != null) {
        final int version = int.parse(match.group(1)!);
        if (version >= maxVersion) maxVersion = version + 1;
      } else if (formTitle == originalTitle) {
        maxVersion = 2;
      }
    }
    return maxVersion;
  }

  /// Method Name: [refreshShownList]
  ///
  /// Purpose: re-emits the lists after a change made elsewhere (for example
  /// after a dialog flow finished).
  void refreshShownList() => _emitLoadedState();

  List<FormEntity> _getListFromIndex(int index) {
    switch (index) {
      case 0:
        return publishFormModels;
      case 1:
        return draftFormModels;
      case 2:
        return requestedFormModels;
      case 3:
        return submissionsFormModels;
      default:
        return deleteFormModels;
    }
  }

  /// Method Name: [onChangeFilterDropDownValue]
  ///
  /// Purpose: stores the access type picked in the filter.
  ///
  /// Parameters:
  /// - [value]: an [AccessManagement] name, or null.
  void onChangeFilterDropDownValue(String? value) {
    currentDropDownValue = value;
    _emitLoadedState();
  }

  /// Method Name: [onChangeDateValue]
  ///
  /// Purpose: stores the date picked in the filter.
  ///
  /// Parameters:
  /// - [value]: the formatted date, or null.
  void onChangeDateValue(String? value) {
    currentDateValue = (value == null || value.isEmpty) ? null : value;
    _emitLoadedState();
  }

  /// Method Name: [resetFilters]
  ///
  /// Purpose: clears the filter and the search (the page closes the filter
  /// dialog and clears its search field).
  void resetFilters() {
    shownFormModels = _getListFromIndex(selectedTabIndex);
    currentDateValue = null;
    currentDropDownValue = null;
    searchQuery = '';
    _emitLoadedState();
  }

  /// Method Name: [applyFilter]
  ///
  /// Purpose: applies the filter picked in the filter dialog (the page
  /// closes the dialog).
  void applyFilter() {
    if (currentDropDownValue != null) {
      shownFormModels = _filterByAccessManagement(
        currentDropDownValue,
        selectedTabIndex,
      );
      if (searchQuery.isNotEmpty) {
        shownFormModels = shownFormModels
            .where(
              (element) => element.getTitle.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }
    }
    if (currentDateValue != null) {
      _filterByDate(currentDateValue!);
    }
    sortForms();
  }

  /// Compares through [AccessManagementExtension.fromStored], so an access
  /// type saved in an older spelling still matches (FB-HOME-25).
  List<FormEntity> _filterByAccessManagement(
    String? accessManagement,
    int tabIndex,
  ) {
    final AccessManagement? wanted = AccessManagementExtension.fromStored(
      accessManagement,
    );
    return _getListFromIndex(tabIndex)
        .where(
          (element) =>
              AccessManagementExtension.fromStored(
                element.formHeadModel.accessManagement,
              ) ==
              wanted,
        )
        .toList();
  }

  void _filterByDate(String date) {
    if (currentDropDownValue == null) {
      shownFormModels = _getListFromIndex(selectedTabIndex);
      if (searchQuery.isNotEmpty) {
        onSearch(searchQuery);
      }
    }
    shownFormModels = shownFormModels
        .where(
          (element) =>
              FormDateTimeHelper.formatDate(element.createDate) == date,
        )
        .toList();
  }

  /// Method Name: [onSearch]
  ///
  /// Purpose: shows the forms of the open tab whose title contains [value],
  /// keeping the filter and sort.
  ///
  /// Parameters:
  /// - [value]: the search text.
  void onSearch(String value) {
    searchQuery = value;
    shownFormModels = _getListFromIndex(selectedTabIndex);
    if (currentDropDownValue != null) {
      shownFormModels = _filterByAccessManagement(
        currentDropDownValue,
        selectedTabIndex,
      );
    }
    if (currentDateValue != null) {
      shownFormModels = shownFormModels
          .where(
            (element) =>
                FormDateTimeHelper.formatDate(element.createDate) ==
                currentDateValue,
          )
          .toList();
    }
    if (value.isNotEmpty) {
      shownFormModels = shownFormModels
          .where(
            (element) =>
                element.getTitle.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    }
    sortForms();
  }

  void _emitLoadedState() {
    // Runs after awaits from many places.
    if (isClosed) return;
    emit(
      HomeLoaded(
        revision: ++_stateRevision,
        publishForms: publishFormModels,
        draftForms: draftFormModels,
        deletedForms: deleteFormModels,
        requestedForms: requestedFormModels,
        submissionForms: submissionsFormModels,
        // A copy, so a later in-place sort cannot rewrite this state too.
        shownForms: List<FormEntity>.of(shownFormModels),
        selectedTab: selectedTab,
        currentDropDownValue: currentDropDownValue,
        currentDateValue: currentDateValue,
      ),
    );
  }
}
