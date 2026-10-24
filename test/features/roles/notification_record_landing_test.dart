/// Module: roles (tests)
///
///*************************** FILE INFO ****************************///
/// File Name: notification_record_landing_test.dart
/// Purpose: A Roles-area notification's View lands on its record (owner,
///          22/10/2026): which tab a record belongs to, and how User Access
///          pins, outlines and offers to unlock the notification's account.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/role_management_module/role_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_access_module/user_access_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_management_module/user_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';

/// Never called: the tests fill the cubit's lists directly.
class _NoRepository implements UserAccessRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserAccessEntity _account(
  String id,
  String email,
  String name, {
  EmployeeStatusEnum status = EmployeeStatusEnum.active,
  String department = 'd1',
}) {
  return UserAccessEntity(
    employeeId: id,
    email: email,
    status: status,
    firstLogin: null,
    lastLogin: null,
    tempPassword: '',
    reactivationDate: null,
    englishName: name,
    arabicName: name,
    department: department,
    arabicTitle: '',
    englishTitle: 'Engineer',
    expirationTimeOfPassword: '',
    photoUrl: null,
    deactivationDate: null,
    expirationTimeUnit: '',
  );
}

PendingNotificationRecord _record(String pageKey) =>
    PendingNotificationRecord(recordId: 'x', pageKey: pageKey);

void main() {
  group('RoleScreen.tabForRecord', () {
    test('Role Management pages open tab 0', () {
      for (final RoleManagementNotificationPage p
          in RoleManagementNotificationPage.values) {
        expect(RoleScreen.tabForRecord(_record(p.key)), 0, reason: p.key);
      }
    });

    test('User Management pages open tab 1', () {
      for (final UserManagementNotificationPage p
          in UserManagementNotificationPage.values) {
        expect(RoleScreen.tabForRecord(_record(p.key)), 1, reason: p.key);
      }
    });

    test('User Access pages open tab 2', () {
      for (final UserAccessNotificationPage p
          in UserAccessNotificationPage.values) {
        expect(RoleScreen.tabForRecord(_record(p.key)), 2, reason: p.key);
      }
    });

    test('an unknown page opens no record', () {
      expect(RoleScreen.tabForRecord(_record('SomethingElse')), isNull);
    });
  });

  group('UserAccessCubit.focusAccount', () {
    late UserAccessCubit cubit;

    setUp(() {
      cubit = UserAccessCubit(repository: _NoRepository());
      cubit.accountStatusEntities = {
        EmployeeStatusEnum.all: [
          _account('1', 'a@x.com', 'Ali'),
          _account('2', 'b@x.com', 'Badr', department: 'd2'),
          _account('3', 'C@x.com', 'Caro',
              status: EmployeeStatusEnum.lockedWithRequest),
        ],
        EmployeeStatusEnum.active: [_account('1', 'a@x.com', 'Ali')],
      };
    });

    tearDown(() => cubit.close());

    test('clears filters and pins the account to the top', () {
      cubit.selectedStatus = EmployeeStatusEnum.active;
      cubit.selectedDepartment = 'd1';
      cubit.searchTerm = 'Ali';

      cubit.focusAccount('b@x.com');

      expect(cubit.selectedStatus, EmployeeStatusEnum.all);
      expect(cubit.selectedDepartment, isNull);
      expect(cubit.searchTerm, '');
      expect(cubit.filteredSortedSelectedEntities.first.employeeId, '2');
      expect(
          cubit.isFocused(cubit.filteredSortedSelectedEntities.first), isTrue);
      expect(cubit.filteredSortedSelectedEntities, hasLength(3));
    });

    test('matches the email case-insensitively, or the employee id', () {
      cubit.focusAccount('c@X.com');
      expect(cubit.filteredSortedSelectedEntities.first.employeeId, '3');

      cubit.focusAccount('2');
      expect(cubit.filteredSortedSelectedEntities.first.employeeId, '2');
    });

    test('a locked account is offered for unlocking once', () {
      cubit.focusAccount('c@x.com');
      expect(cubit.takeAccountToUnlock()?.employeeId, '3');
      expect(cubit.takeAccountToUnlock(), isNull);
    });

    test('an active account is not offered for unlocking', () {
      cubit.focusAccount('a@x.com');
      expect(cubit.takeAccountToUnlock(), isNull);
    });

    test('picking another status clears the focus', () {
      cubit.focusAccount('b@x.com');
      cubit.selectStatus(EmployeeStatusEnum.all);
      expect(cubit.focusedAccount, isNull);
      expect(cubit.filteredSortedSelectedEntities.first.employeeId, '1');
    });
  });
}
