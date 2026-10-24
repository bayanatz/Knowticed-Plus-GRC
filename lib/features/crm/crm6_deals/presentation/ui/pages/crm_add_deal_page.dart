// ****************** FILE INFO ******************
// File Name: crm_add_deal_page.dart
// Purpose: Multi-step wizard page for creating a new Deal matching Figma designs
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm_get_it.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_line_item_draft.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_pricing.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_form_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step1_details.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step2_products_services.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step3_progress.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step4_review.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_stepper_header.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmAddDealPage extends StatefulWidget {
  final String? clientId;

  const CrmAddDealPage({
    super.key,
    this.clientId,
  });

  @override
  State<CrmAddDealPage> createState() => _CrmAddDealPageState();
}

class _CrmAddDealPageState extends State<CrmAddDealPage> {
  // Step 1 Form Controllers & State
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _noteEn = TextEditingController();
  final TextEditingController _noteAr = TextEditingController();
  final TextEditingController _expectedValue = TextEditingController();
  String? _selectedCategory;
  String? _selectedCurrency = CrmCurrencyEnum.defaultCurrency.code;
  String? _selectedLikelihood = '50%';
  DateTime? _startDate = DateTime.now();
  DateTime? _closeDate;
  CrmTeamMemberModel? _selectedEmployee;
  bool _step1Submitted = false;

