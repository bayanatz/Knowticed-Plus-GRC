/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_owners_tab.dart
/// Purpose: Control Owners tab body for GrcModuleDetailsPage. Renders the owner
///          request buttons, search, department filter, add/bulk-upload action,
///          and the owner list for a single GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_page.dart';
import 'package:grc_module/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:grc_module/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:grc_module/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart';
import 'package:grc_module/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart';
import 'package:grc_module/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:grc_module/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/features/grc/module/presentation/ui/widgets/grc_module_person_card.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/core/custom/messaging_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:grc_module/generated/l10n.dart';

/// class name: [GrcModuleOwnersTab]
///
/// purpose: Control Owners tab for a single [GRCModuleEntity]. Reads the
///          provided [OwnerCubit] from the widget tree and owns its own search
///          and department-filter state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModuleOwnersTab extends StatefulWidget {
  final GRCModuleEntity module;

  const GrcModuleOwnersTab({super.key, required this.module});

  @override
  State<GrcModuleOwnersTab> createState() => _GrcModuleOwnersTabState();
}

class _GrcModuleOwnersTabState extends State<GrcModuleOwnersTab> {
  final _ownerSearchController = TextEditingController();
  final GlobalKey _addOwnerButtonKey = GlobalKey();
  String _ownerSearchQuery = '';
  String? _ownerDepartmentFilter;

  @override
  void dispose() {
    _ownerSearchController.dispose();
    super.dispose();
  }

  Future<void> _showOwnerCreationMenu(BuildContext context) async {
    final buttonBox =
        _addOwnerButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(value: 'add', child: Text(S.of(context).addOwner)),
        PopupMenuItem(value: 'bulk', child: Text(S.of(context).bulkUpload)),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddOwnerPage(
            moduleId: widget.module.moduleId,
            moduleNameEn: widget.module.moduleNameEn,
            moduleNameAr: widget.module.moduleNameAr,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    } else if (choice == 'bulk') {
      final ownerCubit = context.read<OwnerCubit>();
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
            moduleId: widget.module.moduleId,
            assigneeLabel: S.of(context).controlOwner,
            createAssignee: ({
              required moduleId,
              required email,
              required assigningControls,
              required editorId,
            }) {
              return ownerCubit.createOwner(
                moduleId: moduleId,
                ownerEmail: email,
                assigningControls: assigningControls,
              );
            },
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    }
  }

  List<OwnerEntity> _applyOwnerFilters(
      BuildContext context, List<OwnerEntity> owners) {
    var result = owners;
    if (_ownerDepartmentFilter != null && _ownerDepartmentFilter!.isNotEmpty) {
      result = result.where((o) {
        final employee = findEmployeeByEmail(o.ownerEmail);
        if (employee == null) return false;
        final department = EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context);
        return department == _ownerDepartmentFilter;
      }).toList();
    }
    if (_ownerSearchQuery.isNotEmpty) {
      final q = _ownerSearchQuery.toLowerCase();
      result = result
          .where((o) =>
              employeeDisplayName(context, o.ownerEmail)
                  .toLowerCase()
                  .contains(q) ||
              o.ownerEmail.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        final owners =
            state is OwnerListLoaded ? state.owners : <OwnerEntity>[];
        final filtered = _applyOwnerFilters(context, owners);
        final departmentController = Get.find<MainCoreDepartmentCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  buttonText: S.of(context).myRequests,
                  width: 110.w,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          onlyRequestedBy: currentGrcUserEmail(),
                          typeFilter: GrcRequestType.reassignOwner,
                        ),
                      ),
                    );
                  },
                ),
                CustomButton(
                  buttonText: S.of(context).requests,
                  width: 110.w,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          typeFilter: GrcRequestType.reassignOwner,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              spacing: 10.w,
              children: [
                Expanded(
                  child: AppSearchTextField(
                    onChanged: (v) => setState(() => _ownerSearchQuery = v),
                    hintText: S.of(context).search,
                    controller: _ownerSearchController,
                  ),
                ),
                SizedBox(
                  width: 160.w,
                  child: CustomDropdown<String>(
                    hint: S.of(context).department,
                    items: [
                      DropdownItem<String>(value: '', label: S.of(context).all),
                      ...departmentController.departmentIds.map((id) {
                        final label = context.isArabic
                            ? departmentController
                                    .getArabicDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                ''
                            : departmentController
                                    .getEnglishDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                '';
                        return DropdownItem<String>(value: label, label: label);
                      }),
                    ],
                    value: _ownerDepartmentFilter ?? '',
                    onChanged: (v) => setState(
                        () => _ownerDepartmentFilter = v.isEmpty ? null : v),
                    fillColor: AppColors.background,
                    required: false,
                  ),
                ),
                Container(
                  key: _addOwnerButtonKey,
                  child: customButtonWithSvg(
                    colorBorder: AppColors.primary,
                    space: 10.w,
                    widthImage: 16.w,
                    heightImage: 16.h,
                    function: () => _showOwnerCreationMenu(context),
                    title: isTablet ? 'Add Owner' : '',
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    image:
                        'assets/icons_assets/database_builder_assets/plus_head.svg',
                    color: AppColors.primary,
                    svgColor: AppColors.textButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Expanded(child: _buildOwnerList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildOwnerList(
    BuildContext context,
    OwnerState state,
    List<OwnerEntity> owners,
  ) {
    if (state is OwnerLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is OwnerFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (owners.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noControlOwnersFound,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: owners.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) {
          final owner = owners[index];
          return GrcModulePersonCard(
            email: owner.ownerEmail,
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ControlOwnerDetailsPage(
                    owner: owner,
                    module: widget.module,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              if (context.mounted) {
                context
                    .read<OwnerCubit>()
                    .getAllOwners(moduleId: widget.module.moduleId);
              }
            },
          );
        },
      ),
    );
  }
}
