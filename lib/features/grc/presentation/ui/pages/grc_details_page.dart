/// Module: GRC Module Management
/// Description: Provides the details page UI for viewing, creating, editing,
///              and restoring GRC Module records.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: flutter_bloc, GRCModuleCubit, GRCModuleEntity, get_it
/// Revision History: 2026-06-28 - Initial creation
///                    2026-06-30 - Connected to GRCModuleCubit (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_details_page.dart
/// Purpose: Contains the GovernanceRiskAndComplianceDetails page, which
///          handles view, create, edit, and restore modes for a GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'dart:io';

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/46_custom_image_picker.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_module_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_bottom_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_status_switch.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// enum name: [GrcPageMode]
///
/// purpose: describes the active interaction mode of
///          [GovernanceRiskAndComplianceDetails] so the page can show the
///          correct widgets and route user actions to the right cubit call.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
enum GrcPageMode { view, edit, create, restore }

/// class name: [GovernanceRiskAndComplianceDetails]
///
/// purpose: stateful page that handles all CRUD modes for a single GRC Module.
///          Receives an optional [entity] to pre-fill the form in view / edit /
///          restore modes, and delegates every action to [GRCModuleCubit].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GovernanceRiskAndComplianceDetails extends StatefulWidget {
  final GrcPageMode mode;

  /// Entity to pre-fill the form in view / edit / restore modes.
  /// Null when [mode] is [GrcPageMode.create].
  final GRCModuleEntity? entity;
  final bool autoDelete;

  const GovernanceRiskAndComplianceDetails({
    super.key,
    this.mode = GrcPageMode.create,
    this.entity,
    this.autoDelete = false,
  });

  @override
  State<GovernanceRiskAndComplianceDetails> createState() =>
      _GovernanceRiskAndComplianceDetailsState();
}