  // Step 2 Form State
  bool _productsEnabled = true;
  List<String> _productCategoryIds = <String>[];
  bool _servicesEnabled = true;
  List<String> _serviceCategoryIds = <String>[];
  final List<DealProductLineItem> _productLines = <DealProductLineItem>[
    DealProductLineItem(),
  ];
  final List<DealServiceLineItem> _serviceLines = <DealServiceLineItem>[
    DealServiceLineItem(),
  ];
  bool _step2Submitted = false;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _noteEn.dispose();
    _noteAr.dispose();
    _expectedValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmClientDealFormCubit>(
      create: (_) =>
          CrmClientDealFormCubit()..init(clientId: widget.clientId ?? ''),
      child: BlocConsumer<CrmClientDealFormCubit, CrmClientDealFormState>(
        listenWhen: (CrmClientDealFormState a, CrmClientDealFormState b) =>
            a.errorMessage != b.errorMessage ||
            a.successMessage != b.successMessage,
        listener: _listen,
        builder: (BuildContext context, CrmClientDealFormState state) => Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: AppColors.background,
              body: SideFrameMasterServices(
                titleText: S.current.crmClients,
                secondTitle: 'Client Profile',
                thirdTitle: 'Add Deal',
                onFirstTap: () => Navigator.pop(context),
                onSecondTap: () => Navigator.pop(context),
                child: state.isLoading
                    ? const Center(child: CircleProgressMaster())
                    : _body(context, state),
              ),
            ),
            if (state.isSubmitting)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircleProgressMaster(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _listen(BuildContext context, CrmClientDealFormState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: 'Unable to create deal',
          arabicName: 'تعذر إنشاء الصفقة',
        ),
        subtitle: state.errorMessage!,
      );
    }
    if (state.successMessage != null && state.successMessage!.isNotEmpty) {
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: 'Deal Created Successfully',
          arabicName: 'تم إنشاء الصفقة بنجاح',
        ),
        subtitle: FormatHelper.localizedString(
          englishName: 'The new deal has been added to the client pipeline.',
          arabicName: 'تمت إضافة الصفقة الجديدة إلى خط صفقات العميل.',
        ),
        onComplete: () => Navigator.pop(context),
      );
    }
  }

  Widget _body(BuildContext context, CrmClientDealFormState state) {
    if (!state.isClientEligible) return const SizedBox.shrink();
    final CrmClientDealFormCubit cubit = context.read<CrmClientDealFormCubit>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Step wizard header (1 Deal Details, 2 Add Products & Services, 3 Progress, 4 Review & Confirm)
          CrmAddDealStepperHeader(
            currentStep: state.currentStep,
            onStepTapped: (int step) {
              if (step < state.currentStep) {
                cubit.goToStep(step);
              } else if (step > state.currentStep) {
                _handleNextStep(cubit, state);
              }
            },
          ),

          SizedBox(height: 24.sp),

          // Step 1: Deal Details
          if (state.currentStep == 1)
            CrmAddDealStep1Details(
              dealNameEnController: _nameEn,
              dealNameArController: _nameAr,
              noteEnController: _noteEn,
              noteArController: _noteAr,
              expectedValueController: _expectedValue,
              categories: state.categories,
              employees: state.employees,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (String? cat) =>
                  setState(() => _selectedCategory = cat),
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: (String? curr) =>
                  setState(() => _selectedCurrency = curr),
              selectedLikelihood: _selectedLikelihood,
              onLikelihoodChanged: (String? l) =>
                  setState(() => _selectedLikelihood = l),
              startDate: _startDate,
              onStartDateChanged: (DateTime? dt) =>
                  setState(() => _startDate = dt),
              closeDate: _closeDate,
              onCloseDateChanged: (DateTime? dt) =>
                  setState(() => _closeDate = dt),
              selectedEmployee: _selectedEmployee,
              onEmployeeSelected: (CrmTeamMemberModel? emp) =>
                  setState(() => _selectedEmployee = emp),
              isSubmitted: _step1Submitted,
            ),

          // Step 2: Add Products & Services
          if (state.currentStep == 2)
            CrmAddDealStep2ProductsServices(
              productsEnabled: _productsEnabled,
              onProductsToggleChanged: (bool val) =>
                  setState(() => _productsEnabled = val),
              productCategoryIds: _productCategoryIds,
              onProductCategoryIdsChanged: (List<String> categoryIds) =>
                  _changeProductCategories(categoryIds, state),
              servicesEnabled: _servicesEnabled,
              onServicesToggleChanged: (bool val) =>
                  setState(() => _servicesEnabled = val),
              serviceCategoryIds: _serviceCategoryIds,
              onServiceCategoryIdsChanged: (List<String> categoryIds) =>
                  _changeServiceCategories(categoryIds, state),
              currency: _selectedCurrency ?? 'EGP',
              productCategories: state.productCategories,
              products: state.products,
              serviceCategories: state.serviceCategories,
              services: state.services,
              productLines: _productLines,
              serviceLines: _serviceLines,
              onProductChanged: (int index, String? productId) =>
                  _selectProductLine(cubit, index, productId),
              onServiceChanged: (int index, String? serviceId) =>
                  _selectServiceLine(cubit, index, serviceId),
              onAddProductLine: () =>
                  setState(() => _productLines.add(DealProductLineItem())),
              onRemoveProductLine: (int idx) =>
                  setState(() => _productLines.removeAt(idx)),
              onAddServiceLine: () =>
                  setState(() => _serviceLines.add(DealServiceLineItem())),
              onRemoveServiceLine: (int idx) =>
                  setState(() => _serviceLines.removeAt(idx)),
              isSubmitted: _step2Submitted,
            ),

          // Step 3: Progress Per Stage
          if (state.currentStep == 3)
            CrmAddDealStep3Progress(
              stages: state.stages,
            ),

          // Step 4: Review & Confirm
          if (state.currentStep == 4)
            CrmAddDealStep4Review(
              dealNameEn: _nameEn.text.trim(),
              dealNameAr: _nameAr.text.trim(),
              category: _selectedCategory ?? '',
              expectedValue: _expectedValue.text.trim(),
              currency: _selectedCurrency ?? 'EGP',
              likelihood: _selectedLikelihood ?? '',
              startDate: _startDate,
              closeDate: _closeDate,
              employee: _selectedEmployee,
              productLines: _productLines,
              serviceLines: _serviceLines,
            ),

          SizedBox(height: 32.sp),

          // Bottom Action Row: Back and Next / Confirm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              customButton(
                title: 'Back',
                color: const Color(0xFFE2E8F0),
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                  fontWeight: FontWeight.bold,
                ),
                function: state.currentStep == 1
                    ? () => Navigator.pop(context)
                    : cubit.previousStep,
              ),
              customButton(
                title: state.isSubmitting
                    ? 'Saving...'
                    : (state.currentStep == 4 ? 'Confirm' : 'Next'),
                color: state.isSubmitting
                    ? AppColors.disabledGrey
                    : AppColors.primary,
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                  fontWeight: FontWeight.bold,
                ),
                function: state.isSubmitting
                    ? () {}
                    : () => _handleNextStep(cubit, state),
              ),
            ],
          ),

          SizedBox(height: 24.sp),
        ],
      ),
    );
  }

  void _syncAllDraftsToCubit(
    CrmClientDealFormCubit cubit,
    CrmClientDealFormState state,
  ) {
    CrmDealCategoryModel? matchedCategory;
    if (state.categories.isNotEmpty && _selectedCategory != null) {
      for (final CrmDealCategoryModel cat in state.categories) {
        if (cat.nameEn == _selectedCategory ||
            cat.nameAr == _selectedCategory ||
            cat.id == _selectedCategory ||
            FormatHelper.localizedString(
                  englishName: cat.nameEn,
                  arabicName: cat.nameAr,
                ) ==
                _selectedCategory) {
          matchedCategory = cat;
          break;
        }
      }
    }
    cubit.selectCategory(matchedCategory);
    cubit.selectEmployee(_selectedEmployee);

    final double? parsedVal = double.tryParse(_expectedValue.text.trim());
    final double parsedLikelihood =
        double.tryParse(_selectedLikelihood?.replaceAll('%', '') ?? '') ?? 50.0;

    cubit.updateDetails(
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      noteEn: _noteEn.text.trim(),
      noteAr: _noteAr.text.trim(),
      currency: _selectedCurrency ?? 'EGP',
      expectedValue: parsedVal,
      likelihood: parsedLikelihood,
      startDate: _startDate,
      closeDate: _closeDate,
    );

    final List<CrmDealLineDraft> pDrafts = <CrmDealLineDraft>[];
    if (_productsEnabled) {
      for (final DealProductLineItem item in _productLines) {
        final CrmDealLineDraft? draft = cubit.productDraftFor(
          productId: item.product,
          quantity: double.tryParse(item.quantity),
        );
        if (draft != null) pDrafts.add(draft);
      }
    }

    final List<CrmDealLineDraft> sDrafts = <CrmDealLineDraft>[];
    if (_servicesEnabled) {
      for (final DealServiceLineItem item in _serviceLines) {
        final CrmDealLineDraft? draft = cubit.serviceDraftFor(
          serviceId: item.service,
        );
        if (draft != null) sDrafts.add(draft);
      }
    }

    cubit.setDraftLines(products: pDrafts, services: sDrafts);
  }

  void _changeProductCategories(
    List<String> categoryIds,
    CrmClientDealFormState state,
  ) {
    setState(() {
      _productCategoryIds = List<String>.from(categoryIds);
      for (final DealProductLineItem line in _productLines) {
        final bool isStillVisible = state.products.any(
          (product) =>
              product.id == line.product &&
              _productCategoryIds.contains(product.categoryId),
        );
        if (!isStillVisible) line.product = null;
      }
    });
  }

  void _changeServiceCategories(
    List<String> categoryIds,
    CrmClientDealFormState state,
  ) {
    setState(() {
      _serviceCategoryIds = List<String>.from(categoryIds);
      for (final DealServiceLineItem line in _serviceLines) {
        final bool isStillVisible = state.services.any(
          (service) =>
              service.id == line.service &&
              _serviceCategoryIds.contains(service.categoryId),
        );
        if (!isStillVisible) line.service = null;
      }
    });
  }

  void _selectProductLine(
    CrmClientDealFormCubit cubit,
    int index,
    String? productId,
  ) {
    final DealProductLineItem line = _productLines[index];
    final CrmDealLineDraft? draft = cubit.productDraftFor(
      productId: productId,
      quantity: double.tryParse(line.quantity) ?? 1,
    );
    setState(() {
      line.product = productId;
      if (draft != null) {
        line.unitPrice = draft.unitPrice;
        line.tax = draft.taxRate;
        line.discount = draft.discountValue;
      }
    });
  }

  void _selectServiceLine(
    CrmClientDealFormCubit cubit,
    int index,
    String? serviceId,
  ) {
    final DealServiceLineItem line = _serviceLines[index];
    final CrmDealLineDraft? draft = cubit.serviceDraftFor(serviceId: serviceId);
    setState(() {
      line.service = serviceId;
      if (draft != null) {
        line.price = draft.unitPrice;
        line.tax = draft.taxRate;
        line.discount = draft.discountValue.toString();
      }
    });
  }

  void _handleNextStep(
    CrmClientDealFormCubit cubit,
    CrmClientDealFormState state,
  ) async {
    if (state.currentStep == 1) {
      final bool isStep1Valid = _nameEn.text.trim().isNotEmpty &&
          _nameAr.text.trim().isNotEmpty &&
          _expectedValue.text.trim().isNotEmpty &&
          _selectedCategory != null &&
          _selectedCurrency != null &&
          _selectedLikelihood != null &&
          _startDate != null &&
          _closeDate != null &&
          _selectedEmployee != null;

      if (!isStep1Valid) {
        setState(() => _step1Submitted = true);
        return;
      }

      _syncAllDraftsToCubit(cubit, state);
      cubit.goToStep(2);
    } else if (state.currentStep == 2) {
      final bool hasProduct = _productsEnabled &&
          _productLines.any((DealProductLineItem item) =>
              cubit.productDraftFor(
                productId: item.product,
                quantity: double.tryParse(item.quantity),
              ) !=
              null);
      final bool hasService = _servicesEnabled &&
          _serviceLines.any((DealServiceLineItem item) =>
              cubit.serviceDraftFor(serviceId: item.service) != null);
      if (!hasProduct && !hasService) {
        setState(() => _step2Submitted = true);
        return;
      }
      _syncAllDraftsToCubit(cubit, state);
      cubit.goToStep(3);
    } else if (state.currentStep == 3) {
      _syncAllDraftsToCubit(cubit, state);
      cubit.goToStep(4);
    } else if (state.currentStep == 4) {
      await CrmControlDialogs.showSaveDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: 'Save Deal',
          arabicName: 'حفظ الصفقة',
        ),
        subtitle: FormatHelper.localizedString(
          englishName: 'Are you sure you want to save this deal?',
          arabicName: 'هل أنت متأكد من حفظ هذه الصفقة؟',
        ),
        onConfirm: () async {
          _syncAllDraftsToCubit(cubit, state);
          await cubit.submit();
        },
      );
    }
  }
}
