// ****************** FILE INFO ******************
// File Name: crm_template_builder_page.dart
// Purpose: CRM template builder details page inside controls.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_custom_grid_dialog.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_builder_toolbar.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_details_content.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_section_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_state_view.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_statistics_grid.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateBuilderPage extends StatefulWidget {
  const CrmTemplateBuilderPage({
    required this.templateId,
    required this.templateName,
    required this.clientTypeId,
    required this.clientType,
    super.key,
  });

  final String templateId;
  final String templateName;
  final String clientTypeId;
  final String clientType;

  @override
  State<CrmTemplateBuilderPage> createState() => _CrmTemplateBuilderPageState();
}

class _CrmTemplateBuilderPageState extends State<CrmTemplateBuilderPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isReadOnly = true;
  String? _selectedCategory;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.templateId.isNotEmpty && widget.clientTypeId.isNotEmpty) {
      context.read<CrmTemplateBuilderCubit>().init(
            templateId: widget.templateId,
            clientTypeId: widget.clientTypeId,
          );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = _fieldCardCrossAxisCount(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmSectionControls,
        secondTitle: S.current.crmControlTemplates,
        thirdTitle: widget.templateName,
        onFirstTap: () => CrmNavigationHelper.pop(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmTemplateBuilderCubit, CrmTemplateBuilderState>(
          listener: (context, state) {},
          builder: (context, state) {
            final bool isMobile = kpIsPhoneLayout(context);
            final CrmTemplateModel? template = state.template;
            final String templateName = FormatHelper.localizedString(
              englishName: template?.nameEn.isNotEmpty == true
                  ? template!.nameEn
                  : widget.templateName,
              arabicName: template?.nameAr,
            );
            final String templateNameAr = template?.nameAr ?? 'الاسم';

            return CrmTemplateStateView(
              overlayLoading: false,
              isLoading: state.isLoading && state.template == null,
              errorMessage: state.template == null &&
                      state.sections.isEmpty &&
                      state.fields.isEmpty
                  ? state.errorMessage
                  : null,
              onRetry: () => context.read<CrmTemplateBuilderCubit>().init(
                    templateId: widget.templateId,
                    clientTypeId: widget.clientTypeId,
                  ),
              minHeight: MediaQuery.sizeOf(context).height - 160.sp,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.sp,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CrmTemplateStatusButton(
                            initialStatus: _statusLabel(template?.status),
                            onChanged: (String newStatus) =>
                                _confirmTemplateStatus(context, newStatus),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomEditIcon(
                                onTap: () => _showEditTemplateDialog(
                                  context,
                                  nameEn: templateName,
                                  nameAr: templateNameAr,
                                ),
                              ),
                              SizedBox(width: isMobile ? 8.sp : 12.w),
                              CustomDeleteIcon(
                                color: AppColors.red,
                                svgColor: AppColors.black,
                                onTap: () => _confirmRemoveTemplate(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.sp),
                      CrmTemplateSectionShell(
                        title: S.current.crmTemplateDetails,
                        child: CrmTemplateDetailsContent(
                          isReadOnly: _isReadOnly,
                          nameEn: templateName,
                          nameAr: templateNameAr,
                        ),
                      ),
                      SizedBox(height: 24.sp),
                      Text(
                        S.current.crmFieldsAndSections,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 14.sp),
                      CrmTemplateStatisticsGrid(fields: state.fields),
                      SizedBox(height: 24.sp),
                      CrmTemplateBuilderToolbar(
                        searchController: _searchController,
                        onSearch:
                            context.read<CrmTemplateBuilderCubit>().search,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (val) {
                          setState(() => _selectedCategory = val);
                          context
                              .read<CrmTemplateBuilderCubit>()
                              .search(val == 'All' ? '' : val ?? '');
                        },
                        selectedType: _selectedType,
                        onTypeChanged: (val) {
                          setState(() => _selectedType = val);
                          context
                              .read<CrmTemplateBuilderCubit>()
                              .search(val == 'All' ? '' : val ?? '');
                        },
                        sections: state.sections,
                        fieldTypes: state.fieldTypes,
                        onAdd: () => CrmNavigationHelper
                            .navigateToControlTemplateElementForm(
                          context,
                          templateId: widget.templateId,
                          templateName: templateName,
                          clientTypeId: widget.clientTypeId,
                          clientType: widget.clientType,
                        ),
                        onLayout: () =>
                            CrmNavigationHelper.navigateToControlTemplateLayout(
                          context,
                          templateId: widget.templateId,
                          templateName: templateName,
                          clientTypeId: widget.clientTypeId,
                          clientType: widget.clientType,
                        ),
                        onCustomGrid: () => _openCustomGrid(
                          context,
                          state,
                          templateName,
                        ),
                      ),
                      SizedBox(height: 28.sp),
                      // The full-page state view above handles loading and
                      // errors for the whole page (status button included); this
                      // wrapper only keeps the grid/empty area tall.
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height - 460.sp,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: state.filteredSections.isEmpty &&
                                  state.filteredFields.isEmpty
                              ? const Center(child: CrmTemplateEmptyState())
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14.sp,
                                    mainAxisSpacing: 14.sp,
                                    mainAxisExtent: 40.sp,
                                  ),
                                  itemCount: state.filteredSections.length +
                                      state.filteredFields.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < state.filteredSections.length) {
                                      final CrmTemplateSectionModel section =
                                          state.filteredSections[index];
                                      return CrmTemplateSectionCard(
                                        title: FormatHelper.localizedString(
                                          englishName: section.nameEn,
                                          arabicName: section.nameAr,
                                        ),
                                        fieldCount: context
                                            .read<CrmTemplateBuilderCubit>()
                                            .fieldCountForSection(section.id),
                                        onTap: () {
                                          CrmNavigationHelper
                                              .navigateToControlTemplateElementForm(
                                            context,
                                            templateId: widget.templateId,
                                            templateName: templateName,
                                            clientTypeId: widget.clientTypeId,
                                            clientType: widget.clientType,
                                            sectionId: section.id,
                                            isSection: true,
                                          );
                                        },
                                      );
                                    }
                                    final CrmTemplateFieldModel field = state
                                            .filteredFields[
                                        index - state.filteredSections.length];
                                    final CrmFieldTypeModel? fieldType =
                                        _fieldTypeById(
                                            state, field.fieldTypeId);
                                    return CrmTemplateFieldCard(
                                      title: FormatHelper.localizedString(
                                        englishName: field.nameEn,
                                        arabicName: field.nameAr,
                                      ),
                                      fieldTypeLabel: fieldType != null
                                          ? FormatHelper.localizedString(
                                              englishName: fieldType.nameEn,
                                              arabicName: fieldType.nameAr,
                                            )
                                          : _fieldTypeFallback(field),
                                      iconKey: fieldType?.iconKey ??
                                          field.fieldTypeId,
                                      onTap: () {
                                        CrmNavigationHelper
                                            .navigateToControlTemplateElementForm(
                                          context,
                                          templateId: widget.templateId,
                                          templateName: templateName,
                                          clientTypeId: widget.clientTypeId,
                                          clientType: widget.clientType,
                                          fieldId: field.id,
                                          isSection: false,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCustomGrid(
    BuildContext context,
    CrmTemplateBuilderState state,
    String templateName,
  ) {
    final bool isMobile = kpIsPhoneLayout(context);
    if (isMobile) {
      CrmNavigationHelper.navigateToControlTemplateCustomGrid(
        context,
        templateId: widget.templateId,
        templateName: templateName,
        clientTypeId: widget.clientTypeId,
        clientType: widget.clientType,
        cubit: context.read<CrmTemplateBuilderCubit>(),
      );
    } else {
      CrmCustomGridDialog.show(
        context: context,
        sections: state.sections,
        fields: state.fields,
        initialSelectedFieldIds: state.template?.customGridFieldIds ?? const [],
        onSave: (ids) =>
            context.read<CrmTemplateBuilderCubit>().saveCustomGrid(ids),
      );
    }
  }

  String _statusLabel(String? status) {
    final String value = (status ?? '').trim().toLowerCase();
    if (value.isEmpty || value == 'draft' || value == 'inactive') {
      return 'Inactive';
    }
    return value == 'deleted' ? 'Deleted' : 'Active';
  }

  int _fieldCardCrossAxisCount(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1500.sp) return 5;
    if (width >= 1180.sp) return 4;
    return width >= 760.sp ? 3 : 1;
  }

  Future<bool> _confirmTemplateStatus(
    BuildContext context,
    String newStatus,
  ) async {
    final CrmTemplateBuilderCubit cubit =
        context.read<CrmTemplateBuilderCubit>();
    if (_statusLabel(cubit.state.template?.status) == newStatus) return true;

    bool changed = false;
    await CrmControlDialogs.showChangeStatusDialog(
      context: context,
      onConfirm: () async {
        changed = await cubit.updateTemplateStatus(newStatus);
        if (!mounted || !changed) return;
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: S.current.crmSuccessful,
          subtitle: S.current.crmSubmitSuccessfully,
        );
      },
    );
    return changed;
  }

  Future<void> _confirmRemoveTemplate(BuildContext context) async {
    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteTemplate,
      subtitle: S.current.crmDeleteTemplateSubtitle,
      onConfirm: () async {
        final bool removed = await this
            .context
            .read<CrmTemplateBuilderCubit>()
            .updateTemplateStatus('Deleted');
        if (!mounted || !removed) return;
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: S.current.crmSuccessful,
          subtitle: S.current.crmRemovedSuccessfully,
        );
      },
    );
  }

  Future<void> _showEditTemplateDialog(
    BuildContext context, {
    required String nameEn,
    required String nameAr,
  }) async {
    await CrmControlDialogs.showEditTemplateDialog(
      context: context,
      nameEn: nameEn,
      nameAr: nameAr,
      onConfirm: (String updatedNameEn, String updatedNameAr) {
        _updateTemplateNames(context, updatedNameEn, updatedNameAr);
      },
    );
  }

  Future<void> _updateTemplateNames(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    final bool updated = await context
        .read<CrmTemplateBuilderCubit>()
        .updateTemplateNames(nameEn: nameEn, nameAr: nameAr);
    if (!mounted || !updated) return;
    setState(() => _isReadOnly = true);
    await CrmControlDialogs.showSuccessDialog(
      context: this.context,
      title: S.current.crmSuccessful,
      subtitle: S.current.crmSubmitSuccessfully,
    );
  }

  CrmFieldTypeModel? _fieldTypeById(
    CrmTemplateBuilderState state,
    String fieldTypeId,
  ) {
    try {
      return state.fieldTypes.firstWhere((type) => type.id == fieldTypeId);
    } catch (_) {
      return null;
    }
  }

  String _fieldTypeFallback(CrmTemplateFieldModel field) =>
      field.fieldTypeId.trim().isEmpty
          ? S.current.crmFieldType
          : field.fieldTypeId;
}
