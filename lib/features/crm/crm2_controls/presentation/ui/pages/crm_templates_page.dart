// ****************** FILE INFO ******************
// File Name: crm_templates_page.dart
// Purpose: Templates listing page inside CRM controls with filter, sort and builder navigation
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_controls_template_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_demo_data.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_state_view.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_templates_filter_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplatesPage extends StatefulWidget {
  const CrmTemplatesPage({super.key});

  @override
  State<CrmTemplatesPage> createState() => _CrmTemplatesPageState();
}

class _CrmTemplatesPageState extends State<CrmTemplatesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CrmTemplatesCubit>().init();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmSectionControls,
        secondTitle: S.current.crmControlTemplates,
        onFirstTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmTemplatesCubit, CrmTemplatesState>(
          listener: (context, state) {},
          builder: (context, state) {
            final List<CrmTemplateModel> templates =
                context.read<CrmTemplatesCubit>().visibleTemplates();
            final List<String> tabs = state.clientTypes
                .map((type) => FormatHelper.localizedString(
                      englishName:
                          type.nameEn.isNotEmpty ? type.nameEn : type.title,
                      arabicName: type.nameAr,
                    ))
                .toList();
            final int selectedTabIndex = _selectedTabIndex(state);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tabs.isNotEmpty)
                    CustomTabs(
                      spacing: isMobile ? 16.sp : 32.sp,
                      textStyle: isMobile
                          ? StyleText.fontSize14Weight500
                          : StyleText.fontSize20Weight500,
                      tabs: tabs,
                      selectedValue: selectedTabIndex,
                      onChanged: (int value) {
                        context.read<CrmTemplatesCubit>().selectClientType(
                              state.clientTypes[value].id,
                            );
                      },
                    ),
                  CrmTemplateStateView(
                    isLoading: state.isLoading && state.templates.isEmpty,
                    errorMessage:
                        state.templates.isEmpty ? state.errorMessage : null,
                    onRetry: context.read<CrmTemplatesCubit>().init,
                    overlayLoading: false,
                    minHeight: MediaQuery.sizeOf(context).height - 300.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isMobile ? 14.sp : 22.sp),
                        StatusChipFilter(
                          selectedKey: state.selectedStatus,
                          onSelected: (String key) {
                            context.read<CrmTemplatesCubit>().selectStatus(key);
                          },
                          items: _statusItems(state),
                        ),
                        SizedBox(height: 14.sp),
                        CustomSearchFilterSortBar<String, String>(
                          searchController: _searchController,
                          onSearchChanged:
                              context.read<CrmTemplatesCubit>().search,
                          searchHint: S.current.crmSearch,
                          showFilter: true,
                          isFilterActive: state.isFilterActive,
                          filterTitle: S.current.crmFilter,
                          onFilterTap: () => _showFilterDialog(context, state),
                          showSort: true,
                          selectedSort: state.selectedSort,
                          sortTitle: S.current.crmSort,
                          sortItems: const <String>['Oldest', 'Newest'],
                          sortLabelBuilder: (String value) => value == 'Oldest'
                              ? S.current.crmOldest
                              : S.current.crmNewest,
                          onSortChanged:
                              context.read<CrmTemplatesCubit>().setSort,
                          trailingActionsBuilder:
                              (BuildContext context, bool isPhone) => <Widget>[
                            customButtonWithSvg(
                              title: isPhone
                                  ? ''
                                  : state.isSaving
                                      ? S.current.crmSaving
                                      : S.current.crmAdd,
                              function: state.isSaving || tabs.isEmpty
                                  ? () {}
                                  : () => _showCreateTemplateDialog(context),
                              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.blackButton,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmPlusBold,
                              widthImage: 20.sp,
                              heightImage: 20.sp,
                              colorBorder: AppColors.transparent,
                              svgColor: AppColors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 14.sp),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            final int crossAxisCount =
                                constraints.maxWidth < 650
                                    ? 1
                                    : constraints.maxWidth < 1250
                                        ? 2
                                        : 4;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: isMobile ? 10.sp : 14.sp,
                                mainAxisSpacing: isMobile ? 10.sp : 14.sp,
                                mainAxisExtent: isMobile ? 96.sp : 98.sp,
                              ),
                              itemCount: templates.length,
                              itemBuilder: (BuildContext context, int index) {
                                final CrmTemplateModel template =
                                    templates[index];
                                final CrmClientTypeModel clientType =
                                    _clientTypeForTemplate(state, template);
                                return CrmControlsTemplateCard(
                                  template: _summaryFromTemplate(template),
                                  onTap: () {
                                    final String localizedTemplateName =
                                        FormatHelper.localizedString(
                                      englishName: template.nameEn,
                                      arabicName: template.nameAr,
                                    );
                                    final String localizedClientTypeName =
                                        FormatHelper.localizedString(
                                      englishName: clientType.nameEn.isNotEmpty
                                          ? clientType.nameEn
                                          : clientType.title,
                                      arabicName: clientType.nameAr,
                                    );
                                    CrmNavigationHelper
                                        .navigateToControlTemplateBuilder(
                                      context,
                                      templateId: template.id,
                                      templateName: localizedTemplateName,
                                      clientTypeId: template.clientTypeId,
                                      clientType: localizedClientTypeName,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Function Name: _showFilterDialog
  ///
  /// Purpose: Opens the filter modal dialog for templates
  ///
  /// Parameters:
  /// - context: The BuildContext
  /// - state: The current CrmTemplatesState
  void _showFilterDialog(BuildContext context, CrmTemplatesState state) {
    final CrmTemplatesCubit cubit = context.read<CrmTemplatesCubit>();
    CrmTemplatesFilterDialog.show(
      context,
      initialStatus: state.filterStatus,
      initialCreationDate: state.filterCreationDate,
      initialFieldsCountRange: state.filterFieldsCountRange,
      initialCreatedBy: state.filterCreatedBy,
      availableCreators: cubit.availableCreators,
      onApply: ({
        String? status,
        DateTime? creationDate,
        String? fieldsCountRange,
        String? createdBy,
      }) {
        cubit.applyFilter(
          status: status,
          creationDate: creationDate,
          fieldsCountRange: fieldsCountRange,
          createdBy: createdBy,
        );
      },
    );
  }

  /// Function Name: _showCreateTemplateDialog
  ///
  /// Purpose: Opens dialog to create a new template
  void _showCreateTemplateDialog(BuildContext context) {
    CrmControlDialogs.showAddTemplateDialog(
      context: context,
      onConfirm: (String nameEn, String nameAr) {
        _confirmCreateTemplate(context, nameEn, nameAr);
      },
    );
  }

  /// Function Name: _confirmCreateTemplate
  ///
  /// Purpose: Prompts confirmation dialog before template creation
  Future<void> _confirmCreateTemplate(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    await CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmAddTemplate,
      subtitle: S.current.crmAddTemplateSubtitle,
      onConfirm: () => _createTemplate(context, nameEn, nameAr),
    );
  }

  /// Function Name: _createTemplate
  ///
  /// Purpose: Dispatches template draft creation to cubit
  Future<void> _createTemplate(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    final CrmTemplatesCubit cubit = context.read<CrmTemplatesCubit>();
    showLoadingIndicator();
    await cubit.createTemplateDraft(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    hideLoadingIndicator();
    if (!context.mounted) return;
    await CrmControlDialogs.showSuccessDialog(
      context: context,
      title: S.current.crmSuccessful,
      subtitle: S.current.crmSubmitSuccessfully,
    );
  }

  /// Function Name: _statusItems
  ///
  /// Purpose: Generates status chip items with updated counters
  List<StatusChipItem> _statusItems(CrmTemplatesState state) {
    final Iterable<CrmTemplateModel> scopedTemplates = state.templates.where(
      (template) =>
          state.selectedClientTypeId.isEmpty ||
          template.clientTypeId == state.selectedClientTypeId,
    );
    final int active = scopedTemplates
        .where((template) => template.status.toLowerCase() == 'active')
        .length;
    final int inactive = scopedTemplates
        .where((template) =>
            template.status.toLowerCase() == 'inactive' ||
            template.status.toLowerCase() == 'draft')
        .length;
    return <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: S.current.crmAll,
        count: scopedTemplates.length,
      ),
      StatusChipItem(
        key: 'Active',
        label: S.current.crmTemplateActive,
        count: active,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: S.current.crmTemplateInactive,
        count: inactive,
        labelColor: AppColors.orange,
      ),
      StatusChipItem(
        key: 'Deleted',
        label: S.current.crmTemplateDeleted,
        count: 0,
        labelColor: AppColors.red,
      ),
    ];
  }

  /// Function Name: _selectedTabIndex
  ///
  /// Purpose: Calculates selected index for client types tab
  int _selectedTabIndex(CrmTemplatesState state) {
    final int index = state.clientTypes.indexWhere(
      (type) => type.id == state.selectedClientTypeId,
    );
    return index < 0 ? 0 : index;
  }

  /// Function Name: _clientTypeForTemplate
  ///
  /// Purpose: Finds corresponding client type model for a template
  CrmClientTypeModel _clientTypeForTemplate(
    CrmTemplatesState state,
    CrmTemplateModel template,
  ) {
    return state.clientTypes.firstWhere(
      (type) => type.id == template.clientTypeId,
      orElse: () => CrmClientTypeModel(
        id: template.clientTypeId,
        title: 'Individuals',
        svgAsset: '',
      ),
    );
  }

  /// Function Name: _summaryFromTemplate
  ///
  /// Purpose: Converts template model to summary card view data
  CrmTemplateSummaryData _summaryFromTemplate(CrmTemplateModel template) {
    return CrmTemplateSummaryData(
      name: FormatHelper.localizedString(
        englishName: template.nameEn,
        arabicName: template.nameAr,
      ),
      author: template.audit.createdBy.isEmpty
          ? template.audit.updatedBy
          : template.audit.createdBy,
      createdAt: _formatDate(template.audit.createdAt),
      fieldCount: template.fieldCount,
      status: _statusLabel(template.status),
    );
  }

  /// Function Name: _statusLabel
  ///
  /// Purpose: Normalizes status label for display
  String _statusLabel(String status) {
    if (status.toLowerCase() == 'draft') return 'Inactive';
    if (status.isEmpty) return 'Inactive';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  /// Function Name: _formatDate
  ///
  /// Purpose: Formats date to d/M/yyyy
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
