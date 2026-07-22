import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/update_champion_usecase.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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

  // Dropdowns for adding more controls to reassign
  String? _selectedPolicyId;
  List<String> _selectedControlIds = [];
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

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees = Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(employee: employee, context: context);
  }

  ControlEntity? _getControlEntity(String policyId, String controlId) {
    final list = widget.policyControls[policyId];
    if (list != null) {
      for (final c in list) {
        if (c.id == controlId) return c;
      }
    }
    return null;
  }

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addControls() {
    if (_selectedPolicyId == null || _selectedControlIds.isEmpty) return;

    setState(() {
      for (final cid in _selectedControlIds) {
        final exists = _reassignedControls.any((ac) => ac.policyId == _selectedPolicyId && ac.controlId == cid);
        if (!exists) {
          _reassignedControls.add(AssigningControlEntity(
            policyId: _selectedPolicyId!,
            controlId: cid,
          ));
        }
      }
      _selectedControlIds = [];
    });
  }

  void _removeControl(int index) {
    setState(() {
      _reassignedControls.removeAt(index);
    });
  }

  Future<void> _submit() async {
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

    final newChampionEmail = _newSelectedEmployees.first.email;
    if (newChampionEmail == widget.champion.championEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New champion cannot be the current champion'.tr)),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final editor = _currentUserEmail;

      // 1. Update Current Champion: remove reassigned controls
      final remainingControls = widget.champion.assigningControls.where((ac) {
        return !_reassignedControls.any((rc) => rc.policyId == ac.policyId && rc.controlId == ac.controlId);
      }).toList();

      final updateCurrentResult = await GetIt.instance<UpdateChampionUseCase>().call(
        UpdateChampionParams(
          championEmail: widget.champion.championEmail,
          moduleId: widget.module.moduleId,
          editorId: editor,
          assigningControls: remainingControls,
          status: remainingControls.isEmpty ? ChampionStatus.removed : null,
        ),
      );

      bool updateCurrentSuccess = false;
      updateCurrentResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update current champion: ${failure.message}')),
          );
        },
        (_) => updateCurrentSuccess = true,
      );

      if (!updateCurrentSuccess) {
        setState(() => _submitting = false);
        return;
      }

      // 2. Fetch or Create/Update New Champion
      final newChampionGetResult = await GetIt.instance<GetChampionUseCase>().call(
        newChampionEmail,
        moduleId: widget.module.moduleId,
      );

      bool success = false;
      await newChampionGetResult.fold(
        (failure) async {
          // If not found, create new
          final createResult = await GetIt.instance<CreateChampionUseCase>().call(
            CreateChampionParams(
              moduleId: widget.module.moduleId,
              championEmail: newChampionEmail,
              assigningControls: _reassignedControls,
              editorId: editor,
            ),
          );
          createResult.fold(
            (fail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create new champion: ${fail.message}')),
              );
            },
            (_) => success = true,
          );
        },
        (existingChampion) async {
          // If exists, update by merging controls
          final mergedControls = List<AssigningControlEntity>.from(existingChampion.assigningControls);
          for (final rc in _reassignedControls) {
            final exists = mergedControls.any((ac) => ac.policyId == rc.policyId && ac.controlId == rc.controlId);
            if (!exists) {
              mergedControls.add(rc);
            }
          }
          final updateResult = await GetIt.instance<UpdateChampionUseCase>().call(
            UpdateChampionParams(
              championEmail: newChampionEmail,
              moduleId: widget.module.moduleId,
              editorId: editor,
              assigningControls: mergedControls,
              status: ChampionStatus.active, // Restore if it was removed
            ),
          );
          updateResult.fold(
            (fail) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update new champion: ${fail.message}')),
              );
            },
            (_) => success = true,
          );
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Champion reassigned successfully'.tr)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
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
    final currentEmp = _findEmployee(widget.champion.championEmail);
    final currentPhoto = currentEmp != null
        ? EmployeeHelper.getEmployeeImage(employee: currentEmp)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';
    final currentName = _employeeDisplayName(context, widget.champion.championEmail);
    final currentDept = currentEmp != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(employee: currentEmp, context: context)
        : '';
    final currentTitle = currentEmp != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(employee: currentEmp, context: context)?.toString() ?? '')
        : '';

    final availableControlsForPolicy = _selectedPolicyId != null
        ? (widget.policyControls[_selectedPolicyId] ?? [])
        : <ControlEntity>[];

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
                  context.isArabic ? widget.module.moduleNameAr : widget.module.moduleNameEn,
                  'Reassign Control Champion Request'.tr,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // Current Control Champion Section
                      Text('Current Control Champion'.tr, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(color: AppColors.dropShadow, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: currentPhoto.startsWith('http') ? NetworkImage(currentPhoto) : null,
                              child: !currentPhoto.startsWith('http') ? SvgPicture.asset(currentPhoto, width: 22.w, height: 22.h) : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(currentName, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                                  if (currentDept.isNotEmpty)
                                    Text(
                                      '${currentTitle.isNotEmpty ? currentTitle : 'Technician'.tr} • $currentDept',
                                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // New Control Champion Section
                      Text('New Control Champion'.tr, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(color: AppColors.dropShadow, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: GrcOwnerSection(
                          singleSelect: true,
                          onOwnersChanged: (selected) => setState(() => _newSelectedEmployees = selected),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Dates Pickers Section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Date'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                                SizedBox(height: 6.h),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _startDate != null ? dateFormat.format(_startDate!) : 'Choose The Date'.tr,
                                          style: StyleText.fontSize14Weight400.copyWith(
                                            color: _startDate != null ? AppColors.text : AppColors.secondaryText,
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_outlined, size: 16.sp, color: AppColors.secondaryText),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End Date'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                                SizedBox(height: 6.h),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _endDate != null ? dateFormat.format(_endDate!) : 'Choose The Date'.tr,
                                          style: StyleText.fontSize14Weight400.copyWith(
                                            color: _endDate != null ? AppColors.text : AppColors.secondaryText,
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_outlined, size: 16.sp, color: AppColors.secondaryText),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Request Note Section
                      Text('Request Note'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 4,
                        maxLength: 500,
                        onChanged: (v) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Text here'.tr,
                          hintStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText),
                          fillColor: AppColors.background,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          counterText: '${_noteController.text.length}/500',
                          counterStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Assigned Controls List Section
                      Text('Assigned Controls'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 8.h),
                      _reassignedControls.isEmpty
                          ? Text(
                              'No Controls assigned.'.tr,
                              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                            )
                          : Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: List.generate(_reassignedControls.length, (index) {
                                final ac = _reassignedControls[index];
                                final ctrl = _getControlEntity(ac.policyId, ac.controlId);
                                final cName = ctrl != null
                                    ? (context.isArabic ? ctrl.controlsNameAr : ctrl.controlsNameEn)
                                    : ac.controlId;
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(cName, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                                      SizedBox(width: 6.w),
                                      GestureDetector(
                                        onTap: () => _removeControl(index),
                                        child: const Icon(Icons.remove_circle, color: Colors.red, size: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                      SizedBox(height: 20.h),

                      // Assigning Controls Form Section
                      Text('Assigning Controls'.tr, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                      SizedBox(height: 12.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdown<String>(
                                  label: 'Add Policy'.tr,
                                  hint: 'Choose Policy'.tr,
                                  items: widget.allPolicies
                                      .map((p) => DropdownItem<String>(
                                            value: p.id,
                                            label: context.isArabic ? p.policyNameAr : p.policyNameEn,
                                          ))
                                      .toList(),
                                  value: _selectedPolicyId,
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedPolicyId = v;
                                      _selectedControlIds = [];
                                    });
                                  },
                                  fillColor: AppColors.background,
                                  required: false,
                                ),
                                SizedBox(height: 12.h),
                                customButton(
                                  title: '+ Policy'.tr,
                                  function: _addControls,
                                  width: 120.w,
                                  color: AppColors.blackButton,
                                  textStyle: StyleText.fontSize14Weight500.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CustomMultiSelectDropdown<String>(
                              label: 'Control'.tr,
                              hint: 'Choose Control'.tr,
                              enabled: _selectedPolicyId != null,
                              items: availableControlsForPolicy
                                  .map((c) => MultiSelectDropdownItem<String>(
                                        value: c.id,
                                        label: context.isArabic ? c.controlsNameAr : c.controlsNameEn,
                                      ))
                                  .toList(),
                              values: _selectedControlIds,
                              onChanged: (v) => setState(() => _selectedControlIds = v),
                              fillColor: AppColors.background,
                              required: false,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: customButton(
                              title: 'Discard'.tr,
                              function: () => Navigator.pop(context, false),
                              color: AppColors.colorGrey,
                              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: customButton(
                              title: _submitting ? 'Submitting...'.tr : 'Submit'.tr,
                              function: _submitting ? () {} : _submit,
                              color: AppColors.primary,
                              textStyle: StyleText.fontSize16Weight500.copyWith(color: Colors.black),
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