class _GovernanceRiskAndComplianceDetailsState
    extends State<GovernanceRiskAndComplianceDetails> {
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();

  String? _selectedDepartment;
  DateTime? _activationDate;
  bool _statusValue = true;
  late GrcPageMode _currentMode;
  List<String> _selectedOwnerIds = [];
  File? _imageFile;
  bool _submitted = false;
  bool _autoDeleteScheduled = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _prefillFromEntity(widget.entity);
  }

  /// Populate form fields from an existing entity (view / edit / restore modes).
  void _prefillFromEntity(GRCModuleEntity? entity) {
    if (entity == null) return;
    _nameEnController.text = entity.grcModuleNameEnglish;
    _nameArController.text = entity.grcModuleNameArabic;
    _descEnController.text = entity.descriptionEnglish;
    _descArController.text = entity.descriptionArabic;
    _selectedDepartment = entity.owningDepartment;
    _activationDate = entity.activationDate;
    _statusValue = entity.status == 'Active';
    _selectedOwnerIds = List.from(entity.owners);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _submitted = true);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _nameEnController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _descEnController.text.trim().isNotEmpty &&
        _descArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameEnController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_descEnController.text) &&
        !containsEnglishLetters(_descArController.text) &&
        _selectedDepartment != null &&
        _activationDate != null &&
        !_activationDate!.isBefore(startOfToday);
  }

  // ── Cubit action helpers ──────────────────────────────────────────────────

  void _onCreate(GRCModuleCubit cubit) {
    cubit.createModule(
      grcModuleNameEnglish: _nameEnController.text.trim(),
      grcModuleNameArabic: _nameArController.text.trim(),
      descriptionEnglish: _descEnController.text.trim(),
      descriptionArabic: _descArController.text.trim(),
      owningDepartment: _selectedDepartment ?? '',
      activationDate: _activationDate ?? DateTime.now(),
      owners: _selectedOwnerIds,
      status: _statusValue ? 'Active' : 'Inactive',
      imageFile: _imageFile,
    );
  }

  void _onUpdate(GRCModuleCubit cubit) {
    cubit.updateModule(
      id: widget.entity!.id,
      grcModuleNameEnglish: _nameEnController.text.trim(),
      grcModuleNameArabic: _nameArController.text.trim(),
      descriptionEnglish: _descEnController.text.trim(),
      descriptionArabic: _descArController.text.trim(),
      owningDepartment: _selectedDepartment,
      activationDate: _activationDate,
      owners: _selectedOwnerIds,
      status: _statusValue ? 'Active' : 'Inactive',
      imageFile: _imageFile,
    );
  }

  void _onDelete(GRCModuleCubit cubit) {
    cubit.deleteModule(id: widget.entity!.id);
  }

  void _onRestore(GRCModuleCubit cubit) {
    cubit.restoreModule(id: widget.entity!.id);
  }

  void _scheduleAutoDelete(BuildContext context, GRCModuleCubit cubit) {
    if (!widget.autoDelete || _autoDeleteScheduled || widget.entity == null) {
      return;
    }
    _autoDeleteScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showConfirmDialog(
        context: context,
        title: "Deleting GRC Module".tr,
        cancelLabel: "No".tr,
        confirmLabel: "Yes".tr,
        iconWidget: SvgPicture.asset('assets/icons/delete_icon.svg'),
        subtitle: "Are You Sure You Want To Delete This GRC Module ?".tr,
        onConfirm: () {
          _pendingAction = _PendingAction.delete;
          _onDelete(cubit);
        },
      );
    });
  }

  // ── State listener ────────────────────────────────────────────────────────

  void _onStateChange(BuildContext context, GRCModuleState state) {
    if (state is GRCModuleLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is GRCModuleActionSuccess) {
      final isDelete = _pendingAction == _PendingAction.delete;
      final isRestore = _pendingAction == _PendingAction.restore;
      final isCreate = _currentMode == GrcPageMode.create;

      showSuccessDialog(
        context: context,
        title: isDelete
            ? "Deleted GRC Module".tr
            : isRestore
                ? "Restored Modules".tr
                : isCreate
                    ? "Created Modules".tr
                    : "Edited Modules".tr,
        subtitle: isDelete
            ? "You Successfully Deleted This Module".tr
            : isRestore
                ? "You Successfully Restored This Module".tr
                : isCreate
                    ? "You Successfully Created This GRC Module".tr
                    : "You Successfully Edited This Module".tr,
      );
      // pop with true so the list page knows to reload
      Navigator.of(context).pop(true);
      return;
    }

    if (state is GRCModuleFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  _PendingAction _pendingAction = _PendingAction.none;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GRCModuleCubit>(),
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<GRCModuleCubit>();
          _scheduleAutoDelete(ctx, cubit);
          return BlocListener<GRCModuleCubit, GRCModuleState>(
            listener: _onStateChange,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          if (_currentMode == GrcPageMode.create)
                            'Create New GRC Module'.tr
                          else if (_currentMode == GrcPageMode.edit)
                            'Edit GRC Module'.tr
                          else
                            'GRC Module'.tr,
                        ],
                      ),
                      if (_currentMode == GrcPageMode.view)
                        GrcActionButtons(
                          onEditTap: () =>
                              setState(() => _currentMode = GrcPageMode.edit),
                          onDeleteTap: () {
                            _pendingAction = _PendingAction.delete;
                            _onDelete(cubit);
                          },
                        ),
                      if (_currentMode == GrcPageMode.edit)
                        GrcStatusSwitch(
                          value: _statusValue,
                          onToggle: (v) {
                            showConfirmDialog(
                                context: context,
                                title: "Changing Status".tr,
                                cancelLabel: "No".tr,
                                confirmLabel: "Yes".tr,
                                iconWidget: SvgPicture.asset('assets/des.svg'),
                                subtitle:
                                    "Are You Sure You Want To Change The Status Of This Module ?"
                                        .tr,
                                onConfirm: () {
                                  setState(() => _statusValue = v);
                                });
                          },
                        ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IgnorePointer(
                                    ignoring: _currentMode ==
                                            GrcPageMode.view ||
                                        _currentMode == GrcPageMode.restore,
                                    child: CustomImagePicker(
                                      imageUrl: widget.entity?.image,
                                      imageFile: _imageFile,
                                      onImagePicked: (file) =>
                                          setState(() => _imageFile = file),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  GrcFormFields(
                                    nameEnController: _nameEnController,
                                    nameArController: _nameArController,
                                    descEnController: _descEnController,
                                    descArController: _descArController,
                                    selectedDepartment: _selectedDepartment,
                                    activationDate: _activationDate,
                                    submitted: _submitted,
                                    readOnly:
                                        _currentMode == GrcPageMode.view ||
                                            _currentMode == GrcPageMode.restore,
                                    onDepartmentChanged: (v) =>
                                        setState(() => _selectedDepartment = v),
                                    onDateChanged: (v) =>
                                        setState(() => _activationDate = v),
                                  ),
                                  SizedBox(height: 20.h),
                                  GrcOwnerSection(
                                    isViewMode: (_currentMode ==
                                            GrcPageMode.view ||
                                        _currentMode == GrcPageMode.restore),
                                    initialOwnerIds: _selectedOwnerIds,
                                    selectedDepartmentId: _selectedDepartment,
                                    onOwnersChanged: (selected) {
                                      _selectedOwnerIds =
                                          selected.map((o) => o.id).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GrcBottomButtons(
                        mode: _currentMode,
                        validate: (_currentMode == GrcPageMode.create ||
                                _currentMode == GrcPageMode.edit)
                            ? _validate
                            : null,
                        onDiscard: _currentMode == GrcPageMode.create
                            ? () => Navigator.pop(context)
                            : () =>
                                setState(() => _currentMode = GrcPageMode.view),
                        onAction: () {
                          if (_currentMode == GrcPageMode.create) {
                            _pendingAction = _PendingAction.create;
                            _onCreate(cubit);
                          } else if (_currentMode == GrcPageMode.edit) {
                            _pendingAction = _PendingAction.update;
                            _onUpdate(cubit);
                          } else if (_currentMode == GrcPageMode.restore) {
                            _pendingAction = _PendingAction.restore;
                            _onRestore(cubit);
                          }
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tracks which cubit action was last dispatched so the success listener
/// can build the correct dialog title / subtitle.
enum _PendingAction { none, create, update, delete, restore }
