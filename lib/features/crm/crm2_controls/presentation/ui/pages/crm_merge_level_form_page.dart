// ****************** FILE INFO ******************
// File Name: crm_merge_level_form_page.dart
// Purpose: Multi-mode form page for Add, Details (Readonly), and Edit CRM Merge Level in Controls
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_color_picker.dart';
import 'package:knowticed_plus/features/crm/data/legacy_core/custom/custom_status_dropdown_button_99.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_state.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum CrmMergeLevelFormMode { add, details, edit }

class CrmMergeLevelFormPage extends StatefulWidget {
  final CrmMergeLevelFormMode initialMode;
  final CrmMergeLevelModel? level;

  const CrmMergeLevelFormPage({
    super.key,
    this.initialMode = CrmMergeLevelFormMode.add,
    this.level,
  });

  @override
  State<CrmMergeLevelFormPage> createState() => _CrmMergeLevelFormPageState();
}

class _CrmMergeLevelFormPageState extends State<CrmMergeLevelFormPage> {
  late CrmMergeLevelFormMode _mode;
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _rangeFromController;
  late final TextEditingController _rangeToController;
  CrmMergeLevelModel? _level;
  Color? _selectedColor;
  late bool _isActive;
  String? _nameEnError;
  String? _nameArError;
  String? _rangeFromError;
  String? _rangeToError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _level = widget.level;
    _nameController = TextEditingController(text: _level?.nameEn ?? '');
    _nameArController = TextEditingController(text: _level?.nameAr ?? '');
    _rangeFromController = TextEditingController(
      text: _level != null ? '${_level!.rangeFrom}' : '',
    );
    _rangeToController = TextEditingController(
      text: _level != null ? '${_level!.rangeTo}' : '',
    );
    _selectedColor = _level?.color;
    _isActive = _level?.isActive ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmMergeLevelsCubit>().init();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _rangeFromController.dispose();
    _rangeToController.dispose();
    super.dispose();
  }

  void _validateEn(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameEnError = 'This field is required');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(val)) {
      setState(() => _nameEnError = 'English letters only');
    } else {
      setState(() => _nameEnError = null);
    }
  }

  void _validateAr(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameArError = 'هذا الحقل مطلوب');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(val)) {
      setState(() => _nameArError = 'يرجى إدخال حروف عربية فقط');
    } else {
      setState(() => _nameArError = null);
    }
  }

  void _validateRangeFrom(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _rangeFromError = 'This field is required');
    } else if (double.tryParse(text) == null) {
      setState(() => _rangeFromError = 'Please enter a valid number');
    } else {
      setState(() => _rangeFromError = null);
    }
  }

  void _validateRangeTo(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _rangeToError = 'This field is required');
    } else if (double.tryParse(text) == null) {
      setState(() => _rangeToError = 'Please enter a valid number');
    } else if (double.tryParse(_rangeFromController.text.trim()) != null &&
        double.parse(text) < double.parse(_rangeFromController.text.trim())) {
      setState(
          () => _rangeToError = 'Must be greater than or equal to Range From');
    } else {
      setState(() => _rangeToError = null);
    }
  }

  bool _validateForm() {
    final String en = _nameController.text.trim();
    final String ar = _nameArController.text.trim();
    final String range = _rangeFromController.text.trim();
    final String rangeTo = _rangeToController.text.trim();

    String? enErr;
    String? arErr;
    String? rangeErr;
    String? rangeToErr;

    if (en.isEmpty) {
      enErr = 'This field is required';
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) {
      enErr = 'English letters only';
    }

    if (ar.isEmpty) {
      arErr = 'هذا الحقل مطلوب';
    } else if (RegExp(r'[a-zA-Z]').hasMatch(ar)) {
      arErr = 'يرجى إدخال حروف عربية فقط';
    }

    if (range.isEmpty) {
      rangeErr = 'This field is required';
    } else if (double.tryParse(range) == null) {
      rangeErr = 'Please enter a valid number';
    }
    if (rangeTo.isEmpty) {
      rangeToErr = 'This field is required';
    } else if (double.tryParse(rangeTo) == null) {
      rangeToErr = 'Please enter a valid number';
    } else if (rangeErr == null &&
        double.parse(rangeTo) < double.parse(range)) {
      rangeToErr = 'Must be greater than or equal to Range From';
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
      _rangeFromError = rangeErr;
      _rangeToError = rangeToErr;
    });

    return enErr == null &&
        arErr == null &&
        rangeErr == null &&
        rangeToErr == null;
  }

  String get _fourthTitle {
    switch (_mode) {
      case CrmMergeLevelFormMode.add:
        return S.current.crmMergeAddLikelihoodLevel;
      case CrmMergeLevelFormMode.edit:
      case CrmMergeLevelFormMode.details:
        return S.current.crmMergeLevel;
    }
  }

  void _handleRemove() {
    final CrmMergeLevelModel? level = _level;
    if (level == null) return;

    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemove,
      subtitle: S.current.crmMergeDeleteConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool removed =
            await context.read<CrmMergeLevelsCubit>().removeLevel(level);
        hideLoadingIndicator();
        if (!mounted || !removed) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccessful,
          subtitle: S.current.crmMergeDeletedSuccess,
          onComplete: () => CrmNavigationHelper.pop(context),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_validateForm()) return;

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        final CrmMergeLevelsCubit cubit = context.read<CrmMergeLevelsCubit>();
        showLoadingIndicator();
        bool saved = false;

        final double rangeFrom =
            double.tryParse(_rangeFromController.text.trim()) ?? 0.0;
        final double rangeTo =
            double.tryParse(_rangeToController.text.trim()) ?? 0.0;
        final Color finalColor = _selectedColor ?? const Color(0xFFFFD043);
        final String colorHex = CustomColorPickerField.hexOf(finalColor);

        if (_mode == CrmMergeLevelFormMode.edit && _level != null) {
          saved = await cubit.updateLevel(
            currentLevel: _level!,
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            colorHex: colorHex,
            isActive: _isActive,
          );
          _level = cubit.state.selectedLevel ?? _level;
        } else {
          saved = await cubit.createLevel(
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            colorHex: colorHex,
          );
          _level = cubit.state.selectedLevel;
        }
        hideLoadingIndicator();

        if (!mounted) return;
        if (!saved) {
          CrmControlDialogs.showErrorDialog(
            context: context,
            title: S.current.crmError,
            subtitle: cubit.state.errorMessage ?? S.current.crmMergeSaveFailed,
          );
          return;
        }

        if (_mode == CrmMergeLevelFormMode.edit) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () {
              setState(() {
                _mode = CrmMergeLevelFormMode.details;
              });
            },
          );
        } else {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () => CrmNavigationHelper.pop(context),
          );
        }
      },
    );
  }

  void _handleDiscard() {
    if (_mode == CrmMergeLevelFormMode.edit && _level != null) {
      setState(() {
        _mode = CrmMergeLevelFormMode.details;
        _nameController.text = _level!.nameEn;
        _nameArController.text = _level!.nameAr;
        _rangeFromController.text = _level!.rangeFrom.toString();
        _rangeToController.text = _level!.rangeTo.toString();
        _selectedColor = _level!.color;
        _isActive = _level!.isActive;
        _nameEnError = null;
        _nameArError = null;
        _rangeFromError = null;
        _rangeToError = null;
      });
      return;
    }
    CrmNavigationHelper.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);
    final bool isReadOnly = _mode == CrmMergeLevelFormMode.details;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmSectionMerge,
        fourthTitle: _fourthTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.popToControls(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        onFourthTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmMergeLevelsCubit, CrmMergeLevelsState>(
          builder: (BuildContext context, CrmMergeLevelsState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Details mode action triggers (Status Dropdown on left, Edit & Delete on right)
                  if (_level != null) ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CustomStatusDropdownButton<bool>(
                          value: _isActive,
                          color: _isActive ? AppColors.green : AppColors.orange,
                          textColor: AppColors.white,
                          trailingIconColor: AppColors.white,
                          borderRadius: 8.r,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.sp,
                            vertical: 8.sp,
                          ),
                          items: <StatusDropdownItem<bool>>[
                            StatusDropdownItem<bool>(
                              value: true,
                              label: S.current.crmActive,
                              color: AppColors.green,
                              textColor: AppColors.white,
                            ),
                            StatusDropdownItem<bool>(
                              value: false,
                              label: S.current.crmInactive,
                              color: AppColors.orange,
                              textColor: AppColors.white,
                            ),
                          ],
                          onChanged: (bool val) async {
                            setState(() => _isActive = val);
                            if (isReadOnly && _level != null) {
                              showLoadingIndicator();
                              await context
                                  .read<CrmMergeLevelsCubit>()
                                  .toggleLevelStatus(_level!);
                              hideLoadingIndicator();
                            }
                          },
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            customButtonWithSvg(
                              title: '',
                              function: () => setState(
                                () => _mode = CrmMergeLevelFormMode.edit,
                              ),
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(color: AppColors.blackButton),
                              color: AppColors.primary,
                              colorBorder: AppColors.transparent,
                              image: AppAssets.edit,
                              width: 38.sp,
                              height: 38.sp,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              svgColor: AppColors.black,
                            ),
                            SizedBox(width: 8.sp),
                            customButtonWithSvg(
                              title: '',
                              function: _handleRemove,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(color: AppColors.white),
                              color: AppColors.red,
                              colorBorder: AppColors.transparent,
                              image: AppAssets.delete,
                              width: 38.sp,
                              height: 38.sp,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              svgColor: AppColors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),
                  ],

                  // Form Section Card
                  CrmSectionCard(
                    title: S.current.crmTypeDetails,
                    showHideToggle: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Bilingual Name fields
                        buildResponsiveFields(
                          context: context,
                          left: CustomTextField(
                            label: 'Name',
                            hint: 'Text Here',
                            controller: _nameController,
                            readOnly: isReadOnly,
                            fillColor: AppColors.background,
                            errorText: _nameEnError,
                            onChanged: _validateEn,
                          ),
                          right: Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustomTextField(
                              label: 'اسم',
                              hint: 'اكتب هنا',
                              controller: _nameArController,
                              readOnly: isReadOnly,
                              textAlign: TextAlign.right,
                              fillColor: AppColors.background,
                              errorText: _nameArError,
                              onChanged: _validateAr,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.sp),

                        // Range boundaries
                        buildResponsiveFields(
                          context: context,
                          left: CustomTextField(
                            label: S.current.crmMergeRangeFrom,
                            hint: 'Text Here',
                            controller: _rangeFromController,
                            readOnly: isReadOnly,
                            fillColor: AppColors.background,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _rangeFromError,
                            onChanged: _validateRangeFrom,
                          ),
                          right: CustomTextField(
                            label: S.current.crmMergeRangeTo,
                            hint: 'Text Here',
                            controller: _rangeToController,
                            readOnly: isReadOnly,
                            fillColor: AppColors.background,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _rangeToError,
                            onChanged: _validateRangeTo,
                          ),
                        ),
                        SizedBox(height: 16.sp),

                        // Color Field (Opens Color Picker Dialog)
                        if (isMobile)
                          _buildColorField(isReadOnly)
                        else
                          buildResponsiveFields(
                            context: context,
                            left: _buildColorField(isReadOnly),
                            right: const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),

                  // Bottom Action Buttons (Discard / Add or Save)
                  if (!isReadOnly) ...<Widget>[
                    SizedBox(height: 24.sp),
                    Row(
                      textDirection: TextDirection
                          .ltr, // X-73: Cancel left, action right in both languages

                      children: <Widget>[
                        Expanded(
                          child: customButton(
                            title: S.current.crmDiscard,
                            function: _handleDiscard,
                            color: AppColors.grey,
                            textColor: AppColors.black,
                          ),
                        ),
                        SizedBox(width: 16.sp),
                        Expanded(
                          child: customButton(
                            title: _mode == CrmMergeLevelFormMode.add
                                ? S.current.crmAdd
                                : S.current.crmSave,
                            function: _handleSubmit,
                            color: AppColors.primary,
                            textColor: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Function Name: _buildColorField
  ///
  /// Purpose: Builds the color selector field using [CustomColorPickerField]
  /// which opens a color picker dialog on tap.
  ///
  /// Parameters:
  /// - isReadOnly: Whether the form is currently in read-only details mode.
  ///
  /// Returns: Widget containing the labeled color picker field.
  Widget _buildColorField(bool isReadOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.current.crmMergeColor,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.sp),
        CustomColorPickerField(
          label: S.current.crmMergeChooseColor,
          color: _selectedColor,
          dialogTitle: S.current.crmMergeColor,
          enabled: !isReadOnly,
          onColorSelected: (Color picked) {
            setState(() => _selectedColor = picked);
          },
        ),
      ],
    );
  }
}
