import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:get/get.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/entity/user_access_entity.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/use_case/get_user_access_entities_use_case.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/use_case/update_user_access_status_use_case.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/ui/widgets/filter_widget.dart'; // ✅ Import SortOptionRole from here
import './user_access_state.dart';

/// App-wide shared UserAccessCubit instance.
///
/// Moved here from role_responsive_page.dart when that wrapper page was
/// removed. Top-level variables are lazily initialised in Dart, so this is
/// only constructed on first use.
UserAccessCubit accountStatusCubit = UserAccessCubit();

class UserAccessCubit extends Cubit<UserAccessState> {
  UserAccessCubit() : super(UserAccessInitial());
  UserAccessRepository repository = UserAccessRepository();
  EmployeeStatusEnum selectedStatus = EmployeeStatusEnum.all;
  SortOptionRole? selectedSortOption; // ✅ Use SortOptionRole
  Map<EmployeeStatusEnum, List<UserAccessEntity>>
  accountStatusEntities = {};
  List<UserAccessEntity> filteredSortedSelectedEntities = [];
  TextEditingController searchController = TextEditingController();
  String? selectedDepartment;

  /// Method Name: [getAccountsStatusEntities]
  ///
  /// Purpose: get all employees account status categorized according to status.
  getAccountsStatusEntities() async {
    Either<Failure, dynamic> result =
    await GetUserAccessEntitiesUseCase(repository).execute();
    if (result.isRight()) {
      accountStatusEntities = result.getOrElse(() => {});
      searchAccountsStatusEntities(searchController.text, selectedSortOption);
    }
  }

  /// Method Name: [sortAccountsStatusEntities]
  ///
  /// Purpose: sort account status entities according to the selected option.
  sortAccountsStatusEntities(SortOptionRole? option) { // ✅ Changed parameter type
    if (option == null) return; // ✅ Handle null case

    selectedSortOption = option;
    switch (option) {
      case SortOptionRole.firstName:
        filteredSortedSelectedEntities.sort((a, b) => a.englishName
            .split(" ")
            .first
            .compareTo(b.englishName.split(" ").first));
        break;
      case SortOptionRole.lastName:
        filteredSortedSelectedEntities.sort((a, b) => a.englishName
            .split(" ")
            .last
            .compareTo(b.englishName.split(" ").last));
        break;
      case SortOptionRole.firstLogin:
        filteredSortedSelectedEntities.sort((a, b) {
          if (a.firstLogin == null) {
            return 1;
          }
          if (b.firstLogin == null) {
            return -1;
          }
          return a.firstLogin!.compareTo(b.firstLogin!);
        });

        break;
      case SortOptionRole.lastLogin:
        filteredSortedSelectedEntities.sort((a, b) {
          if (a.lastLogin == null) {
            return 1;
          }
          if (b.lastLogin == null) {
            return -1;
          }

          return a.lastLogin!.compareTo(b.lastLogin!);
        });

        break;
    }
    // print("reach to update ui");
    emit(UserAccessLoaded());
  }

  /// Method Name: [searchAccountsStatusEntities]
  ///
  /// Purpose: search for account status entities according to the search value.
  searchAccountsStatusEntities(String searchValue, SortOptionRole? option) { // ✅ Changed parameter type
    filteredSortedSelectedEntities = [];
    for (UserAccessEntity entity
    in accountStatusEntities[selectedStatus]!) {
      if (entity.englishName
          .toLowerCase()
          .contains(searchValue.toLowerCase()) ||
          entity.arabicName.toLowerCase().contains(searchValue.toLowerCase())) {
        if(selectedDepartment == null || selectedDepartment == entity.department)
          filteredSortedSelectedEntities.add(entity);
      }
    }
    if(option != null) {
      sortAccountsStatusEntities(option);
    }
    else {
      // print('reach to update ui and filter list lenght is ${filteredSortedSelectedEntities.length}');
      emit(UserAccessLoaded());
    }
  }

  /// Method Name: [selectStatus]
  ///
  /// Purpose: select status to filter account status entities.
  selectStatus(EmployeeStatusEnum newStatus) {
    selectedStatus = newStatus;
    searchAccountsStatusEntities(searchController.text, selectedSortOption);
  }

  /// Method Name: [updateAccountStatus]
  ///
  /// Purpose: update account status in the database.
  updateAccountStatus(
      UserAccessEntity accountStatusAccessEntity) async
  {
    Either<Failure, dynamic> result =
    await UpdateUserAccessStatusUseCase(repository)
        .execute(accountStatusAccessEntity);
    if (result.isRight()) {
      // print('reach to update ui and filter list lenght is ${filteredSortedSelectedEntities.length}');
      getAccountsStatusEntities();
    }
  }

