import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/small_drop_down.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/DatePicker.dart';
import 'package:demo_app/features/roles/widgets/confirm_dialog.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/onboarding/authentication/domain/enums/employee_status_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/user_access_permission.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';
import 'edit_dialog_box.dart';
import 'schedule_activation.dart';
import 'schedule_deactivation.dart';

class ActionDropdown extends StatefulWidget {
  ActionDropdown({required this.accountStatusEntity});
  AccountStatusAccessEntity accountStatusEntity;

  @override
  State<ActionDropdown> createState() => _ActionDropdownState();
}

class _ActionDropdownState extends State<ActionDropdown> {
  late AccountStatusCubit controller;
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    controller = context.read<AccountStatusCubit>();
    final options = _getOptionsForStatus();

    // If no options available, don't show dropdown at all
    if (options.isEmpty) {
      return SizedBox.shrink();
    }

    return SizedBox(
      width: 30.sp,
      height: 12.sp,
      child: SmallDropdown(
          yOffset: context.isArabic ? 130.sp : -130.sp,
          fillColor: Colors.transparent,
          menuWidth: 160.sp,
          svgIconPath: 'assets/icons/three_dots.svg',
          onChanged: (selectedOption) async {
            await applyAction(selectedOption, context);
            setState(() {
              this.selectedOption = _getOptionsForStatus().isNotEmpty
                  ? _getOptionsForStatus().first
                  : null;
            });
          },
          value: selectedOption,
          items: options.map((String action) {
            return DropdownMenuItem<String>(
              value: action,
              child: Text(
                FormatHelper.capitalize(action.tr),
                style: AppTextStyles.font14SecondaryBlackCairo,
              ),
            );
          }).toList(),
          textButton: ''),
    );
  }

  List<String> _getOptionsForStatus() {
    List<String> options = [];

    // Check permissions
    final hasEditAccessPermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.changeDefaultPassword, // Use existing permission or create new one
    ) || Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.changeExpirationDate,
    );

    final hasDeactivatePermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.deactivateUser,
    );

    final hasReactivePermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.reactiveUser,
    );

    final hasUnlockPermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.unlockUserAccount,
    );

    final hasScheduleDeactivatePermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.scheduleToDeactivate,
    );

    final hasScheduleReactivatePermission = Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: UserAccess.scheduleToReactivate,
    );

    // Add Edit option at the top
    if (hasEditAccessPermission) {
      options.add("Edit");
    }

    // Build options based on status and permissions
    if (widget.accountStatusEntity.willBeDeactivated) {
      if (hasScheduleDeactivatePermission) {
        options.add('Edit Schedule');
      }
      if (hasDeactivatePermission) {
        options.add("Deactivate Now");
        options.add("Cancel Deactivation");
      }
    } else if (widget.accountStatusEntity.willBeActivated) {
      if (hasScheduleReactivatePermission) {
        options.add("Edit Schedule");
      }
      if (hasReactivePermission) {
        options.add("Reactivate Now");
        options.add("Cancel Reactivation");
      }
    } else if (widget.accountStatusEntity.status == EmployeeStatusEnum.active) {
      if (hasDeactivatePermission) {
        options.add("Deactivate");
      }
    } else if (widget.accountStatusEntity.status == EmployeeStatusEnum.deactivated) {
      if (hasReactivePermission) {
        options.add("Active");
      }
    } else if (widget.accountStatusEntity.status == EmployeeStatusEnum.inactive) {
      if (hasDeactivatePermission) {
        options.add("Deactivate");
      }
    } else if (widget.accountStatusEntity.status == EmployeeStatusEnum.locked) {
      if (hasUnlockPermission) {
        options.add("Unlock");
      }
    }

    return options;
  }

  Future<void> applyAction(String selectedOption, BuildContext context) async {
    if (selectedOption == 'Edit') {
      // Show edit access details dialog
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: BlocProvider<AccountStatusCubit>.value(
              value: controller,
              child: EditAccessDetailsDialog(
                accountStatusEntity: widget.accountStatusEntity,
              ),
            ),
          );
        },
      );
    } else if (selectedOption == 'Deactivate') {
      ConfirmDialog().show(context,
          title: 'Deactivating User Account'.tr,
          subtitle: 'Are You Sure You Want To Deactivate This Account?'.tr,
          icon: 'assets/lottie/Edit Document.json',
          onConfirm: () {
            controller.updateAccountStatus(widget.accountStatusEntity);
          },
          onConfirmText: 'Continue'.tr,
          onCancelText: 'Schedule'.tr,
          onCancel: () async {
            // Check permission before showing schedule dialog
            if (Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.roles,
              section: RolePermissionsSections.userAccess,
              permission: UserAccess.scheduleToDeactivate,
            )) {
              showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      child: BlocProvider<AccountStatusCubit>.value(
                        value: controller,
                        child: ScheduleDeactivation(
                          selectedDate: widget.accountStatusEntity.deactivationDate,
                          accountStatusAccessEntity: widget.accountStatusEntity,
                        ),
                      ),
                    );
                  });
            }
          });
    } else if (selectedOption == 'Active') {
      ConfirmDialog().show(context,
          title: 'Activating User Account'.tr,
          subtitle: 'Are You Sure You Want To Activate This Account?'.tr,
          icon: 'assets/lottie/Edit Document.json',
          onConfirm: () {
            controller.updateAccountStatus(widget.accountStatusEntity);
          },
          onConfirmText: 'Continue'.tr,
          onCancelText: 'Schedule'.tr,
          onCancel: () async {
            // Check permission before showing schedule dialog
            if (Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.roles,
              section: RolePermissionsSections.userAccess,
              permission: UserAccess.scheduleToReactivate,
            )) {
              showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      child: BlocProvider<AccountStatusCubit>.value(
                        value: controller,
                        child: ScheduleActivation(
                          selectedDate: widget.accountStatusEntity.reactivationDate!,
                          accountStatusAccessEntity: widget.accountStatusEntity,
                        ),
                      ),
                    );
                  });
            }
          });
    } else if (selectedOption == 'Edit Schedule' &&
        widget.accountStatusEntity.willBeDeactivated) {
      showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              child: BlocProvider<AccountStatusCubit>.value(
                value: controller,
                child: ScheduleDeactivation(
                  selectedDate: widget.accountStatusEntity.deactivationDate,
                  accountStatusAccessEntity: widget.accountStatusEntity,
                ),
              ),
            );
          });
    } else if (selectedOption == 'Edit Schedule' &&
        widget.accountStatusEntity.willBeActivated) {
      showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              child: BlocProvider<AccountStatusCubit>.value(
                value: controller,
                child: ScheduleActivation(
                  selectedDate: widget.accountStatusEntity.reactivationDate!,
                  accountStatusAccessEntity: widget.accountStatusEntity,
                ),
              ),
            );
          });
    } else if (selectedOption == "Deactivate Now") {
      controller.updateAccountStatus(widget.accountStatusEntity);
    } else if (selectedOption == "Reactivate Now") {
      controller.updateAccountStatus(widget.accountStatusEntity);
    } else if (selectedOption == "Cancel Deactivation") {
      widget.accountStatusEntity.status = EmployeeStatusEnum.deactivated;
      controller.updateAccountStatus(widget.accountStatusEntity);
    } else if (selectedOption == "Cancel Reactivation") {
      widget.accountStatusEntity.status = EmployeeStatusEnum.active;
      controller.updateAccountStatus(widget.accountStatusEntity);
    } else if (selectedOption == "Unlock") {
      controller.updateAccountStatus(widget.accountStatusEntity);
    }
  }
}