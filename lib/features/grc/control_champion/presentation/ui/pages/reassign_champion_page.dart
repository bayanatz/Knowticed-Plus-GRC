import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ReassignChampionPage extends StatefulWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const ReassignChampionPage({
    super.key,
    required this.champion,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<ReassignChampionPage> createState() => _ReassignChampionPageState();
}

class _ReassignChampionPageState extends State<ReassignChampionPage> {
  List<OwnerData> _newSelectedEmployees = [];
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _noteController = TextEditingController();

  // Controls being reassigned (transferred to the new champion)
  List<AssigningControlEntity> _reassignedControls = [];

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _reassignedControls
  // (and so don't appear as chips under "Assigned Controls") until Submit.
  final List<_PendingAssignmentRow> _pendingRows = [_PendingAssignmentRow()];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reassignedControls = List.from(widget.champion.assigningControls);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addPolicyRow() {
    setState(() {
      _pendingRows.add(_PendingAssignmentRow());
    });
  }

  void _commitPendingRows() {
    for (final row in _pendingRows) {
      if (row.policyId == null || row.controlIds.isEmpty) continue;
      for (final cid in row.controlIds) {
        final exists = _reassignedControls
            .any((ac) => ac.policyId == row.policyId && ac.controlId == cid);
        if (!exists) {
          _reassignedControls.add(AssigningControlEntity(
            policyId: row.policyId!,
            controlId: cid,
          ));
        }
      }
    }
  }

  void _removeControl(int index) {
    setState(() {
      _reassignedControls.removeAt(index);
    });
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _commitPendingRows();
      _pendingRows
        ..clear()
        ..add(_PendingAssignmentRow());
    });

    if (_newSelectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a new Control Champion'.tr)),
      );
      return;
    }
    if (_reassignedControls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please assign at least one Control'.tr)),
      );
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please choose a start date'.tr)),
      );
      return;
    }

    final newChampionEmail = _newSelectedEmployees.first.email;
    if (newChampionEmail == widget.champion.championEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('New champion cannot be the current champion'.tr)),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final requestCubit = context.read<GrcRequestCubit>();
      await requestCubit.createRequest(
        CreateGrcRequestParams(
          moduleId: widget.module.moduleId,
          requestedBy: currentGrcUserEmail(),
          note: _noteController.text,
          currentChampionEmail: widget.champion.championEmail,
          newChampionEmail: newChampionEmail,
          controls: _reassignedControls,
          startDate: _startDate!,
          endDate: _endDate,
        ),
      );

      final state = requestCubit.state;
      if (state is GrcRequestActionSuccess) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted'.tr)),
        );
        Navigator.pop(context, true);
      } else if (state is GrcRequestFailure) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: ${state.message}')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final currentEmp = findEmployeeByEmail(widget.champion.championEmail);
    final currentPhoto = currentEmp != null
        ? EmployeeHelper.getEmployeeImage(employee: currentEmp)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';
    final currentName =
        employeeDisplayName(context, widget.champion.championEmail);
    final currentDept = currentEmp != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: currentEmp, context: context)
        : '';
    final currentTitle = currentEmp != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: currentEmp, context: context)
                ?.toString() ??
            '')
        : '';
    final currentPhone = currentEmp?.mobilePhone?.phone ?? '2010258963';

    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  context.isArabic
                      ? widget.module.moduleNameAr
                      : widget.module.moduleNameEn,
                  'Reassign Control Champion Request'.tr,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Control Champion Section
                            Text('Current Control Champion'.tr,
                                style: StyleText.fontSize16Weight600
                                    .copyWith(color: AppColors.text)),
                            SizedBox(height: 8.h),
                            ContactCard(
                              name: currentName,
                              jobTitle: currentTitle.isNotEmpty
                                  ? currentTitle
                                  : 'Technician'.tr,
                              department: currentDept.isNotEmpty
                                  ? currentDept
                                  : 'IT'.tr,
                              email: widget.champion.championEmail,
                              phone: currentPhone,
                              avatar: currentPhoto.startsWith('http')
                                  ? NetworkImage(currentPhoto)
                                  : null,
                              onMessage: () {},
                            ),
                            SizedBox(height: 20.h),

                            // New Control Champion Section
                            Text('New Control Champion'.tr,
                                style: StyleText.fontSize16Weight600
                                    .copyWith(color: AppColors.text)),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: GrcOwnerSection(
                                singleSelect: true,
                                onOwnersChanged: (selected) => setState(
                                    () => _newSelectedEmployees = selected),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Dates Pickers Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomDropdownCalendar(
                                    label: 'Start Date'.tr,
                                    hint: 'Choose The Date'.tr,
                                    value: _startDate,
                                    onChanged: (d) =>
                                        setState(() => _startDate = d),
                                    fillColor: AppColors.background,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateFormatter: dateFormat.format,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: CustomDropdownCalendar(
                                    label: 'End Date'.tr,
                                    hint: 'Choose The Date'.tr,
                                    value: _endDate,
                                    onChanged: (d) =>
                                        setState(() => _endDate = d),
                                    fillColor: AppColors.background,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    dateFormatter: dateFormat.format,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),

                            // Request Note Section
                            CustomTextField(
                              label: 'Request Note'.tr,
                              hint: 'Text here'.tr,
                              controller: _noteController,
                              maxLines: 4,
                              maxLength: 500,
                              fillColor: AppColors.background,
                              onChanged: (v) => setState(() {}),
                            ),
                            SizedBox(height: 20.h),

                            // Assigned Controls List Section
                            Text('Assigned Controls'.tr,
                                style: StyleText.fontSize14Weight500
                                    .copyWith(color: AppColors.text)),
                            SizedBox(height: 8.h),
                            _reassignedControls.isEmpty
                                ? Text(
                                    'No Controls assigned.'.tr,
                                    style: StyleText.fontSize12Weight400
                                        .copyWith(
                                            color: AppColors.secondaryText),
                                  )
                                : Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.h,
                                    children: List.generate(
                                        _reassignedControls.length, (index) {
                                      final ac = _reassignedControls[index];
                                      final ctrl = findControlInPolicy(
                                          widget.policyControls,
                                          ac.policyId,
                                          ac.controlId);
                                      final cName = ctrl != null
                                          ? (context.isArabic
                                              ? ctrl.controlsNameAr
                                              : ctrl.controlsNameEn)
                                          : ac.controlId;
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.w, vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(24.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(cName,
                                                style: StyleText
                                                    .fontSize14Weight500
                                                    .copyWith(
                                                        color: AppColors.text)),
                                            SizedBox(width: 8.w),
                                            GestureDetector(
                                              onTap: () =>
                                                  _removeControl(index),
                                              child: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                  size: 18),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                            SizedBox(height: 20.h),

                            // Assigning Controls Form Section — one Policy +
                            // Controls picker row per pending assignment. Tapping
                            // "+ Policy" appends another independent row; nothing
                            // here touches "Assigned Controls" until Submit.
                            Text('Assigning Controls'.tr,
                                style: StyleText.fontSize16Weight600
                                    .copyWith(color: AppColors.text)),
                            SizedBox(height: 12.h),
                            ...List.generate(_pendingRows.length, (i) {
                              final row = _pendingRows[i];
                              final availableControlsForPolicy = row.policyId !=
                                      null
                                  ? (widget.policyControls[row.policyId] ?? [])
                                  : <ControlEntity>[];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomDropdown<String>(
                                        label: 'Add Policy'.tr,
                                        hint: 'Choose Policy'.tr,
                                        items: widget.allPolicies
                                            .map((p) => DropdownItem<String>(
                                                  value: p.id,
                                                  label: context.isArabic
                                                      ? p.policyNameAr
                                                      : p.policyNameEn,
                                                ))
                                            .toList(),
                                        value: row.policyId,
                                        onChanged: (v) {
                                          setState(() {
                                            row.policyId = v;
                                            row.controlIds = [];
                                          });
                                        },
                                        fillColor: AppColors.background,
                                        required: false,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: CustomMultiSelectDropdown<String>(
                                        label: 'Control'.tr,
                                        hint: 'Choose Control'.tr,
                                        enabled: row.policyId != null,
                                        items: availableControlsForPolicy
                                            .map((c) =>
                                                MultiSelectDropdownItem<String>(
                                                  value: c.id,
                                                  label: context.isArabic
                                                      ? c.controlsNameAr
                                                      : c.controlsNameEn,
                                                ))
                                            .toList(),
                                        values: row.controlIds,
                                        onChanged: (v) =>
                                            setState(() => row.controlIds = v),
                                        fillColor: AppColors.background,
                                        required: false,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            customButton(
                              title: '+ Policy'.tr,
                              function: _addPolicyRow,
                              width: 120.w,
                              color: AppColors.blackButton,
                              textStyle: StyleText.fontSize14Weight500
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: customButton(
                              title: 'Discard'.tr,
                              function: () => Navigator.pop(context, false),
                              color: AppColors.colorGrey,
                              textStyle: StyleText.fontSize16Weight500
                                  .copyWith(color: AppColors.text),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: customButton(
                              title: _submitting
                                  ? 'Submitting...'.tr
                                  : 'Submit'.tr,
                              function:
                                  _submitting ? () {} : () => _submit(context),
                              color: AppColors.primary,
                              textStyle: StyleText.fontSize16Weight500
                                  .copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One staged Policy + Controls picker row on [ReassignChampionPage].
/// Selections here are local UI state only — see
/// [_ReassignChampionPageState._commitPendingRows].
class _PendingAssignmentRow {
  String? policyId;
  List<String> controlIds = [];
}