  /// Method Name: [updateAccessDetails]
  ///
  /// Purpose: update access details (expiration time and default password) in the database.
  ///
  /// Parameters: [UserAccessEntity] accountStatusAccessEntity
  updateAccessDetails(UserAccessEntity accountStatusAccessEntity) async {
    // print('');
    // print('========================================');
    // print('🔄 UPDATE ACCESS DETAILS - START');
    // print('========================================');
    // print('📋 Entity Details:');
    // print('   - Employee ID: ${accountStatusAccessEntity.employeeId}');
    // print('   - UID: ${accountStatusAccessEntity.employeeId}');
    // print('   - Name: ${accountStatusAccessEntity.englishName}');
    // print('   - Expiration Time: ${accountStatusAccessEntity.expirationTimeOfPassword}');
    // print('   - Password: ${accountStatusAccessEntity.tempPassword}');
    // print('   - Department: ${accountStatusAccessEntity.department}');
    // print('========================================');

    try {
      emit(UserAccessLoading());
      // print('✅ State changed to: UserAccessLoading');

      // print('🔄 Calling repository.updateAccessDetails...');
      await repository.updateAccessDetails(accountStatusAccessEntity);
      // print('✅ Repository update completed successfully');

      // print('🔄 Refreshing account status entities...');
      await getAccountsStatusEntities();
      // print('✅ Account status entities refreshed');

      emit(UserAccessLoaded());
      // print('✅ State changed to: UserAccessLoaded');

      // print('========================================');
      // print('✅ UPDATE ACCESS DETAILS - SUCCESS');
      // print('========================================');
      // print('');
    } catch (e) {
      // print('');
      // print('========================================');
      // print('❌ UPDATE ACCESS DETAILS - ERROR');
      // print('========================================');
      // print('❌ Error message: $e');
      // print('❌ Error type: ${e.runtimeType}');
      // print('========================================');
      // print('');
      emit(UserAccessError('Failed to update access details: ${e.toString()}'));
    }
  }

  /// Method Name: [scheduleReactivation]
  ///
  /// Purpose: schedule reactivation time for the account.
  ///
  /// Parameters: [UserAccessEntity] accountStatusAccessEntity
  ///             [String] reactivationTime
  scheduleReactivation(UserAccessEntity accountStatusAccessEntity,
      String reactivationTime) async {
    // Inlined from the removed ScheduleReactivationTimeUseCase.
    final Either<Failure, dynamic> result = await repository
        .scheduleReactivationTime(accountStatusAccessEntity, reactivationTime);

    if (result.isRight()) {
      _notifyScheduled(
        email: accountStatusAccessEntity.email,
        title: 'Reactivated Account',
        arabicTitle: ' إعادة تنشيط الحساب',
        body: 'Your account will be reactivated at $reactivationTime.',
        arabicBody:
            'سيتم اعادة تنشيط حسابك في ${dateforamtToArabic(reactivationTime)}.',
      );
      getAccountsStatusEntities();
    }
  }

  /// Method Name: [scheduleDeactivation]
  ///
  /// Purpose: schedule deactivation time for the account.
  ///
  /// Parameters: [UserAccessEntity] accountStatusEntity
  ///            [String] selectedDateTime
  scheduleDeactivation(UserAccessEntity accountStatusEntity,
      String selectedDateTime) async {
    // Inlined from the removed ScheduleDeactivationTimeUseCase.
    final Either<Failure, dynamic> result = await repository
        .scheduleDeactivationTime(accountStatusEntity, selectedDateTime);

    if (result.isRight()) {
      _notifyScheduled(
        email: accountStatusEntity.email,
        title: 'Deactivated Account',
        arabicTitle: 'تم ايقاف حسابك',
        body: 'Your account will be deactivated at $selectedDateTime.',
        arabicBody:
            'سيتم الغاء تنشيط حسابك في ${dateforamtToArabic(selectedDateTime)}.',
      );
      getAccountsStatusEntities();
    }
  }

  /// Bilingual push sent after a schedule write succeeds.
  ///
  /// Both removed use cases wrapped this in a bare `catch (e) {}`; the swallow
  /// is kept so a push failure never breaks the schedule flow, but it now logs
  /// instead of vanishing silently.
  void _notifyScheduled({
    required String email,
    required String title,
    required String arabicTitle,
    required String body,
    required String arabicBody,
  }) {
    try {
      Get.find<AppNotificationCubit>().sendNotification(
        type: 'employee',
        topic: email,
        title: title,
        arabicTitle: arabicTitle,
        body: body,
        arabicBody: arabicBody,
      );
    } catch (e) {
      debugPrint('scheduled-account notification failed: $e');
    }
  }
}