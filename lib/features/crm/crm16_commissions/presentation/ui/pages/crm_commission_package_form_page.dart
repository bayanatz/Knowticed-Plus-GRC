// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_package_form_page.dart
// Purpose: Add, view, and edit commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/interfaces/crm_commissions_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commission_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commission_form_state.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/widgets/crm_commission_range_fields.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/widgets/crm_compensation_details_fields.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/widgets/crm_license_domain_fields.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/widgets/crm_commission_value_rows.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class CrmCommissionPackageFormPage extends StatefulWidget {
  final CrmCommissionPackage? package;

  const CrmCommissionPackageFormPage({super.key, this.package});

  @override
  State<CrmCommissionPackageFormPage> createState() =>
      _CrmCommissionPackageFormPageState();
}

class _CrmCommissionPackageFormPageState
    extends State<CrmCommissionPackageFormPage> {
  late final CrmCommissionFormCubit _cubit;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _valueController;
  bool _readOnly = false;

  @override
  void initState() {
    super.initState();
    final CrmCommissionPackage? package = widget.package;
    _readOnly = package != null;
    _nameEnController = TextEditingController(text: package?.nameEn ?? '');
    _nameArController = TextEditingController(text: package?.nameAr ?? '');
    _valueController = TextEditingController(
      text:
          package == null || package.value == 0 ? '' : package.value.toString(),
    );
    _cubit = CrmCommissionFormCubit(
      repository: Get.find<CrmCommissionsBaseRepository>(),
      productsRepository: Get.find<CrmProductsBaseRepository>(),
      servicesRepository: Get.find<CrmServicesBaseRepository>(),
      package: package,
    )..init();
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _valueController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _save() {
    CrmControlDialogs.showSaveDialog(
      context: context,
      title: _cubit.isEditing ? 'Save Package' : 'Add Package',
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        showLoadingIndicator();
        final bool saved = await _cubit.save();
        hideLoadingIndicator();
        if (!mounted || !saved) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: _cubit.isEditing
              ? 'Package updated successfully'
              : 'Package added successfully',
          onComplete: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _delete() {
    final CrmCommissionPackage? package = widget.package;
    if (package == null) return;
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: 'Delete Package',
      subtitle: 'Are you sure you want to delete this package?',
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await _cubit.delete();
        hideLoadingIndicator();
        if (!mounted || !deleted) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: 'Package deleted successfully',
          onComplete: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CrmCommissionFormCubit, CrmCommissionFormState>(
        bloc: _cubit,
        listener: (BuildContext context, CrmCommissionFormState state) {
          if (state.errorMessage != null) {
            final String message = state.errorMessage!;
            _cubit.clearError();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: S.current.crmAlert,
                subtitle: message,
              );
            });
          }
        },
        builder: (BuildContext context, CrmCommissionFormState state) =>
            Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: S.current.crm,
            secondTitle: S.current.crmSectionControls,
            thirdTitle: S.current.crmControlCommissions,
            fourthTitle: _readOnly
                ? 'Package Details'
                : (_cubit.isEditing ? 'Edit Package' : 'Add Package'),
            onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
            onSecondTap: () => CrmNavigationHelper.pop(context),
            onThirdTap: () => CrmNavigationHelper.pop(context),
            child: state.isLoadingOptions &&
                    state.categories.isEmpty &&
                    state.serviceCategories.isEmpty
                ? const Center(child: CircleProgressMaster())
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        if (_readOnly) _readOnlyActions(),
                        CrmSectionCard(
                          title: 'Package Details',
                          child: _packageDetails(state),
                        ),
                        SizedBox(height: 14.sp),
                        CrmSectionCard(
                          title: 'Compensation Details',
                          child: _compensationDetails(state),
                        ),
                        SizedBox(height: 14.sp),
                        CrmSectionCard(
                          title: 'Domain & Target',
                          child: _domains(state),
                        ),
                        if (state.compensationCategory == 'Commission' &&
                            state.compensationType == 'Product Based' &&
                            state.productCommissions.isNotEmpty) ...<Widget>[
                          SizedBox(height: 14.sp),
                          CrmSectionCard(
                            title: 'Products',
                            child: _productCommissions(state),
                          ),
                        ],
                        if (state.compensationCategory == 'Commission' &&
                            state.compensationType == 'Product Based' &&
                            state.serviceCommissions.isNotEmpty) ...<Widget>[
                          SizedBox(height: 14.sp),
                          CrmSectionCard(
                            title: 'Services',
                            child: _serviceCommissions(state),
                          ),
                        ],
                        if (state.compensationCategory == 'Commission' &&
                            state.compensationType == 'Product Based' &&
                            state.licenseCommissions.isNotEmpty) ...<Widget>[
                          SizedBox(height: 14.sp),
                          CrmSectionCard(
                            title: 'Licenses',
                            child: _licenseCommissions(state),
                          ),
                        ],
                        if (state.compensationCategory == 'Commission' &&
                            state.compensationType == 'Tiers') ...<Widget>[
                          SizedBox(height: 14.sp),
                          CrmSectionCard(
                            title: 'Commission Ranges',
                            child: CrmCommissionRangeFields(
                              ranges: state.tierRanges,
                              readOnly: _readOnly,
                              keyPrefix: 'tier',
                              addButtonAlignment: AlignmentDirectional.center,
                              onAddRange: _cubit.addTierRange,
                              onRemoveRange: _cubit.removeTierRange,
                              onFromChanged: _cubit.updateTierRangeFrom,
                              onToChanged: _cubit.updateTierRangeTo,
                              onValueChanged: _cubit.updateTierRangeValue,
                            ),
                          ),
                        ],
                        if (state.compensationCategory ==
                            'Compensation') ...<Widget>[
                          SizedBox(height: 14.sp),
                          CrmSectionCard(
                            title: 'Partial Compensation',
                            trailing: DefaultSwitchButton(
                              value: state.partialCompensation,
                              onChanged: _readOnly
                                  ? (_) {}
                                  : _cubit.updatePartialCompensation,
                            ),
                            child: state.partialCompensation
                                ? _partialCompensationDetails(state)
                                : const SizedBox.shrink(),
                          ),
                          if (state.partialCompensation) ...<Widget>[
                            SizedBox(height: 14.sp),
                            CrmSectionCard(
                              title: 'Commission After Target',
                              child: _commissionAfterTarget(state),
                            ),
                          ],
                        ],
                        if (!_readOnly) ...<Widget>[
                          SizedBox(height: 12.sp),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: customButtonWithSvg(
                              title: 'Domain',
                              function: _cubit.addDomain,
                              color: AppColors.blackButton,
                              colorBorder: AppColors.transparent,
                              image: AppAssets.crmPlusBold,
                              svgColor:
                                  AppTheme.readableOn(AppColors.blackButton),
                              widthImage: 14.sp,
                              heightImage: 14.sp,
                              textStyle: StyleText.fontSize12Weight400.copyWith(
                                  color: AppTheme.readableOn(
                                      AppColors.blackButton)),
                            ),
                          ),
                          SizedBox(height: 18.sp),
                          _saveActions(state),
                        ],
                        SizedBox(height: 32.sp),
                      ],
                    ),
                  ),
          ),
        ),
      );

  Widget _readOnlyActions() => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Wrap(
          spacing: 12.sp,
          children: <Widget>[
            CustomEditIcon(onTap: () => setState(() => _readOnly = false)),
            CustomDeleteIcon(onTap: _delete),
          ],
        ),
      );

  Widget _packageDetails(CrmCommissionFormState state) => Column(
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _nameEnController,
              label: 'Package Name',
              hint: 'Text Here',
              enabled: !_readOnly,
              fillColor: AppColors.background,
              onChanged: _cubit.updateNameEn,
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: _nameArController,
                label: 'اسم الحزمة',
                hint: 'اكتب هنا',
                enabled: !_readOnly,
                textAlign: TextAlign.right,
                fillColor: AppColors.background,
                onChanged: _cubit.updateNameAr,
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          CustomMultiSelectFilter<String>(
            label: 'Country',
            hint: 'Choose',
            values: state.countries,
            enabled: !_readOnly,
            fillColor: AppColors.background,
            items: const <MultiSelectDropdownItem<String>>[
              MultiSelectDropdownItem(value: 'Egypt', label: 'Egypt'),
              MultiSelectDropdownItem(value: 'Qatar', label: 'Qatar'),
              MultiSelectDropdownItem(
                  value: 'Saudi Arabia', label: 'Saudi Arabia'),
            ],
            onChanged: _cubit.updateCountries,
          ),
        ],
      );

  Widget _compensationDetails(CrmCommissionFormState state) =>
      CrmCompensationDetailsFields(
        state: state,
        valueController: _valueController,
        readOnly: _readOnly,
        onCategoryChanged: _cubit.updateCompensationCategory,
        onTypeChanged: _cubit.updateCompensationType,
        onValueChanged: _cubit.updateValue,
        onCurrencyChanged: _cubit.updateCurrency,
        onTiersTypeChanged: _cubit.updateTiersType,
        onTiersFrequencyChanged: _cubit.updateTiersFrequency,
      );

  Widget _domains(CrmCommissionFormState state) => Column(
        children: List<Widget>.generate(state.domains.length, (int index) {
          final CrmCommissionDomain domain = state.domains[index];
          return Padding(
            padding: EdgeInsets.only(
                bottom: index == state.domains.length - 1 ? 0 : 18.sp),
            child: _domainFields(state, domain, index),
          );
        }),
      );

  Widget _domainFields(
    CrmCommissionFormState state,
    CrmCommissionDomain domain,
    int index,
  ) =>
      Column(
        children: <Widget>[
          if (!_readOnly && state.domains.length > 1)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: customButtonWithSvg(
                title: '',
                function: () => _cubit.removeDomain(index),
                color: AppColors.red,
                colorBorder: AppColors.transparent,
                image: AppAssets.minusCircle,
                svgColor: AppColors.white,
                widthImage: 15.sp,
                heightImage: 15.sp,
                textStyle: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.white),
              ),
            ),
          if (domain.applyOn == 'License')
            CrmLicenseDomainFields(
              state: state,
              domain: domain,
              index: index,
              readOnly: _readOnly,
              onApplyOnChanged: (String value) =>
                  _cubit.updateDomainApplyOn(index, value),
              onCategoriesChanged: (List<String> values) =>
                  _cubit.updateDomainCategories(index, values),
              onLicensesChanged: (List<String> values) =>
                  _cubit.updateDomainProducts(index, values),
              onBillingCycleChanged: (String value) =>
                  _cubit.updateDomainBillingCycle(index, value),
              onTargetTypeChanged: (String value) =>
                  _cubit.updateDomainTargetType(index, value),
              onTargetFrequencyChanged: (String value) =>
                  _cubit.updateDomainFrequency(index, value),
              onTargetValueChanged: (String value) =>
                  _cubit.updateDomainTargetValue(index, value),
              onCurrencyChanged: (String value) =>
                  _cubit.updateDomainCurrency(index, value),
            )
          else ...<Widget>[
            buildResponsiveFields(
              context: context,
              left: CustomDropdown<String>(
                label: 'Apply on',
                hint: 'Choose',
                value: domain.applyOn,
                enabled: !_readOnly,
                fillColor: AppColors.background,
                items: const <DropdownItem<String>>[
                  DropdownItem<String>(value: 'Products', label: 'Products'),
                  DropdownItem<String>(value: 'Services', label: 'Services'),
                  DropdownItem<String>(value: 'License', label: 'License'),
                ],
                onChanged: (String value) =>
                    _cubit.updateDomainApplyOn(index, value),
              ),
              right: CustomMultiSelectFilter<String>(
                label: 'Category',
                hint: 'Choose',
                values: domain.categoryIds,
                enabled: !_readOnly,
                fillColor: AppColors.background,
                items: _categoryItems(state, domain),
                onChanged: (List<String> values) =>
                    _cubit.updateDomainCategories(index, values),
              ),
            ),
            if (state.compensationType != 'Tiers') ...<Widget>[
              SizedBox(height: 14.sp),
              buildResponsiveFields(
                context: context,
                left: CustomMultiSelectFilter<String>(
                  label: domain.applyOn == 'Services' ? 'Services' : 'Products',
                  hint: 'Choose',
                  values: domain.productIds,
                  enabled: !_readOnly,
                  fillColor: AppColors.background,
                  items: _itemChoices(domain),
                  onChanged: (List<String> values) =>
                      _cubit.updateDomainProducts(index, values),
                ),
                right: CustomDropdown<String>(
                  label: 'Target Type',
                  hint: 'Choose',
                  value: domain.targetType,
                  enabled: !_readOnly,
                  fillColor: AppColors.background,
                  items: const <DropdownItem<String>>[
                    DropdownItem<String>(value: 'Count', label: 'Count'),
                    DropdownItem<String>(value: 'Amount', label: 'Amount'),
                  ],
                  onChanged: (String value) =>
                      _cubit.updateDomainTargetType(index, value),
                ),
              ),
              SizedBox(height: 14.sp),
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Target Frequency',
                  hint: 'Choose',
                  value: domain.frequency,
                  enabled: !_readOnly,
                  fillColor: AppColors.background,
                  items: const <DropdownItem<String>>[
                    DropdownItem<String>(value: 'Monthly', label: 'Monthly'),
                    DropdownItem<String>(
                        value: 'Quarterly', label: 'Quarterly'),
                    DropdownItem<String>(value: 'Annually', label: 'Annually'),
                    DropdownItem<String>(value: 'Weekly', label: 'Weekly'),
                  ],
                  onChanged: (String value) =>
                      _cubit.updateDomainFrequency(index, value),
                ),
                right: CustomTextField(
                  key: ValueKey<String>('target-$index'),
                  initialValue: domain.targetValue == 0
                      ? ''
                      : domain.targetValue.toString(),
                  label: domain.targetType == 'Count'
                      ? 'Count of ${domain.applyOn}'
                      : 'Target Amount',
                  hint: 'Text Here',
                  enabled: !_readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  fillColor: AppColors.background,
                  onChanged: (String value) =>
                      _cubit.updateDomainTargetValue(index, value),
                ),
              ),
            ],
          ],
        ],
      );

  List<MultiSelectDropdownItem<String>> _categoryItems(
    CrmCommissionFormState state,
    CrmCommissionDomain domain,
  ) =>
      domain.applyOn == 'Services'
          ? state.serviceCategories
              .map((CrmServiceCategoryModel item) =>
                  MultiSelectDropdownItem<String>(
                      value: item.id, label: item.nameEn))
              .toList()
          : state.categories
              .map((CrmProductCategoryModel item) =>
                  MultiSelectDropdownItem<String>(
                      value: item.id, label: item.nameEn))
              .toList();

  List<MultiSelectDropdownItem<String>> _itemChoices(
          CrmCommissionDomain domain) =>
      domain.applyOn == 'Services'
          ? _cubit
              .servicesForDomain(domain)
              .map((CrmServiceItemModel item) =>
                  MultiSelectDropdownItem<String>(
                      value: item.id, label: item.nameEn))
              .toList()
          : _cubit
              .productsForDomain(domain)
              .map((CrmProductItemModel item) =>
                  MultiSelectDropdownItem<String>(
                      value: item.id, label: item.nameEn))
              .toList();

  Widget _productCommissions(CrmCommissionFormState state) =>
      CrmCommissionValueRows(
        commissions: state.productCommissions,
        itemLabel: 'Product',
        categoryNameOf: (CrmProductCommission item) =>
            state.categories
                .where((CrmProductCategoryModel category) =>
                    category.id == item.categoryId)
                .map((CrmProductCategoryModel category) => category.nameEn)
                .firstOrNull ??
            '-',
        itemNameOf: (CrmProductCommission item) =>
            state.products
                .where((CrmProductItemModel product) =>
                    product.id == item.productId)
                .map((CrmProductItemModel product) => product.nameEn)
                .firstOrNull ??
            '-',
        onValueChanged: _cubit.updateProductCommissionValue,
        readOnly: _readOnly,
      );

  Widget _serviceCommissions(CrmCommissionFormState state) =>
      CrmCommissionValueRows(
        commissions: state.serviceCommissions,
        itemLabel: 'Service',
        categoryNameOf: (CrmProductCommission item) =>
            state.serviceCategories
                .where((CrmServiceCategoryModel category) =>
                    category.id == item.categoryId)
                .map((CrmServiceCategoryModel category) => category.nameEn)
                .firstOrNull ??
            '-',
        itemNameOf: (CrmProductCommission item) =>
            state.services
                .where((CrmServiceItemModel service) =>
                    service.id == item.productId)
                .map((CrmServiceItemModel service) => service.nameEn)
                .firstOrNull ??
            '-',
        onValueChanged: _cubit.updateServiceCommissionValue,
        readOnly: _readOnly,
      );

  Widget _licenseCommissions(CrmCommissionFormState state) =>
      CrmCommissionValueRows(
        commissions: state.licenseCommissions,
        itemLabel: 'License',
        categoryNameOf: (CrmProductCommission item) =>
            state.categories
                .where((CrmProductCategoryModel category) =>
                    category.id == item.categoryId)
                .map((CrmProductCategoryModel category) => category.nameEn)
                .firstOrNull ??
            '-',
        itemNameOf: (CrmProductCommission item) =>
            state.products
                .where((CrmProductItemModel product) =>
                    product.id == item.productId)
                .map((CrmProductItemModel product) => product.nameEn)
                .firstOrNull ??
            '-',
        onValueChanged: _cubit.updateLicenseCommissionValue,
        readOnly: _readOnly,
      );

  Widget _partialCompensationDetails(CrmCommissionFormState state) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: kpIsPhoneLayout(context) ? null : 360.sp,
          child: CustomDropdown<String>(
            label: 'Type',
            hint: 'Choose',
            value: state.partialCompensationType,
            enabled: !_readOnly,
            fillColor: AppColors.background,
            items: const <DropdownItem<String>>[
              DropdownItem<String>(value: 'Default', label: 'Default'),
              DropdownItem<String>(value: 'Custom', label: 'Custom'),
            ],
            onChanged: _cubit.updatePartialCompensationType,
          ),
        ),
      );

  Widget _commissionAfterTarget(CrmCommissionFormState state) => Column(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: kpIsPhoneLayout(context) ? null : 480.sp,
              child: CustomDropdown<String>(
                label: 'Commission Trigger',
                hint: 'Choose',
                value: state.commissionTrigger.isEmpty
                    ? null
                    : state.commissionTrigger,
                enabled: !_readOnly,
                fillColor: AppColors.background,
                items: const <DropdownItem<String>>[
                  DropdownItem<String>(
                    value: 'After Deal Closure',
                    label: 'After Deal Closure',
                  ),
                  DropdownItem<String>(value: 'Monthly', label: 'Monthly'),
                  DropdownItem<String>(
                    value: 'Quarterly',
                    label: 'Quarterly',
                  ),
                  DropdownItem<String>(value: 'Annually', label: 'Annually'),
                ],
                onChanged: _cubit.updateCommissionTrigger,
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          CrmCommissionRangeFields(
            ranges: state.commissionAfterTargetRanges,
            readOnly: _readOnly,
            keyPrefix: 'after-target',
            addButtonAlignment: AlignmentDirectional.centerStart,
            onAddRange: _cubit.addCommissionAfterTargetRange,
            onRemoveRange: _cubit.removeCommissionAfterTargetRange,
            onFromChanged: _cubit.updateCommissionAfterTargetRangeFrom,
            onToChanged: _cubit.updateCommissionAfterTargetRangeTo,
            onValueChanged: _cubit.updateCommissionAfterTargetRangeValue,
          ),
        ],
      );

  Widget _saveActions(CrmCommissionFormState state) => Row(
        textDirection: TextDirection
            .ltr, // X-73: Cancel left, action right in both languages

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          customButton(
            title: S.current.crmDiscard,
            function: () => Navigator.of(context).pop(),
            color: AppColors.grey,
            textColor: AppColors.black,
          ),
          customButton(
            title: _cubit.isEditing ? S.current.crmSave : S.current.crmAdd,
            function: state.isSaving ? () {} : _save,
            color: state.isSaving ? AppColors.disabledGrey : AppColors.primary,
            textColor: AppColors.black,
          ),
        ],
      );
}
